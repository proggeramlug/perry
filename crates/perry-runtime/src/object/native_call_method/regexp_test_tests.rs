use super::regexp_test::{FAST_RETURNS, FORCE_DECLINE, GENERIC_VECTORS};
use crate::gc::RuntimeHandleScope;
use crate::object::exotic_expando::{self, ExoticKind};
use crate::object::regex_proto_thunks;
use crate::object::ObjectHeader;
use crate::value::{js_nanbox_pointer, JSValue, TAG_UNDEFINED};
use std::sync::atomic::Ordering;

fn string(text: &str) -> f64 {
    crate::value::js_nanbox_string(crate::string::js_string_from_bytes(
        text.as_ptr(),
        text.len() as u32,
    ) as i64)
}

// Same rooting order as intl::rooted_fields::set_field, using the public
// object setter because the Intl convenience helper is private to Intl.
fn set_field(object: *mut ObjectHeader, key: &str, value: f64) {
    let scope = RuntimeHandleScope::new();
    let object = scope.root_raw_mut_ptr(object);
    let value = scope.root_nanbox_f64(value);
    let key = scope.root_string_ptr(crate::string::js_string_from_bytes(
        key.as_ptr(),
        key.len() as u32,
    ));
    object.with_mut_ptr(|object| {
        key.with_const_ptr(|key| {
            crate::object::js_object_set_field_by_name(object, key, value.get_nanbox_f64())
        })
    });
}

fn install() {
    // Full real installation appends compile/toString and ordinary Object
    // methods after the canonical test site is recorded.
    crate::object::js_get_global_this();
    assert_ne!(
        regex_proto_thunks::REGEXP_PROTOTYPE_PTR.load(Ordering::Acquire),
        0
    );
}

fn regexp(flags: &str) -> f64 {
    let re = crate::regex::test_construct_regexp_and_exec_once("a", flags);
    crate::regex::js_regexp_set_last_index(re, 0.0);
    js_nanbox_pointer(re as i64)
}

unsafe fn call(receiver: f64, args: &[f64]) -> f64 {
    super::js_native_call_method(
        receiver,
        b"test".as_ptr().cast(),
        4,
        args.as_ptr(),
        args.len(),
    )
}

fn reset_counts() {
    FAST_RETURNS.with(|count| count.set(0));
    GENERIC_VECTORS.with(|count| count.set(0));
}
fn counts() -> (u64, u64) {
    (
        FAST_RETURNS.with(|count| count.get()),
        GENERIC_VECTORS.with(|count| count.get()),
    )
}

struct ForceDecline(bool);
impl ForceDecline {
    fn new() -> Self {
        Self(FORCE_DECLINE.with(|flag| flag.replace(true)))
    }
}
impl Drop for ForceDecline {
    fn drop(&mut self) {
        FORCE_DECLINE.with(|flag| flag.set(self.0));
    }
}

#[test]
fn real_installation_admits_and_forced_decline_reenters_generic_vectors() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    install();
    let scope = RuntimeHandleScope::new();
    let subject = scope.root_nanbox_f64(string("aaaaaaaa"));
    for flags in ["", "g", "y"] {
        let receiver = scope.root_nanbox_f64(regexp(flags));
        assert!(regex_proto_thunks::regexp_prototype_test_is_canonical(
            receiver.get_nanbox_f64()
        ));
        let mut fast = Vec::new();
        reset_counts();
        for _ in 0..16 {
            fast.push(
                unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) }.to_bits(),
            );
        }
        assert_eq!(
            counts(),
            (16, 0),
            "actual early returns must skip generic vector setup"
        );
        crate::regex::js_regexp_set_last_index(
            crate::value::js_nanbox_get_pointer(receiver.get_nanbox_f64()) as *mut _,
            0.0,
        );
        let control = {
            let _decline = ForceDecline::new();
            reset_counts();
            (0..16)
                .map(|_| {
                    unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) }
                        .to_bits()
                })
                .collect::<Vec<_>>()
        };
        assert_eq!(control, fast, "same engine and lastIndex progression");
        assert_eq!(
            counts(),
            (0, 16),
            "disabling only admission must activate the actual generic route"
        );
    }
}

