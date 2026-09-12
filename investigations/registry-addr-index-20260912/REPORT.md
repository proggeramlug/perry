# Sizing the canonical-handle index: −7.63% command CPU, node gap 2.81× → 2.60×

**Retain this.** Minimum command CPU falls from **1.18 to 1.09 seconds
(−7.63%)**; the candidate is faster in four of five interleaved pairs and tied in
the fifth. Startup-plus-command minima fall 2.15 → 2.05 s (−4.65%) and every
pair improves. Startup minima are unchanged at 0.95 s. The largest per-pair
peak-RSS increase is **+3.78%**, inside the campaign's budget. Against the node
arm measured in the same session (command 0.42 s), Perry goes from **2.81× to
2.60× node's minimum command CPU**.

## All pairs

| Pair | Control command CPU | Candidate command CPU | CPU change | Control peak RSS | Candidate peak RSS | RSS change |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 1.24 s | 1.24 s | 0.00% | 631.121 MiB | 632.707 MiB | +0.25% |
| 2 | 1.27 s | 1.19 s | −6.30% | 629.797 MiB | 632.074 MiB | +0.36% |
| 3 | 1.27 s | 1.09 s | −14.17% | 647.191 MiB | 632.270 MiB | −2.31% |
| 4 | 1.20 s | 1.16 s | −3.33% | 632.906 MiB | 656.840 MiB | +3.78% |
| 5 | 1.18 s | 1.12 s | −5.08% | 632.141 MiB | 634.508 MiB | +0.38% |

Command CPU medians are 1.24 → 1.16 s; the paired median change is −5.08%. CPU
accounting has hundredth-second granularity, so five pairs support a positive
result of this size, not a precise universal figure. Pair 4's +3.78% RSS is
**larger than the change's own footprint** — 2 KiB of static bit array plus a
live-address set of 643–648 entries, tens of kilobytes — so its cause is not the
structure and was not measured; pair 3's control is likewise 14–17 MiB above the
other four controls. Command wall minima fall 1.662 → 1.563 s (−5.93%) and every
pair improves.

Node anchor, same session, same bundle: command CPU **0.44 / 0.43 / 0.42 s**,
startup **0.64 / 0.63 / 0.63 s**, peak RSS **337.715 / 337.691 / 334.395 MiB**.
Parity remains unmet and this result does not change that conclusion; it removes
one named cost.

## What changed, and why it was worth changing

`value::addr_class`'s three cheapest predicates — `is_handle_band`,
`is_small_handle`, `is_above_handle_band` — each embed
`is_canonical_handle_addr`, so every heap pointer whose numeric arm cannot decide
consults a 1,024-bit Bloom filter, and a filter pass continues
`canonical_handle_parts_from_addr → handle_from_addr →
gc_malloc_header_is_tracked`, the exact malloc registry.

The [census](../canonical-filter-census-20260912/REPORT.md) measured that filter
admitting **66.25%** of 65,133,719 classifications per command while **0.021%**
of admissions found a real wrapper, against **643–648 live** wrapper addresses in
1,024 bits. The type's own sizing note anticipated the cliff and prescribed the
remedy — "if a corpus is found sitting on the wrong side of it, raise `WORDS`" —
but `WORDS` was one shared constant, and the note also records that bits accrue
per admission, so a larger fixed filter only postpones saturation.

`RegistryAddrIndex` does both halves. `WORDS` becomes a per-owner parameter and
the canonical owner takes 256 words (16,384 bits, 2 KiB, L1-resident). Beside the
bit array it keeps an exact set of the addresses the owner currently holds,
mutated only when a wrapper is created or retired — 712–721 and 69–76 times per
command, against tens of millions of probes — and recomputes the bit array from
that set once enough has changed. Refresh work is O(live) per O(live) changes, so
it is amortized O(1) and needs no interval, schedule or workload-specific
setting. **The hot side is untouched**: the same three bit tests on a plain array
of atomics, no lock, no allocation, no pointer chase.

Overwriting bits is what the monotone filter deliberately refused to do, so the
argument is written out in full on the type. In short: admissions and refreshes
for one index are serialized by the same guard, so no admission can be lost to a
refresh; the new words are computed from the complete live set, so every live
address's three bits are set in both the old and the new value, and every mix a
concurrent reader can observe still admits every live address. No reader can see
a false negative at any instant. A stale `true` for a retired address costs the
authoritative lookup that was always there, exactly as a Bloom false positive
does — and the authoritative lookup is unchanged, which is why a missed
retirement can only cost performance, never correctness.

## The mechanism, measured

Three census rows against the same change built with counters:

| Command phase, 3 rows summed | Before | After | Change |
|---|---:|---:|---:|
| Classifications | 65,133,719 | 64,809,993 | same workload |
| Filter passes | 43,150,678 | **144,246** | **−99.67%** |
| Passes resolving to a wrapper | 9,225 | **9,225** | **identical** |
| Pass rate | 66.25% | 0.223% | 298× more selective |

`RESOLVED` is 3,075 in every row of both arms: the index changes which addresses
reach the authoritative lookup, not what it answers. Startup passes are now 100%
genuine, against 4.47% before.

## Validation and evidence

Runtime change: `perf/registry-addr-index-20260912` (`d3bd47879`) against the
retained own-read-cache candidate base `4ca8ec59a`; three files, +386/−28. The
census arm is `diag/canonical-filter-census-20260912`.

Focused tests, on this box, verbatim:
`test result: ok. 33 passed; 0 failed; 0 ignored; 0 measured; 3257 filtered out`.
Three of the 33 are new and each fails without the change: the measured
644-address population at both widths (a 1,024-bit witness of the same population
admits **80.4%** of non-members), retirement narrowing the index while keeping
every live address, and 20,000 churned addresses against 64 resident ones not
walking to saturation. Disabling the refresh fails two of them; reverting the
width fails the third. `native_handle` (15) and `addr_class` (8) tests pass
unchanged. This is a focused set, not the repository's full gap gate, and no
broad CI verdict is claimed.

Control is the retained own-read-cache candidate reused by exact digest
`42bfb149…`; candidate is `4bc0b160…`. Compiler, object cache and bundle are
unchanged (`d4d3f467…`, bundle `bc335828…`, node v26.8.1). All 13 rows reconcile
against the raw receipt; the analyzer's own controls reject a removed row and a
modified CPU value. Load1 before the rows ranges 1.27–1.62. The whole comparison
held the campaign lock.

[Summary and statistics](results/summary.json), [exact rows](results/rows.csv),
[paired deltas](results/paired-changes.csv), [pair binding](results/build.execution.json),
[source receipt](results/source-receipt.sha256), [driver controls](results/driver-controls-v2.json).

## What is left

Two sibling filters of the same type are still saturated on the same workload and
are not touched here: `BUFFER_LIKE_ADDR_FILTER` ends every row with **all 1,024
bits set**, and `CLASS_PROTOTYPE_ADDR_FILTER` sits at 811–834 of 1,024. Both
have admit and removal funnels, but both are re-keyed by the moving collector, so
each needs its own audit: a retirement that misses the old address after an
evacuation would grow the live set without bound, and an admission that misses
the new one would be a false negative. `SYMBOL_ADDR_FILTER` (261–274 bits) still
discriminates and needs nothing.

The 232 call sites of the three range predicates are untouched. Separating the
numeric range test from semantic receiver classification at each site remains the
larger architectural change the caller census recommended, and it is independent
of this one.
