//! Compiler-private projection of a nonescaping grapheme Segments producer.
//!
//! The public Segmenter API is unchanged. A successful admission keeps input
//! and a REAL Array iterator in traced slots. Ordinary steps make only the
//! projected string. Before a user next/close operation can observe the
//! iterator, the full original backing is restored at its consumed ordinal.
//! Materialization is sticky; subsequent operations use the original protocol.

use crate::gc::{RuntimeHandle, RuntimeHandleScope};
use crate::object::ObjectHeader;
use crate::string::StringHeader;
use crate::value::{js_nanbox_get_pointer, js_nanbox_pointer, JSValue, TAG_UNDEFINED};

const CURSOR_CLASS_ID: u32 = 0xFFFF_000F;
const INPUT: usize = 0;
const ITERATOR: usize = 1;
const BYTE_END: usize = 2;
const UTF16_END: usize = 3;
const CURRENT_START: usize = 4;
const CURRENT_END: usize = 5;
const ORDINAL: usize = 6;
const MODE: usize = 7;
const RESULT: usize = 8;
const FIELDS: u32 = 9;
const PROJECTED: usize = 0;
const MATERIALIZED: usize = 1;
const EXHAUSTED: usize = 2;

#[cfg(test)]
thread_local! {
    static COUNTS: std::cell::Cell<[usize; 3]> = const { std::cell::Cell::new([0; 3]) };
}

#[cfg(test)]
fn count(index: usize) {
    COUNTS.with(|counts| {
        let mut values = counts.get();
        values[index] += 1;
        counts.set(values);
    });
}

/// Only the compiler's admitted cursor ABI calls these fixed-layout helpers.
/// No user-visible property/shape lookup is part of a projected step.
#[inline(always)]
unsafe fn cursor(value: f64) -> *mut ObjectHeader {
    let pointer = js_nanbox_get_pointer(value) as *mut ObjectHeader;
    debug_assert!(!pointer.is_null() && (*pointer).class_id == CURSOR_CLASS_ID);
    pointer
}

#[inline(always)]
unsafe fn slot(object: *const ObjectHeader, index: usize) -> JSValue {
    *((object as *const u8).add(std::mem::size_of::<ObjectHeader>()) as *const JSValue).add(index)
}

#[inline(always)]
unsafe fn number(object: *const ObjectHeader, index: usize) -> usize {
    f64::from_bits(slot(object, index).bits()) as usize
}

#[inline(always)]
unsafe fn set_number(object: *mut ObjectHeader, index: usize, value: usize) {
    // GC_STORE_AUDIT(NON_GC): these established slots hold numeric state only.
    ((object as *mut u8).add(std::mem::size_of::<ObjectHeader>()) as *mut JSValue)
        .add(index)
        .write(JSValue::number(value as f64));
}

#[inline]
unsafe fn store(object: *mut ObjectHeader, index: usize, value: f64) {
    crate::object::object_store_known_live_slot(
        object,
        index as u32,
        JSValue::from_bits(value.to_bits()),
    );
}

fn own_data(object: *const ObjectHeader, key: &[u8]) -> Option<JSValue> {
    let name = std::str::from_utf8(key).ok()?;
    if crate::object::descriptor_state::may_have_descriptor_entry(object as usize, name, true) {
        return None;
    }
    let value = crate::object::js_object_get_own_field_or_undef(
        js_nanbox_pointer(object as i64),
        key.as_ptr(),
        key.len(),
    );
    Some(JSValue::from_bits(value.to_bits()))
}

fn string_is(value: JSValue, expected: &[u8]) -> bool {
    let mut short = [0u8; crate::value::SHORT_STRING_MAX_LEN];
    unsafe { crate::string::js_string_key_bytes(value, &mut short) == Some(expected) }
}

/// Must run before argument evaluation. This predicate allocates no managed
/// state, invokes no property callback and never coerces a value.
#[no_mangle]
pub extern "C" fn js_segments_project_can_open(receiver: f64) -> f64 {
    let Some(object) = (unsafe { crate::object::object_ptr_from_value(receiver) }) else {
        return 0.0;
    };
    if unsafe { (*object).class_id } != 0 || crate::array::array_proto_iterator_modified() {
        return 0.0;
    }
    let Some(kind) = own_data(object, b"__intlKind") else {
        return 0.0;
    };
    let Some(granularity) = own_data(object, b"__intlGranularity") else {
        return 0.0;
    };
    let Some(method) = own_data(object, b"segment") else {
        return 0.0;
    };
    if !string_is(kind, b"Segmenter")
        || !string_is(granularity, b"grapheme")
        || !method.is_pointer()
    {
        return 0.0;
    }
    let method = js_nanbox_get_pointer(f64::from_bits(method.bits()))
        as *const crate::closure::ClosureHeader;
    if !crate::closure::is_closure_ptr(method as usize)
        || crate::closure::get_valid_func_ptr(method)
            != super::segmenter::segmenter_bound_segment_thunk as *const u8
        || unsafe { (*method).capture_count } != 1
        || crate::closure::js_closure_get_capture_f64(method, 0).to_bits() != receiver.to_bits()
    {
        return 0.0;
    }
    1.0
}