#[test]
fn ignored_extra_arguments_admit_but_other_representations_decline() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    install();
    let scope = RuntimeHandleScope::new();
    let receiver = scope.root_nanbox_f64(regexp(""));
    let subject = scope.root_nanbox_f64(string("a"));
    reset_counts();
    assert_eq!(
        unsafe {
            call(
                receiver.get_nanbox_f64(),
                &[
                    subject.get_nanbox_f64(),
                    17.0,
                    f64::from_bits(TAG_UNDEFINED),
                ],
            )
        }
        .to_bits(),
        crate::value::TAG_TRUE
    );
    assert_eq!(counts(), (1, 0));
    let short = JSValue::try_short_string(b"a").unwrap();
    assert!(short.is_short_string());
    for args in [vec![f64::from_bits(short.bits())], vec![17.0], Vec::new()] {
        reset_counts();
        let actual = unsafe { call(receiver.get_nanbox_f64(), &args) }.to_bits();
        assert_eq!(counts(), (0, 1));
        let _decline = ForceDecline::new();
        assert_eq!(
            unsafe { call(receiver.get_nanbox_f64(), &args) }.to_bits(),
            actual
        );
    }
    let object = scope.root_nanbox_f64(js_nanbox_pointer(
        crate::object::js_object_alloc(0, 0) as i64
    ));
    reset_counts();
    // This ordinary object has no `test` method. Its generic call must throw;
    // catch that JS exception so the native test harness can inspect the route.
    let outcome = crate::exception::catch_js_throw(|| unsafe {
        call(object.get_nanbox_f64(), &[subject.get_nanbox_f64()])
    });
    assert!(outcome.is_err(), "missing ordinary method must throw");
    assert_eq!(
        counts(),
        (0, 1),
        "non-RegExp receiver must keep generic dispatch"
    );
}

thread_local! {
    static GETTERS: std::cell::Cell<u32> = const { std::cell::Cell::new(0) };
    static MOVING: std::cell::Cell<(u64, u64, u32)> = const { std::cell::Cell::new((0, 0, 0)) };
}
extern "C" fn false_method(_closure: *const crate::closure::ClosureHeader, _arg: f64) -> f64 {
    f64::from_bits(crate::value::TAG_FALSE)
}
extern "C" fn own_getter(closure: *const crate::closure::ClosureHeader) -> f64 {
    GETTERS.with(|count| count.set(count.get() + 1));
    crate::closure::js_closure_get_capture_f64(closure, 0)
}

