# Earlier own-data cache: small positive result

**Retain this as a small runtime candidate for later integration.** Minimum
command CPU falls from **1.22 to 1.19 seconds (−2.46%)**; medians are **1.25 to
1.22 seconds (−2.40%)**. The candidate is faster in all five interleaved pairs.
The largest per-pair RSS increase is **+0.080%**, within the campaign budget
for these rows. This is not a large CPU lever: the candidate still uses
**2.83× Node's minimum command CPU**. Do not keep repeating this comparison to
seek a larger number.

## All Perry pairs

| Pair | Control command CPU | Candidate command CPU | CPU change | Control peak RSS | Candidate peak RSS |
|---|---:|---:|---:|---:|---:|
| 1 | 1.28 s | 1.25 s | −2.34% | 629.574 MiB | 625.301 MiB |
| 2 | 1.45 s | 1.22 s | −15.86% | 633.754 MiB | 634.258 MiB |
| 3 | 1.22 s | 1.20 s | −1.64% | 646.371 MiB | 635.129 MiB |
| 4 | 1.25 s | 1.22 s | −2.40% | 649.926 MiB | 637.480 MiB |
| 5 | 1.22 s | 1.19 s | −2.46% | 638.375 MiB | 635.387 MiB |

The slow control in pair 2 is preserved. Its cause was not measured, and its
15.86% delta is not the headline gain. CPU accounting has hundredth-second
granularity; five pairs support a modest positive result, not a precise universal
speedup. Startup CPU minima are 0.97 → 0.95 s (−2.06%), medians 0.98 → 0.97 s.
Per-row startup-plus-command minima are 2.19 → 2.15 s (−1.83%). Command wall
minima are 1.693 → 1.660 s; that window includes the reply plus a 0.5-second tail.

Peak RSS maxima are 649.926 → 637.480 MiB (−1.91%), medians 638.375 →
635.129 MiB (−0.51%). Four RSS pairs decrease; pair 2 increases by 0.504 MiB.
These rows do not establish an all-workload memory guarantee or identify the
cause of the RSS differences.

Node command CPU is **0.42 / 0.44 / 0.42 s**, startup **0.63 / 0.62 / 0.63 s**,
peak RSS **332.285 / 337.965 / 332.797 MiB**. The much larger remaining parity
gap requires another source of improvement. The prior census's 31.26% tail-read
population is not a measured cache hit rate and did not imply comparable CPU
savings. [Exact rows](results/rows.csv), [paired deltas](results/paired-changes.csv),
[full statistics and reconciliation](results/summary.json).

## What changed

The runtime remembers a fully resolved ordinary own data slot by exact class,
ShapeId and short-key content. A later by-name read can load that current slot
after the existing receiver prelude, avoiding the remaining generic resolver.
Entries retain no addresses or field values. Storage is a bounded 96 KiB per
initialized thread on this target, using the existing read stub's bucket/way
counts; it has no workload-specific setting.

The new table is separate from write-side priming and direct SSO reads, whose
proofs differ. It rejects heap class objects, native modules, typed-array
prototypes, boxed String objects, TTY `rows`, and registered arguments objects
at admission. Descriptor and class-kind transitions revoke identities; stable
deletion holes miss. The existing private-member, array-element, process.env
and Proxy handling remains ahead of lookup.

Two independent Astra reviews found the heap-class exclusion necessary: an
undefined tail result can be an intermediate result before static dispatch.
That issue was corrected before the build. Descriptor/slot review and the
implemented exclusions are documented in [AUDIT.md](AUDIT.md). No GC effect,
statepoint, write-barrier or regex behavior is changed.

## Validation and evidence

The runtime implementation is commit
`5960e845718275107fff835f4fefd5b3ea375ed6` on
`perf/runtime-own-read-cache-20260911`, against retained baseline
`b6545b491ee0dc4b6fb36db7b47903431686b313`.

Focused module, verbatim:

`test result: ok. 9 passed; 0 failed; 0 ignored; 0 measured; 3278 filtered out; finished in 0.03s`

The checks cover actual hits, current values, accessor invalidation with a
deliberately relabeled stale proof, exact class identity, SSO isolation, later
elements attachment, class-kind rejection, long keys, overflow growth and
stable deletion/re-add. The focused build takes 2m56s; shipping takes 3m07s.
Both compiled fixtures match Node 26.8.1 byte-for-byte on getters, inheritance,
Proxy, array elements, boxed strings, freezing and repeated deletion/re-add.
This is a focused fixture, not the repository-pinned full gap gate. Existing
unused-import/future-compatibility warnings remain; no broad CI verdict is claimed.
No explicit forced-moving-GC run was performed.

All 13 sandboxed startup/actual-two-Read/stream rows reconcile against raw
phase, process-identity, source, binary and tool-result receipts. The paired
driver and phase recorder are unchanged from the preceding comparison; only
labels, ports and stage bindings change. No runtime counters, BPF or perf run
beside these timings. Builds, rows and subsequent static analysis hold the
campaign lock. The analyzer rejects a removed real row and modified real CPU.
Load1 before/after the rows ranges from 1.06 to 1.58.

The compiler and generated-object cache are unchanged. The retained control
binary is reused by exact SHA, but its timing rows are fresh. Control SHA is
`5560e04fe7016923d098ea70d254cb8edd3252c9973282aca40ff62d3415bf97`;
candidate SHA is
`42bfb149007b5c79d11b11d6acb7ad16008932945a78efe700c19bec9d3e513a`.
The getter's machine body changes from 15,891 to 16,055 bytes; whole `.text`
grows 1,728 bytes. **Both GC maps are byte-identical at 24,009,616 bytes.**
The diagnostic and test counters are absent. [Binary inspection](results/binary-verification.json).

All 155 sealed data members / 1,184,210 uncompressed bytes verify locally.
The 291,870-byte archive has SHA
`26521ca45b95301636d96cb70299e42e32a92baa783ba07266797c730dcb07ef`.
It contains evidence, not cc binaries, build caches or HOME/configuration
contents. One completed owned diagnostic build cache was retired to make room;
its binary, source and sealed evidence remain. [Archive receipt](evidence/seal-v1.json),
[cache retirement](controls/owned-cache-retirement.json).

No main commit, push or PR occurs. Keep this candidate isolated from the parked
property-key-selector change. The next optimization step is to profile the
remaining cost on this measured binary, rather than infer another win from
static call counts. GC-point/barrier elision remains measurement-only and regex
optimization remains paused.
