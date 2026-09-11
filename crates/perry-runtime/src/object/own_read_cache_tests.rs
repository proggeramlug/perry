use super::*;
use crate::gc::{RuntimeHandle, RuntimeHandleScope};

fn reset() {
    OWN_READ_CACHE.with(|table| {
        for bucket in table {
            for entry in bucket {
                entry.set((0, 0, 0));
            }
        }
    });
    HITS.with(|hits| hits.set(0));
}

fn fixture<'a>(
    scope: &'a RuntimeHandleScope,
    class: u32,
    name: &[u8],
    descriptor: bool,
) -> (RuntimeHandle<'a>, RuntimeHandle<'a>) {
    let obj = scope.root_raw_mut_ptr(crate::object::js_object_alloc(class, 0));
    let key = scope.root_raw_const_ptr(crate::string::js_string_from_bytes(
        name.as_ptr(),
        name.len() as u32,
    ));
    crate::object::js_object_set_field_by_name(
        obj.get_raw_mut_ptr(),
        key.get_raw_const_ptr(),
        71.0,
    );
    if descriptor {
        crate::object::set_property_attrs(
            obj.get_raw_mut_ptr::<ObjectHeader>() as usize,
            std::str::from_utf8(name).unwrap().to_owned(),
            crate::object::PropertyAttrs::new(true, true, true),
        );
    }
    (obj, key)
}

fn read(obj: &RuntimeHandle<'_>, key: &RuntimeHandle<'_>) -> crate::JSValue {
    crate::object::js_object_get_field_by_name(obj.get_raw_const_ptr(), key.get_raw_const_ptr())
}

#[test]
fn ordinary_and_descriptor_data_reads_use_the_early_cache() {
    let _lock = crate::gc::global_side_table_test_lock();
    for (class, descriptor) in [(0, false), (0, true), (4242, true)] {
        reset();
        let scope = RuntimeHandleScope::new();
        let (obj, key) = fixture(&scope, class, b"field", descriptor);
        assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
        assert_eq!(HITS.with(|hits| hits.get()), 0);
        assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
        assert_eq!(
            HITS.with(|hits| hits.get()),
            1,
            "the actual getter must use the learned entry"
        );
        crate::object::js_object_set_field_by_name(
            obj.get_raw_mut_ptr(),
            key.get_raw_const_ptr(),
            82.0,
        );
        assert_eq!(
            read(&obj, &key).bits(),
            82.0_f64.to_bits(),
            "cache stores slots, not values"
        );
    }
}

#[test]
fn accessor_install_revokes_a_learned_slot_and_the_check_detects_sabotage() {
    let _lock = crate::gc::global_side_table_test_lock();
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, key) = fixture(&scope, 0, b"field", true);
    assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
    let key_bits = crate::JSValue::try_short_string(b"field").unwrap().bits();
    let old_slot = unsafe { probe(obj.get_raw_const_ptr(), key_bits).unwrap() };
    let old_identity = unsafe { identity(obj.get_raw_const_ptr()).unwrap() };
    crate::object::set_accessor_descriptor(
        obj.get_raw_mut_ptr::<ObjectHeader>() as usize,
        "field".to_owned(),
        crate::object::AccessorDescriptor::default(),
    );
    let current = unsafe { identity(obj.get_raw_const_ptr()).unwrap() };
    assert_ne!(old_identity, current);
    assert!(
        read(&obj, &key).is_undefined(),
        "getterless accessor must replace the data result"
    );
    assert_eq!(HITS.with(|hits| hits.get()), 0);
    // Sabotage the semantic-generation fence by relabeling the old proof as
    // current. The real getter must now produce the wrong old data result,
    // demonstrating that the accessor assertion above is load-bearing.
    OWN_READ_CACHE
        .with(|table| table[bucket(current, key_bits)][0].set((current, key_bits, old_slot)));
    let sabotaged = read(&obj, &key);
    assert!(!sabotaged.is_undefined());
    assert_eq!(sabotaged.bits(), 71.0_f64.to_bits());
    assert_eq!(HITS.with(|hits| hits.get()), 1);
    reset();
}

