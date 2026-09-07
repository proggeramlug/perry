# Full mark probe and in-place-promotion census

## Result and revision

Diagnostics implementation SHA: `6f303fa9c07b6d749b4b5801903fc4c336e26f4b`.
The report is the final, report-only descendant on branch
`diag/gc-full-mark-probe`; use the branch-head SHA proved by `git ls-remote`
for the perrymaster relink.

The original worktree's linked `.git` directory was read-only. I made the
required shared clone at `/private/tmp/tn-lock-full-probe`, fetched the real
`origin/main`, and used that clone's writable Git metadata with the requested
worktree. The branch starts at `origin/main` SHA
`43200e9d41c2a95415b83bfde3a297b0589c7d6f`.

This is diagnostics-only. Runtime reads and non-initialization marker writes
are behind the cached `gc_verify_mark_enabled()` result. No collector repair
is included.

## Full marks-final boundary

The hook is in `GcCycleState::step_sweep`, inside the one-time
`self.sweep_state.is_none()` entry. It runs after the finalize-to-sweep gap
drain, after `incremental_mark_barrier_disable()`, and after
`finish_full_trace()`, but before `IncrementalSweepState::new` creates a sweep
snapshot or frees an object. It calls, in this order:

1. `verify_marked_heap_report_nonfatal("full")`
2. `verify_array_pointer_slots_enumerated_report("full")`
3. `verify_full_promoted_blocks_report(scan_site, trigger_kind)`

Because the call is before sweep-state construction, it runs exactly once per
full cycle even when later sweep work is sliced. The synchronous path traced
was `gc_collect_full_mark_sweep_with_trigger` -> `GcCycleState::new_full` ->
`run_to_completion` -> `GcCycleState::step_sweep`. The incremental path traced
was `gc_start_budgeted_full_cycle` -> `GcCycleState::new_full` -> budgeted
`step` calls -> the same `GcCycleState::step_sweep`. Thus both entry points,
and future full entry points that use the universal `new_full` constructor,
reach the same boundary.

The full probe emits the existing verifier formats with a `full` phase:

```text
[gc-mark-verify:full] marked->UNMARKED edges=<n> checked_marked=<n> checked_edges=<n> | first parent=0x<addr> ptype=<name>(<id>) slot=0x<addr> child=0x<addr> ctype=<name>(<id>)
[gc-mark-verify:full] OK (no marked->unmarked) checked_marked=<n> checked_edges=<n>
[gc-array-slots:full] UNENUMERATED slots=<n> arrays=<n> pointer_slots=<n> | first array=0x<addr> index=<n> length=<n> reserved=0x<word> child=0x<addr>
[gc-array-slots:full] OK arrays=<n> pointer_slots=<n>
```

## Promoted-block provenance and census

`ArenaBlock` has a diagnostic provenance bit,
`promoted_in_place_since_full`. Every constructor initializes it false.
`finish_in_place_promotion` caches `gc_verify_mark_enabled()` once and writes
the bit true on the promotion path only: one store per promoted block, not per
object. After the full sweep's linear arena-object walk completes,
`IncrementalSweepState::step` clears the marker on old blocks, and that clear
also runs only with verify-mark armed.

At the marks-final boundary the census walks marked blocks in `OLD_ARENA` by
the same 8-byte-aligned `GcHeader::size` hop used by
`finish_in_place_promotion`. It emits exactly one line per full cycle:

```text
[gc-full-verify] site=<site-or-precise> trigger=<kind> promoted_blocks=<n> promoted_objs marked=<n> unmarked=<n> tenured_flag_missing=<n> page_index_missing=<n> | first_unmarked=0x<addr> type=<name>
```

Counter derivation:

- `promoted_blocks`: old blocks whose provenance bit is set.
- `marked` / `unmarked`: arena-walkable headers in those blocks, partitioned
  by `GC_FLAG_MARKED` at the pre-sweep boundary.
