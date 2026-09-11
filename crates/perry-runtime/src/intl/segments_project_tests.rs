use super::*;
use std::sync::atomic::Ordering;

fn string(value: &str) -> f64 {
    crate::value::js_nanbox_string(crate::string::js_string_from_bytes(
        value.as_ptr(),
        value.len() as u32,
    ) as i64)
}

fn text(value: f64) -> String {
    let mut short = [0u8; crate::value::SHORT_STRING_MAX_LEN];
    let bytes = unsafe {
        crate::string::js_string_key_bytes(JSValue::from_bits(value.to_bits()), &mut short)
    }
    .expect("projected value must be a string");
    std::str::from_utf8(bytes).unwrap().to_owned()
}

fn open(input: &str) -> f64 {
    open_value(string(input))
}

fn open_value(input: f64) -> f64 {
    // Exercise the real constructor, including its data-property attributes
    // and one-capture bound method. The inner scope does not retain the input
    // or iterator across the caller's collection: only the cursor does that.
    let scope = RuntimeHandleScope::new();
    let input = scope.root_nanbox_f64(input);
    let receiver = scope.root_nanbox_f64(crate::intl::make_instance(
        std::ptr::null(),
        crate::intl::KIND_SEGMENTER,
        f64::from_bits(TAG_UNDEFINED),
        f64::from_bits(TAG_UNDEFINED),
    ));
    assert_eq!(js_segments_project_can_open(receiver.get_nanbox_f64()), 1.0);
    let current = js_segments_project_open(receiver.get_nanbox_f64(), input.get_nanbox_f64());
    assert_ne!(current, 0.0, "the actual constructor must be admitted");
    current
}

#[test]
fn inline_short_string_is_admitted_and_projected() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let scope = RuntimeHandleScope::new();
    let input = JSValue::try_short_string(b"abc").unwrap();
    assert!(
        input.is_short_string() && !input.is_string(),
        "the fixture must exercise SSO admission"
    );
    COUNTS.with(|counts| counts.set([0; 3]));
    let current = scope.root_nanbox_f64(open_value(f64::from_bits(input.bits())));
    let mut actual = String::new();
    while js_segments_project_next(current.get_nanbox_f64()) != 0.0 {
        actual.push_str(&text(js_segments_project_segment(current.get_nanbox_f64())));
    }
    assert_eq!(actual, "abc");
    assert_eq!(COUNTS.with(|counts| counts.get()), [1, 3, 0]);
}

#[test]
fn admitted_ascii_steps_make_no_records_backing_or_result_objects() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let scope = RuntimeHandleScope::new();
    let warm = scope.root_string_ptr(crate::string::js_string_from_bytes(b"abc".as_ptr(), 3));
    for index in 0..3 {
        warm.with_const_ptr::<StringHeader, _>(|value| {
            crate::string::js_string_slice(value, index, index + 1)
        });
    }
    COUNTS.with(|counts| counts.set([0; 3]));
    let current = scope.root_nanbox_f64(open("abcabc"));
    let before_bytes = crate::arena::arena_in_use_bytes();
    let before_cycles = crate::gc::copying_minor_cycles();
    let mut answer = String::new();
    for _ in 0..6 {
        assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
        let segment = js_segments_project_segment(current.get_nanbox_f64());
        answer.push_str(&text(segment));
        unsafe {
            let header = (segment.to_bits() & crate::value::POINTER_MASK) as *const StringHeader;
            assert_eq!(
                (*header).refcount,
                0,
                "ordinary record stores share the returned string"
            );
            let iter = cursor(current.get_nanbox_f64());
            let iter = js_nanbox_get_pointer(f64::from_bits(slot(iter, ITERATOR).bits()))
                as *const ObjectHeader;
            assert!(
                slot(iter, 0).is_undefined(),
                "no full backing while pristine"
            );
            assert!(
                slot(iter, 5).is_undefined(),
                "no cached result object while pristine"
            );
        }
    }
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 0.0);
    assert_eq!(answer, "abcabc");
    assert_eq!(COUNTS.with(|counts| counts.get()), [1, 6, 0]);
    assert_eq!(crate::gc::copying_minor_cycles(), before_cycles);
    assert_eq!(
        crate::arena::arena_in_use_bytes(),
        before_bytes,
        "the six admitted shared-character steps must allocate zero managed bytes"
    );
}

#[test]
fn unicode_steps_match_full_input_engine_including_regional_indicator_context() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let scope = RuntimeHandleScope::new();
    let input = format!("a\u{301}b👩\u{200d}💻{}z", "🇦🇧".repeat(12));
    let current = scope.root_nanbox_f64(open(&input));
    let mut actual = Vec::new();
    while js_segments_project_next(current.get_nanbox_f64()) != 0.0 {
        actual.push(text(js_segments_project_segment(current.get_nanbox_f64())));
    }
    #[cfg(feature = "intl-segmenter")]
    let expected: Vec<String> = {
        use unicode_segmentation::UnicodeSegmentation;
        input.graphemes(true).map(str::to_owned).collect()
    };
    #[cfg(not(feature = "intl-segmenter"))]
    let expected: Vec<String> = input.chars().map(|value| value.to_string()).collect();
    assert_eq!(actual, expected);
    assert_eq!(actual.concat(), input);
    assert!(actual.len() >= 12, "a short prefix is not a completed walk");
}