#[test]
fn own_undefined_method_and_accessors_decline_without_admission_callbacks() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    install();
    let scope = RuntimeHandleScope::new();
    let receiver = scope.root_nanbox_f64(regexp(""));
    let subject = scope.root_nanbox_f64(string("a"));
    let method = scope.root_nanbox_f64(js_nanbox_pointer(crate::closure::js_closure_alloc(
        false_method as *const u8,
        0,
    ) as i64));
    for value in [f64::from_bits(TAG_UNDEFINED), method.get_nanbox_f64()] {
        let addr = crate::value::js_nanbox_get_pointer(receiver.get_nanbox_f64()) as usize;
        assert!(unsafe {
            exotic_expando::exotic_set_property(
                addr,
                ExoticKind::RegExp,
                "test",
                value,
                receiver.get_nanbox_f64(),
            )
        });
        assert!(exotic_expando::exotic_has_own_property(
            ExoticKind::RegExp,
            addr,
            "test"
        ));
        assert!(unsafe {
            super::regexp_test::try_dispatch(receiver.get_nanbox_f64(), subject.get_nanbox_f64())
        }
        .is_none());
        reset_counts();
        let actual =
            unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) }.to_bits();
        assert_eq!(counts(), (0, 1));
        let _decline = ForceDecline::new();
        assert_eq!(
            unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) }.to_bits(),
            actual
        );
        if value.to_bits() == method.get_nanbox_u64() {
            assert_eq!(actual, crate::value::TAG_FALSE);
        }
        assert!(exotic_expando::value_remove(
            ExoticKind::RegExp,
            addr,
            "test"
        ));
    }
    let getter =
        scope.root_raw_mut_ptr(crate::closure::js_closure_alloc(own_getter as *const u8, 1));
    getter.with_mut_ptr(|getter| {
        crate::closure::js_closure_set_capture_f64(getter, 0, method.get_nanbox_f64())
    });
    let addr = crate::value::js_nanbox_get_pointer(receiver.get_nanbox_f64()) as usize;
    crate::object::set_accessor_descriptor(
        addr,
        "test".to_owned(),
        crate::object::AccessorDescriptor {
            get: getter.with_const_ptr::<crate::closure::ClosureHeader, _>(|getter| {
                JSValue::pointer(getter.cast()).bits()
            }),
            set: 0,
        },
    );
    GETTERS.with(|count| count.set(0));
    assert!(unsafe {
        super::regexp_test::try_dispatch(receiver.get_nanbox_f64(), subject.get_nanbox_f64())
    }
    .is_none());
    assert_eq!(
        GETTERS.with(|count| count.get()),
        0,
        "admission must not invoke a getter"
    );
    reset_counts();
    assert_eq!(
        unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) }.to_bits(),
        crate::value::TAG_FALSE
    );
    assert_eq!(counts(), (0, 1));
    assert!(GETTERS.with(|count| count.get()) > 0);
    crate::object::set_accessor_descriptor(
        addr,
        "test".to_owned(),
        crate::object::AccessorDescriptor {
            get: 0,
            set: method.get_nanbox_u64(),
        },
    );
    assert!(
        unsafe {
            super::regexp_test::try_dispatch(receiver.get_nanbox_f64(), subject.get_nanbox_f64())
        }
        .is_none(),
        "setter-only own property is still present"
    );
    crate::object::clear_accessor_descriptor(addr, "test");
    // Each proof-negative assertion begins with live positive admission.
    assert!(regex_proto_thunks::regexp_prototype_test_is_canonical(
        receiver.get_nanbox_f64()
    ));
    let other = scope.root_nanbox_f64(regexp(""));
    assert!(regex_proto_thunks::regexp_prototype_test_is_canonical(
        other.get_nanbox_f64()
    ));
    crate::object::prototype_chain::object_set_user_prototype(
        crate::value::js_nanbox_get_pointer(other.get_nanbox_f64()) as usize,
        crate::value::TAG_NULL,
    );
    assert!(!regex_proto_thunks::regexp_prototype_test_is_canonical(
        other.get_nanbox_f64()
    ));
    let proto = regex_proto_thunks::REGEXP_PROTOTYPE_PTR.load(Ordering::Acquire) as usize;
    crate::object::set_accessor_descriptor(
        proto,
        "test".to_owned(),
        crate::object::AccessorDescriptor {
            get: 0,
            set: method.get_nanbox_u64(),
        },
    );
    assert!(
        !regex_proto_thunks::regexp_prototype_test_is_canonical(receiver.get_nanbox_f64()),
        "prototype accessor must decline even with unchanged canonical data"
    );
    crate::object::clear_accessor_descriptor(proto, "test");
}

