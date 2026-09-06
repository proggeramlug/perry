**The `ArenaBytes` trigger arm now gets first *refusal* rather than first
*claim***, so a collection whose fixed cost is paid anyway goes to the arm that
can do something with it.

The arm is due on `arena_total_bytes()` and, under generational GC, schedules a
copying **minor** — which cannot lower that total: promotion hands Eden's blocks
to the old generation, and a committed block keeps its bump offset. Old-gen
growth was ordering young collections. Measured on the compiled claude-code TUI
(3300-character reply, `PERRY_GC_DIAG=1`, one line per **firing** rather than
per trigger evaluation):

| median per firing | `ArenaBytes` | `MallocCount` |
|---|---|---|
| `survival_permille` | **569** (791 on a second binary) | 257 (48) |
| nursery occupancy | 545 KB | 12.2 MB |
| bytes freed | **131 KB** | **10.0 MB** |
| root-scan cost | 11,234 µs | 32,291 µs |

`ArenaBytes` was paying the full fixed cost of a collection to evacuate a
nursery that had not died yet. The root scan alone is essentially the whole cost
of one of those minors — 11.2 ms against a 110 KB copy — and every collection
pays it regardless of which arm claimed it. So when two arms are due at the same
moment, *which* one claims decides how much work that fixed cost buys, and it is
not a neutral label: `copied_minor_malloc_sweep_due()` gates the malloc sweep on
the trigger kind, so a collection claimed by `ArenaBytes` sweeps no malloc
objects at all.

When the arena arm is due but its minor cannot act on what made it due — the
young generation holds less than one `BLOCK_SIZE` — the collection is offered to
an arm that can. If none is due, **the arena arm still fires, on the same
evaluation**. There is no deferral, nothing waits on mutator behaviour, and
there is no cadence bound to justify: yielding decides which arm collects, never
whether one does.

The offer goes only to an arm whose collection will actually run.
`YoungScavengeCap` is deliberately not one: a budgeted cycle is
`low_pause_non_moving` and cannot lower the quantity that trigger tests, so
`gc_runtime_safepoint` declines it and hands the pressure to the precise moving
minor (#7909). Yielding to it would turn "a collection is scheduled" into
"nothing is scheduled". That is not reasoning —
`a_nursery_cap_only_trigger_is_deferred_to_the_collector_that_can_discharge_it`
failed in exactly its **control** phase when an earlier draft yielded to the
cap, which is what that phase exists to catch.

`gc::tests::arena_yield` pins all three directions: arena pressure with a quiet
nursery still collects (the bound, and it is zero); a due malloc arm takes the
collection from a stalled arena arm; a nursery above one block keeps the arena
arm's claim. Removing the fallback fails the first of those **and** reproduces
the exact failure set — `host_safepoints`, `budgeted_step_api` — that refuted an
earlier variant which declined outright.

Three earlier attempts and why each was refuted are recorded in
`secret-tests/cc-perf-campaign/HANDOFF_arenabytes_solution_space.md`; the
latent backoff defect found along the way is issue #9831.
`PERRY_GC_ARENA_YIELD=0` restores first-claim ordering.
