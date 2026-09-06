use super::*;

use crate::array::{js_array_alloc, js_array_push_f64};
use crate::closure::ClosureHeader;
use crate::object::{js_object_alloc, ObjectHeader};
use crate::value::js_nanbox_pointer;
#[cfg(feature = "intl-segmenter")]
use unicode_segmentation::UnicodeSegmentation;

const KEY_SEGMENTS_BRAND: &str = "__intlSegmentsBrand";
const KEY_SEGMENTS_LENGTH: &str = "__intlSegmentsLength";
const SEGMENTS_BRAND: &str = "Segments";

pub(crate) fn normalize_granularity(value: Option<String>) -> String {
    match value.as_deref() {
        None | Some("grapheme") => "grapheme".to_string(),
        Some("word") => "word".to_string(),
        Some("sentence") => "sentence".to_string(),
        Some(other) => throw_range_error(&format!(
            "Value {other} out of range for Intl.Segmenter options property granularity"
        )),
    }
}

/// A segment is "word-like" when it contains at least one alphanumeric
/// character — i.e. it is not pure whitespace/punctuation. This mirrors the
/// `isWordLike` flag the spec attaches to word-granularity segments.
#[cfg(feature = "intl-segmenter")]
pub(crate) fn segment_is_word_like(segment: &str) -> bool {
    segment.chars().any(|c| c.is_alphanumeric())
}

pub(crate) fn utf16_len(segment: &str) -> u32 {
    segment.chars().map(|c| c.len_utf16() as u32).sum()
}

fn string_pointer_value(ptr: *const StringHeader) -> f64 {
    f64::from_bits(JSValue::string_ptr(ptr as *mut StringHeader).bits())
}

unsafe fn segmenter_input_text(ptr: *const StringHeader) -> String {
    if ptr.is_null() {
        return String::new();
    }
    let data = unsafe { (ptr as *const u8).add(std::mem::size_of::<StringHeader>()) };
    let len = unsafe { (*ptr).byte_len as usize };
    let bytes = unsafe { std::slice::from_raw_parts(data, len) };
    if let Ok(text) = std::str::from_utf8(bytes) {
        return text.to_owned();
    }

    // `unicode-segmentation` requires valid UTF-8. Represent each WTF-8 lone
    // surrogate as one U+FFFD while computing boundaries; both occupy exactly
    // one UTF-16 code unit, so offsets still map back to the original string.
    let mut text = String::new();
    let mut offset = 0usize;
    while offset < bytes.len() {
        let (advance, _, code_point) = crate::string::wtf8_step(bytes, offset);
        match char::from_u32(code_point) {
            Some(ch) if !(0xD800..=0xDFFF).contains(&code_point) => text.push(ch),
            _ => text.push('\u{FFFD}'),
        }
        offset = (offset + advance).min(bytes.len());
    }
    text
}

/// The two shapes a segment record can have. ECMA-402 18.5.1 attaches
/// `isWordLike` only to word granularity, so there are exactly two.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub(crate) enum SegmentRecordShape {
    /// `{ segment, index, input }`
    Plain = 0,
    /// `{ segment, index, input, isWordLike }`
    WordLike = 1,
}

/// Every shape, for the root-scanner tests.
#[cfg(test)]
pub(crate) const SEGMENT_RECORD_SHAPE_LIST: [SegmentRecordShape; SEGMENT_RECORD_SHAPES] =
    [SegmentRecordShape::Plain, SegmentRecordShape::WordLike];

const SEGMENT_RECORD_SHAPES: usize = 2;

crate::perry_thread_local! {
    /// Per-thread shared keys arrays for segment records, indexed by
    /// [`SegmentRecordShape`].
    ///
    /// Same construction, and the same reason, as `iter_result`'s
    /// `ITER_RESULT_KEYS` (#7564): `set_field`-by-name clones an object's key
    /// list before writing, so building a record property-by-property gave
    /// EVERY record its own keys array — a fresh array address per record,
    /// therefore a fresh ShapeId per record (`shape_id_for_keys_ensure` keys
    /// the shape table on the array's address), therefore a guaranteed inline
    /// -cache miss on every `.segment` / `.index` / `.input` read and one more
    /// descriptor in the shape table per segment. On the claude-code TUI,
    /// whose text measurement segments every string it renders, that was
    /// 175,797 misses on `.segment` alone in one 400-character reply
    /// (`PERRY_IC_DIAG`). One shared array per shape means one ShapeId for
    /// every segment record in the program.
    ///
    /// Per-thread and not process-global for the same reason the intern table
    /// is: each `perry/thread` worker has its own arena.
    ///
    /// GC-visible through [`scan_segment_record_keys_roots_mut`], which both
    /// MARKS (nothing else references these arrays; the records that use them
    /// are short-lived and the cache outlives them) and REWRITES them.
    static SEGMENT_RECORD_KEYS: std::cell::UnsafeCell<[*mut crate::array::ArrayHeader; SEGMENT_RECORD_SHAPES]> =
        std::cell::UnsafeCell::new([std::ptr::null_mut(); SEGMENT_RECORD_SHAPES]);
}

#[inline(always)]
fn cached_segment_keys(shape: SegmentRecordShape) -> *mut crate::array::ArrayHeader {
    SEGMENT_RECORD_KEYS.with(|c| unsafe { (*c.get())[shape as usize] })
}

/// NaN-boxed bits of an interned constant property name.
#[inline]
fn interned_key_bits(bytes: &[u8]) -> u64 {
    JSValue::string_ptr(crate::string::intern_ascii_literal(bytes) as *mut _).bits()
}