thread_local! {
    static OBSERVED: std::cell::Cell<(usize, usize)> = const { std::cell::Cell::new((0, 0)) };
    static GET_ORDER: std::cell::Cell<u32> = const { std::cell::Cell::new(0) };
}

extern "C" fn captured_result(closure: *const crate::closure::ClosureHeader) -> f64 {
    crate::closure::js_closure_get_capture_f64(closure, 0)
}

extern "C" fn ordered_getter(closure: *const crate::closure::ClosureHeader) -> f64 {
    let digit = crate::closure::js_closure_get_capture_f64(closure, 1) as u32;
    GET_ORDER.with(|order| order.set(order.get() * 10 + digit));
    crate::closure::js_closure_get_capture_f64(closure, 0)
}

fn define_ordered_getter(owner: f64, name: &str, answer: f64, digit: u32) {
    let scope = RuntimeHandleScope::new();
    let owner = scope.root_nanbox_f64(owner);
    let answer = scope.root_nanbox_f64(answer);
    let getter = scope.root_raw_mut_ptr(crate::closure::js_closure_alloc(
        ordered_getter as *const u8,
        2,
    ));
    getter.with_mut_ptr(|getter| {
        crate::closure::js_closure_set_capture_f64(getter, 0, answer.get_nanbox_f64());
        crate::closure::js_closure_set_capture_f64(getter, 1, digit as f64);
    });
    let descriptor = scope.root_raw_mut_ptr(crate::object::js_object_alloc(0, 0));
    descriptor.with_mut_ptr(|descriptor| {
        getter.with_const_ptr::<crate::closure::ClosureHeader, _>(|getter| {
            crate::intl::set_field(descriptor, "get", js_nanbox_pointer(getter as i64));
        });
    });
    let key = scope.root_nanbox_f64(string(name));
    descriptor.with_const_ptr::<ObjectHeader, _>(|descriptor| {
        crate::object::js_object_define_property(
            owner.get_nanbox_f64(),
            key.get_nanbox_f64(),
            js_nanbox_pointer(descriptor as i64),
        )
    });
}

#[test]
fn generic_result_reads_done_before_value_and_segment_getters() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let scope = RuntimeHandleScope::new();
    COUNTS.with(|counts| counts.set([0; 3]));
    GET_ORDER.with(|order| order.set(0));
    let current = scope.root_nanbox_f64(open("abc"));
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "a"
    );
    let iterator = scope.root_nanbox_f64(js_segments_project_iterator(current.get_nanbox_f64()));
    let record = scope.root_nanbox_f64(js_nanbox_pointer(
        crate::object::js_object_alloc(0, 0) as i64
    ));
    define_ordered_getter(record.get_nanbox_f64(), "segment", string("custom"), 3);
    let result = scope.root_nanbox_f64(js_nanbox_pointer(
        crate::object::js_object_alloc(0, 0) as i64
    ));
    define_ordered_getter(
        result.get_nanbox_f64(),
        "done",
        f64::from_bits(crate::value::TAG_FALSE),
        1,
    );
    define_ordered_getter(result.get_nanbox_f64(), "value", record.get_nanbox_f64(), 2);
    let replacement = scope.root_raw_mut_ptr(crate::closure::js_closure_alloc(
        captured_result as *const u8,
        1,
    ));
    replacement.with_mut_ptr(|replacement| {
        crate::closure::js_closure_set_capture_f64(replacement, 0, result.get_nanbox_f64());
    });
    replacement.with_const_ptr::<crate::closure::ClosureHeader, _>(|replacement| {
        crate::intl::set_field(
            js_nanbox_get_pointer(iterator.get_nanbox_f64()) as *mut ObjectHeader,
            "next",
            js_nanbox_pointer(replacement as i64),
        );
    });
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(
        GET_ORDER.with(|order| order.get()),
        1,
        "next reads only done"
    );
    assert_eq!(COUNTS.with(|counts| counts.get()), [1, 1, 1]);
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "custom"
    );
    assert_eq!(GET_ORDER.with(|order| order.get()), 123);
    assert_eq!(
        js_segments_project_iterator(current.get_nanbox_f64()).to_bits(),
        iterator.get_nanbox_u64()
    );
    // Nullish values keep the generic read's TypeError, rather than becoming
    // a missing property. These calls use the normal Rust-owned JS catcher.
    for nullish in [crate::value::TAG_NULL, TAG_UNDEFINED] {
        assert!(crate::exception::js_call_catching(|| property(
            f64::from_bits(nullish),
            b"segment"
        ))
        .is_err());
    }
}

