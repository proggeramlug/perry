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

## H4: mask-free verifier and the generated-store witness

Implementation commit: `c25116db788248b3b45211e8fcb5a27bfa8b82ab`.
This change is diagnostics and tests only; it does not repair or otherwise
change collector behavior. The new verifier runs once at the existing
marks-final entry to `GcCycleState::step_sweep`, only for a full trace and only
when `gc_verify_mark_enabled()` is true. The existing `[gc-full-verify]` and
`[gc-mark-verify:full]` lines are unchanged.

### Mask-free line and derivation

Every full emits this summary (the suffix after `|` describes the first bad
edge, or uses zero/`none` values when there is no bad edge):

```text
[gc-mark-verify:full-maskfree] unmasked_live_edges=<n> masked_parents_checked=<n> words_checked=<n> | first parent=0x<addr> ptype=<name> has_mask=<yes/no> descriptor_visited=<yes/no> promoted_block=<yes/no> parent_space=<old_page|promoted|nursery|malloc> slot_index=<i> child=0x<addr> ctype=<name>
```

Up to two additional examples use the same fields on lines beginning:

```text
[gc-mark-verify:full-maskfree] sample=2 ...
[gc-mark-verify:full-maskfree] sample=3 ...
```

Field derivation:

- `unmasked_live_edges` counts mask-free JS-value words in marked Object and
  Closure parents that resolve through `current_heap_header_for_heap_word` to
  a child with neither `GC_FLAG_MARKED` nor `GC_FLAG_PINNED`. Only
  pointer/string/bigint NaN-box tags are candidates. Weak-target trace slots
  are excluded with `weakref::is_weak_target_trace_slot`, as in the existing
  verifier.
- `masked_parents_checked` counts checked parents for which the real layout
  lookup finds either a `LAYOUT_SLOT_MASKS` entry or a typed-layout entry. It
  does not infer mask presence from header bits.
- `words_checked` counts every bounded physical JS-value payload word visited:
  Object inline words, legacy overflow/dynamic-property value words, Closure
  captures, and Closure dynamic-property value words. Object spill arrays are
  separately covered by the existing mask-free array verifier. Bounds come
  from the header's `size`, never from an untrusted logical length alone.
- `descriptor_visited` is address membership in the slot-address vector
  collected once for that parent by `visit_gc_rewrite_slots` before the
  mask-free walk.
- `promoted_block` comes from the arena block's existing
  `promoted_in_place_since_full` diagnostic provenance bit.
- `parent_space` is `malloc` for `MALLOC_STATE`, `promoted` for an arena block
  with that provenance bit, `nursery` for either young semispace, and
  `old_page` for another arena block.
- `slot_index` is the physical inline/capture index; dynamic-property value
  slots continue after the fixed physical payload so samples remain distinct.
  `ptype` and `ctype` use the registered GC type names.

### Store-path audit

The crucial distinction is between a barrier entry point and a complete
generated store. The barrier functions maintain incremental marking and the
remembered set; they do not maintain the layout descriptor. The complete
field-store lowering normally emits a separate layout note between its raw
store and its barrier call.