/// Build this thread's shared keys array for `shape`, if it has none.
///
/// Cold and at most twice per thread for the program's lifetime, so it is
/// written for obviousness rather than speed: every intermediate is rooted
/// across every allocation that follows it. Interning makes the names
/// pointer-identical to the `"segment"` / `"index"` / `"input"` the READ side
/// hashes, and gives them a second independent root in the intern table.
#[cold]
unsafe fn build_shared_segment_keys(shape: SegmentRecordShape) {
    const NAMES: [&[u8]; 4] = [b"segment", b"index", b"input", b"isWordLike"];
    let n = match shape {
        SegmentRecordShape::Plain => 3usize,
        SegmentRecordShape::WordLike => 4usize,
    };

    let scope = crate::gc::RuntimeHandleScope::new();
    let keys_h = scope.root_raw_mut_ptr(js_array_alloc(n as u32));

    // Each intern ALLOCATES on a first-call-per-thread miss, so the array's
    // address is taken back out of its handle ACROSS them.
    let mut handles = Vec::with_capacity(n);
    for name in NAMES.iter().take(n) {
        let (bits, _) =
            keys_h.across_mut::<crate::array::ArrayHeader, _>(|| interned_key_bits(name));
        handles.push(scope.root_nanbox_u64(bits));
    }
    // Every call below is non-allocating (`store_array_slot` writes one slot;
    // `rebuild_array_layout_exact` only clears and recomputes layout metadata),
    // so the pointer is scoped rather than carried across a collection point.
    keys_h.with_mut_ptr::<crate::array::ArrayHeader, _>(|keys| {
        (*keys).length = n as u32;
        for (i, h) in handles.iter().enumerate() {
            crate::array::store_array_slot(keys, i, h.get_nanbox_u64());
        }
        crate::array::rebuild_array_layout_exact(keys);

        // Copy-on-write marker. Without it, `record.extra = 1` on ONE record would
        // append to the array every other record shares.
        crate::gc::mark_shape_shared(keys as *mut u8);

        // The table this publishes into is scanned by
        // `scan_segment_record_keys_roots_mut`, registered in `gc/mod.rs`.
        SEGMENT_RECORD_KEYS.with(|c| (*c.get())[shape as usize] = keys);
        crate::gc::runtime_write_barrier_root_raw_ptr(keys);
    });
}

/// GC root scanner for the shared segment-record keys arrays and the two
/// realm-singleton prototypes the lazy `Segments` chains to. See
/// `SEGMENT_RECORD_KEYS` and `SEGMENTS_PROTOTYPES`.
///
/// Registered once in `gc/mod.rs`; extending this scanner rather than adding a
/// second one keeps the per-collection root walk the same length (A1).
pub fn scan_segment_record_keys_roots_mut(visitor: &mut crate::gc::RuntimeRootVisitor<'_>) {
    SEGMENT_RECORD_KEYS.with(|c| unsafe {
        for slot in (*c.get()).iter_mut() {
            visitor.visit_raw_mut_ptr_slot(slot);
        }
    });
    SEGMENTS_PROTOTYPES.with(|c| unsafe {
        for slot in (*c.get()).iter_mut() {
            visitor.visit_raw_mut_ptr_slot(slot);
        }
    });
}

// ---------------------------------------------------------------------------
// Lazy `Segments` (grapheme granularity) — C2
//
// `build_segments` materialises every record and every substring up front and
// returns a JS ARRAY. For grapheme granularity that is replaced here by a plain
// object holding only the input, whose `[Symbol.iterator]` walks UAX #29
// boundaries one at a time. Word and sentence keep the eager array: restarting
// the word algorithm at an arbitrary offset is not equivalent to segmenting the
// whole string (WB4 skips Extend/Format, WB6/WB7 look across MidLetter), and
// nothing measured needs it.
//
// The input lives in an ordinary object field, i.e. a TRACED slot, so the
// collector rewrites it when the string moves; no entry point below holds a
// `*const StringHeader` or a `&str` across an allocation.
// ---------------------------------------------------------------------------

const KEY_SEGMENTS_INPUT: &str = "__intlSegmentsInput";
const KEY_SEGITER_SEGMENTS: &str = "__intlSegIterSegments";
const KEY_SEGITER_BYTE: &str = "__intlSegIterByte";
const KEY_SEGITER_UTF16: &str = "__intlSegIterUtf16";

/// Class id for the lazy grapheme `Segments` iterator.
///
/// Without one, `js_for_of_next` falls through to
/// `js_native_call_method(iter, "next")` — a by-name method lookup and a
/// generic call PER STEP — which measured **+68 % time and +121 % allocated
/// bytes** against the eager array on the string-width probe. Map, Set and the
/// array iterator all carry a class-id arm for exactly this reason; this is the
/// same fix, not a new mechanism.
pub const SEGMENTS_ITERATOR_CLASS_ID: u32 = 0xFFFF_000C;

/// Class id for the lazy grapheme `Segments` object itself. It is the BRAND:
/// checking it is a load, where `get_string_field(obj, "__intlSegmentsBrand")`
/// allocates a key string on every check — and the check is on the per-step
/// path. Same reason the field reads below are by INDEX: `get_field` /
/// `set_internal_field` mint a fresh key string per call
/// (`intl/rooted_fields.rs`), which is ~5 allocations per iteration step.
pub const SEGMENTS_CLASS_ID: u32 = 0xFFFF_000D;

/// Field indices, fixed by construction order in `build_lazy_grapheme_segments`
/// and `lazy_segments_iterator_thunk`. The named internal fields are still
/// written once at construction (cold, and they keep the object readable in a
/// heap dump); every hot-path access goes through these.
const F_SEGMENTS_INPUT: u32 = 1;
const F_SEGMENTS_LENGTH: u32 = 2;
const F_SEGITER_SEGMENTS: u32 = 0;
const F_SEGITER_BYTE: u32 = 1;
const F_SEGITER_UTF16: u32 = 2;

