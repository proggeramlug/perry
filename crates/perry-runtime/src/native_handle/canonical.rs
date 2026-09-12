//! Weak canonical interning for legacy integer-handle families.
//!
//! The wrapper is a malloc-backed `GC_TYPE_NATIVE_HANDLE`, so its address does
//! not move. The table stores that address as an integer and is deliberately
//! not a GC root: the native-handle finalizer removes the weak entry before the
//! allocation is reclaimed. Resource registries remain keyed by `(provider,
//! id)`, never by this address.

use super::{
    current_thread_id, handle_from_addr, native_handle_new, NativeHandleFinalizer,
    NativeHandleHeader, NATIVE_HANDLE_FLAG_CANONICAL, OWNERSHIP_BORROWED, OWNERSHIP_OWNED,
    THREAD_ANY,
};
use std::cell::RefCell;
use std::collections::HashMap;
use std::ffi::c_void;
use std::ptr;

/// Monotone negative filter for the generic address classifier. Canonical
/// wrappers are uncommon, while that classifier sees every pointer-shaped
/// receiver; reject ordinary heap addresses before resolving TLS and probing
/// the weak identity table.
static CANONICAL_HANDLE_ADDR_FILTER: crate::registry_latch::RegistryAddrFilter =
    crate::registry_latch::RegistryAddrFilter::new();

pub const NATIVE_HANDLE_PROVIDER_TIMER: u64 = 0x5045_5252_5954_494d; // PERRYTIM
pub const NATIVE_HANDLE_PROVIDER_TEXT_ENCODER: u64 = 0x5045_5252_5954_454e; // PERRYTEN
pub const NATIVE_HANDLE_PROVIDER_TEXT_DECODER: u64 = 0x5045_5252_5954_4445; // PERRYTDE
pub const NATIVE_HANDLE_PROVIDER_COMMON: u64 = 0x5045_5252_5943_4f4d; // PERRYCOM
pub const NATIVE_HANDLE_PROVIDER_FETCH: u64 = 0x5045_5252_5946_4554; // PERRYFET

crate::perry_thread_local! {
    /// Integer addresses make this a weak identity index rather than an
    /// unregistered heap-pointer root. `finalize_once` removes each entry.
    static CANONICAL_HANDLES: RefCell<HashMap<(u64, i64), usize>> =
        RefCell::new(HashMap::new());
}

unsafe fn canonical_parts(handle: *mut NativeHandleHeader) -> Option<(u64, i64)> {
    if handle.is_null()
        || (*handle).flags & NATIVE_HANDLE_FLAG_CANONICAL == 0
        || (*handle).finalized != 0
    {
        return None;
    }
    Some(((*handle).type_id, (*handle).resource_ptr as i64))
}

fn canonical_handle_value_with_policy(
    provider: u64,
    id: i64,
    ownership: u8,
    finalizer: *mut c_void,
    debug_name: &'static [u8],
) -> f64 {
    if let Some(addr) = CANONICAL_HANDLES.with(|table| table.borrow().get(&(provider, id)).copied())
    {
        let live = unsafe {
            let handle = handle_from_addr(addr);
            canonical_parts(handle) == Some((provider, id))
        };
        if live {
            return f64::from_bits(crate::value::JSValue::pointer(addr as *const u8).bits());
        }
        CANONICAL_HANDLES.with(|table| {
            table.borrow_mut().remove(&(provider, id));
        });
    }

    let value = unsafe {
        native_handle_new(
            id,
            provider as i64,
            ownership,
            0,
            THREAD_ANY as i32,
            finalizer,
            debug_name.as_ptr(),
            debug_name.len() as i64,
        )
    };
    let addr = (value.to_bits() & crate::value::POINTER_MASK) as usize;
    unsafe {
        let handle = handle_from_addr(addr);
        debug_assert!(!handle.is_null());
        (*handle).flags |= NATIVE_HANDLE_FLAG_CANONICAL;
        (*handle).ownership = ownership;
        // Canonical wrappers are per-agent values. Preserve the creator marker
        // even though the public affinity is ANY so debug inspection can prove
        // the weak table never crosses a runtime thread.
        (*handle).creator_thread_id = current_thread_id();
    }
    CANONICAL_HANDLE_ADDR_FILTER.admit(addr);
    let replaced = CANONICAL_HANDLES.with(|table| {
        table.borrow_mut().insert((provider, id), addr).is_some()
    });
    crate::hot_diag::canonical_census_note_admit(replaced);
    value
}