extern "C" fn observing_next(_closure: *const crate::closure::ClosureHeader) -> f64 {
    unsafe {
        let iterator = crate::object::js_implicit_this_get();
        let object = js_nanbox_get_pointer(iterator) as *mut ObjectHeader;
        let backing = js_nanbox_get_pointer(f64::from_bits(slot(object, 0).bits()))
            as *const crate::array::ArrayHeader;
        assert!(
            !backing.is_null(),
            "materialize before the replacement observes this"
        );
        OBSERVED.with(|seen| {
            seen.set((
                crate::array::js_array_length(backing) as usize,
                number(object, 1),
            ))
        });
        assert!(
            slot(object, 3).is_undefined(),
            "the private association must be gone before observation"
        );
        crate::array::dispatch_array_iterator_method_builtin(object, "next")
    }
}

#[test]
fn next_mutation_after_first_body_restores_same_iterator_and_consumed_ordinal() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let scope = RuntimeHandleScope::new();
    COUNTS.with(|counts| counts.set([0; 3]));
    let current = scope.root_nanbox_f64(open("abc"));
    let original_iterator =
        scope.root_nanbox_f64(js_segments_project_iterator(current.get_nanbox_f64()));
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "a"
    );
    let proto = scope.root_raw_mut_ptr(
        crate::object::iterator_prototypes::ARRAY_ITERATOR_PROTOTYPE_PTR.load(Ordering::Acquire)
            as *mut ObjectHeader,
    );
    let canonical = scope.root_nanbox_u64(
        proto.with_const_ptr::<ObjectHeader, _>(|proto| own_data(proto, b"next").unwrap().bits()),
    );
    let replacement = scope.root_nanbox_f64(js_nanbox_pointer(crate::closure::js_closure_alloc(
        observing_next as *const u8,
        0,
    ) as i64));
    // This is the user-body mutation after the first projected value.
    proto.with_mut_ptr(|proto| crate::intl::set_field(proto, "next", replacement.get_nanbox_f64()));
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(OBSERVED.with(|seen| seen.get()), (3, 1));
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "b"
    );
    assert_eq!(
        js_segments_project_iterator(current.get_nanbox_f64()).to_bits(),
        original_iterator.get_nanbox_u64()
    );
    proto.with_mut_ptr(|proto| crate::intl::set_field(proto, "next", canonical.get_nanbox_f64()));
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "c"
    );
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 0.0);
    assert_eq!(
        COUNTS.with(|counts| counts.get()),
        [1, 1, 1],
        "restoring next must not reopen projection"
    );
}

#[test]
fn cursor_edges_move_and_materialized_backing_survives_full_collection() {
    let _guard = crate::gc::CopyingNurseryTestGuard::new(0);
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    crate::gc::register_runtime_handle_root_scanner_for_tests();
    // The isolation guard deliberately clears automatic root registration.
    // Restore the existing holders the real constructor/iterator touches.
    crate::gc::gc_register_mutable_root_scanner(crate::object::scan_object_cache_roots_mut);
    crate::gc::gc_register_mutable_root_scanner(
        crate::intl::segmenter::scan_segment_record_keys_roots_mut,
    );
    crate::gc::gc_register_mutable_root_scanner(crate::symbol::scan_symbol_side_table_roots_mut);
    crate::gc::gc_register_mutable_root_scanner(
        crate::object::scan_builtin_closure_metadata_roots_mut,
    );
    let scope = RuntimeHandleScope::new();
    let current = scope.root_nanbox_f64(open("ééa"));
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "é"
    );
    let before = unsafe {
        let object = cursor(current.get_nanbox_f64());
        [
            object as usize,
            (slot(object, INPUT).bits() & crate::value::POINTER_MASK) as usize,
            js_nanbox_get_pointer(f64::from_bits(slot(object, ITERATOR).bits())) as usize,
        ]
    };
    let cycles = crate::gc::copying_minor_cycles();
    crate::gc::gc_collect_minor();
    assert!(
        crate::gc::copying_minor_cycles() > cycles,
        "the collection must actually be a copying minor"
    );
    let after = unsafe {
        let object = cursor(current.get_nanbox_f64());
        [
            object as usize,
            (slot(object, INPUT).bits() & crate::value::POINTER_MASK) as usize,
            js_nanbox_get_pointer(f64::from_bits(slot(object, ITERATOR).bits())) as usize,
        ]
    };
    for index in 0..before.len() {
        assert_ne!(
            before[index], after[index],
            "cursor/input/iterator edge {index} did not move"
        );
    }
    // Close observation restores the same moved iterator at ordinal one.
    assert_eq!(
        js_segments_project_observe_iterator(current.get_nanbox_f64()).to_bits(),
        js_segments_project_iterator(current.get_nanbox_f64()).to_bits()
    );
    crate::gc::js_gc_collect();
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "é"
    );
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 1.0);
    assert_eq!(
        text(js_segments_project_segment(current.get_nanbox_f64())),
        "a"
    );
    assert_eq!(js_segments_project_next(current.get_nanbox_f64()), 0.0);
}