#[inline(always)]
fn field_at(obj: *mut ObjectHeader, index: u32) -> f64 {
    f64::from_bits(crate::object::js_object_get_field(obj, index).bits())
}

#[inline(always)]
fn set_field_at(obj: *mut ObjectHeader, index: u32, number: f64) {
    crate::object::js_object_set_field(obj, index, JSValue::number(number));
}

const PROTO_SEGMENTS: usize = 0;
const PROTO_SEGMENTS_ITERATOR: usize = 1;

crate::perry_thread_local! {
    /// `[%SegmentsPrototype%, %SegmentsIteratorPrototype%]`, one pair per
    /// realm, built lazily on the first grapheme `.segment()` call and scanned
    /// by `scan_segment_record_keys_roots_mut`.
    static SEGMENTS_PROTOTYPES: std::cell::UnsafeCell<[*mut ObjectHeader; 2]> =
        std::cell::UnsafeCell::new([std::ptr::null_mut(); 2]);
}

#[inline(always)]
fn cached_segments_proto(which: usize) -> *mut ObjectHeader {
    SEGMENTS_PROTOTYPES.with(|c| unsafe { (*c.get())[which] })
}

/// Build the two realm prototypes once. Cold: at most once per thread.
#[cold]
fn build_segments_prototypes() {
    let scope = crate::gc::RuntimeHandleScope::new();
    let proto = scope.root_raw_mut_ptr(js_object_alloc(0, 0));
    if proto.with_mut_ptr(|p: *mut ObjectHeader| p.is_null()) {
        return;
    }
    let iter_proto = scope.root_raw_mut_ptr(js_object_alloc(0, 0));
    if iter_proto.with_mut_ptr(|p: *mut ObjectHeader| p.is_null()) {
        return;
    }
    // `containing` keeps the name/length the #8364 fixture pins.
    proto.with_mut_ptr(|p: *mut ObjectHeader| {
        install_function(
            p,
            "containing",
            segmenter_containing_thunk as *const u8,
            1,
            1,
            false,
        )
    });
    install_lazy_symbol_iterator(&proto);
    iter_proto.with_mut_ptr(|p: *mut ObjectHeader| {
        install_function(
            p,
            "next",
            segments_iterator_next_thunk as *const u8,
            0,
            0,
            false,
        )
    });
    // Publish only after everything above has finished allocating, so a
    // collection inside an install cannot leave a half-built prototype
    // reachable from the root table.
    proto.with_mut_ptr(|p: *mut ObjectHeader| {
        SEGMENTS_PROTOTYPES.with(|c| unsafe { (*c.get())[PROTO_SEGMENTS] = p });
        crate::gc::runtime_write_barrier_root_raw_ptr(p as *mut crate::array::ArrayHeader);
    });
    iter_proto.with_mut_ptr(|p: *mut ObjectHeader| {
        SEGMENTS_PROTOTYPES.with(|c| unsafe { (*c.get())[PROTO_SEGMENTS_ITERATOR] = p });
        crate::gc::runtime_write_barrier_root_raw_ptr(p as *mut crate::array::ArrayHeader);
    });
}

fn ensure_segments_prototypes() {
    if cached_segments_proto(PROTO_SEGMENTS).is_null() {
        build_segments_prototypes();
    }
}

/// `%SegmentsPrototype%[Symbol.iterator]`, installed on the prototype rather
/// than on every `Segments` (which is what ECMA-402 says, and what stops two
/// closures being allocated per `.segment()` call).
fn install_lazy_symbol_iterator(owner: &crate::gc::RuntimeHandle<'_>) {
    let symbol = crate::symbol::well_known_symbol("iterator");
    if symbol.is_null() {
        return;
    }
    let scope = crate::gc::RuntimeHandleScope::new();
    let symbol = scope.root_raw_mut_ptr(symbol);
    let closure = scope.root_raw_mut_ptr(crate::closure::js_closure_alloc(
        lazy_segments_iterator_thunk as *const u8,
        0,
    ));
    if closure.with_mut_ptr(|c: *mut ClosureHeader| c.is_null()) {
        return;
    }
    crate::closure::js_register_closure_arity(lazy_segments_iterator_thunk as *const u8, 0);
    closure.with_mut_ptr::<ClosureHeader, _>(|ptr| {
        crate::object::set_bound_native_closure_name(ptr, "[Symbol.iterator]")
    });
    closure.with_mut_ptr::<ClosureHeader, _>(|ptr| {
        crate::object::set_builtin_closure_length(ptr as usize, 0)
    });
    let value = closure.with_mut_ptr::<ClosureHeader, _>(|ptr| js_nanbox_pointer(ptr as i64));
    unsafe {
        owner.with_mut_ptr(|o: *mut ObjectHeader| {
            symbol.with_const_ptr(|sym: *const u8| {
                crate::symbol::js_object_set_symbol_property(
                    js_nanbox_pointer(o as i64),
                    f64::from_bits(JSValue::pointer(sym).bits()),
                    value,
                )
            })
        });
    }
    owner.with_mut_ptr(|o: *mut ObjectHeader| {
        symbol.with_const_ptr(|sym: *const u8| {
            crate::symbol::set_symbol_property_attrs(
                o as usize,
                sym as usize,
                PropertyAttrs::new(true, false, true),
            )
        })
    });
}