- `tenured_flag_missing`: those headers without `GC_FLAG_TENURED`.
- `page_index_missing`: marked headers for which at least one overlapped page
  lacks the header in `OLD_GEN_PAGE_OBJECTS`, after applying the same deferred
  registration flush and promoted-run materialization contract as other page
  index readers.
- `first_unmarked`: address and registered type name of the first unmarked
  walkable header, or `0x0 type=none`.

Current `main` has an architectural difference from the fault brief worth
making explicit: synchronous `BuildValidPointerSet` validates conservative
roots against its address-ordered arena census, while budgeted cycles use the
generation/object-start classifier. It no longer consumes
`OLD_GEN_PAGE_OBJECTS` directly. The new `page_index_missing` counter therefore
checks the actual old-generation page object index used by remembered-set and
promotion readers; the simultaneous stack-rejection probe checks the exact
valid-pointer-set decision independently. This keeps the two proposed H2
signals separately observable instead of claiming they are the same lookup on
this revision.

The site is captured only when verify-mark is armed. It reuses the existing
`SCAN_FALLBACKS` thread-local record by extending its value with an
`active_site` field; no new runtime thread-local was added. An engaged
`ManualGcScanGuard` sets/clears that field only under the cached verify flag.
`GcCycleState::new_full` snapshots it, yielding
`site=old_reclaim_alloc_point` for the faulting path and `site=precise` when no
named forced scan covers the collection.

## Conservative rejection report

`mark_stack_roots_unchecked` creates one report accumulator only for a full
scan (`pin_only_old == false`) with verify-mark enabled. Each of its register,
frame-pointer-register, and stack loops retains the original successful arm:
if `try_mark_conservative_word` accepts a candidate, it only increments the
root count. The diagnostic is called solely from the `else` rejection arm.
With the flag off, a rejected word pays at most the accumulator's one cached
boolean test; accepted words execute no new diagnostic call or lookup.

For a rejected NaN-boxed candidate the diagnostic tests its decoded pointer;
for a rejected raw word it tests the raw address. Only candidates inside a
reserved arena block count. Header plausibility reads `obj_type` and `size`
only when a full header fits inside the block's initialized `used` range, at
the candidate or candidate minus `GC_HEADER_SIZE`; it additionally requires a
walkable type, a header-sized object, and an object end within that used range.
The first three records are retained. The first/zero summary is:

```text
[gc-full-verify] stack_words_rejected_in_blocks=<n> first=0x<word> block=0x<base> space=<name> header_plausible=<yes/no> type=<name>
[gc-full-verify] stack_words_rejected_in_blocks=0 first=0x0 block=0x0 space=none header_plausible=no type=none
```

If present, records two and three follow as:

```text
[gc-full-verify] stack_word_rejected_sample=<2-or-3> word=0x<word> block=0x<base> space=<name> header_plausible=<yes/no> type=<name>
```

## Tests and gates

Immediately before the Cargo gates, `df -g /` reported only **4 GB**
available, below the required 12 GB. Accordingly no Cargo command was run.

- `full_mark_probe_reports_marked_to_unmarked_edge`: **not run: disk**. It
  drives `gc_collect_full_mark_sweep_with_trigger` with a manually marked old
  parent and a planted unmarked young child, then asserts the captured
  `[gc-mark-verify:full] marked->UNMARKED` line. Sabotage expectation: removing
  the call from `GcCycleState::step_sweep` leaves no captured line, so the
  assertion fails. Sabotage execution: **not run: disk**.
- `alloc_point_full_after_in_place_promotion_keeps_stack_held_objects`:
  **not run: disk**. It uses `GcTestIsolationGuard`, moving pacing, suppressed
  automatic thresholds, active generated barriers, and the existing
  `InPlacePromotionTestGuard::enabled(1000)` setup. It plants 2,000 mixed
  object/array/string roots, verifies a traced whole-block promotion, removes
  the shadow frame, adds fresh young children to promoted parent slots, keeps
  roots only in a black-boxed native-stack array, and drives exactly
  `clear_old_reclaim_state(); reset_scan_fallback_counters(); arm_old_reclaim();
  gc_check_trigger();`. It verifies every recorded parent/root/child header and
  slot plus zero H2 counters. No runtime counters are available because the
  test could not run. Probe sabotage was therefore not attempted; it needs a
  test-only one-shot hook in `arena/promote.rs::stamp_and_index_block`, at the
  traced live-header page-run aggregation before `flush_page_run`, to omit one
  promoted header from registration.
