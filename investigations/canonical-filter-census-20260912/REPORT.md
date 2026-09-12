# The address filters stop filtering: 43.1 M empty registry queries per command

**Measured, three rows, one owned offline cc command each.** The runtime's
canonical-handle classification runs **65,133,719** times per command. The
1,024-bit Bloom filter that exists to reject those addresses cheaply admits
**43,150,678** of them (**66.25%**). Of the admissions, **9,225** find a real
canonical wrapper — **0.021%**. The other **43,141,453** are registry queries
with nothing in them: a thread-local resolution, a `RefCell` borrow and an exact
`PtrHashSet` probe each, which is the `gc_malloc_header_is_tracked` symbol the
profiles rank at **4.35% of command sampled cycles**.

The filter is not broken. It is **600× too small for its population**, and it
loses its selectivity inside a single process:

| Phase | Calls | Filter passes | Pass rate | Resolved | Live wrappers |
|---|---:|---:|---:|---:|---:|
| startup, row 1 | 15,792,978 | 4,232 | 0.0268% | 483 | 66 |
| startup, row 2 | 15,793,512 | 24,384 | 0.1544% | 477 | 63 |
| startup, row 3 | 15,798,184 | 3,370 | 0.0213% | 471 | 66 |
| command, row 1 | 21,604,693 | 14,329,746 | **66.33%** | 3,075 | 644 |
| command, row 2 | 21,679,684 | 12,517,886 | **57.74%** | 3,075 | 643 |
| command, row 3 | 21,849,342 | 16,303,046 | **74.62%** | 3,075 | 648 |

A guard that rejects 99.97% of addresses when the process reaches the prompt
rejects a third of them by the time one command finishes — **a 430–3,500× loss
of selectivity, same process, same binary, no configuration involved.**

## The cause is live population, not history

The filter is monotone: `admit` sets three bits and nothing ever clears them,
so retired wrappers keep their bits forever. That is a real defect, but it is
**not** the dominant one here. Per row the workload admits **712–721** wrapper
addresses and retires only **69–76**, leaving **643–648 live**. Three bits per
live address in 1,024 bits saturates the filter on the live set alone: at
n = 644, k = 3, m = 1,024 the false-positive rate is (1 − e^(−3n/m))³ ≈ 72%,
which is what the occupancy (908–919 of 1,024 bits) and the observed 57.7–74.6%
pass rate both show. Clearing retired bits would leave ~640 live addresses in a
filter that cannot hold 60.

So sizing is the first-order fix and reclamation is the second. Neither is
sufficient alone, and a fixed size is wrong for a process whose wrapper
population grows with session length: 644 live after **one** command.

## Three sibling filters, same type, same run

`RegistryAddrFilter` has four instances. Reading all four at the same phase
boundaries:

| Filter | Bits after startup | Bits after command | Estimated pass rate after command |
|---|---:|---:|---:|
| `BUFFER_LIKE_ADDR_FILTER` | 79–83 | **1,024 / 1,024** | **100%** |
| `CANONICAL_HANDLE_ADDR_FILTER` | 175–187 | 908–919 | 69.7–72.3% |
| `CLASS_PROTOTYPE_ADDR_FILTER` | 688–727 | 805–825 | 48.6–52.3% |
| `SYMBOL_ADDR_FILTER` | 261–274 | 261–274 | 1.7–1.9% |

**The buffer filter ends every row with every bit set.** Its `may_contain`
answers true for every address in the process, so the probe it guards runs its
full slow path unconditionally — `is_registered_buffer_slow` is 1.36% of command
sampled cycles in the same profiles. The class-prototype filter is already at
31% pass rate when the prompt appears. Only the symbol filter still works.

The type's own documentation names this state — "a filter whose bits are nearly
all set has stopped discriminating" — and `bits_set()` is marked *diagnostics
and tests only*. Nothing in the shipping runtime looks at it, so a filter that
has stopped filtering is indistinguishable from one that works.

## Why ordinary property work pays for it

`value::addr_class` embeds the canonical question in its three cheapest
predicates:

- `is_handle_band(addr)` = `addr < HANDLE_BAND_MAX || is_canonical_handle_addr(addr)`
- `is_small_handle(addr)` = `(1..HANDLE_BAND_MAX).contains(&addr) || is_canonical_handle_addr(addr)`
- `is_above_handle_band(addr)` = `addr >= HANDLE_BAND_MAX && !is_canonical_handle_addr(addr)`

For an ordinary heap pointer the numeric arm cannot decide, so every call runs
the filter, and a pass continues `canonical_handle_parts_from_addr →
handle_from_addr → gc_malloc_header_is_tracked`. The check is load-bearing
compatibility work, added when timer receivers became managed heap wrappers
(`9fcd96d1c`): callers that used to separate small integer handle ids from heap
pointers numerically must now also recognise high-address wrappers. It cannot
simply be removed.

