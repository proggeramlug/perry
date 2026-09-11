# Runtime caller census: cheap range guards acquired an expensive path

**The next architectural target is the shared native-handle classification path.** In the retained source, `is_handle_band`, `is_small_handle` and `is_above_handle_band` also classify canonical native wrappers at high heap addresses. A seemingly cheap address-range guard can therefore enter the exact malloc registry. Common runtime operations repeat these guards. This is a concrete explanation for some of the [previously measured validation cost](../cc-runtime-helper-profile-20260911/REPORT.md), not a measured optimization win.

## Executed counts

Three successful offline cc commands perform the same two actual Reads and streamed response as the GC-leaf study. Entry/return probes count only `gc_malloc_header_is_tracked`, with startup separated from the command. They record return-continuation addresses and the Boolean result; they do not read JS payloads or credentials.

| Row | Startup calls | Command calls | Command false | Command true |
|---|---:|---:|---:|---:|
| 1 | 65,587 | 18,127,286 | 18,101,831 | 25,455 |
| 2 | 66,927 | 16,582,740 | 16,557,324 | 25,416 |
| 3 | 68,039 | 14,855,785 | 14,829,433 | 26,352 |
| **Command total** | — | **49,565,811** | **49,488,588** | **77,223** |

**99.844% of command answers are negative.** A positive result means a tracked malloc allocation, not necessarily a canonical native handle. These are actual **instrumented** counts, not ordinary-run call frequencies: probe overhead stretches command CPU to 39.59/36.41/32.75 seconds and can change scheduling, rendering and GC activity. Do not divide the ordinary profile's CPU by these counts to infer nanoseconds per call.

Largest return-continuation owners, aggregated across the three instrumented commands:

| Caller body | Validator calls | Share |
|---|---:|---:|
| `js_object_get_field_by_name` | 10,133,074 | 20.44% |
| `closure::dynamic_props::is_closure_ptr` | 7,002,050 | 14.13% |
| `object::object_ops::extract_obj_ptr` | 6,664,009 | 13.44% |
| `typed_feedback::normalize_raw_object_addr` | 4,192,338 | 8.46% |
| `gc::trace::classifier_valid_object_start` | 3,028,217 | 6.11% |
| `iterator_prototypes::prototype_next_is_canonical` | 2,768,524 | 5.59% |
| `native_handle::canonical::is_canonical_handle_addr` | 1,941,076 | 3.92% |
| `js_native_call_value` | 1,673,057 | 3.38% |

Inlining explains why a malloc query can appear directly inside a caller that only names a range predicate in Rust. Exact ELF bounds resolve return continuations. For 49,725,010 of 49,766,364 startup-plus-command entries, the preceding instruction calls a GOT slot whose `R_X86_64_RELATIVE` relocation resolves to the counted helper. The remaining 41,354 entries retain a conservative “other call or tail continuation” label. [Complete caller ranking](results/caller-ranking.csv), [all exact totals and bindings](results/summary.json).

Inside `js_object_get_field_by_name`, **six distinct sites each execute 441,857 times in row 1**. The source repeats `is_above_handle_band(obj)` before several special-property arms. There are also guards on the key and key arrays; equal counts alone do not establish equal operands. The `.size` arm can collect and republish `obj`, so a result cannot simply be cached across the whole function. [Per-site counts for all three rows](results/property-getter-sites.csv).

The optional repeat counter records 25,289,005 calls with the same address as the preceding call at that site on that thread (51.02%). Other work can intervene, including collection, reallocation and callbacks. This is a repetition clue, **not proof of redundant validation or an unchanged operation**.

## Filter occupancy without entry/return probes

Three additional successful runs use **no BPF probes or runtime counters**. At phase boundaries the controller reads only the exact 128-byte `CANONICAL_HANDLE_ADDR_FILTER` variable, identified by the binary's ELF symbol and process load bias. It stores bit counts, not arbitrary memory contents.

| Row | Bits set after startup | Before Enter | After command | Capacity |
|---|---:|---:|---:|---:|
| 1 | 181 | 847 | 904 | 1,024 |
| 2 | 177 | 876 | 931 | 1,024 |
| 3 | 169 | 806 | 878 | 1,024 |

