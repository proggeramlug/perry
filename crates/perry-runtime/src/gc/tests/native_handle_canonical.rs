//! Runtime-linked substrate fixtures; no production timer publisher is active.
use super::super::*;
use super::support::*;
use crate::native_handle::canonical::{self, PublicationError};
use crate::object::handle_expando::{handle_expando_get, handle_expando_set};
use perry_native_registration::{
    NativeLeaseKind, NativeQuarantine, NativeRegistrationIdentity, NativeRegistrationKind,
    NativeRegistrationRegistry,
};
use std::sync::{Arc, Barrier};
use std::time::Instant;

fn timer_type() -> u64 {
    crate::native_handle::js_native_handle_type_id(b"Timer".as_ptr(), 5) as u64
}

fn registry() -> (NativeRegistrationRegistry, NativeRegistrationIdentity) {
    // Each local registry owns a separate timer domain with the same numeric id.
    let registry = NativeRegistrationRegistry::new(1, 2, 4);
    let identity = registry
        .begin_registration(NativeRegistrationKind::Reserved)
        .unwrap();
    assert!(registry.publish(identity));
    (registry, identity)
}

fn retire(registry: &NativeRegistrationRegistry, identity: NativeRegistrationIdentity) {
    assert!(registry.begin_retirement_of(identity));
    assert!(registry.finish_retirement(identity, NativeQuarantine::NextDrain));
}

fn publish(registry: &NativeRegistrationRegistry, identity: NativeRegistrationIdentity) -> f64 {
    let lease = registry
        .acquire(identity, NativeLeaseKind::Wrapper)
        .unwrap();
    unsafe { canonical::publish(registry.domain(), timer_type(), lease).unwrap() }
}

fn address(value: f64) -> usize {
    crate::value::JSValue::from_bits(value.to_bits()).as_pointer::<u8>() as usize
}

fn collect() {
    let before = gc_collection_count();
    gc_collect_full_mark_sweep_with_trigger(GcTriggerSnapshot::capture(GcTriggerKind::Direct));
    assert!(
        gc_collection_count() > before,
        "fixture must run a real full collection"
    );
}

fn register_roots() {
    register_runtime_handle_root_scanner_for_tests();
    gc_register_mutable_root_scanner(crate::object::handle_expando::scan_handle_expando_roots_mut);
}

#[test]
fn equal_ids_in_distinct_domains_keep_distinct_wrappers() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (a, ai) = registry();
    let (b, bi) = registry();
    assert_eq!(ai.numeric_id(), bi.numeric_id());
    let scope = RuntimeHandleScope::new();
    let av = scope.root_nanbox_f64(publish(&a, ai));
    let bv = scope.root_nanbox_f64(publish(&b, bi));
    assert_ne!(
        av.get_nanbox_u64(),
        bv.get_nanbox_u64(),
        "independent domains must not share a canonical wrapper"
    );
    assert_eq!(publish(&a, ai).to_bits(), av.get_nanbox_u64());
    assert_eq!(publish(&b, bi).to_bits(), bv.get_nanbox_u64());
    unsafe {
        assert_eq!(
            canonical::identity(av.get_nanbox_f64(), b.domain(), timer_type()),
            None,
            "wrong domain must reject representation recognition"
        );
        assert_eq!(
            canonical::identity(av.get_nanbox_f64(), a.domain(), timer_type() + 1),
            None,
            "wrong type must reject representation recognition"
        );
        assert_eq!(
            canonical::with_operation(av.get_nanbox_f64(), a.domain(), timer_type(), &b, |_| 7),
            None,
            "operation acquisition must use the exact authoritative registry"
        );
    }
    retire(&a, ai);
    retire(&b, bi);
    drop(scope);
    collect();
    assert_eq!(a.drain(Instant::now()), 1);
    assert_eq!(b.drain(Instant::now()), 1);
}

#[test]
fn publication_handoff_balances_wrapper_leases() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(publish(&registry, identity));
    for _ in 0..3 {
        assert_eq!(
            publish(&registry, identity).to_bits(),
            value.get_nanbox_u64()
        );
    }
    retire(&registry, identity);
    collect();
    assert_eq!(
        registry.drain(Instant::now()),
        0,
        "published cell must retain its wrapper lease"
    );
    drop(scope);
    collect();
    assert_eq!(
        registry.drain(Instant::now()),
        1,
        "cache hit must not retain an extra wrapper lease"
    );
    assert_eq!(
        canonical::indexed_address(identity),
        None,
        "collection must remove the weak entry"
    );
}