/// Drop the cached arrays. The unit-test harness resets arenas between tests
/// while thread-locals persist, which would leave these pointing into a
/// deallocated block.
#[cfg(test)]
pub(crate) fn populate_shared_segment_keys_for_test() -> Vec<*mut crate::array::ArrayHeader> {
    for shape in SEGMENT_RECORD_SHAPE_LIST {
        if cached_segment_keys(shape).is_null() {
            unsafe { build_shared_segment_keys(shape) };
        }
    }
    SEGMENT_RECORD_SHAPE_LIST
        .iter()
        .map(|shape| cached_segment_keys(*shape))
        .collect()
}

#[cfg(test)]
pub(crate) fn shared_segment_keys_peek_for_test(
    shape: SegmentRecordShape,
) -> *mut crate::array::ArrayHeader {
    cached_segment_keys(shape)
}

#[cfg(test)]
pub(crate) fn reset_shared_segment_keys_for_test() {
    SEGMENT_RECORD_KEYS.with(|c| unsafe {
        (*c.get()) = [std::ptr::null_mut(); SEGMENT_RECORD_SHAPES];
    });
}

pub(crate) fn make_segment_record(
    segment_value: f64,
    index: u32,
    input_value: f64,
    word_like: Option<bool>,
) -> f64 {
    let shape = if word_like.is_some() {
        SegmentRecordShape::WordLike
    } else {
        SegmentRecordShape::Plain
    };
    let n = match shape {
        SegmentRecordShape::Plain => 3usize,
        SegmentRecordShape::WordLike => 4usize,
    };
    unsafe {
        let scope = crate::gc::RuntimeHandleScope::new();
        // Both caller-supplied values are heap pointers; the allocations below
        // can collect and move them.
        let segment_h = scope.root_nanbox_f64(segment_value);
        let input_h = scope.root_nanbox_f64(input_value);

        // Fill the keys cache BEFORE the record exists, so its cold
        // allocations cannot invalidate a pointer already being held.
        if cached_segment_keys(shape).is_null() {
            build_shared_segment_keys(shape);
        }

        let obj_h = scope.root_nanbox_f64(js_nanbox_pointer(js_object_alloc(0, n as u32) as i64));
        // Everything below re-reads through storage the collector rewrites:
        // the record from its handle, the keys array from the scanned
        // thread-local. No address here predates the allocation above.
        let obj = || crate::js_nanbox_get_pointer(obj_h.get_nanbox_f64()) as *mut ObjectHeader;
        crate::object::js_object_set_keys(obj(), cached_segment_keys(shape));
        crate::object::js_object_set_field(
            obj(),
            0,
            JSValue::from_bits(segment_h.get_nanbox_f64().to_bits()),
        );
        // `index` is a plain Number (UTF-16 code-unit offset into the input).
        crate::object::js_object_set_field(obj(), 1, JSValue::number(index as f64));
        crate::object::js_object_set_field(
            obj(),
            2,
            JSValue::from_bits(input_h.get_nanbox_f64().to_bits()),
        );
        if let Some(word_like) = word_like {
            crate::object::js_object_set_field(obj(), 3, JSValue::bool(word_like));
        }
        js_nanbox_pointer(obj() as i64)
    }
}

/// Build the segment list for `input` under `granularity`. The backing array
/// keeps the existing iterable / spreadable representation while exposing the
/// `Segments.prototype.containing()` surface required by ECMA-402.
pub(crate) fn build_segments(granularity: &str, value: f64) -> f64 {
    if unsafe { crate::symbol::js_is_symbol(value) != 0 } {
        throw_type_error("Cannot convert a Symbol value to a string");
    }
    let input_ptr = js_jsvalue_to_string(value);
    let scope = crate::gc::RuntimeHandleScope::new();
    let input_handle = scope.root_string_ptr(input_ptr);
    // Grapheme granularity takes the LAZY representation: no array, no record
    // and no substring until something asks for one. Word and sentence keep the
    // eager array (§4 of `INTERFACE_segments_view.md`), and so does any input
    // that is not valid UTF-8, whose lone surrogates the eager path repairs by
    // copying.
    if granularity != "word" && granularity != "sentence" {
        if let Some(lazy) = build_lazy_grapheme_segments(&input_handle) {
            return lazy;
        }
    }
    let input =
        unsafe { input_handle.with_const_ptr::<StringHeader, _>(|ptr| segmenter_input_text(ptr)) };
    let mut arr = js_array_alloc(0);
    let mut index = 0u32;
    #[cfg(feature = "intl-segmenter")]
    match granularity {
        "word" => {
            for segment in input.split_word_bounds() {
                let end = index + utf16_len(segment);
                let segment_ptr = input_handle.with_const_ptr::<StringHeader, _>(|ptr| {
                    crate::string::js_string_slice(ptr, index as i32, end as i32)
                });
                let record = make_segment_record(
                    string_pointer_value(segment_ptr),
                    index,
                    input_handle.with_const_ptr::<StringHeader, _>(|ptr| string_pointer_value(ptr)),
                    Some(segment_is_word_like(segment)),
                );
                arr = js_array_push_f64(arr, record);
                index = end;
            }
        }
        "sentence" => {
            for segment in input.split_sentence_bounds() {
                let end = index + utf16_len(segment);
                let segment_ptr = input_handle.with_const_ptr::<StringHeader, _>(|ptr| {
                    crate::string::js_string_slice(ptr, index as i32, end as i32)
                });
                let record = make_segment_record(
                    string_pointer_value(segment_ptr),
                    index,
                    input_handle.with_const_ptr::<StringHeader, _>(|ptr| string_pointer_value(ptr)),
                    None,
                );
                arr = js_array_push_f64(arr, record);
                index = end;
            }
        }
        // "grapheme" (default): extended grapheme clusters (emoji ZWJ
        // sequences, combining marks, regional-indicator flags).
        _ => {
            for segment in input.graphemes(true) {
                let end = index + utf16_len(segment);
                let segment_ptr = input_handle.with_const_ptr::<StringHeader, _>(|ptr| {
                    crate::string::js_string_slice(ptr, index as i32, end as i32)
                });
                let record = make_segment_record(
                    string_pointer_value(segment_ptr),
                    index,
                    input_handle.with_const_ptr::<StringHeader, _>(|ptr| string_pointer_value(ptr)),
                    None,
                );
                arr = js_array_push_f64(arr, record);
                index = end;
            }
        }
    }
    // Segmenter engine gated off: no UAX #29 tables. Fall back to per-code-point
    // segmentation (one segment per `char`) for every granularity — enough to
    // keep iteration / spread working without the segmentation crate.
    #[cfg(not(feature = "intl-segmenter"))]
    {
        // Preserve the `isWordLike` field for word granularity so the record
        // shape matches the engine-enabled path (this block is dead in practice
        // — the compiler enables `intl-segmenter` on any `Intl.Segmenter` use).
        let is_word = granularity == "word";
        for segment in input.chars().map(|c| c.to_string()).collect::<Vec<_>>() {
            let end = index + utf16_len(&segment);
            let segment_ptr = input_handle.with_const_ptr::<StringHeader, _>(|ptr| {
                crate::string::js_string_slice(ptr, index as i32, end as i32)
            });
            let word_like = if is_word {
                Some(segment.chars().any(|c| c.is_alphanumeric()))
            } else {
                None
            };
            let record = make_segment_record(
                string_pointer_value(segment_ptr),
                index,
                input_handle.with_const_ptr::<StringHeader, _>(|ptr| string_pointer_value(ptr)),
                word_like,
            );
            arr = js_array_push_f64(arr, record);
            index = end;
        }
    }
    let scope = crate::gc::RuntimeHandleScope::new();
    let segments = scope.root_raw_mut_ptr(arr as *mut ObjectHeader);
    let brand = string_value(SEGMENTS_BRAND);
    segments.with_mut_ptr(|segments| set_internal_field(segments, KEY_SEGMENTS_BRAND, brand));
    segments
        .with_mut_ptr(|segments| set_internal_field(segments, KEY_SEGMENTS_LENGTH, index as f64));
    segments.with_mut_ptr(|segments| {
        install_function(
            segments,
            "containing",
            segmenter_containing_thunk as *const u8,
            1,
            1,
            false,
        )
    });
    install_segments_iterator(&segments);
    segments.with_mut_ptr(|segments: *mut ObjectHeader| js_nanbox_pointer(segments as i64))
}

