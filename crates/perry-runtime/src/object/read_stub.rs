//! Megamorphic stub cache for dynamic string-keyed property READS.
//!
//! The read twin of the dynamic-write stub in `proxy::put_value`, and it exists
//! for the same reason: a site that rotates more keys than a per-site cache can
//! hold gets no benefit from one, so the cache has to be keyed on the PROGRAM's
//! live `(shape, key)` pairs instead of on a site.
//!
//! What a hit skips is the point. `js_object_get_field_by_name`'s fast lane
//! re-proves a long chain on every read — address-class checks, the interned-key
//! flag, arena classification, header type/flags/class, keys-array validation —
//! and then consults the read-plan cache, whose epoch is bumped by the
//! incremental collector at loop-poll cadence, so on a plain read loop it is
//! repeatedly cold and falls through to a shape-index hash lookup. A stub hit
//! replaces all of that with a handful of loads and compares.
//!
//! # Why entries cannot go stale dangerously
//!
//! Every hit re-validates the receiver's CURRENT state: heap-object type, not
//! forwarded, none of the blocking flags, a real class id, and — decisively —
//! the receiver's current shape token. The token identifies the exact key set
//! AND order, so a matching token means the cached slot still names this key.
//! A stale entry therefore misses; it cannot resolve to the wrong property.
//!
//! Entries hold no roots and no addresses: the key is stored as CONTENT bits
//! (an SSO immediate, or a short ASCII heap string folded to the bits its
//! content would encode as), so a key that dies and has its address recycled
//! cannot produce a false hit. Keys that do not fit the inline form are simply
//! not cached — the same rule the write stub follows, and for the same reason.
//!
//! # Two ways, not one
//!
//! Direct-mapped was measured on the write side and it is a trap: a colliding
//! pair evicts each other on every rotation through the key set, so both miss
//! FOREVER — the miss is permanent, not probabilistic. Making that table 2-way
//! at equal capacity was worth 50% on the write loop (#8977). This one starts
//! 2-way for that reason.

use crate::object::ObjectHeader;

const READ_STUB_BUCKETS: usize = 2048;
const READ_STUB_ASSOC: usize = 2;

crate::perry_thread_local! {
    static READ_STUB: [[std::cell::Cell<(u64, u64, u64)>; READ_STUB_ASSOC]; READ_STUB_BUCKETS] =
        std::array::from_fn(|_| std::array::from_fn(|_| std::cell::Cell::new((0, 0, 0))));
}

/// Marks a cache key as a CONTENT HASH rather than an inline encoding.
///
/// `0xFFFF` is not a NaN-box tag, so a hashed key can never collide with the
/// SSO bits of a short key: the two live in disjoint halves of the key space.
const READ_STUB_HASHED_TAG: u64 = 0xFFFF << 48;

/// Longest key admitted to the cache, matching the intern table's own ceiling.
const READ_STUB_MAX_KEY_BYTES: u32 = 64;

/// Cache key for a property name, or `None` when it must not be cached.
///
/// Short keys (≤ `SHORT_STRING_MAX_LEN` ASCII bytes) use their inline SSO
/// encoding, which IS their content, so a hit needs no further check.
///
/// Anything longer is keyed on a content hash and tagged as such. Real
/// property names — `userName`, `createdAt` — are longer than five bytes, so
/// the inline-only rule left this cache doing nothing for the workloads that
/// matter most: with realistic names perry ran 27 ms against node's 9 ms on a
/// loop the cache never touched.
///
/// A hash is not an identity, so a hashed hit is VERIFIED against the key
/// actually stored in the receiver's keys array before it is believed (see
/// `try_read_slot`). That keeps the original guarantee — an entry never names
/// an address, and a wrong entry cannot resolve to the wrong property — while
/// covering keys that do not fit in 64 bits.
#[inline(always)]
pub(crate) fn read_stub_key_bits(key: *const crate::StringHeader) -> Option<u64> {
    unsafe {
        if let Some(bits) = crate::string::short_ascii_sso_bits(key) {
            return Some(bits);
        }
        if !crate::string::is_valid_string_ptr(key) {
            return None;
        }
        let blen = (*key).byte_len;
        if blen == 0 || blen > READ_STUB_MAX_KEY_BYTES {
            return None;
        }
        let data = crate::string::string_data(key);
        let mut h = 0xcbf2_9ce4_8422_2325u64;
        for i in 0..blen as usize {
            h ^= *data.add(i) as u64;
            h = h.wrapping_mul(0x0100_0000_01b3);
        }
        // Keep the tag intact and never produce the empty-entry sentinel.
        Some(READ_STUB_HASHED_TAG | (h & 0x0000_FFFF_FFFF_FFFF) | 1)
    }
}