/// Called only after can_open and a pure/nonthrowing input read. A decline
/// leaves the original saved-receiver/saved-input call to the compiler.
#[no_mangle]
pub extern "C" fn js_segments_project_open(receiver: f64, input: f64) -> f64 {
    if js_segments_project_can_open(receiver) == 0.0 {
        return 0.0;
    }
    let input_value = JSValue::from_bits(input.to_bits());
    if !input_value.is_any_string() {
        return 0.0;
    }
    let mut short = [0u8; crate::value::SHORT_STRING_MAX_LEN];
    let Some(bytes) = (unsafe { crate::string::js_string_key_bytes(input_value, &mut short) })
    else {
        return 0.0;
    };
    if std::str::from_utf8(bytes).is_err() {
        return 0.0;
    }
    // No callback/decline follows this point. The primitive conversion gives
    // SSO input one stable heap representation, just like build_segments.
    let scope = RuntimeHandleScope::new();
    let input = scope.root_nanbox_f64(input);
    let input = scope.root_string_ptr(crate::value::js_jsvalue_to_string(input.get_nanbox_f64()));
    let current = scope
        .root_nanbox_f64(js_nanbox_pointer(
            crate::object::js_object_alloc(CURSOR_CLASS_ID, FIELDS) as i64,
        ));
    unsafe {
        // The ordinary reference store marks input shared at open, preserving
        // the original record stores' ownership effect before any loop body.
        store(
            cursor(current.get_nanbox_f64()),
            INPUT,
            input.with_const_ptr::<StringHeader, _>(|value| {
                crate::value::js_nanbox_string(value as i64)
            }),
        );
        for index in BYTE_END..=MODE {
            set_number(cursor(current.get_nanbox_f64()), index, 0);
        }
        let iterator = scope.root_nanbox_f64(crate::array::array_projected_values_iter(
            current.get_nanbox_f64(),
        ));
        store(
            cursor(current.get_nanbox_f64()),
            ITERATOR,
            iterator.get_nanbox_f64(),
        );
    }
    #[cfg(test)]
    count(0);
    current.get_nanbox_f64()
}

#[no_mangle]
pub extern "C" fn js_segments_project_iterator(value: f64) -> f64 {
    unsafe { f64::from_bits(slot(cursor(value), ITERATOR).bits()) }
}

#[cfg(feature = "intl-segmenter")]
fn boundary(text: &str, from: usize) -> Option<usize> {
    use unicode_segmentation::{GraphemeCursor, GraphemeIncomplete};
    let mut walk = GraphemeCursor::new(from, text.len(), true);
    loop {
        match walk.next_boundary(text, 0) {
            Ok(next) => return next,
            Err(GraphemeIncomplete::PreContext(end)) => walk.provide_context(&text[..end], 0),
            // The complete validated string was supplied at offset zero.
            Err(_) => unreachable!("complete Segmenter input supplies all grapheme context"),
        }
    }
}

#[cfg(not(feature = "intl-segmenter"))]
fn boundary(text: &str, from: usize) -> Option<usize> {
    text[from..]
        .chars()
        .next()
        .map(|value| from + value.len_utf8())
}

fn materialize(current: &RuntimeHandle<'_>) {
    unsafe {
        let object = cursor(current.get_nanbox_f64());
        if number(object, MODE) != PROJECTED {
            return;
        }
        let input = f64::from_bits(slot(object, INPUT).bits());
        // This is the original producer with its captured granularity. Never
        // re-read the possibly modified Segmenter or invoke its method again.
        let backing = super::segmenter::build_segments("grapheme", input);
        let object = cursor(current.get_nanbox_f64());
        let iterator = js_nanbox_get_pointer(f64::from_bits(slot(object, ITERATOR).bits()))
            as *mut ObjectHeader;
        store(iterator, 0, backing);
        set_number(iterator, 1, number(object, ORDINAL));
        store(iterator, 3, f64::from_bits(TAG_UNDEFINED));
        set_number(object, MODE, MATERIALIZED);
    }
    #[cfg(test)]
    count(2);
}

/// Called before a projected iterator enters public/builtin Array dispatch.
/// `slot 3` is inspected only after that caller has proved Array-values kind.
pub(crate) fn materialize_associated_iterator(iterator: f64) {
    let scope = RuntimeHandleScope::new();
    let iterator = scope.root_nanbox_f64(iterator);
    unsafe {
        let object = js_nanbox_get_pointer(iterator.get_nanbox_f64()) as *mut ObjectHeader;
        let value = f64::from_bits(slot(object, 3).bits());
        let Some(current) = crate::object::object_ptr_from_value(value) else {
            return;
        };
        if (*current).class_id != CURSOR_CLASS_ID {
            return;
        }
        let current = scope.root_nanbox_f64(value);
        materialize(&current);
    }
}

