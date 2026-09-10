//! #7850: the header-directed probe dispatch in `gc_pointer_and_type_from_value`.
//!
//! Every dynamic method call goes through that function, and it used to run four
//! side-registry probes — `is_registered_set`, `is_registered_map`,
//! `is_regex_pointer`, `is_registered_symbol` — before reading the `GcHeader`
//! that already records the kind three of them were looking for. The symbol one
//! is the expensive one: a process-global `Mutex` plus a SipHash, entered on
//! every dispatch as soon as ANY `Symbol` exists, which one `for…of` makes true
//! (it materialises `Symbol.iterator`).
//!
//! These tests pin the two halves that a re-ordering can break:
//!
//! * **the saving is real** — a plain-object receiver must not move the symbol,
//!   map or set probe counters, *with the symbol latch armed*. A test that only
//!   checked "nothing threw" would pass with the whole optimisation deleted;
//!   this one goes red (case 4 of CLAUDE.md's "four ways a gate can be unable to
//!   fail").
//! * **the answer is unchanged** — Set, Map, RegExp, fresh `Symbol()` and
//!   process-global (`Symbol.for` / well-known) receivers must all still be
//!   excluded. Global symbols now carry an allocator-tracked, pinned
//!   `GC_TYPE_SYMBOL` header, so the header itself is authoritative and no
//!   payload-magic or symbol-registry probe is needed here.
//!
//! Global symbols are minted through `Symbol.for` with a key unique to each
//! test rather than through the well-known cache: `WELL_KNOWN_SYMBOLS` is a
//! process-global cache while `SYMBOL_POINTERS` is `per_test_global!` (i.e. per
//! THREAD under `cargo test`), so a well-known symbol first created on another
//! test thread would come back cached and unregistered here. A unique key always
//! allocates and registers on the calling thread.

use super::*;

fn nanboxed(ptr: usize) -> f64 {
    f64::from_bits(crate::value::js_nanbox_pointer(ptr as i64).to_bits())
}

fn plain_object() -> usize {
    crate::object::js_object_alloc(0, 4) as usize
}

/// A pinned process-global symbol, registered on THIS thread. Same storage
/// class as `Symbol.iterator` and the Intl fallback symbol.
fn global_symbol(key: &str) -> usize {
    let key_str = crate::string::js_string_from_str(key);
    let key_f64 = f64::from_bits(crate::value::js_nanbox_string(key_str as i64).to_bits());
    let addr = unsafe { crate::value::js_nanbox_get_pointer(crate::symbol::js_symbol_for(key_f64)) }
        as usize;
    assert!(addr != 0, "test premise: Symbol.for({key}) allocated");
    assert!(
        crate::symbol::is_registered_symbol(addr),
        "test premise: Symbol.for({key}) is registered on this thread"
    );
    addr
}

fn classify(addr: usize) -> Option<(*const u8, u8)> {
    unsafe { test_gc_pointer_and_type_from_value(nanboxed(addr)) }
}

/// The `obj_type` match at the tail of `gc_pointer_and_type_from_value`, kept as
/// a test mirror so the dedicated-kind exclusions are explicitly fail-capable.
fn excluded_by_the_header_arms(addr: usize, obj_type: u8) -> bool {
    match obj_type {
        crate::gc::GC_TYPE_SET => crate::set::is_registered_set(addr),
        crate::gc::GC_TYPE_MAP => crate::map::is_registered_map(addr),
        crate::gc::GC_TYPE_REGEXP => true,
        crate::gc::GC_TYPE_SYMBOL => true,
        _ => false,
    }
}

/// The saving, asserted rather than assumed: with the symbol latch ARMED — the
/// state every realistic program is in — a plain-object dispatch must not enter
/// `is_registered_symbol` at all, nor the map/set registries.
///
/// Delete the `obj_type` dispatch and this goes red, because the probes run
/// again.
#[test]
fn plain_object_dispatch_probes_no_side_registry() {
    // Arm the latch the way ordinary code does.
    global_symbol("perry-7850-arm-the-latch");
    assert!(
        !crate::symbol::test_symbol_latch_is_idle(),
        "test premise: creating a symbol must arm SYMBOL_EVER_REGISTERED"
    );

    let obj = plain_object();
    // Warm any lazy state so the measured call below is steady-state.
    assert!(classify(obj).is_some());

    let sym_before = crate::symbol::test_symbol_registry_probe_count();
    let map_before = crate::map::test_map_registry_probe_count();
    let set_before = crate::set::test_set_registry_probe_count();

    let got = classify(obj);
    assert_eq!(
        got.map(|(_, t)| t),
        Some(crate::gc::GC_TYPE_OBJECT),
        "a plain object must classify as GC_TYPE_OBJECT"
    );

    assert_eq!(
        crate::symbol::test_symbol_registry_probe_count(),
        sym_before,
        "a plain-object dispatch must not take the process-global symbol \
         registry mutex — that was 6.5% of `pipeline` (#7850)"
    );
    assert_eq!(
        crate::map::test_map_registry_probe_count(),
        map_before,
        "GC_TYPE_OBJECT rules a Map out; the registry must not be consulted"
    );
    assert_eq!(
        crate::set::test_set_registry_probe_count(),
        set_before,
        "GC_TYPE_OBJECT rules a Set out; the registry must not be consulted"
    );
}

