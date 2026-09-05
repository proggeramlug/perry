**The `ArenaBytes` trigger arm now requires that the collection it schedules can
act on the thing that made it due** — and on the compiled claude-code TUI that
removes 22 % of all copying minors while *increasing* total bytes reclaimed.

The arm is due on `arena_total_bytes()` and, under generational GC, schedules a
copying **minor**. A minor cannot lower that total: promotion hands Eden's
blocks to the old generation, and a committed block keeps its bump offset, so
only a whole-block release moves it. Old-generation growth was therefore
ordering young collections.

Measured (3300-character streamed reply, `PERRY_GC_DIAG=1`, one line per firing
rather than per trigger evaluation), the two arms of the same predicate were
doing completely different work:

| median per firing | `ArenaBytes` | `MallocCount` |
|---|---|---|
| nursery occupancy at the collection | 545 KB | 12.2 MB |
| `survival_permille` | 569 — the nursery is mostly **live** | 257 |
| bytes freed | 131 KB | 10.0 MB |

`ArenaBytes` was paying the full fixed cost of a collection — root scan,
`restore_surviving_dirty_coverage`, the side-table prunes, ~440 M address
classifications a turn — to evacuate a nursery that had not died yet.

This is precisely the mistake `young_scavenge_cap_due` was moved off, and that
function's own doc comment predicted this data: comparing a young-generation
budget against the total "put every old-gen byte on the young budget … every
fresh 1 MB Eden block re-crossed the trigger, degenerating the scavenge cadence
to once-per-block on any program with a large tenured set". The cap arm was
fixed. This one was not — and it is tested *first*, so it claimed the collection
before the cap arm was ever consulted.

**This is not a cadence change, and the bound is what makes that true.** Eden
occupancy only grows between collections, so an arm skipped here is retried
after at most one `BLOCK_SIZE` of further allocation: the deferral is bounded by
one block, by construction. The same bytes are collected, in fewer and
better-timed collections. Measured against the pre-registered falsifier, on one
binary through the `PERRY_GC_ARENA_YOUNG_BASIS` gate so no build difference can
be confounded with the change:

| 3300-char reply | basis off (old) | basis on (fix) |
|---|---|---|
| copying minors | 100 | **78** |
| `ArenaBytes` firings | 51 | 30 |
| their median `survival_permille` | 569 | **364** |
| their median bytes freed | 131,560 | **775,264** |
| **total bytes reclaimed, all minors** | 695,339,080 | **719,571,952** |

Fewer collections and *more* reclaim is the signature of removed work rather
than deferred work; had reclaim fallen with the collection count, the change
would have been a pacing knob and is rejected on those terms.

A cycle that would escalate to a **full** passes through unconditionally: a full
releases blocks and therefore can lower the total the arm measures, so for that
collection the basis is the correct one. Old-generation growth keeps its
existing watchers — `OldReclaim` is tested before this arm, and
`arena_growth_full_escalation_due` still escalates on the pacing reading.
`PERRY_GC_ARENA_YOUNG_BASIS=0` restores the previous basis.
