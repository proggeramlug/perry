//! Per-site construction cache for `js_regexp_new`.
//!
//! # What construction costs, and why
//!
//! A regex literal lowers to `js_regexp_new(<interned pattern handle>,
//! <interned flags handle>)`, so every evaluation of the same literal arrives
//! with the same `StringHeader` address. Construction nevertheless re-derived
//! everything from the TEXT:
//!
//! * `lazy::pattern_already_validated` built `(pattern.to_string(),
//!   flags.to_string())` and SipHashed the pair to ask a question whose answer
//!   is a pure function of the pattern — two copies and a hash of the whole
//!   pattern;
//! * `owned_pattern = pattern_str.to_string()` — a third copy;
//! * the `REGEX_SOURCE_TABLE` entry (#637: `.source`/`.flags` must survive GC
//!   of a temporary input string) took a fourth copy, per HEADER, so N live
//!   regexes over one literal retained N copies of its text.
//!
//! `emoji-regex` is a 12,807-character literal that `string-width` evaluates
//! once per measured text segment, and ink's layout pass measures every
//! segment of every line on every keystroke. That is ~50 KB copied and ~12 KB
//! SipHashed per construction, thousands of times per rendered reply.
//!
//! # The cache
//!
//! A small direct-mapped table keyed by the pattern `StringHeader` ADDRESS —
//! free to compute, and stable for a literal because the handle global holds
//! one interned string. An address is never trusted on its own: a hit is
//! confirmed by comparing the stored bytes against the incoming pattern and
//! flags, so a GC that recycles the address for a different string can only
//! cost a refill, never produce a wrong answer. `memcmp` of an equal 12 KB
//! pattern is ~20x cheaper than SipHashing it, and the hit path performs no
//! allocation at all.
//!
//! A hit yields the shared `Arc<str>` pattern and canonical flags, which the
//! header's `REGEX_SOURCE_TABLE` entry then SHARES: every live regex built
//! from one literal holds one pointer, not one copy of the text.
//!
//! Nothing here changes what is validated — a miss runs the unchanged
//! validation. The cache only records that a byte-identical pair already
//! passed it.

use std::cell::RefCell;
use std::sync::Arc;

/// Slots in the direct-mapped table. Sized to cover the literal sites a render
/// pass touches without becoming a scan; the cost of a collision is one
/// re-validation, so a miss is never wrong.
const SLOTS: usize = 512;

/// One remembered construction.
struct Site {
    /// The pattern `StringHeader` address this entry was filled from.
    addr: usize,
    /// The exact pattern bytes — the soundness check, not a hint.
    pattern: Arc<str>,
    /// The CANONICAL flags (sorted, deduplicated), which is what the header
    /// and the side table store.
    canonical_flags: Arc<str>,
    /// The raw flags the caller passed, checked so a different spelling of the
    /// same flags does not silently adopt the canonical form's validation.
    raw_flags: Arc<str>,
}

crate::perry_thread_local! {
    static SITES: RefCell<Vec<Option<Site>>> = RefCell::new(Vec::new());
}

#[inline]
fn slot_of(addr: usize) -> usize {
    // The low bits of a GC allocation address are alignment zeros; shift them
    // off before folding.
    (addr >> 4) % SLOTS
}

/// Look for a previous construction from this exact pattern address with these
/// exact bytes.
///
/// Returns the shared `(pattern, canonical_flags)` when the stored bytes match
/// — the caller may then skip validation and reuse the strings.
pub(super) fn lookup(
    pattern_addr: usize,
    pattern: &str,
    raw_flags: &str,
) -> Option<(Arc<str>, Arc<str>)> {
    if pattern_addr == 0 {
        return None;
    }
    SITES.with(|sites| {
        let sites = sites.borrow();
        let entry = sites.get(slot_of(pattern_addr))?.as_ref()?;
        if entry.addr != pattern_addr {
            return None;
        }
        // The address agreeing is a hint; the bytes agreeing is the answer.
        if &*entry.raw_flags != raw_flags || &*entry.pattern != pattern {
            return None;
        }
        Some((entry.pattern.clone(), entry.canonical_flags.clone()))
    })
}

/// Remember a construction that has just cleared validation.
///
/// Returns the shared strings so the caller stores the same allocation it
/// cached rather than a second copy.
pub(super) fn insert(
    pattern_addr: usize,
    pattern: &str,
    raw_flags: &str,
    canonical_flags: &str,
) -> (Arc<str>, Arc<str>) {
    let pattern_arc: Arc<str> = Arc::from(pattern);
    let canonical_arc: Arc<str> = Arc::from(canonical_flags);
    if pattern_addr == 0 {
        return (pattern_arc, canonical_arc);
    }
    SITES.with(|sites| {
        let mut sites = sites.borrow_mut();
        if sites.is_empty() {
            sites.resize_with(SLOTS, || None);
        }
        sites[slot_of(pattern_addr)] = Some(Site {
            addr: pattern_addr,
            pattern: pattern_arc.clone(),
            canonical_flags: canonical_arc.clone(),
            raw_flags: Arc::from(raw_flags),
        });
    });
    (pattern_arc, canonical_arc)
}

/// Drop every entry.
///
/// Nothing in the runtime needs this: the table is a pure memo whose hits are
/// confirmed by a byte compare, so a stale entry can only miss. It exists for
/// the tests, which must start from a known table.
#[cfg(test)]
pub(super) fn clear() {
    SITES.with(|sites| sites.borrow_mut().clear());
}

#[cfg(test)]
mod tests {
    /// A recycled address must not be able to answer for a different pattern:
    /// the byte compare, not the address, decides.
    #[test]
    fn address_reuse_with_different_bytes_misses() {
        super::clear();
        let addr = 0x4000usize;
        let (_p, _f) = super::insert(addr, "abc", "g", "g");
        assert!(super::lookup(addr, "abc", "g").is_some());
        assert!(
            super::lookup(addr, "abd", "g").is_none(),
            "same address, different pattern bytes must miss"
        );
        assert!(
            super::lookup(addr, "abc", "gi").is_none(),
            "same address, different flags must miss"
        );
        assert!(super::lookup(addr + 0x10, "abc", "g").is_none());
    }

    /// Two constructions from one literal share one allocation of the text.
    #[test]
    fn repeat_construction_shares_the_pattern_allocation() {
        super::clear();
        let addr = 0x8000usize;
        let (first, _) = super::insert(addr, "emoji", "gu", "gu");
        let (second, _) = super::lookup(addr, "emoji", "gu").expect("hit");
        assert!(
            std::sync::Arc::ptr_eq(&first, &second),
            "a hit must hand back the SAME allocation, not a copy"
        );
    }
}