The ordinary workload therefore fills **85.74–90.92%** of this monotone filter by the end of the command. None of these snapshots is fully saturated. Occupancy is **not** a measured false-positive/admission rate. The source sets three bits per admitted wrapper address and never clears them when wrappers retire; occupancy tracks addresses ever admitted rather than just currently live handles. These observation rows take 1.21–1.22 seconds of command CPU, but they are not an optimization comparison.

## Source chain and recommendation

The inspected chain is:

`range predicate → is_canonical_handle_addr → filter → canonical_handle_parts_from_addr → handle_from_addr → gc_malloc_header_is_tracked`.

The canonical-wrapper bridge is real compatibility work: callers must still distinguish legacy IDs, ordinary managed objects and native wrappers. The next design should separate a numeric address-range test from semantic receiver classification and carry a validated receiver result through the parts of one operation where it stays valid. Audit each caller's required distinction; do not just remove the canonical check globally. A lifetime-maintained exact canonical-membership index is another possible design, but it still adds per-call work and needs measurement. Increasing this filter's size would only postpone its lifetime-growth problem.

Preserve the existing malloc/arena **union** in GC tracing: malloc allocations can overlap ranges attributed to arena metadata. Preserve wrapper retirement/finalization, thread ownership, Proxy/getter behavior, and refreshed addresses after collecting callbacks. No stale classification may outlive its proof. [Reviewed source hashes](source-receipt.json).

The next acceptance evidence is a focused case that proves fewer repeated registry queries while returning the same values, followed by an ordinary matched cc CPU/RSS comparison. The existing 4.90% validator self share and these instrumented counts do not price that change. No runtime implementation, GC-point elision, barrier elision or regex optimization was performed in this investigation.

## Validation and reproducibility

The probe admits only an actual one-byte `push rbp` entry instruction. Before the subject resumes, `bpftool` must show exactly the owned entry, return and phase-marker attachments at the expected file offset. The phase marker is a synchronous write by the controller to its private pipe. Return values use the Boolean ABI's low byte; entry/return totals and per-caller results must balance, with no unfinished depth or invalid return PC. Maximum observed depth is one.

The compiled control has two callers and known argument sequences. Unprobed/probed output agrees exactly; it counts 5/6 entries, 2/3 true answers and 2/2 repeated values. Removing a real attachment from the verifier's input or one return from the counter map is rejected. The first control correctly rejects the C compiler's `endbr64` entry; its replacement fixture emits the required entry instruction. A subsequent attempt records expected zero-valued map misses under bpftrace `-kk` and is rejected by the parser; the final version uses normal map semantics, explicit invalid-PC/result checks and independent count conservation. Both attempts remain preserved. Tuple keys are parsed in the installed JSON format, which has no spaces after commas.

Every cc row preserves exact output/tool-result evidence, sandbox HOME/configuration, process identity checks and cleanup. All workload runs take the campaign lock. Static symbolization also takes the lock. A transfer of completed row-1 evidence overlaps the second **instrumented-count** row; no ordinary timing claim uses it. The three runs without BPF perform no concurrent study build or static analysis.

The measured binary remains SHA256 `b907d616caf8eea350543185de24fc2af1426090fc58161ee49952e6980314f7`. The [archive](evidence-v1.tar.gz) is 1,063,958 bytes, SHA256 `f0f3759ea9c9d3c9aded2854fd8f380d8820fda57786e4d438df36b6abe2fd7f`; all 288 manifest-listed files verify locally. It includes controls and rejected attempts, all six workload rows, exact maps/disassembly, scripts and receipts. [Manifest](evidence-manifest-v1.json), [verification](archive-validation.json).

Extract the archive into an owned `raw/` directory beside this report, verify its manifest, then run `python3 -B analyze.py`. The large measured cc binary remains on perrymaster at `/root/cc-perf-native-recv-0909/gc-leaf-census-20260911/compile-v2/cc-diagnostic`. This study is on `diag/cc-runtime-caller-census-20260911`; all jobs are complete and main is untouched.
