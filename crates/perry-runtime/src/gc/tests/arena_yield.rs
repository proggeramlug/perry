//! `ArenaBytes` offers the collection to an arm that can act; it never cancels
//! one.
//!
//! The arm is due on `arena_total_bytes()` and, under gen-gc, schedules a
//! copying minor — which cannot lower that total. Measured on the compiled
//! claude-code TUI, those collections land on a nursery that is 79 % live and
//! free a median of 131 KB, against `MallocCount`'s 95 %-dead nursery and
//! 10.0 MB, for the same ~11 ms root scan.
//!
//! Three earlier attempts to act on that are recorded in
//! `secret-tests/cc-perf-campaign/HANDOFF_arenabytes_solution_space.md`. The
//! one that mattered — declining the arm outright — broke 26 tests across seven
//! modules because arena pressure with a quiet nursery became served by
//! nothing. **The first test below is that hole, pinned**: it is the reason
//! yielding is safe where declining was not, and it must fail if the fallback
//! is ever removed.
use super::super::policy::{gc_budgeted_due_trigger_for_tests, BudgetedGcTrigger};
use super::super::policy::{GC_LAST_OLD_RECLAIM_IN_USE_BYTES, GC_OLD_RECLAIM_PENDING};
use super::support::{young_leaf, GcTriggerThresholdTestGuard};

/// Same shape the other GC test modules use: the old-gen arm is tested first in
/// `gc_budgeted_due_trigger`, so it must be quiesced or it answers instead.
fn reset_old_reclaim_pressure() {
    let old_in_use = crate::arena::old_gen_in_use_bytes();
    GC_LAST_OLD_RECLAIM_IN_USE_BYTES.with(|bytes| bytes.set(old_in_use));
    GC_OLD_RECLAIM_PENDING.with(|pending| pending.set(false));
}

/// **The bound, and it is zero.** No deferral, no waiting on the mutator, no
/// cadence to justify: when nothing better is due the arena arm fires on the
/// same evaluation it was consulted. A quiet nursery — the exact fixture that
/// refuted the declining variant — still collects.
#[test]
fn arena_pressure_with_a_quiet_nursery_still_collects() {
    let trigger_guard = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    reset_old_reclaim_pressure();
    // A handful of objects: deliberately far below the one-block bar at which
    // the arm considers its own minor able to act.
    let _ = young_leaf();
    trigger_guard.make_arena_trigger_due();

    assert!(
        crate::arena::copying_from_space_in_use_bytes() < crate::arena::BLOCK_SIZE,
        "fixture must present the quiet nursery this test is about"
    );
    assert_eq!(
        gc_budgeted_due_trigger_for_tests(),
        Some(BudgetedGcTrigger::ArenaBytes),
        "arena pressure must still schedule a collection when no arm that could \
         act on it is due — yielding decides WHICH arm collects, never whether \
         one does. Removing the fallback reintroduces the hole that refuted the \
         declining variant."
    );
}

/// And when an arm that will actually be discharged IS due, it gets the
/// collection — the same fixed root-scan cost buying the malloc sweep and a
/// 10 MB reclaim instead of 131 KB.
#[test]
fn a_due_malloc_arm_takes_the_collection_from_a_stalled_arena_arm() {
    let trigger_guard = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    reset_old_reclaim_pressure();
    let _ = young_leaf();
    trigger_guard.make_arena_trigger_due();
    trigger_guard.make_malloc_trigger_due();

    assert!(
        crate::arena::copying_from_space_in_use_bytes() < crate::arena::BLOCK_SIZE,
        "fixture must present a nursery the arena arm's minor cannot act on"
    );
    assert_eq!(
        gc_budgeted_due_trigger_for_tests(),
        Some(BudgetedGcTrigger::MallocCount),
        "with both due and the nursery below a block, the arm that can act takes it"
    );
}

/// A nursery the minor CAN act on keeps the arena arm's claim, so the yield is
/// scoped to the case it was measured for and does not quietly demote the arm
/// everywhere.
#[test]
fn a_full_nursery_keeps_the_arena_arms_claim() {
    let trigger_guard = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
    reset_old_reclaim_pressure();
    while crate::arena::copying_from_space_in_use_bytes() < crate::arena::BLOCK_SIZE {
        let _ = young_leaf();
    }
    trigger_guard.make_arena_trigger_due();
    trigger_guard.make_malloc_trigger_due();

    assert_eq!(
        gc_budgeted_due_trigger_for_tests(),
        Some(BudgetedGcTrigger::ArenaBytes),
        "above one block the arena arm's own minor can act, so it keeps the collection"
    );
}