#[test]
fn prototype_replacement_key_relocation_and_deletion_decline() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    install();
    let scope = RuntimeHandleScope::new();
    let receiver = scope.root_nanbox_f64(regexp(""));
    assert!(regex_proto_thunks::regexp_prototype_test_is_canonical(
        receiver.get_nanbox_f64()
    ));
    let proto = scope.root_raw_mut_ptr(
        regex_proto_thunks::REGEXP_PROTOTYPE_PTR.load(Ordering::Acquire) as *mut ObjectHeader,
    );
    let canonical = scope
        .root_nanbox_u64(regex_proto_thunks::REGEXP_PROTOTYPE_TEST_CLOSURE.load(Ordering::Acquire));
    let replacement = scope.root_nanbox_f64(js_nanbox_pointer(crate::closure::js_closure_alloc(
        false_method as *const u8,
        0,
    ) as i64));
    proto.with_mut_ptr(|proto| set_field(proto, "test", replacement.get_nanbox_f64()));
    assert!(!regex_proto_thunks::regexp_prototype_test_is_canonical(
        receiver.get_nanbox_f64()
    ));
    proto.with_mut_ptr(|proto| set_field(proto, "test", canonical.get_nanbox_f64()));
    assert!(regex_proto_thunks::regexp_prototype_test_is_canonical(
        receiver.get_nanbox_f64()
    ));
    let keys = scope.root_raw_mut_ptr(proto.with_const_ptr::<ObjectHeader, _>(|proto| unsafe {
        crate::object::object_keys_array(proto)
    }));
    let count = keys
        .with_const_ptr::<crate::array::ArrayHeader, _>(|keys| crate::array::js_array_length(keys));
    let changed = scope.root_raw_mut_ptr(crate::array::js_array_alloc_with_length(count));
    let renamed = scope.root_nanbox_f64(string("not_test"));
    let mut test_index = None;
    for index in 0..count {
        let key = keys.with_const_ptr::<crate::array::ArrayHeader, _>(|keys| {
            crate::array::js_array_get(keys, index)
        });
        let is_test = unsafe { crate::string::js_string_key_matches_bytes(key, b"test") };
        if is_test {
            test_index = Some(index);
        }
        changed.with_mut_ptr(|changed| {
            crate::array::js_array_set_f64(
                changed,
                index,
                if is_test {
                    renamed.get_nanbox_f64()
                } else {
                    f64::from_bits(key.bits())
                },
            )
        });
    }
    let index = test_index.expect("real installed prototype has test key");
    let before_shape = proto.with_const_ptr::<ObjectHeader, _>(|proto| unsafe {
        crate::object::shapes::object_shape_stamp(proto)
    });
    proto.with_mut_ptr(|proto| {
        changed.with_mut_ptr(|changed| crate::object::js_object_set_keys(proto, changed))
    });
    let after_shape = proto.with_const_ptr::<ObjectHeader, _>(|proto| unsafe {
        crate::object::shapes::object_shape_stamp(proto)
    });
    assert_ne!(before_shape, after_shape);
    assert_eq!(
        proto.with_const_ptr::<ObjectHeader, _>(|proto| crate::object::js_object_get_field(
            proto, index
        )
        .bits()),
        canonical.get_nanbox_u64(),
        "old value-only proof would admit this renamed key"
    );
    assert!(!regex_proto_thunks::regexp_prototype_test_is_canonical(
        receiver.get_nanbox_f64()
    ));
    proto.with_mut_ptr(|proto| {
        keys.with_mut_ptr(|keys| crate::object::js_object_set_keys(proto, keys))
    });
    assert!(regex_proto_thunks::regexp_prototype_test_is_canonical(
        receiver.get_nanbox_f64()
    ));
    let key = scope.root_string_ptr(crate::string::js_string_from_bytes(b"test".as_ptr(), 4));
    proto.with_mut_ptr(|proto| {
        key.with_const_ptr::<crate::StringHeader, _>(|key| {
            assert_eq!(
                crate::object::delete_rest::js_object_delete_field(proto, key),
                1
            );
        })
    });
    assert!(
        !regex_proto_thunks::regexp_prototype_test_is_canonical(receiver.get_nanbox_f64()),
        "deleting test must decline"
    );
    proto.with_mut_ptr(|proto| set_field(proto, "test", canonical.get_nanbox_f64()));
}

extern "C" fn collecting_value_of(_closure: *const crate::closure::ClosureHeader) -> f64 {
    let before = crate::gc::copying_minor_cycles();
    let depth = crate::object::call_method_depth_savepoint();
    crate::gc::gc_collect_minor();
    MOVING.with(|seen| seen.set((before, crate::gc::copying_minor_cycles(), depth)));
    0.0
}