#[test]
fn exact_receiver_class_is_part_of_the_proof() {
    let _lock = crate::gc::global_side_table_test_lock();
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, key) = fixture(&scope, 0, b"field", true);
    assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
    let bits = crate::JSValue::try_short_string(b"field").unwrap().bits();
    unsafe {
        assert!(probe(obj.get_raw_const_ptr(), bits).is_some());
        let shape = crate::object::shapes::object_shape_stamp(obj.get_raw_const_ptr());
        (*obj.get_raw_mut_ptr::<ObjectHeader>()).class_id = 4242;
        assert_eq!(
            crate::object::shapes::object_shape_stamp(obj.get_raw_const_ptr()),
            shape
        );
        assert!(
            probe(obj.get_raw_const_ptr(), bits).is_none(),
            "shared shape does not mean shared receiver semantics"
        );
        (*obj.get_raw_mut_ptr::<ObjectHeader>()).class_id = 0;
    }
}

#[test]
fn learned_entries_are_not_visible_to_the_direct_sso_consumer() {
    let _lock = crate::gc::global_side_table_test_lock();
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, key) = fixture(&scope, 0, b"field", true);
    assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
    let bits = crate::JSValue::try_short_string(b"field").unwrap().bits();
    unsafe {
        assert!(probe(obj.get_raw_const_ptr(), bits).is_some());
        assert!(
            crate::object::read_stub::try_read_by_content_bits(obj.get_raw_const_ptr(), bits)
                .is_none()
        );
    }
}

#[test]
fn elements_attached_after_learning_still_precede_the_cache() {
    let _lock = crate::gc::global_side_table_test_lock();
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, key) = fixture(&scope, 0, b"0", true);
    assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
    let bits = crate::JSValue::try_short_string(b"0").unwrap().bits();
    let shape = unsafe { crate::object::shapes::object_shape_stamp(obj.get_raw_const_ptr()) };
    unsafe {
        crate::array::subclass_elements::install_elements(obj.get_raw_mut_ptr(), 1);
        let elements = crate::array::subclass_elements::elements_of(obj.get_raw_const_ptr());
        assert!(!elements.is_null());
        crate::array::js_array_set_f64(elements, 0, 99.0);
        assert_eq!(
            crate::object::shapes::object_shape_stamp(obj.get_raw_const_ptr()),
            shape
        );
        assert!(
            probe(obj.get_raw_const_ptr(), bits).is_some(),
            "the old entry must still exist for this ordering test"
        );
    }
    assert_eq!(read(&obj, &key).bits(), 99.0_f64.to_bits());
    assert_eq!(HITS.with(|hits| hits.get()), 0);
    assert_eq!(
        crate::typed_feedback::js_typed_feedback_object_get_field_by_value_f64(
            0,
            obj.get_raw_const_ptr(),
            f64::from_bits(bits)
        )
        .to_bits(),
        99.0_f64.to_bits()
    );
}

#[test]
fn long_keys_keep_the_ordinary_path() {
    let _lock = crate::gc::global_side_table_test_lock();
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, key) = fixture(&scope, 0, b"long_field", true);
    for _ in 0..3 {
        assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
    }
    assert_eq!(HITS.with(|hits| hits.get()), 0);
}

#[test]
fn current_overflow_values_survive_shape_growth() {
    let _lock = crate::gc::global_side_table_test_lock();
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, _) = fixture(&scope, 0, b"first", true);
    for i in 0..24 {
        let name = format!("k{i}");
        let key = crate::string::js_string_from_bytes(name.as_ptr(), name.len() as u32);
        crate::object::js_object_set_field_by_name(obj.get_raw_mut_ptr(), key, i as f64);
    }
    let key = scope.root_raw_const_ptr(crate::string::js_string_from_bytes(b"k23".as_ptr(), 3));
    assert_eq!(read(&obj, &key).bits(), 23.0_f64.to_bits());
    assert_eq!(read(&obj, &key).bits(), 23.0_f64.to_bits());
    assert!(HITS.with(|hits| hits.get()) > 0);
    let extra = crate::string::js_string_from_bytes(b"extra".as_ptr(), 5);
    crate::object::js_object_set_field_by_name(obj.get_raw_mut_ptr(), extra, 45.0);
    crate::object::js_object_set_field_by_name(
        obj.get_raw_mut_ptr(),
        key.get_raw_const_ptr(),
        81.0,
    );
    assert_eq!(read(&obj, &key).bits(), 81.0_f64.to_bits());
}