/// The answer, unchanged. Each of these kinds resolved to `None` before the
/// re-ordering and must still.
#[test]
fn exotic_receivers_are_still_excluded() {
    let set = crate::set::js_set_alloc(4) as usize;
    assert!(
        classify(set).is_none(),
        "a Set must not classify as an object"
    );

    let map = crate::map::js_map_alloc(4) as usize;
    assert!(
        classify(map).is_none(),
        "a Map must not classify as an object"
    );

    // Fresh `Symbol(desc)` has the same dedicated kind as global symbols.
    let fresh = unsafe {
        crate::value::js_nanbox_get_pointer(crate::symbol::js_symbol_new_empty()) as usize
    };
    assert!(fresh != 0, "test premise: Symbol() allocated");
    assert!(
        classify(fresh).is_none(),
        "a fresh Symbol must not classify as an object"
    );

    // A pinned global symbol created AFTER the idle fast path has already
    // answered for the unrelated addresses above (#7474 shape).
    let leaked = global_symbol("perry-7850-after-the-fast-path");
    assert!(
        classify(leaked).is_none(),
        "a global symbol created after the idle fast path must still be excluded"
    );

    // The realistic well-known-symbol path — what a `for…of` mints.
    let wk = crate::symbol::well_known_symbol("iterator") as usize;
    let header = unsafe { crate::value::addr_class::try_read_tracked_gc_header(wk) }
        .expect("a well-known symbol must have a tracked header");
    assert_eq!(
        unsafe { header.as_ref().obj_type },
        crate::gc::GC_TYPE_SYMBOL
    );
}

/// RegExp has its own GC kind, so it must be rejected without entering the
/// ordinary-object arm or consulting an `ObjectHeader` payload word.
#[cfg(feature = "regex-engine")]
#[test]
fn regexp_receiver_is_still_excluded() {
    let pattern = crate::string::js_string_from_str("a+b");
    let flags = crate::string::js_string_from_str("g");
    let re = crate::regex::js_regexp_new(pattern, flags) as usize;
    assert!(re != 0, "test premise: RegExp allocated");
    assert!(
        classify(re).is_none(),
        "a RegExp has GC_TYPE_REGEXP and must be excluded before ordinary-object \
         header reads"
    );
}

/// Sabotage boundary: a global symbol is excluded specifically because its
/// tracked header says `GC_TYPE_SYMBOL`. Supplying any ordinary object kind to
/// the mirrored match must remove the exclusion.
#[test]
fn header_directed_dispatch_needs_the_symbol_kind() {
    let symbol = global_symbol("perry-7850-symbol-kind");
    assert!(excluded_by_the_header_arms(
        symbol,
        crate::gc::GC_TYPE_SYMBOL
    ));
    assert!(
        !excluded_by_the_header_arms(symbol, crate::gc::GC_TYPE_OBJECT),
        "sabotage: replacing GC_TYPE_SYMBOL with GC_TYPE_OBJECT must route the \
         value into ordinary-object handling"
    );
}

/// Every symbol storage class must carry the dedicated GC kind, and no ordinary
/// object may be excluded by that arm.
#[test]
fn the_symbol_kind_covers_every_symbol_and_no_ordinary_object() {
    for i in 0..8 {
        let sym = global_symbol(&format!("perry-7850-kind-{i}"));
        assert_eq!(classify(sym), None, "global symbol {sym:#x} excluded");
        let header = unsafe { crate::value::addr_class::try_read_tracked_gc_header(sym) }
            .expect("global symbol header");
        assert_eq!(
            unsafe { header.as_ref().obj_type },
            crate::gc::GC_TYPE_SYMBOL
        );
    }
    let fresh = unsafe {
        crate::value::js_nanbox_get_pointer(crate::symbol::js_symbol_new_empty()) as usize
    };
    let header = unsafe { crate::value::addr_class::try_read_tracked_gc_header(fresh) }
        .expect("fresh symbol header");
    assert_eq!(
        unsafe { header.as_ref().obj_type },
        crate::gc::GC_TYPE_SYMBOL
    );

    let object = plain_object();
    assert!(!excluded_by_the_header_arms(
        object,
        crate::gc::GC_TYPE_OBJECT
    ));
}