#[test]
fn rejected_publications_release_the_offered_ownership() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let other = NativeRegistrationRegistry::new(1, 2, 4);
    unsafe {
        let lease = registry
            .acquire(identity, NativeLeaseKind::Wrapper)
            .unwrap();
        assert_eq!(
            canonical::publish(other.domain(), timer_type(), lease),
            Err(PublicationError::WrongDomain),
            "publication must reject another domain"
        );
        let lease = registry
            .acquire(identity, NativeLeaseKind::Operation)
            .unwrap();
        assert_eq!(
            canonical::publish(registry.domain(), timer_type(), lease),
            Err(PublicationError::WrongLeaseKind),
            "publication must reject an operation lease"
        );
    }
    let scope = RuntimeHandleScope::new();
    let _value = scope.root_nanbox_f64(publish(&registry, identity));
    unsafe {
        let lease = registry
            .acquire(identity, NativeLeaseKind::Wrapper)
            .unwrap();
        assert_eq!(
            canonical::publish(registry.domain(), timer_type() + 1, lease),
            Err(PublicationError::ConflictingType),
            "publication must reject inconsistent runtime type"
        );
    }
    retire(&registry, identity);
    drop(scope);
    collect();
    assert_eq!(
        registry.drain(Instant::now()),
        1,
        "rejected publication must release offered ownership"
    );
}

#[test]
fn worker_retirement_preserves_retained_wrapper_identity() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(publish(&registry, identity));
    let addr = address(value.get_nanbox_f64());
    handle_expando_set(addr as i64, "owner", 73.0);
    let worker_registry = registry.clone();
    // The native worker carries no JS bits, address, callback, or TLS access.
    std::thread::spawn(move || retire(&worker_registry, identity))
        .join()
        .unwrap();
    collect();
    unsafe {
        assert_eq!(
            canonical::identity(value.get_nanbox_f64(), registry.domain(), timer_type()),
            Some(identity),
            "retirement must preserve retained wrapper identity"
        );
        assert_eq!(
            canonical::with_operation(
                value.get_nanbox_f64(),
                registry.domain(),
                timer_type(),
                &registry,
                |_| 7
            ),
            None,
            "retirement must prevent new operation acquisition"
        );
    }
    assert_eq!(
        handle_expando_get(addr as i64, "owner"),
        Some(73.0),
        "retirement must preserve retained owner state"
    );
    assert_eq!(canonical::indexed_address(identity), Some(addr));
    assert_eq!(registry.drain(Instant::now()), 0);
    drop(scope);
    collect();
    assert_eq!(
        handle_expando_get(addr as i64, "owner"),
        None,
        "collection must remove owner state"
    );
    assert_eq!(registry.drain(Instant::now()), 1);
}

#[test]
fn wrapper_and_operation_leases_release_independently() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(publish(&registry, identity));
    let bits = value.get_nanbox_f64();
    unsafe {
        assert_eq!(
            canonical::with_operation(bits, registry.domain(), timer_type(), &registry, |exact| {
                assert_eq!(exact, identity);
                retire(&registry, identity);
                drop(scope);
                collect();
                assert_eq!(
                    canonical::indexed_address(identity),
                    None,
                    "wrapper must collect during retained operation"
                );
                assert_eq!(
                    registry.drain(Instant::now()),
                    0,
                    "operation must hold registration after wrapper collection"
                );
                19
            }),
            Some(19)
        );
    }
    assert_eq!(
        registry.drain(Instant::now()),
        1,
        "operation completion must release its lease"
    );
}

