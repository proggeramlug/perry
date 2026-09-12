# The buffer filter is saturated and it does not matter: 88.9% of what it admits is real

**Do not build this fix.** `BUFFER_LIKE_ADDR_FILTER` ends every cc command with
all 1,024 bits set, and the instrument that ships beside it computes the obvious
verdict — "a 1,024-bit/3-hash Bloom holding all admissions would be 100.0%
false-positive". Read alone, that line sends you off to size the filter the way
the canonical-handle owner just was. It is the wrong conclusion, because the
same instrument records the number that decides it: **88.87% and 88.13% of the
addresses the probe admits are genuine registered buffers.**

Two rows on the retained control binary, no build, the shipping
`PERRY_BUFFER_DIAG` instrument:

| | Row 1 | Row 2 |
|---|---:|---:|
| Probes | 31,457,281 | 31,457,281 |
| Admitted by window + filter | 26,577,900 (84.49%) | 26,803,207 (85.21%) |
| Rejected before the slow path | 4,879,381 (15.51%) | 4,654,074 (14.79%) |
| **True positives** | **23,620,613 (88.87% of admits)** | **23,620,604 (88.13% of admits)** |
| Registrations / unregistrations | 3,232 / 1,907 | 3,231 / 1,908 |
| Live buffers, maximum | 1,618 | 1,618 |

The removable work is admits minus true positives: **about 2.96 M probes per
row**, not 26.6 M. Those are the only calls a perfect filter could take off the
slow path; the other 23.6 M must reach the registry because the answer is yes.
Against `is_registered_buffer_slow` at 1.36% of command sampled cycles, the
share a perfect filter could remove is on the order of **0.15% of command CPU** —
below the ±5% spread of the campaign's own paired rows, so it could not be
measured even if it were built.

## Why this owner is different from the canonical one

The canonical-handle probe asked about ordinary heap pointers, because
`is_above_handle_band` embedded it: 43,150,678 admissions per command and 9,225
genuine, so **99.98% of the admitted work was waste** and removing it was worth
7.63% of command CPU. The buffer probe is reached from code that is mostly
holding actual buffers. Same structure, same saturation, opposite verdict.

The population also puts this owner permanently out of a 1,024-bit filter's
range: 1,618 live and 3,232 cumulative registrations, against the type's sizing
note which assumes 213 cumulative admissions and claims the filter "rejects about
nine of every ten addresses the window admits". On this workload it rejects none
— every rejection in the table above comes from `BUFFER_LIKE_ADDR_WINDOW`, the
min/max window in front of it, which rejects 14.79–15.51% (the note claims
25.94%). **Both numbers in that note are falsified by these rows**, and the
filter contributes nothing to this probe. That is worth recording even though
the fix is not worth building: the filter costs three hashes and up to three
loads on every admitted probe and buys zero rejections.

If anything is done here later, the cheap and honest option is to delete this
filter for this owner rather than enlarge it — `PERRY_BUFFER_ADDR_FILTER=0`
already selects that arm in one binary, so the A/B needs no build either. That
would be a small CPU win of the same order as the one above, in the opposite
direction from sizing, and it is not claimed here because it was not measured.

## Method note

Cost: two workload rows and no compilation. The instrument, the window and the
`true_positives` counter were already in the control binary; the campaign's own
earlier work put them there for exactly this question. Instrumented command CPU
is 1.34/1.30 s against the ordinary 1.18 s, so these rows are counts, not a CPU
comparison. Probes are 31,457,281 in both rows and true positives differ by 9,
which is the deterministic replay behaving as it should.

**The general rule this row bought:** an occupancy number prices a filter only
together with the true-positive rate of what it admits. A saturated filter in
front of a question whose answer is usually *yes* is not costing anything worth
recovering.
