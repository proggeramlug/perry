//! Inactive managed-wrapper substrate. Native workers use only the neutral
//! registration registry; all functions here run on the owning JS thread.
//!
//! The index is weak, and its cells are malloc-backed/nonmoving. An owned native
//! Wrapper lease crosses publication and stays with the cell until GC cleanup.
//! Neither retirement nor explicit disposal changes a retained cell's identity.
//! Production publishers and owner-conditioned property tracing are not enabled.

use super::NativeHandleHeader;
use perry_native_registration::{
    NativeLeaseKind, NativeRegistrationIdentity, NativeRegistrationLease,
    NativeRegistrationRegistry, NativeRegistryDomain,
};
use std::cell::RefCell;
use std::collections::HashMap;
use std::ptr;

crate::perry_thread_local! {
    // Not a root: only cleanup removes the matching nonmoving address.
    static CANONICAL: RefCell<HashMap<NativeRegistrationIdentity, usize>> =
        RefCell::new(HashMap::new());
}

pub(crate) struct Registration {
    identity: NativeRegistrationIdentity,
    // Option separates immutable recognition from exactly-once release.
    wrapper: Option<NativeRegistrationLease>,
}

/// A rejected publication consumes and releases the offered lease.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum PublicationError {
    /// Publication requires a Wrapper lease, never an Operation lease.
    WrongLeaseKind,
    /// The registration belongs to another authoritative domain.
    WrongDomain,
    /// One registration cannot be published with two runtime types.
    ConflictingType,
}

/// Publish an already-acquired Wrapper lease on this JS thread.
///
/// Acquisition, not allocation, orders publication against retirement: a lease
/// acquired while Live may finish publishing that same identity after retirement.
/// A weak hit releases the offered lease and returns the existing cell. There is
/// no numeric-id lookup or replacement-identity retry.
///
/// # Safety
/// Release native/payload locks before calling on the owning JS thread. Root
/// the returned value before any subsequent runtime allocation or collection.
/// Do not serialize its address to workers.
pub unsafe fn publish(
    expected_domain: NativeRegistryDomain,
    type_id: u64,
    lease: NativeRegistrationLease,
) -> Result<f64, PublicationError> {
    publish_inner(expected_domain, type_id, lease, || {})
}

unsafe fn lookup(
    identity: NativeRegistrationIdentity,
    type_id: u64,
) -> Result<Option<f64>, PublicationError> {
    let existing = CANONICAL.with(|index| index.borrow().get(&identity).copied());
    if let Some(addr) = existing {
        let value = crate::value::js_nanbox_pointer(addr as i64);
        let handle = super::handle_from_value(value);
        // Membership checks stay in place until the later representation cut.
        if !handle.is_null() && !(*handle).registration.is_null() {
            let registration = &*(*handle).registration;
            if registration.identity == identity {
                if (*handle).type_id != type_id {
                    return Err(PublicationError::ConflictingType);
                }
                return Ok(Some(value));
            }
        }
    }
    Ok(None)
}

unsafe fn publish_inner(
    expected_domain: NativeRegistryDomain,
    type_id: u64,
    lease: NativeRegistrationLease,
    before_allocate: impl FnOnce(),
) -> Result<f64, PublicationError> {
    if lease.kind() != NativeLeaseKind::Wrapper {
        return Err(PublicationError::WrongLeaseKind);
    }
    let identity = lease.identity();
    if identity.domain() != expected_domain {
        return Err(PublicationError::WrongDomain);
    }
    if let Some(value) = lookup(identity, type_id)? {
        drop(lease);
        return Ok(value);
    }
    before_allocate();
    // No RefCell borrow spans allocation/GC. The lease remains Rust-owned
    // through allocation and transfers only after the cell is initialized.
    let value = super::native_handle_new(
        0,
        type_id as i64,
        super::OWNERSHIP_NULL,
        0,
        super::THREAD_CREATOR as i32,
        ptr::null_mut(),
        b"canonical".as_ptr(),
        9,
    );
    let handle = crate::value::JSValue::from_bits(value.to_bits())
        .as_pointer::<NativeHandleHeader>() as *mut NativeHandleHeader;
    (*handle).registration = Box::into_raw(Box::new(Registration {
        identity,
        wrapper: Some(lease),
    }));
    // Allocation can run native cleanup. Recheck before installing this cell,
    // so even a reentrant publication keeps its earlier canonical winner.
    match lookup(identity, type_id) {
        Ok(None) => {
            let _ = CANONICAL.with(|index| index.borrow_mut().insert(identity, handle as usize));
            Ok(value)
        }
        winner => {
            // This unpublished cell has no resource or owner entries. Native
            // release cannot collect; no JS value is used across a GC point.
            let _ = release_native_metadata(handle);
            winner.map(|value| value.expect("publication winner must exist"))
        }
    }
}