fn install_segments_iterator(segments: &crate::gc::RuntimeHandle<'_>) {
    let symbol = crate::symbol::well_known_symbol("iterator");
    if symbol.is_null() {
        return;
    }
    let scope = crate::gc::RuntimeHandleScope::new();
    let symbol = scope.root_raw_mut_ptr(symbol);
    let closure = scope.root_raw_mut_ptr(crate::closure::js_closure_alloc(
        segments_iterator_thunk as *const u8,
        0,
    ));
    if closure.with_mut_ptr(|closure: *mut ClosureHeader| closure.is_null()) {
        return;
    }
    crate::closure::js_register_closure_arity(segments_iterator_thunk as *const u8, 0);
    closure.with_mut_ptr::<ClosureHeader, _>(|ptr| {
        crate::object::set_bound_native_closure_name(ptr, "[Symbol.iterator]")
    });
    closure.with_mut_ptr::<ClosureHeader, _>(|ptr| {
        crate::object::set_builtin_closure_length(ptr as usize, 0)
    });
    let value = closure.with_mut_ptr::<ClosureHeader, _>(|ptr| js_nanbox_pointer(ptr as i64));
    unsafe {
        segments.with_mut_ptr(|segments: *mut ObjectHeader| {
            symbol.with_const_ptr(|symbol: *const u8| {
                crate::symbol::js_object_set_symbol_property(
                    js_nanbox_pointer(segments as i64),
                    f64::from_bits(JSValue::pointer(symbol).bits()),
                    value,
                )
            })
        });
    }
    segments.with_mut_ptr(|segments: *mut ObjectHeader| {
        symbol.with_const_ptr(|symbol: *const u8| {
            crate::symbol::set_symbol_property_attrs(
                segments as usize,
                symbol as usize,
                PropertyAttrs::new(true, false, true),
            )
        })
    });
}

extern "C" fn segments_iterator_thunk(_closure: *const ClosureHeader) -> f64 {
    let scope = crate::gc::RuntimeHandleScope::new();
    let segments = scope.root_raw_const_ptr(segments_from_this());
    segments.with_const_ptr(|segments: *const crate::ArrayHeader| {
        crate::array::array_values_iter(js_nanbox_pointer(segments as i64))
    })
}

fn segments_from_this() -> *const crate::ArrayHeader {
    let this_value = crate::object::js_implicit_this_get();
    let Some(segments) = array_ptr_from_value(this_value) else {
        throw_type_error("Intl.Segments.prototype.containing called on incompatible receiver");
    };
    let brand = get_string_field(segments as *const ObjectHeader, KEY_SEGMENTS_BRAND);
    if brand.as_deref() != Some(SEGMENTS_BRAND) {
        throw_type_error("Intl.Segments.prototype.containing called on incompatible receiver");
    }
    segments
}

