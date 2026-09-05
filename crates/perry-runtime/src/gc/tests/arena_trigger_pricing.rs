//! The `ArenaBytes` threshold must be priced by how productive the collection
//! that just ran was — the rule #9589 established for the reducer, applied to
//! the trigger.
//!
//! Before this, the productivity signal existed and was discarded.
//! `gc_finish_arena_trigger_collection` computes
//! `next = max(min(new_total + step, ceiling), new_total + headroom_floor)`.
//! `gc_trigger_absolute_ceiling_bytes()` is a quarter of the device budget
//! capped at 128 MB, and `step` starts at 128 MB, so `new_total + step` clears
//! the ceiling on the first collection and `capped` is pinned AT the ceiling
//! forever after. Once `new_total` passes `ceiling - headroom_floor` the `max`
//! always selects the floor, and `step` — by then doubled to its 1 GiB maximum
//! precisely because these collections free nothing — stops affecting the
//! answer at all.
use super::super::policy::{arena_trigger_headroom_bytes, GC_THRESHOLD_MAX_BYTES};
use crate::gc::heap_budget::{gc_trigger_absolute_ceiling_bytes, gc_trigger_headroom_floor_bytes};

/// A collection that reclaimed well keeps the tight floor: it earns collecting
/// again soon, which is the whole point of the 16 MB headroom.
#[test]
fn a_productive_collection_keeps_the_headroom_floor() {
    let floored_step = 16 * 1024 * 1024;
    assert_eq!(
        arena_trigger_headroom_bytes(floored_step),
        gc_trigger_headroom_floor_bytes(),
        "a collection whose step sits at the productive floor must not buy extra headroom"
    );
}

/// A collection that reclaimed nothing must earn MORE room than one that
/// reclaimed a lot. This is the assertion the old arithmetic could not satisfy:
/// above the ceiling it returned the floor for every step, so the two were
/// equal and the backoff was inert.
#[test]
fn an_unproductive_collection_earns_more_headroom_than_a_productive_one() {
    let productive = arena_trigger_headroom_bytes(16 * 1024 * 1024);
    let unproductive = arena_trigger_headroom_bytes(GC_THRESHOLD_MAX_BYTES);
    assert!(
        unproductive > productive,
        "a saturated step (the collector reporting that these collections free \
         nothing: measured median pct_freed 0 %, median sweep_freed 203 KB on a \
         3300-char claude-code reply) must widen the next threshold. \
         unproductive={unproductive} productive={productive}"
    );
}

/// …and it stays bounded by the same ceiling constant the adaptive trigger
/// already respects, so backing off cannot run away with the heap.
#[test]
fn headroom_is_bounded_by_the_absolute_ceiling() {
    assert_eq!(
        arena_trigger_headroom_bytes(GC_THRESHOLD_MAX_BYTES),
        gc_trigger_absolute_ceiling_bytes(),
        "an unbounded backoff would trade footprint for CPU, which this campaign rejects"
    );
    assert!(gc_trigger_absolute_ceiling_bytes() >= gc_trigger_headroom_floor_bytes());
}