/// Whether a cache key is a hash (and therefore needs verification on hit).
#[inline(always)]
pub(crate) fn read_stub_key_is_hashed(key_bits: u64) -> bool {
    (key_bits >> 48) == 0xFFFF
}

#[inline(always)]
fn bucket_of(token: u64, key_bits: u64) -> usize {
    // Multiplicative mixing taking the TOP bits of the product. An SSO key's
    // LOW bits are its first byte, so a low-bit index collapses a whole key
    // family onto a few buckets — measured on the write side before #8977.
    let h = (token ^ key_bits).wrapping_mul(0x9E37_79B9_7F4A_7C15);
    ((h >> 40) as usize) & (READ_STUB_BUCKETS - 1)
}

#[inline(always)]
pub(crate) fn read_stub_probe(token: u64, key_bits: u64) -> Option<u32> {
    READ_STUB.with(|t| {
        for way in t[bucket_of(token, key_bits)].iter() {
            let (tok, kb, slot) = way.get();
            if tok == token && kb == key_bits && tok != 0 {
                return Some(slot as u32);
            }
        }
        None
    })
}

#[inline(always)]
pub(crate) fn read_stub_insert(token: u64, key_bits: u64, slot: u32) {
    if token == 0 || key_bits == 0 {
        return;
    }
    READ_STUB.with(|t| {
        let bucket = &t[bucket_of(token, key_bits)];
        let entry = (token, key_bits, slot as u64);
        for way in bucket.iter() {
            let (tok, kb, _) = way.get();
            if tok == token && kb == key_bits {
                way.set(entry);
                return;
            }
        }
        for way in bucket.iter() {
            if way.get().0 == 0 {
                way.set(entry);
                return;
            }
        }
        for i in (1..READ_STUB_ASSOC).rev() {
            bucket[i].set(bucket[i - 1].get());
        }
        bucket[0].set(entry);
    });
}

/// The receiver's shape token, or `None` when it has no live shape.
///
/// Same discriminated form the write ICs use, so the two caches agree on what
/// "this shape" means.
#[inline(always)]
pub(crate) unsafe fn receiver_shape_token(obj: *const ObjectHeader) -> Option<u64> {
    let stamp = crate::object::shapes::object_shape_stamp(obj);
    if stamp == 0 {
        return None;
    }
    Some(crate::object::shapes::PIC_ID_TOKEN_BIT | stamp as u64)
}

/// Verify a hashed hit: the key stored at `slot` in the receiver's keys array
/// must actually be this key.
///
/// A content hash identifies a key only probabilistically, so without this a
/// collision would resolve to the WRONG property — silently, which is the
/// worst failure shape available. One `js_string_key_matches` against the slot
/// the cache proposed is far cheaper than the shape-index lookup it replaces,
/// and it restores the same guarantee the inline-encoded keys have by
/// construction.
#[inline]
pub(crate) unsafe fn verify_slot_key(
    obj: *const ObjectHeader,
    slot: u32,
    key: *const crate::StringHeader,
) -> bool {
    let keys = crate::object::object_keys_array(obj);
    if keys.is_null() || (keys as u64) >> 48 != 0 {
        return false;
    }
    if slot >= crate::array::keys_array_len_capped_to_capacity(keys) as u32 {
        return false;
    }
    let stored = crate::array::keys_array_slot(keys, slot);
    crate::string::js_string_key_matches(stored, key)
}