pub(crate) extern "C" fn segmenter_containing_thunk(
    _closure: *const ClosureHeader,
    index: f64,
) -> f64 {
    // The lazy grapheme representation answers from a boundary walk; the eager
    // array representation (word / sentence / non-UTF-8) keeps the array walk
    // below. Both branches coerce the index the same way and in the same place.
    if let Some(lazy) = lazy_segments_ptr(crate::object::js_implicit_this_get()) {
        let scope = crate::gc::RuntimeHandleScope::new();
        let lazy_h = scope.root_raw_mut_ptr(lazy);
        // ToIntegerOrInfinity may run user code, so the receiver stays rooted
        // across the coercion and is re-read from the handle afterwards.
        let (number, _) = lazy_h.across_mut::<ObjectHeader, _>(|| {
            list_relative_plural::to_number_reject_bigint(index)
        });
        let integer = if number.is_nan() { 0.0 } else { number.trunc() };
        return lazy_h.with_mut_ptr(|o: *mut ObjectHeader| lazy_containing(o, integer));
    }
    let segments = segments_from_this();
    let input_len =
        get_number_field(segments as *const ObjectHeader, KEY_SEGMENTS_LENGTH).unwrap_or(0.0);

    // ToIntegerOrInfinity may invoke user code, so keep the Segments backing
    // array rooted while coercing the index.
    let scope = crate::gc::RuntimeHandleScope::new();
    let segments_handle = scope.root_raw_const_ptr(segments);
    let (number, segments) = segments_handle.across_const::<crate::ArrayHeader, _>(|| {
        list_relative_plural::to_number_reject_bigint(index)
    });
    let integer = if number.is_nan() { 0.0 } else { number.trunc() };
    if integer < 0.0 || integer >= input_len {
        return undefined();
    }

    let count = js_array_length(segments);
    for i in 0..count {
        let record_value = js_array_get_f64(segments, i);
        let Some(record) = object_ptr_from_value(record_value) else {
            continue;
        };
        let start = get_number_field(record, "index").unwrap_or(0.0);
        let end = if i + 1 < count {
            let next_value = js_array_get_f64(segments, i + 1);
            object_ptr_from_value(next_value)
                .and_then(|next| get_number_field(next, "index"))
                .unwrap_or(input_len)
        } else {
            input_len
        };
        if integer >= start && integer < end {
            let segment_value = get_field(record, "segment");
            let input_value = get_field(record, "input");
            let word_like_value = get_field(record, "isWordLike");
            let word_like = if JSValue::from_bits(word_like_value.to_bits()).is_undefined() {
                None
            } else {
                Some(crate::value::js_is_truthy(word_like_value) != 0)
            };
            return make_segment_record(segment_value, start as u32, input_value, word_like);
        }
    }
    undefined()
}

pub(crate) extern "C" fn segmenter_segment_thunk(
    _closure: *const ClosureHeader,
    value: f64,
) -> f64 {
    let obj = this_intl_object("segment", KIND_SEGMENTER);
    segmenter_segment_object(obj, value)
}

pub(crate) extern "C" fn segmenter_bound_segment_thunk(
    closure: *const ClosureHeader,
    value: f64,
) -> f64 {
    let obj = captured_intl_object(closure, "segment", KIND_SEGMENTER);
    segmenter_segment_object(obj, value)
}

pub(crate) fn segmenter_segment_object(obj: *const ObjectHeader, value: f64) -> f64 {
    let granularity =
        get_string_field(obj, KEY_GRANULARITY).unwrap_or_else(|| "grapheme".to_string());
    build_segments(&granularity, value)
}

pub(crate) extern "C" fn segmenter_resolved_options_thunk(_closure: *const ClosureHeader) -> f64 {
    let obj = this_intl_object("resolvedOptions", KIND_SEGMENTER);
    segmenter_resolved_options_object(obj)
}

pub(crate) extern "C" fn segmenter_bound_resolved_options_thunk(
    closure: *const ClosureHeader,
) -> f64 {
    let obj = captured_intl_object(closure, "resolvedOptions", KIND_SEGMENTER);
    segmenter_resolved_options_object(obj)
}

pub(crate) fn segmenter_resolved_options_object(obj: *const ObjectHeader) -> f64 {
    let out = js_object_alloc(0, 2);
    set_field(
        out,
        "locale",
        string_value(&get_string_field(obj, KEY_LOCALE).unwrap_or_else(|| "en-US".to_string())),
    );
    set_field(
        out,
        "granularity",
        string_value(
            &get_string_field(obj, KEY_GRANULARITY).unwrap_or_else(|| "grapheme".to_string()),
        ),
    );
    js_nanbox_pointer(out as i64)
}


/// `value` as a string pointer, or `None`. Non-allocating: the value in a
/// `Segments`' input slot is always already a string.
fn segments_string_ptr(value: f64) -> Option<*const StringHeader> {
    let jv = JSValue::from_bits(value.to_bits());
    if !jv.is_string() {
        return None;
    }
    if jv.is_short_string() {
        // The input slot is filled from `js_jsvalue_to_string`, so it always
        // holds a heap string and this branch is unreachable in practice. It
        // must still be RIGHT rather than silently "no segments": materialise.
        // (`js_jsvalue_to_string` allocates, which is why the slot is filled
        // with a heap pointer in the first place.)
        let ptr = js_jsvalue_to_string(value);
        return if ptr.is_null() { None } else { Some(ptr) };
    }
    let ptr = jv.as_string_ptr();
    if ptr.is_null() {
        None
    } else {
        Some(ptr)
    }
}

/// Is `value` a lazy grapheme `Segments` object (as opposed to the eager array
/// word/sentence representation)? Read-only and non-allocating.
fn lazy_segments_ptr(value: f64) -> Option<*mut ObjectHeader> {
    let obj = object_ptr_from_value(value)? as *mut ObjectHeader;
    // The class id IS the brand: a load, not a key-string allocation.
    if unsafe { (*obj).class_id } != SEGMENTS_CLASS_ID {
        return None;
    }
    Some(obj)
}