/// Called on the exact generated close receiver, BEFORE a return getter.
#[no_mangle]
pub extern "C-unwind" fn js_segments_project_observe_iterator(value: f64) -> f64 {
    let scope = RuntimeHandleScope::new();
    let current = scope.root_nanbox_f64(value);
    materialize(&current);
    js_segments_project_iterator(current.get_nanbox_f64())
}

fn property(value: f64, name: &[u8]) -> f64 {
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(value);
    let key = scope.root_string_ptr(crate::string::js_string_from_bytes(
        name.as_ptr(),
        name.len() as u32,
    ));
    // The IC entry requires caller-owned cache storage. This cold path uses
    // the ordinary by-name dispatcher, preserving the IC entry's nullish
    // error and receiver encoding without introducing a cache.
    key.with_const_ptr::<StringHeader, _>(|key| {
        let bits = value.get_nanbox_u64();
        if bits == crate::value::TAG_NULL || bits == TAG_UNDEFINED {
            crate::error::js_throw_type_error_property_access(
                u32::from(bits == crate::value::TAG_NULL),
                name.as_ptr(),
                name.len(),
            );
        }
        if ((bits >> 48) & 0xFFFD) == 0x7FFD {
            // The tagged-receiver IC miss ends at raw by-name; its f64
            // sibling adds alias forwarding after an undefined result.
            let receiver = (bits & crate::value::POINTER_MASK) as *const ObjectHeader;
            f64::from_bits(crate::object::js_object_get_field_by_name(receiver, key).bits())
        } else {
            crate::object::js_object_get_field_by_name_f64(bits as *const ObjectHeader, key)
        }
    })
}

/// 1 means a value is available, 0 means done. Generic result validation and
/// its done Get happen here; value/segment Gets stay at the binding's original
/// lexical position in the compiler via the separate segment entry point.
#[no_mangle]
pub extern "C-unwind" fn js_segments_project_next(value: f64) -> f64 {
    unsafe {
        let object = cursor(value);
        if number(object, MODE) == EXHAUSTED {
            return 0.0;
        }
        let iterator = js_nanbox_get_pointer(f64::from_bits(slot(object, ITERATOR).bits()))
            as *mut ObjectHeader;
        if number(object, MODE) == PROJECTED
            && crate::object::iterator_prototypes::projected_array_next_is_canonical(iterator)
        {
            let input =
                (slot(object, INPUT).bits() & crate::value::POINTER_MASK) as *const StringHeader;
            let bytes = std::slice::from_raw_parts(
                (input as *const u8).add(std::mem::size_of::<StringHeader>()),
                (*input).byte_len as usize,
            );
            // INPUT is written once from validated bytes; movement changes
            // only its traced address. No allocation occurs during this borrow.
            let text = std::str::from_utf8_unchecked(bytes);
            let from = number(object, BYTE_END);
            if let Some(end) = boundary(text, from) {
                let start_utf16 = number(object, UTF16_END);
                let end_utf16 = start_utf16 + text[from..end].encode_utf16().count();
                set_number(object, BYTE_END, end);
                set_number(object, UTF16_END, end_utf16);
                set_number(object, CURRENT_START, start_utf16);
                set_number(object, CURRENT_END, end_utf16);
                let ordinal = number(object, ORDINAL) + 1;
                set_number(object, ORDINAL, ordinal);
                set_number(iterator, 1, ordinal);
                #[cfg(test)]
                count(1);
                return 1.0;
            }
            set_number(object, MODE, EXHAUSTED);
            store(iterator, 3, f64::from_bits(TAG_UNDEFINED));
            return 0.0;
        }
    }
    let scope = RuntimeHandleScope::new();
    let current = scope.root_nanbox_f64(value);
    materialize(&current);
    let result = unsafe {
        crate::collection_iter_object::js_for_of_next(js_segments_project_iterator(
            current.get_nanbox_f64(),
        ))
    };
    unsafe { store(cursor(current.get_nanbox_f64()), RESULT, result) };
    let done = property(result, b"done");
    if crate::value::js_is_truthy(done) != 0 {
        0.0
    } else {
        1.0
    }
}

#[no_mangle]
pub extern "C-unwind" fn js_segments_project_segment(value: f64) -> f64 {
    let scope = RuntimeHandleScope::new();
    let current = scope.root_nanbox_f64(value);
    unsafe {
        let object = cursor(current.get_nanbox_f64());
        if number(object, MODE) == PROJECTED {
            let start = number(object, CURRENT_START) as i32;
            let end = number(object, CURRENT_END) as i32;
            let input =
                (slot(object, INPUT).bits() & crate::value::POINTER_MASK) as *const StringHeader;
            // Keep the existing slice implementation and its ASCII sharing.
            let segment = crate::string::js_string_slice(input, start, end);
            crate::string::js_string_addref(segment);
            return crate::value::js_nanbox_string(segment as i64);
        }
        let result = f64::from_bits(slot(object, RESULT).bits());
        let record = scope.root_nanbox_f64(property(result, b"value"));
        property(record.get_nanbox_f64(), b"segment")
    }
}

#[cfg(test)]
#[path = "segments_project_tests.rs"]
mod tests;