#[test]
fn class_kind_tail_results_are_not_learned() {
    let _lock = crate::gc::global_side_table_test_lock();
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, key) = fixture(&scope, 4243, b"field", true);
    assert_eq!(read(&obj, &key).bits(), 71.0_f64.to_bits());
    let bits = crate::JSValue::try_short_string(b"field").unwrap().bits();
    unsafe {
        assert!(probe(obj.get_raw_const_ptr(), bits).is_some());
    }
    crate::object::js_object_mark_class(obj.get_raw_mut_ptr::<ObjectHeader>() as i64);
    unsafe {
        assert!(
            probe(obj.get_raw_const_ptr(), bits).is_none(),
            "kind transition must revoke ordinary proofs"
        );
        // Exercise the exact priming API used by the class-kind tail too.
        prime(obj.get_raw_const_ptr(), b"field", 0, None);
        assert!(
            probe(obj.get_raw_const_ptr(), bits).is_none(),
            "intermediate class-kind tail results are not final reads"
        );
    }
}

#[test]
fn stable_hole_misses_and_readdition_reads_the_new_slot() {
    let _lock = crate::gc::global_side_table_test_lock();
    struct Restore;
    impl Drop for Restore {
        fn drop(&mut self) {
            crate::object::delete_rest::test_set_tombstone_deletes(None);
        }
    }
    crate::object::delete_rest::test_set_tombstone_deletes(Some(true));
    let _restore = Restore;
    reset();
    let scope = RuntimeHandleScope::new();
    let (obj, _) = fixture(&scope, 0, b"first", false);
    for i in 0..20 {
        let name = format!("k{i}");
        let key = crate::string::js_string_from_bytes(name.as_ptr(), name.len() as u32);
        crate::object::js_object_set_field_by_name(obj.get_raw_mut_ptr(), key, i as f64);
    }
    let first = crate::string::js_string_from_bytes(b"k11".as_ptr(), 3);
    assert_eq!(
        crate::object::js_object_delete_field(obj.get_raw_mut_ptr(), first),
        1
    );
    let key = scope.root_raw_const_ptr(crate::string::js_string_from_bytes(b"k3".as_ptr(), 2));
    assert_eq!(read(&obj, &key).bits(), 3.0_f64.to_bits());
    assert_eq!(read(&obj, &key).bits(), 3.0_f64.to_bits());
    assert!(HITS.with(|hits| hits.get()) > 0);
    let shape = unsafe { crate::object::shapes::object_shape_stamp(obj.get_raw_const_ptr()) };
    let bits = crate::JSValue::try_short_string(b"k3").unwrap().bits();
    let old_slot = unsafe { probe(obj.get_raw_const_ptr(), bits).unwrap() };
    assert_eq!(
        crate::object::js_object_delete_field(obj.get_raw_mut_ptr(), key.get_raw_const_ptr()),
        1
    );
    unsafe {
        assert_eq!(
            crate::object::shapes::object_shape_stamp(obj.get_raw_const_ptr()),
            shape
        );
        assert_eq!(probe(obj.get_raw_const_ptr(), bits), Some(old_slot));
        assert!(crate::object::read_stub::read_slot_by_tag(
            obj.get_raw_const_ptr(),
            obj.get_raw_const_ptr::<ObjectHeader>() as usize,
            old_slot
        )
        .is_none());
    }
    let hits = HITS.with(|hits| hits.get());
    assert!(read(&obj, &key).is_undefined());
    assert_eq!(HITS.with(|hits| hits.get()), hits);
    crate::object::js_object_set_field_by_name(
        obj.get_raw_mut_ptr(),
        key.get_raw_const_ptr(),
        93.0,
    );
    assert_eq!(read(&obj, &key).bits(), 93.0_f64.to_bits());
    assert_eq!(read(&obj, &key).bits(), 93.0_f64.to_bits());
}