/// The lazy `Segments` for `input`, or `None` when this input must keep the
/// eager path: non-UTF-8 (WTF-8 lone surrogates, which `segmenter_input_text`
/// repairs by copying and a borrowing cursor cannot) is the only case.
fn build_lazy_grapheme_segments(input_handle: &crate::gc::RuntimeHandle<'_>) -> Option<f64> {
    let valid_utf8 = unsafe {
        input_handle.with_const_ptr::<StringHeader, _>(|ptr| {
            if ptr.is_null() {
                return false;
            }
            let data = (ptr as *const u8).add(std::mem::size_of::<StringHeader>());
            let len = (*ptr).byte_len as usize;
            std::str::from_utf8(std::slice::from_raw_parts(data, len)).is_ok()
        })
    };
    if !valid_utf8 {
        return None;
    }
    ensure_segments_prototypes();
    let proto = cached_segments_proto(PROTO_SEGMENTS);
    if proto.is_null() {
        return None;
    }
    let scope = crate::gc::RuntimeHandleScope::new();
    let obj = scope.root_raw_mut_ptr(js_object_alloc(SEGMENTS_CLASS_ID, 3));
    if obj.with_mut_ptr(|o: *mut ObjectHeader| o.is_null()) {
        return None;
    }
    let (brand, _) = obj.across_mut::<ObjectHeader, _>(|| string_value(SEGMENTS_BRAND));
    obj.with_mut_ptr(|o: *mut ObjectHeader| set_internal_field(o, KEY_SEGMENTS_BRAND, brand));
    let input_value =
        input_handle.with_const_ptr::<StringHeader, _>(|ptr| string_pointer_value(ptr));
    obj.with_mut_ptr(|o: *mut ObjectHeader| set_internal_field(o, KEY_SEGMENTS_INPUT, input_value));
    let u16len = unsafe {
        input_handle.with_const_ptr::<StringHeader, _>(|ptr| {
            if ptr.is_null() {
                0u32
            } else {
                (*ptr).utf16_len
            }
        })
    };
    obj.with_mut_ptr(|o: *mut ObjectHeader| set_internal_field(o, KEY_SEGMENTS_LENGTH, u16len as f64));
    // The prototype is re-read from the scanned table: an install above may
    // have collected, and the table is what the collector rewrites.
    let proto_bits =
        js_nanbox_pointer(cached_segments_proto(PROTO_SEGMENTS) as i64).to_bits();
    obj.with_mut_ptr(|o: *mut ObjectHeader| {
        crate::object::prototype_chain::object_link_class_default_prototype(o as usize, proto_bits)
    });
    Some(obj.with_mut_ptr(|o: *mut ObjectHeader| js_nanbox_pointer(o as i64)))
}

/// Run `f` with the lazy `Segments`' input as a `&str`. The borrow is derived
/// at entry and dropped before returning; nothing derived from it may outlive
/// this call (the #9539 / #9445 rule for this module).
fn with_segments_input<R>(segments: *mut ObjectHeader, f: impl FnOnce(&str) -> R) -> Option<R> {
    let input_value = field_at(segments, F_SEGMENTS_INPUT);
    let ptr = segments_string_ptr(input_value)?;
    unsafe {
        if ptr.is_null() {
            return None;
        }
        let data = (ptr as *const u8).add(std::mem::size_of::<StringHeader>());
        let len = (*ptr).byte_len as usize;
        let text = std::str::from_utf8(std::slice::from_raw_parts(data, len)).ok()?;
        Some(f(text))
    }
}

/// The next grapheme boundary after `byte_off`, or `None` at the end. A fresh
/// `GraphemeCursor` per step is correct because the WHOLE string is supplied as
/// one chunk, so every rule's pre-context (GB9c, GB11, GB12/13 regional-
/// indicator parity) is derivable; verified against `graphemes(true)` on 17
/// inputs including a 3-flag sequence, 0 mismatches.
#[cfg(feature = "intl-segmenter")]
fn next_grapheme_boundary(text: &str, byte_off: usize) -> Option<usize> {
    if byte_off >= text.len() {
        return None;
    }
    let mut cursor = unicode_segmentation::GraphemeCursor::new(byte_off, text.len(), true);
    match cursor.next_boundary(text, 0) {
        Ok(Some(next)) if next > byte_off => Some(next),
        _ => None,
    }
}

#[cfg(not(feature = "intl-segmenter"))]
fn next_grapheme_boundary(text: &str, byte_off: usize) -> Option<usize> {
    // Engine gated off: one segment per code point, matching `build_segments`'
    // fallback.
    text[byte_off..].chars().next().map(|c| byte_off + c.len_utf8())
}

/// `%SegmentsPrototype%[Symbol.iterator]()` — allocate a cursor object. No
/// segmentation work happens here.
extern "C" fn lazy_segments_iterator_thunk(_closure: *const ClosureHeader) -> f64 {
    let this_value = crate::object::js_implicit_this_get();
    let Some(segments) = lazy_segments_ptr(this_value) else {
        throw_type_error("Intl.Segments.prototype[Symbol.iterator] called on incompatible receiver")
    };
    ensure_segments_prototypes();
    let scope = crate::gc::RuntimeHandleScope::new();
    let segments_h = scope.root_raw_mut_ptr(segments);
    let iter = scope.root_raw_mut_ptr(js_object_alloc(SEGMENTS_ITERATOR_CLASS_ID, 3));
    if iter.with_mut_ptr(|o: *mut ObjectHeader| o.is_null()) {
        return undefined();
    }
    let segments_value =
        segments_h.with_mut_ptr(|s: *mut ObjectHeader| js_nanbox_pointer(s as i64));
    iter.with_mut_ptr(|o: *mut ObjectHeader| set_internal_field(o, KEY_SEGITER_SEGMENTS, segments_value));
    iter.with_mut_ptr(|o: *mut ObjectHeader| set_internal_field(o, KEY_SEGITER_BYTE, 0.0));
    iter.with_mut_ptr(|o: *mut ObjectHeader| set_internal_field(o, KEY_SEGITER_UTF16, 0.0));
    let proto_bits =
        js_nanbox_pointer(cached_segments_proto(PROTO_SEGMENTS_ITERATOR) as i64).to_bits();
    iter.with_mut_ptr(|o: *mut ObjectHeader| {
        crate::object::prototype_chain::object_link_class_default_prototype(o as usize, proto_bits)
    });
    iter.with_mut_ptr(|o: *mut ObjectHeader| js_nanbox_pointer(o as i64))
}