#[test]
fn disposed_wrapper_still_runs_gc_cleanup_once() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(publish(&registry, identity));
    let bits = value.get_nanbox_f64();
    let addr = address(bits);
    handle_expando_set(addr as i64, "owner", 37.0);
    // Canonical resource metadata is native-owned. Explicit disposal marks the
    // JS surface; native retirement is separately performed by the registry.
    assert_eq!(crate::native_handle::js_native_handle_dispose(bits), 0);
    assert_eq!(crate::native_handle::js_native_handle_dispose(bits), 0);
    unsafe {
        assert_eq!(
            canonical::identity(bits, registry.domain(), timer_type()),
            Some(identity),
            "disposal must preserve representation identity"
        );
        assert_eq!(
            canonical::with_operation(bits, registry.domain(), timer_type(), &registry, |_| 7),
            None,
            "disposal must reject new operations"
        );
    }
    assert_eq!(
        handle_expando_get(addr as i64, "owner"),
        Some(37.0),
        "disposal must preserve owner state"
    );
    retire(&registry, identity);
    assert_eq!(
        registry.drain(Instant::now()),
        0,
        "disposal must not release the wrapper lease"
    );
    drop(scope);
    collect();
    assert_eq!(
        registry.drain(Instant::now()),
        1,
        "disposed wrapper must release its wrapper lease at collection"
    );
    assert_eq!(canonical::indexed_address(identity), None);
    assert_eq!(handle_expando_get(addr as i64, "owner"), None);
    collect();
    assert_eq!(
        registry.drain(Instant::now()),
        0,
        "cleanup must release exactly once"
    );
}

#[test]
fn publication_retirement_forced_orders() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let acquired = Arc::new(Barrier::new(2));
    let retired = Arc::new(Barrier::new(2));
    let worker_registry = registry.clone();
    let worker_acquired = acquired.clone();
    let worker_retired = retired.clone();
    let worker = std::thread::spawn(move || {
        worker_acquired.wait();
        retire(&worker_registry, identity);
        worker_retired.wait();
    });
    let lease = registry
        .acquire(identity, NativeLeaseKind::Wrapper)
        .unwrap();
    acquired.wait();
    retired.wait();
    worker.join().unwrap();
    assert!(
        registry
            .acquire(identity, NativeLeaseKind::Wrapper)
            .is_none(),
        "retirement ordered before acquisition must reject publication"
    );
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(unsafe {
        canonical::publish(registry.domain(), timer_type(), lease).unwrap()
    });
    unsafe {
        assert_eq!(
            canonical::identity(value.get_nanbox_f64(), registry.domain(), timer_type()),
            Some(identity),
            "publication must preserve the pre-retirement exact identity"
        );
    }
    assert_eq!(
        registry.drain(Instant::now()),
        0,
        "publication ordered before retirement must retain ownership"
    );
    drop(scope);
    collect();
    assert_eq!(registry.drain(Instant::now()), 1);
    let replacement = registry
        .begin_registration(NativeRegistrationKind::Reserved)
        .unwrap();
    assert!(registry.publish(replacement));
    assert_eq!(replacement.numeric_id(), identity.numeric_id());
    assert_ne!(replacement, identity);
    assert!(
        registry
            .acquire(identity, NativeLeaseKind::Wrapper)
            .is_none(),
        "publication must not substitute another registration"
    );
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(publish(&registry, replacement));
    unsafe {
        assert_eq!(
            canonical::identity(value.get_nanbox_f64(), registry.domain(), timer_type()),
            Some(replacement)
        );
    }
    retire(&registry, replacement);
    drop(scope);
    collect();
    assert_eq!(registry.drain(Instant::now()), 1);
}

#[test]
fn old_cleanup_preserves_a_replacement_weak_entry() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let (other_registry, other_identity) = self::registry();
    let scope = RuntimeHandleScope::new();
    let other = scope.root_nanbox_f64(publish(&other_registry, other_identity));
    let old = publish(&registry, identity);
    let old_addr = address(old);
    let replacement_addr = address(other.get_nanbox_f64());
    assert_ne!(
        old_addr, replacement_addr,
        "fixture keeps both cells allocated"
    );
    canonical::replace_index_for_test(identity, replacement_addr);
    retire(&registry, identity);
    collect();
    assert_eq!(
        canonical::indexed_address(identity),
        Some(replacement_addr),
        "old cleanup must not remove the replacement entry"
    );
    assert_eq!(registry.drain(Instant::now()), 1);
    // Remove the deliberately synthetic row without dereferencing the old cell.
    canonical::remove_index_for_test(identity, replacement_addr);
    retire(&other_registry, other_identity);
    drop(scope);
    collect();
    assert_eq!(other_registry.drain(Instant::now()), 1);
}

