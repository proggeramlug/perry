//! Weak canonical interning for legacy integer-handle families.
//!
//! The wrapper is a malloc-backed `GC_TYPE_NATIVE_HANDLE`, so its address does
//! not move. The table stores that address as an integer and is deliberately
//! not a GC root: the native-handle finalizer removes the weak entry before the
//! allocation is reclaimed. Resource registries remain keyed by `(provider,
//! id)`, never by this address.

use super::{
    current_thread_id, handle_from_addr, native_handle_new, NativeHandleHeader,
    NATIVE_HANDLE_FLAG_CANONICAL, OWNERSHIP_BORROWED, THREAD_ANY,
};
use std::cell::RefCell;
use std::collections::HashMap;
use std::ptr;

pub const NATIVE_HANDLE_PROVIDER_TIMER: u64 = 0x5045_5252_5954_494d; // PERRYTIM
pub const NATIVE_HANDLE_PROVIDER_TEXT_ENCODER: u64 = 0x5045_5252_5954_454e; // PERRYTEN
pub const NATIVE_HANDLE_PROVIDER_TEXT_DECODER: u64 = 0x5045_5252_5954_4445; // PERRYTDE
pub const NATIVE_HANDLE_PROVIDER_COMMON: u64 = 0x5045_5252_5943_4f4d; // PERRYCOM
pub const NATIVE_HANDLE_PROVIDER_FETCH: u64 = 0x5045_5252_5946_4554; // PERRYFET

thread_local! {
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

pub fn canonical_handle_value(provider: u64, id: i64) -> f64 {
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
            OWNERSHIP_BORROWED,
            0,
            THREAD_ANY as i32,
            ptr::null_mut(),
            b"registry-handle".as_ptr(),
            15,
        )
    };
    let addr = (value.to_bits() & crate::value::POINTER_MASK) as usize;
    unsafe {
        let handle = handle_from_addr(addr);
        debug_assert!(!handle.is_null());
        (*handle).flags |= NATIVE_HANDLE_FLAG_CANONICAL;
        (*handle).ownership = OWNERSHIP_BORROWED;
        // Canonical wrappers are per-agent values. Preserve the creator marker
        // even though the public affinity is ANY so debug inspection can prove
        // the weak table never crosses a runtime thread.
        (*handle).creator_thread_id = current_thread_id();
    }
    CANONICAL_HANDLES.with(|table| {
        table.borrow_mut().insert((provider, id), addr);
    });
    value
}

pub fn canonical_handle_parts_from_addr(addr: usize) -> Option<(u64, i64)> {
    unsafe { canonical_parts(handle_from_addr(addr)) }
}

pub fn canonical_handle_parts_from_value(value: f64) -> Option<(u64, i64)> {
    let js = crate::value::JSValue::from_bits(value.to_bits());
    if !js.is_pointer() {
        return None;
    }
    canonical_handle_parts_from_addr(js.as_pointer::<u8>() as usize)
}

pub fn canonical_handle_id_for_provider(value: f64, provider: u64) -> Option<i64> {
    let (actual, id) = canonical_handle_parts_from_value(value)?;
    (actual == provider).then_some(id)
}

pub fn is_canonical_handle_addr(addr: usize) -> bool {
    canonical_handle_parts_from_addr(addr).is_some()
}

pub(super) unsafe fn remove_finalized(provider: u64, id: i64, finalized: *mut NativeHandleHeader) {
    CANONICAL_HANDLES.with(|table| {
        let mut table = table.borrow_mut();
        if table.get(&(provider, id)).copied() == Some(finalized as usize) {
            table.remove(&(provider, id));
        }
    });
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