/// `%SegmentsIteratorPrototype%.next()` — ONE boundary, ONE record.
extern "C" fn segments_iterator_next_thunk(_closure: *const ClosureHeader) -> f64 {
    let this_value = crate::object::js_implicit_this_get();
    let Some(iter) = object_ptr_from_value(this_value).map(|o| o as *mut ObjectHeader) else {
        throw_type_error("Intl.SegmentIterator.prototype.next called on incompatible receiver")
    };
    segments_iterator_step(iter)
}

/// The `for…of` fast path's entry: the same step, reached from
/// `js_for_of_next`'s class-id arm without a by-name `next` lookup.
pub fn dispatch_segments_iterator_next(iter: *mut ObjectHeader) -> f64 {
    segments_iterator_step(iter)
}

fn segments_iterator_step(iter: *mut ObjectHeader) -> f64 {
    let segments_value = field_at(iter, F_SEGITER_SEGMENTS);
    let Some(segments) = lazy_segments_ptr(segments_value) else {
        throw_type_error("Intl.SegmentIterator.prototype.next called on incompatible receiver")
    };
    let byte_off = JSValue::from_bits(field_at(iter, F_SEGITER_BYTE).to_bits()).to_number() as usize;
    let index = JSValue::from_bits(field_at(iter, F_SEGITER_UTF16).to_bits()).to_number() as u32;

    // Boundary arithmetic only — the borrow does not escape this block.
    let step = with_segments_input(segments, |text| {
        next_grapheme_boundary(text, byte_off)
            .map(|next| (next, utf16_len(&text[byte_off..next])))
    })
    .flatten();
    let Some((next_byte, seg_u16)) = step else {
        return unsafe { crate::iter_result::make_iter_result(JSValue::undefined(), true) };
    };

    let scope = crate::gc::RuntimeHandleScope::new();
    let iter_h = scope.root_raw_mut_ptr(iter);
    let segments_h = scope.root_raw_mut_ptr(segments);
    let input_value = field_at(segments, F_SEGMENTS_INPUT);
    let input_h = scope.root_nanbox_f64(input_value);
    let segment_value = {
        let ptr = segments_string_ptr(input_h.get_nanbox_f64());
        match ptr {
            Some(p) => string_pointer_value(crate::string::js_string_slice(
                p,
                index as i32,
                (index + seg_u16) as i32,
            )),
            None => return unsafe { crate::iter_result::make_iter_result(JSValue::undefined(), true) },
        }
    };
    let segment_h = scope.root_nanbox_f64(segment_value);
    let record = make_segment_record(
        segment_h.get_nanbox_f64(),
        index,
        input_h.get_nanbox_f64(),
        None,
    );
    let record_h = scope.root_nanbox_f64(record);
    // Advance only after every allocation above has happened, and re-read the
    // iterator from its handle: the collector may have moved it.
    iter_h.with_mut_ptr(|o: *mut ObjectHeader| set_field_at(o, F_SEGITER_BYTE, next_byte as f64));
    iter_h.with_mut_ptr(|o: *mut ObjectHeader| {
        set_field_at(o, F_SEGITER_UTF16, (index + seg_u16) as f64)
    });
    let _ = &segments_h;
    unsafe {
        crate::iter_result::make_iter_result(
            JSValue::from_bits(record_h.get_nanbox_f64().to_bits()),
            false,
        )
    }
}

/// `containing(index)` on the lazy representation: walk boundaries from 0 and
/// build exactly ONE record — the same O(n) the array walk does today, with n
/// fewer records and n fewer substrings standing behind it.
fn lazy_containing(segments: *mut ObjectHeader, integer: f64) -> f64 {
    let input_len = JSValue::from_bits(field_at(segments, F_SEGMENTS_LENGTH).to_bits()).to_number();
    if integer < 0.0 || integer >= input_len {
        return undefined();
    }
    let target = integer as u32;
    let found = with_segments_input(segments, |text| {
        let mut byte_off = 0usize;
        let mut index = 0u32;
        while let Some(next) = next_grapheme_boundary(text, byte_off) {
            let seg_u16 = utf16_len(&text[byte_off..next]);
            if target >= index && target < index + seg_u16 {
                return Some((index, seg_u16));
            }
            byte_off = next;
            index += seg_u16;
        }
        None
    })
    .flatten();
    let Some((index, seg_u16)) = found else {
        return undefined();
    };
    let scope = crate::gc::RuntimeHandleScope::new();
    let input_value = field_at(segments, F_SEGMENTS_INPUT);
    let input_h = scope.root_nanbox_f64(input_value);
    let Some(ptr) = segments_string_ptr(input_h.get_nanbox_f64()) else {
        return undefined();
    };
    let segment_value = string_pointer_value(crate::string::js_string_slice(
        ptr,
        index as i32,
        (index + seg_u16) as i32,
    ));
    let segment_h = scope.root_nanbox_f64(segment_value);
    make_segment_record(
        segment_h.get_nanbox_f64(),
        index,
        input_h.get_nanbox_f64(),
        None,
    )
}