pub fn canonical_handle_value(provider: u64, id: i64) -> f64 {
    canonical_handle_value_with_policy(
        provider,
        id,
        OWNERSHIP_BORROWED,
        ptr::null_mut(),
        b"registry-handle",
    )
}

pub(crate) fn canonical_handle_value_owned(
    provider: u64,
    id: i64,
    finalizer: NativeHandleFinalizer,
    debug_name: &'static [u8],
) -> f64 {
    canonical_handle_value_with_policy(
        provider,
        id,
        OWNERSHIP_OWNED,
        finalizer as *mut c_void,
        debug_name,
    )
}

pub fn canonical_handle_parts_from_addr(addr: usize) -> Option<(u64, i64)> {
    unsafe { canonical_parts(handle_from_addr(addr)) }
}

pub fn canonical_handle_parts_from_value(value: f64) -> Option<(u64, i64)> {
    let js = crate::value::JSValue::from_bits(value.to_bits());
    if !js.is_pointer() {
        return None;
    }
    unsafe {
        let addr = js.as_pointer::<u8>() as usize;
        let header = crate::value::addr_class::direct_receiver_gc_header(addr)?;
        if (*header).obj_type != crate::gc::GC_TYPE_NATIVE_HANDLE {
            return None;
        }
        let handle = addr as *mut NativeHandleHeader;
        debug_assert_eq!((*handle).magic, super::NATIVE_HANDLE_MAGIC);
        canonical_parts(handle)
    }
}

pub fn canonical_handle_id_for_provider(value: f64, provider: u64) -> Option<i64> {
    let (actual, id) = canonical_handle_parts_from_value(value)?;
    (actual == provider).then_some(id)
}

pub fn is_canonical_handle_addr(addr: usize) -> bool {
    let census = crate::hot_diag::canonical_census_on();
    if census {
        crate::hot_diag::canonical_census_note_call();
    }
    if !CANONICAL_HANDLE_ADDR_FILTER.may_contain(addr) {
        return false;
    }
    let resolved = canonical_handle_parts_from_addr(addr).is_some();
    if census {
        crate::hot_diag::canonical_census_note_pass(resolved);
    }
    resolved
}

/// Bits set in the canonical-handle filter, and its capacity. Diagnostics
/// only: a filter whose bits are nearly all set has stopped discriminating,
/// and the census cannot report that from outside this module.
pub(crate) fn canonical_filter_occupancy() -> (u32, u32) {
    (
        CANONICAL_HANDLE_ADDR_FILTER.bits_set(),
        CANONICAL_HANDLE_ADDR_FILTER.capacity_bits(),
    )
}

pub(super) unsafe fn remove_finalized(provider: u64, id: i64, finalized: *mut NativeHandleHeader) {
    CANONICAL_HANDLES.with(|table| {
        let mut table = table.borrow_mut();
        if table.get(&(provider, id)).copied() == Some(finalized as usize) {
            table.remove(&(provider, id));
            crate::hot_diag::canonical_census_note_retire();
        }
    });
}

/// Retire the canonical identity when its authoritative registry entry dies.
/// This prevents an id recycled by the provider from reusing the wrapper of a
/// logically different resource that JavaScript still happens to retain.
pub(crate) fn retire(provider: u64, id: i64) {
    let addr = CANONICAL_HANDLES.with(|table| table.borrow_mut().remove(&(provider, id)));
    let Some(addr) = addr else {
        return;
    };
    crate::hot_diag::canonical_census_note_retire();
    unsafe {
        let handle = handle_from_addr(addr);
        if canonical_parts(handle) == Some((provider, id)) {
            let _ = super::finalize_once(handle);
        }
    }
}

#[cfg(test)]
pub(super) fn canonical_entry_count_for_tests(provider: u64) -> usize {
    CANONICAL_HANDLES.with(|table| {
        table
            .borrow()
            .keys()
            .filter(|(actual, _)| *actual == provider)
            .count()
    })
}