| Store path | Source | Reaches `layout_note_slot`? | Condition / audit result |
|---|---|---|---|
| Generated Object/class field store | `crates/perry-codegen/src/expr/write_barrier.rs:821-926` | Yes, as a separate emitted call | Raw store is at line 840, layout selection/note at 876-905, then `js_write_barrier_slot` at 906-926. The note is elided only for a value proven non-pointer, or for a pointer-declared slot while `SIDE_MASK|INTACT` proves that the existing descriptor already includes it. A per-object mask whose target slot was numeric is not `INTACT`, so a pointer replacement takes the note path. |
| Generic generated JS-value slot store | `crates/perry-codegen/src/expr/write_barrier.rs:932-1002` | Yes, as a separate emitted call | Raw store at 962; note at 983-999; barrier at 1001-1002. Elision has the same proof obligations as above. |
| Generated generation-tested barrier | `crates/perry-codegen/src/expr/write_barrier.rs:201-237` | No | Calls `js_write_barrier_slot_validated_parent` only after its caller has handled layout. It is not a complete store. |
| `js_write_barrier_slot` | `crates/perry-runtime/src/gc/barrier_store.rs:206-208` | No | All parent generations; barrier work only. Raw store plus this entry point, with no separate generated note, is the H4 candidate exercised by the witness. |
| `js_write_barrier_slot_validated_parent` | `crates/perry-runtime/src/gc/barrier_store.rs:225-250` | No | Tenured parent already validated by generated code; barrier work only. |
| `write_barrier_slot_inner` / `runtime_write_barrier_slot` | `crates/perry-runtime/src/gc/barrier_store.rs:26-32,252-278` | No | All parents; marking/remembered-set logic only. A direct post-store call does not update an existing mask. |
| `newborn_parent_needs_barrier` | `crates/perry-runtime/src/gc/barrier_store.rs:373-377` | No | Merely decides whether newborn barrier replay is required; it does not note a slot. |
| `runtime_store_jsvalue_slot` | `crates/perry-runtime/src/gc/barrier_store.rs:103-132` | Yes | All parents, unconditionally at line 130 after the raw store and before the barrier. This is the control path. |
| Deferred boxed-Object runtime store | `crates/perry-runtime/src/gc/barrier_store.rs:74-98`; `crates/perry-runtime/src/object/mod.rs:1766-1783` | At construction finish, not per store | Restricted to deferred newborn construction; `layout_finish_deferred_boxed_object` installs the conservative result. It is not a general old-parent mutation path. |
| Fixed/runtime external GC stores | `crates/perry-runtime/src/gc/barrier/runtime_stores.rs:7-42` | No | Fixed-descriptor or externally visited storage; these paths do not select dynamic payload words through a per-object layout mask. |
| External JS-value store with layout | `crates/perry-runtime/src/gc/barrier/runtime_stores.rs:47-58` | Yes | All parents, unconditionally at line 56. |
| Object field helper | `crates/perry-runtime/src/object/mod.rs:1747-1763` | Yes | `note_object_field_slot` notes directly; `store_object_field_slot` delegates to the always-noting runtime store. |
| Object spill store | `crates/perry-runtime/src/object/spill.rs:65-79,500-529` | Yes | Fast spill slots and both overflow update paths note for all parents before their barrier. |
| Array slot helpers | `crates/perry-runtime/src/array/header_gc_slots.rs:45-164` | Yes | Direct, resolved, layout-only, and general stores all note. The aware path skips only scalar-to-scalar or pointer-to-pointer classification-preserving writes; a numeric-to-pointer replacement notes. |
| Array rebuild/growth replay | `crates/perry-runtime/src/array/header_gc_slots.rs:167-290` | Rebuild, then barrier replay | Full/exact rebuild creates the current layout before any old-parent replay. Growth replay needs no per-slot note because it consumes that rebuilt/copied layout. |
| Array hole/numeric stores | `crates/perry-runtime/src/array/header.rs:1312-1317,1685-1736` | Yes | Hole fill and numeric store/push paths note; numeric values are pointer-free by construction. |
| Generated array push/index stores | `crates/perry-codegen/src/expr/array_push.rs:220-226,291-321`; `crates/perry-codegen/src/expr/index_set_guarded.rs:208-290` | Yes | A pointer classification change reaches the full or aware layout note before the generation-tested barrier. |
| Closure bulk birth | `crates/perry-runtime/src/closure/alloc.rs:340-351` | Full initialization | `layout_init_from_slots` observes all captures before newborn barrier replay. |
| Closure capture update/rebuild | `crates/perry-runtime/src/closure/alloc.rs:372-393,763-775` | Yes | Individual updates call `note_closure_capture_slot`; rebuild scans all captures, then replays barriers. |
| Layout-aware note | `crates/perry-runtime/src/gc/layout.rs:994-1036` | Conditional by classification | Pointer/scalar classification changes reach `layout_note_slot`; scalar-to-scalar and pointer-to-pointer need no mask-bit change. |
| Exported layout notes | `crates/perry-runtime/src/gc/layout.rs:1084-1110` | Yes / classification-aware | `js_gc_note_slot_layout` always notes; the aware export uses the classification rule immediately above. |

