**The `ArenaBytes` threshold is now priced by what the collection actually
freed** — the rule #9589 established for the idle reducer, applied to the
trigger, where the productivity signal already existed and was being discarded.

`gc_finish_arena_trigger_collection` maintains an adaptive `step`: it halves
toward a 16 MB floor when a collection reclaims 25–84 %, and doubles toward
`GC_THRESHOLD_MAX_BYTES` (1 GB) when it reclaims outside 10–84 %. A saturated
step is the collector stating that these collections free nothing. That step
then reached the threshold through

    next = max(min(new_total + step, ceiling), new_total + headroom_floor)

and `gc_trigger_absolute_ceiling_bytes()` is a quarter of the device budget
capped at 128 MB, while `step` *starts* at 128 MB — so `new_total + step`
clears the ceiling on the very first collection and `capped` is pinned at the
ceiling for the rest of the process. Once `new_total` passes
`ceiling − headroom_floor`, the `max` selects the floor every time, and `step`
stops affecting the answer at all.

Measured on the compiled claude-code TUI (3300-character streamed reply,
`PERRY_GC_DIAG=1`, 66 `[gc-step]` lines): median `pct_freed` **0 %**, median
`sweep_freed` **203 KB**, median `block_reclaim` **65 KB**, and `step` already
saturated at **1,073,741,824** while `pre_in_use` ran to 297 MB. **The backoff
was at maximum and inert**: the arm still re-armed at `new_total + 16 MB` and
fired **51 times in one reply**, each freeing a median of 131 KB, against
`MallocCount`'s 10.0 MB per firing in the same run.

The headroom is now `max(headroom_floor, min(step, ceiling))`, so an
unproductive collection earns room in proportion to how little it achieved,
while a productive one — whose step halves toward the floor — still collects
promptly. It stays bounded by the same ceiling constant the adaptive trigger
already respects, so backing off cannot run away with the heap.

`arena_trigger_headroom_bytes` is split out as a pure function because the bug
was invisible in the fused expression, and `gc::tests::arena_trigger_pricing`
asserts the three properties directly: a productive collection keeps the floor,
an unproductive one earns strictly more, and the result is bounded by the
ceiling. Restoring the old arithmetic fails exactly the second and third and
leaves the first passing.

This deliberately changes only *when* the same collection runs again — not what
collection runs, and not the dueness predicate. `make_arena_trigger_due()`, the
shared fixture seven test modules use to make the collector do something, is
untouched.
