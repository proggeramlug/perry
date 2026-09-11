//! Own-data proofs learned after the ordinary by-name resolver.
//!
//! Kept separate from read_stub: its write-side producer and by-value consumer
//! do not pass through the same receiver-specific read checks. Entries contain
//! only exact class/shape identity, short-key content, and a tagged slot. No
//! managed addresses or field values are retained.
//!
//! Descriptor installations give the owner a fresh semantic ShapeId. A hit
//! reads the current slot under that exact shape and class; deletion holes
//! still miss. The by-name caller must retain its private-member, array-element,
//! process.env and Proxy prelude before consulting this cache.

use super::read_stub::{READ_STUB_ASSOC, READ_STUB_BUCKETS};
use super::ObjectHeader;

crate::perry_thread_local! {
    static OWN_READ_CACHE: [[std::cell::Cell<(u64, u64, u32)>; READ_STUB_ASSOC]; READ_STUB_BUCKETS] =
        std::array::from_fn(|_| std::array::from_fn(|_| std::cell::Cell::new((0, 0, 0))));
}

#[cfg(test)]
thread_local! {
    static HITS: std::cell::Cell<u64> = const { std::cell::Cell::new(0) };
}

#[cfg(test)]
pub(super) fn note_hit() {
    HITS.with(|hits| hits.set(hits.get() + 1));
}

#[inline(always)]
unsafe fn identity(obj: *const ObjectHeader) -> Option<u64> {
    let shape = super::shapes::object_shape_stamp(obj);
    (shape != 0).then(|| ((u64::from((*obj).class_id)) << u32::BITS) | u64::from(shape))
}

#[inline(always)]
fn bucket(identity: u64, key: u64) -> usize {
    let hash = (identity ^ key).wrapping_mul(0x9E37_79B9_7F4A_7C15);
    ((hash >> 40) as usize) & (READ_STUB_BUCKETS - 1)
}

/// The by-name caller has validated GC_TYPE_OBJECT, no forwarding, and no
/// typed-array-prototype flag, after its receiver-specific prelude. This
/// consumer deliberately is not used by the direct SSO entry.
#[inline(always)]
pub(super) unsafe fn probe(obj: *const ObjectHeader, key: u64) -> Option<u32> {
    let identity = identity(obj)?;
    OWN_READ_CACHE.with(|table| {
        table[bucket(identity, key)].iter().find_map(|entry| {
            let (stored_identity, stored_key, slot) = entry.get();
            (stored_identity == identity && stored_key == key).then_some(slot)
        })
    })
}

/// Called only at ordinary own-data returns, after own-accessor checks.
/// `key` is the resolver's owned byte copy. `live` is supplied by resolver
/// paths that already computed the inline bound; the late field-cache path
/// computes it only for a short key that can actually be learned.
#[inline]
pub(super) unsafe fn prime(obj: *const ObjectHeader, key: &[u8], index: u32, live: Option<u32>) {
    if key.len() > crate::value::SHORT_STRING_MAX_LEN || !key.is_ascii() {
        return;
    }
    let header =
        &*((obj as *const u8).sub(crate::gc::GC_HEADER_SIZE) as *const crate::gc::GcHeader);
    if header.gc_flags & crate::gc::GC_FLAG_FORWARDED != 0
        || header._reserved & crate::gc::OBJ_FLAG_TYPED_ARRAY_PROTO != 0
        || (*obj).class_id == super::NATIVE_MODULE_CLASS_ID
        || (*obj).class_id == super::CLASS_ID_BOXED_STRING
        || ((*obj).class_id == crate::tty::CLASS_ID_TTY_WRITE_STREAM && key == b"rows")
        || ((*obj).class_id == 0 && super::is_arguments_object(obj))
    {
        return;
    }
    let Some(identity) = identity(obj) else {
        return;
    };
    // Heap class objects use the tail as an intermediate lookup: undefined
    // can continue to static dispatch in the outer getter. Only ordinary
    // objects treat these own-data returns as the final read result.
    if super::shapes::shape_object_kind_by_id(identity as u32)
        != Some(super::shapes::ShapeObjectKind::Ordinary)
    {
        return;
    }
    let live = live.unwrap_or_else(|| super::object_live_slot_count(obj));
    // Match object_field_at_with_live, including its malformed-bound guard.
    if live > 10000 || index & crate::proxy::IC_SLOT_OVERFLOW_BIT != 0 {
        return;
    }
    let slot = if index < live {
        index
    } else {
        index | crate::proxy::IC_SLOT_OVERFLOW_BIT
    };
    let key = crate::JSValue::try_short_string(key).unwrap().bits();
    OWN_READ_CACHE.with(|table| {
        let bucket = &table[bucket(identity, key)];
        let value = (identity, key, slot);
        if let Some(entry) = bucket.iter().find(|entry| {
            let (stored_identity, stored_key, _) = entry.get();
            stored_identity == 0 || (stored_identity == identity && stored_key == key)
        }) {
            entry.set(value);
            return;
        }
        for i in (1..READ_STUB_ASSOC).rev() {
            bucket[i].set(bucket[i - 1].get());
        }
        bucket[0].set(value);
    });
}

#[cfg(test)]
#[path = "own_read_cache_tests.rs"]
mod tests;