#[test]
fn reentrant_publication_balances_unpublished_candidate() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let scope = RuntimeHandleScope::new();
    let mut winner = None;
    let lease = registry
        .acquire(identity, NativeLeaseKind::Wrapper)
        .unwrap();
    let value = unsafe {
        canonical::publish_before_allocate_for_test(registry.domain(), timer_type(), lease, || {
            winner = Some(scope.root_nanbox_f64(publish(&registry, identity)));
        })
        .unwrap()
    };
    assert_eq!(
        value.to_bits(),
        winner.unwrap().get_nanbox_u64(),
        "reentrant publication must return the installed winner"
    );
    retire(&registry, identity);
    // End only the winner's ownership through the actual cleanup hook. The
    // unpublished candidate has not been collected, so collecting both cells
    // cannot conceal an extra lease retained by the rejected candidate.
    unsafe {
        crate::native_handle::finalize_native_handle_for_gc(
            address(value) as *mut crate::native_handle::NativeHandleHeader
        );
    }
    assert_eq!(
        registry.drain(Instant::now()),
        1,
        "unpublished candidate must release its wrapper lease"
    );
    drop(scope);
    collect();
}

#[test]
fn js_thread_exit_releases_native_metadata_without_gc() {
    let (registry, identity) = registry();
    let owner_registry = registry.clone();
    std::thread::spawn(move || {
        let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
        let value = publish(&owner_registry, identity);
        handle_expando_set(address(value) as i64, "owner", 53.0);
        retire(&owner_registry, identity);
        assert_eq!(owner_registry.drain(Instant::now()), 0);
        // No collection: the real malloc TLS destructor reclaims the cell.
    })
    .join()
    .unwrap();
    assert_eq!(
        registry.drain(Instant::now()),
        1,
        "JS thread teardown must release native wrapper ownership"
    );
}

#[test]
fn disposed_cleanup_takes_native_metadata_once() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    register_roots();
    let (registry, identity) = registry();
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(publish(&registry, identity));
    crate::native_handle::js_native_handle_dispose(value.get_nanbox_f64());
    retire(&registry, identity);
    unsafe {
        let header =
            address(value.get_nanbox_f64()) as *mut crate::native_handle::NativeHandleHeader;
        crate::native_handle::finalize_native_handle_for_gc(header);
        assert!(
            (*header).registration.is_null(),
            "cleanup must take native metadata before release"
        );
        assert_eq!(registry.drain(Instant::now()), 1);
        crate::native_handle::finalize_native_handle_for_gc(header);
        assert_eq!(
            registry.drain(Instant::now()),
            0,
            "repeated cleanup must release no second lease"
        );
    }
    drop(scope);
    collect();
}

#[test]
fn acyclic_owner_child_moves_with_existing_scanner() {
    let _guard = CopyingNurseryTestGuard::new(0);
    let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    let _conservative = ConservativeScanDisabledGuard::new();
    let _evacuation = ForcedEvacuationTestGuard::on();
    register_roots();
    let (registry, identity) = registry();
    let scope = RuntimeHandleScope::new();
    let value = scope.root_nanbox_f64(publish(&registry, identity));
    let owner = address(value.get_nanbox_f64());
    let bytes = vec![b'x'; 2048];
    let child = crate::string::js_string_from_bytes(bytes.as_ptr(), bytes.len() as u32);
    assert!(
        crate::arena::pointer_in_nursery(child as usize),
        "fixture child must start in nursery"
    );
    let before = crate::value::js_nanbox_string(child as i64);
    handle_expando_set(owner as i64, "child", before);
    retire(&registry, identity);
    let collections = gc_collection_count();
    gc_collect_minor();
    assert!(
        gc_collection_count() > collections,
        "fixture must run a real moving collection"
    );
    let after = handle_expando_get(owner as i64, "child").unwrap();
    assert_ne!(
        after.to_bits(),
        before.to_bits(),
        "owner child slot must hold the moved value"
    );
    let moved = crate::value::JSValue::from_bits(after.to_bits()).as_string_ptr();
    unsafe {
        assert_eq!(
            std::slice::from_raw_parts(
                crate::string::string_data(moved),
                (*moved).byte_len as usize
            ),
            bytes
        );
        assert_eq!(
            canonical::identity(value.get_nanbox_f64(), registry.domain(), timer_type()),
            Some(identity)
        );
    }
    assert_eq!(
        address(value.get_nanbox_f64()),
        owner,
        "canonical cell must remain nonmoving"
    );
    drop(scope);
    collect();
    assert_eq!(canonical::indexed_address(identity), None);
    assert_eq!(handle_expando_get(owner as i64, "child"), None);
    assert_eq!(registry.drain(Instant::now()), 1);
}