The cost therefore lands on code that never asks about native handles.
Disassembling the measured candidate binary, **`js_object_get_field_by_name`
holds 27 references to the filter variable and 15 `bt` tests**; `extract_obj_ptr`
2, `normalize_raw_object_addr` 1, `prototype_next_is_canonical` 1,
`is_closure_ptr` 1. That matches the earlier caller census, where the largest
owners of the registry helper were ordinary property and pointer work
(`js_object_get_field_by_name` 20.44%, `is_closure_ptr` 14.13%,
`extract_obj_ptr` 13.44%) rather than handle code.

## What this does and does not price

It prices the **wasted work**: 43,141,453 empty registry queries per command,
against a measured 4.35% self share for the helper that serves them plus the
`handle_from_addr` prologue and the filter probe itself. It does **not** predict
a speedup. No fix is implemented here, and the arithmetic from the number of
removed calls to CPU seconds is exactly the inference the campaign forbids —
the next step is an implementation and an ordinary matched CPU/RSS comparison.

Counts come from runtime counters armed by `PERRY_CANONICAL_DIAG` and read from
outside the process at four phase boundaries by bounded read-only `pread`s of
named ELF variables, with process identity and load bias re-derived every time.
The instrument costs about 9% of command CPU (1.30–1.31 s instrumented against
the ordinary arm's 1.19 s), so these are counts from a nearly ordinary run, not
from a 30×-slower probe build. **This binary is not a CPU or RSS comparison
arm.** `RESOLVED` is identical at 3,075 in all three command phases, which is
what a deterministic replay should produce and is a check on the rows, not a
coincidence to explain.

Binary `cc-census` SHA `c0b32995d6ab001982233e0b171f8598984b4ad21de4212850df51474041471a`,
built from the retained own-read-cache candidate source plus the census counters
only. Rows, bindings and the full execution receipt are in
[results/](results/).

## Recommendation

Repair `RegistryAddrFilter` itself, once, for all four owners: the population it
must represent is known exactly at admission time, so the structure should be
sized from that population and should release retired addresses. An exact,
growing address index is the design that cannot degrade — its cost per probe is
a hash and one cache line, against the current three-word probe plus a 66%
chance of an exact registry query. Add a production check that a filter which
has stopped discriminating cannot pass silently; `bits_set()` already exists and
is currently only visible to tests.

Do not weaken the wrapper's compatibility contract: retirement, thread
ownership, the `NATIVE_HANDLE_MAGIC`/`obj_type` validation in `handle_from_addr`,
and the malloc/arena union in GC tracing all stay as they are. The 232 call
sites of the three range predicates are **not** part of this change; auditing
which of them need the semantic distinction is separate work.

## Fixed, and the mechanism is measured (2026-09-12, arm A)

`RegistryAddrIndex` sizes the canonical owner's bit array from its population
(256 words, 16,384 bits, 2 KiB) and recomputes it from an exact live-address set
as wrappers retire. Three rows of the same census against the fixed binary,
beside the three rows above:

| Command phase, 3 rows summed | 1,024-bit filter | Sized, reclaiming index | Change |
|---|---:|---:|---:|
| Classifications | 65,133,719 | 64,809,993 | same workload |
| Filter passes | 43,150,678 | **144,246** | **−99.67%** |
| Passes resolving to a wrapper | 9,225 | **9,225** | **identical** |
| Passes with nothing in them | 43,141,453 | **135,021** | −99.69% |
| Pass rate | 66.25% | **0.223%** | 298× more selective |

Per row the pass rate is 0.226% / 0.292% / 0.149% against 66.33% / 57.74% /
74.62%, and `RESOLVED` is **3,075 in every row of both arms**. That equality is
the correctness evidence: the index changes which addresses reach the
authoritative lookup, not what the lookup answers. In the startup phase every
one of the 1,443 passes now resolves to a real wrapper — a 100% hit rate,
against 4.47% before.

The live population is unchanged at 642–645, so the improvement comes from
sizing and reclamation, not from holding fewer addresses. The other three
filters are untouched in the same rows — `BUFFER_LIKE_ADDR_FILTER` still ends at
1,023–1,024 of 1,024 and `CLASS_PROTOTYPE_ADDR_FILTER` at 811–834 — which
confirms the change is scoped to one owner and leaves the other two saturated
filters as named follow-ups.

**This is still not a speedup measurement.** Both arms carry the census
counters, so neither is a CPU comparison arm; the matched CPU/RSS comparison
runs on a census-free build against the retained control.