No complete generated field/array store inspected writes a pointer into a
previously numeric masked slot without a layout note. The concrete H4
candidate is therefore the low-level composition “raw slot store + barrier
entry point” if any caller uses it without the emitter's separate note. The
generated-path witness deliberately instantiates precisely that composition,
as requested; it must not be read as evidence that the full field emitter
omits its preceding note.

### H4 witnesses

Both tests build 200 eight-slot Objects. Slot 0 is initially a pointer, slot 3
is initially a number, and each parent is asserted to have a real per-object
layout entry before a traced whole-block in-place promotion. A shadow frame
and a black-boxed native-stack array retain the parents. After promotion, each
slot 3 receives a fresh young child and the test drives exactly
`clear_old_reclaim_state(); reset_scan_fallback_counters();
arm_old_reclaim(); gc_check_trigger();`, asserting one
`OldReclaimAllocPoint` fallback. Every child header/type/size and parent slot
is then checked, along with
`[gc-mark-verify:full-maskfree] unmasked_live_edges=0`.

- `full_mask_stays_current_after_generated_store_into_promoted_parent` uses a
  raw slot store followed by `js_write_barrier_slot`, with no
  `runtime_store_jsvalue_slot` and no manual layout note. Expected negative
  witness result: the stale mask omits slot 3, the line reports nonzero
  `unmasked_live_edges`, and the test fails before accepting damaged children.
- `full_mask_stays_current_after_generated_store_into_promoted_parent_control_runtime_store`
  performs the same replacement through `runtime_store_jsvalue_slot`.
  Expected result: zero missing edges and intact children. Sabotage
  expectation: dropping the control's layout note must make it fail like the
  barrier-only arm. Sabotage execution was **not run: disk**, so this report
  cannot claim the expected failure was observed.

The H4 tests themselves were not run locally. Therefore there are no failure
lines to record verbatim and no runtime H4 finding yet. Per the stop rule, if
perrymaster observes the generated-path failure on this setup while the
control passes, its verifier and assertion lines are the finding: append them
verbatim and stop without collector repair.

### H4 gates

Immediately before the Cargo gates, `df -g /` reported only **2 GB** available,
below the required 12 GB. No Cargo command was run; the executed test count is
zero.

- `cargo test -p perry-runtime --release --lib -j4 -- --test-threads=1 gc::tests::full_mark_probe`: **not run: disk** (0 tests ran).
- `cargo test -p perry-runtime --release --lib -j4 -- --test-threads=1 gc::tests::promote_in_place`: **not run: disk** (0 tests ran).
- `cargo test -p perry-runtime --release --lib -j4 -- --test-threads=1 gc::tests::scan_fallback`: **not run: disk** (0 tests ran).
- Verify-test filter (`gc::tests::verify`): **not run: disk** (0 tests ran).
- Full `cargo test -p perry-runtime --release --lib -j4 -- --test-threads=1`: **not run: disk** (0 tests ran).
- `cargo build --release -p perry-runtime --features wasm-host -j4`: **not run: disk**.
- `rustfmt --check`: pass (direct `rustfmt --edition 2021 --check` over all changed Rust files).
- `git diff --check`: pass.
- File-size gate: pass; all changed Rust files are below 2,000 lines.
- `scripts/check_thread_locals.py`: pass.
- `scripts/gc_runtime_root_holders.py`: pass.

### Perrymaster request: H4

On both the arm-at tree and plain `main`, apply/build the diagnostic test
revision and run the full module, with capture enabled:

```text
cargo test --release -p perry-runtime --lib -- --test-threads=1 --nocapture gc::tests::full_mark_probe
```

Record how many tests ran and paste both new tests' verifier and failure/pass
lines verbatim. If the generated-path variant fails on its asserted setup and
the runtime-store control passes, that is the H4 finding and collector work in
this lane stops.

Then relink the cc FMPrun arms to this diagnostic revision. Re-read the
throwing run's `site=old_reclaim_alloc_point` full for:

```text
[gc-mark-verify:full-maskfree] unmasked_live_edges=<n>
```

Any `unmasked_live_edges > 0` at that full is the mask-under-report signature;
record its first/sample lines verbatim and correlate the parent type, mask,
descriptor membership, promotion provenance, space, slot index, and child
type with the thrown turn.