/// Recognize a representation's immutable identity, including after retirement
/// or explicit disposal. This is not native availability or an Operation lease.
///
/// # Safety
/// `value` must belong to the calling JS thread and remain rooted across GC.
pub unsafe fn identity(
    value: f64,
    expected_domain: NativeRegistryDomain,
    expected_type_id: u64,
) -> Option<NativeRegistrationIdentity> {
    let handle = super::handle_from_value(value);
    if handle.is_null() || (*handle).type_id != expected_type_id || (*handle).registration.is_null()
    {
        return None;
    }
    let identity = (*(*handle).registration).identity;
    (identity.domain() == expected_domain).then_some(identity)
}

/// Acquire the recognized exact identity and retain its Operation lease until
/// `operation` returns or unwinds. Retirement prevents new acquisition while an
/// already-acquired operation continues to hold its independent native lease.
/// The lease protects registration identity, not a removed provider payload.
///
/// # Safety
/// Call on the owning JS thread. The closure must root JS values it retains
/// across allocations. It must return or use Rust unwinding; it must not perform
/// a JS nonlocal exit that bypasses Rust destructors. Future provider adapters
/// must separately establish their payload and exception-boundary contracts.
pub unsafe fn with_operation<R>(
    value: f64,
    domain: NativeRegistryDomain,
    type_id: u64,
    registry: &NativeRegistrationRegistry,
    operation: impl FnOnce(NativeRegistrationIdentity) -> R,
) -> Option<R> {
    let identity = identity(value, domain, type_id)?;
    let handle = super::handle_from_value(value);
    if (*handle).finalized != 0 {
        return None;
    }
    let lease = registry.acquire(identity, NativeLeaseKind::Operation)?;
    let result = operation(identity);
    drop(lease);
    Some(result)
}

fn remove_matching(identity: NativeRegistrationIdentity, addr: usize) {
    let _ = CANONICAL.try_with(|index| {
        let mut index = index.borrow_mut();
        if index.get(&identity).copied() == Some(addr) {
            index.remove(&identity);
        }
    });
}

/// Drop only native registration ownership before a cell's allocation is
/// reclaimed. Also used by malloc-thread teardown, where JS TLS may be gone.
/// No resource finalizer, JS callback, or TLS access is permitted here.
pub(crate) unsafe fn release_native_metadata(
    handle: *mut NativeHandleHeader,
) -> Option<NativeRegistrationIdentity> {
    if handle.is_null() {
        return None;
    }
    let metadata = std::mem::replace(&mut (*handle).registration, ptr::null_mut());
    if metadata.is_null() {
        return None;
    }
    let mut registration = Box::from_raw(metadata);
    let identity = registration.identity;
    drop(registration.wrapper.take());
    Some(identity)
}

pub(super) unsafe fn cleanup_for_gc(handle: *mut NativeHandleHeader) {
    // Native release does not depend on any JS TLS still being available.
    let Some(identity) = release_native_metadata(handle) else {
        return;
    };
    remove_matching(identity, handle as usize);
    // Simple acyclic test owners use the existing side table. This is not
    // owner-conditioned tracing and does not establish owner-cycle collection.
    crate::object::handle_expando::clear_plain_expando_for_gc(handle as i64);
}

#[cfg(test)]
pub(crate) fn indexed_address(identity: NativeRegistrationIdentity) -> Option<usize> {
    CANONICAL.with(|index| index.borrow().get(&identity).copied())
}

#[cfg(test)]
pub(crate) fn replace_index_for_test(identity: NativeRegistrationIdentity, addr: usize) {
    let _ = CANONICAL.with(|index| index.borrow_mut().insert(identity, addr));
}

#[cfg(test)]
pub(crate) fn remove_index_for_test(identity: NativeRegistrationIdentity, addr: usize) {
    remove_matching(identity, addr);
}

#[cfg(test)]
pub(crate) unsafe fn publish_before_allocate_for_test(
    domain: NativeRegistryDomain,
    type_id: u64,
    lease: NativeRegistrationLease,
    hook: impl FnOnce(),
) -> Result<f64, PublicationError> {
    publish_inner(domain, type_id, lease, hook)
}