- Existing `gc::tests::{scan_fallback, promote_in_place, verify*}`:
  **not run: disk**; their sources were not changed.
- Requested scoped release test command: **not run: disk**.
- Full `perry-runtime --lib`: **not run: disk**.
- `perry-runtime` release `wasm-host` build: **not run: disk**.
- Direct `rustfmt --edition 2021 --check` over every changed Rust file: pass.
- `git diff --check`: pass.
- `scripts/check_file_size.sh`: pass; no Rust file exceeds 2,000 lines.
- `scripts/check_thread_locals.py`: pass; no new runtime TLS declaration.
- `scripts/gc_runtime_root_holders.py`: pass after re-auditing and re-pinning
  the existing `PASS1_MARKED` non-moving snapshot window. The new verification
  walks run before its existing sweep-entry take, do not access that snapshot,
  and cannot relocate or allocate a managed object or invoke JS.

If the H2 test fails on the Linux box, its captured diagnostic lines are the
finding: record its counters and first addresses verbatim and stop collector
test work without fixing the collector.

## Perrymaster request: stage FMP

Relink `app-m6at` (the crashing m6at + adaptive-tenuring/S=1 arm) and `app-s2`
(S=2 pinned) against the branch-head SHA on their respective caches. Run
**N = 4** four-turn, 3300-token runs per arm with:

```text
PERRY_GC_VERIFY_MARK=1 PERRY_GC_DIAG=1
```

Also run both named tests on the Linux box:

```text
cargo test -p perry-runtime --release --lib -- --test-threads=1 full_mark_probe_reports_marked_to_unmarked_edge
cargo test -p perry-runtime --release --lib -- --test-threads=1 alloc_point_full_after_in_place_promotion_keeps_stack_held_objects
```

The falsifiers at the `old_reclaim_alloc_point` collection of a run that
throws are any of:

- a `[gc-mark-verify:full] marked->UNMARKED` line;
- `page_index_missing > 0`;
- `tenured_flag_missing > 0`;
- `stack_words_rejected_in_blocks > 0`.

The S=2 control should keep all three numeric H2 counters at zero and emit no
full marked-to-unmarked edge.

## Correction after the first box run (FMP on the arm-at tree, 2026-09-08)

The witness failed on its own expectations, not on the collector: the census
showed `marked=2001 unmarked=1333 tenured_flag_missing=0 page_index_missing=0`,
`[gc-mark-verify:full] OK`, and three rejected stack words all equal to the
promoted block's BASE address (raw words, `header_plausible=yes type=string`).

- `unmarked=0` was wrong by construction: the test replaces every parent's
  original young child after the promotion, so the 1,334 original children in
  the promoted block are garbage at the full. The assertion is now
  `marked >= ROOTS` (parsed from the census line).
- `stack_words_rejected_in_blocks=0` was too strict: a raw word equal to a block
  base or a header address is a Rust bookkeeping pointer (`*mut GcHeader`,
  block base) and the scan is right to refuse it. The dropped-root shape is a
  NaN-boxed pointer at a plausible header that the valid-pointer set refused;
  the rejection line now carries `nanboxed_plausible=<n>` (and each sample
  `nanboxed=yes|no`), and the test asserts `nanboxed_plausible == 0`.
- The header-intact checks (all roots, all parents, all new children, and each
  parent slot still naming its child) are the decisive assertions and are now
  reachable.

Reading the cc rows: a nonzero `nanboxed_plausible` at the
`old_reclaim_alloc_point` full of a run that throws is the H2 signature;
`stack_words_rejected_in_blocks` alone is not.