#[test]
fn stateful_last_index_coercion_moves_receiver_and_subject_under_inner_roots() {
    let _guard = crate::gc::CopyingNurseryTestGuard::new(0);
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    crate::gc::register_runtime_handle_root_scanner_for_tests();
    crate::gc::gc_register_mutable_root_scanner(crate::object::scan_object_cache_roots_mut);
    crate::gc::gc_register_mutable_root_scanner(crate::symbol::scan_symbol_side_table_roots_mut);
    crate::gc::gc_register_mutable_root_scanner(
        crate::object::scan_builtin_closure_metadata_roots_mut,
    );
    install();
    let scope = RuntimeHandleScope::new();
    let receiver = scope.root_nanbox_f64(regexp("g"));
    let subject = scope.root_nanbox_f64(string(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    ));
    let value_of = scope.root_nanbox_f64(js_nanbox_pointer(crate::closure::js_closure_alloc(
        collecting_value_of as *const u8,
        0,
    ) as i64));
    let last_index = scope.root_raw_mut_ptr(crate::object::js_object_alloc(0, 0));
    last_index
        .with_mut_ptr(|last_index| set_field(last_index, "valueOf", value_of.get_nanbox_f64()));
    let re = crate::value::js_nanbox_get_pointer(receiver.get_nanbox_f64())
        as *mut crate::regex::RegExpHeader;
    last_index.with_const_ptr::<ObjectHeader, _>(|last_index| {
        crate::regex::js_regexp_set_last_index(re, js_nanbox_pointer(last_index as i64))
    });
    let before = (receiver.get_nanbox_u64(), subject.get_nanbox_u64());
    let depth_before = crate::object::call_method_depth_savepoint();
    reset_counts();
    assert_eq!(
        unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) }.to_bits(),
        crate::value::TAG_TRUE
    );
    assert_eq!(FAST_RETURNS.with(|count| count.get()), 1);
    let (cycles_before, cycles_after, depth_seen) = MOVING.with(|seen| seen.get());
    assert!(
        cycles_after > cycles_before,
        "lastIndex callback must run an actual copying minor"
    );
    assert!(
        depth_seen > depth_before,
        "early entry must retain the original recursion accounting"
    );
    assert_ne!(before.0, receiver.get_nanbox_u64(), "RegExp must move");
    assert_ne!(before.1, subject.get_nanbox_u64(), "subject must move");
    assert_eq!(
        crate::regex::js_regexp_get_last_index(crate::value::js_nanbox_get_pointer(
            receiver.get_nanbox_f64()
        ) as *const _),
        1.0
    );
    assert_eq!(crate::object::call_method_depth_savepoint(), depth_before);
    crate::gc::js_gc_collect();
    assert_eq!(
        unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) }.to_bits(),
        crate::value::TAG_TRUE
    );
}

#[test]
fn recursion_limit_keeps_existing_generic_null_object_result() {
    let _lock = crate::gc::global_side_table_test_lock();
    let _triggers = crate::gc::GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    install();
    let scope = RuntimeHandleScope::new();
    let receiver = scope.root_nanbox_f64(regexp("g"));
    let subject = scope.root_nanbox_f64(string("a"));
    assert!(regex_proto_thunks::regexp_prototype_test_is_canonical(
        receiver.get_nanbox_f64()
    ));
    let before = crate::object::call_method_depth_savepoint();
    // Derive the existing limit by entering its own guard until it declines.
    let mut guards = Vec::new();
    while let Some(guard) = super::CallMethodDepthGuard::enter("test") {
        guards.push(guard);
    }
    reset_counts();
    let result = unsafe { call(receiver.get_nanbox_f64(), &[subject.get_nanbox_f64()]) };
    assert_eq!(counts(), (0, 1));
    let expected = &super::NULL_OBJECT_BYTES as *const super::NullObjectBytes as *const u8;
    assert_eq!(result.to_bits(), JSValue::pointer(expected).bits());
    while guards.pop().is_some() {}
    assert_eq!(crate::object::call_method_depth_savepoint(), before);
}
