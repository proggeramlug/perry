# GC leaf calls in Claude Code: measured opportunity

**Recommendation: annotate runtime calls only, starting with the existing `invoke` gap. Budget roughly 1–3 engineer days for review, focused correctness checks and paired cc measurements.** The static opportunity is substantial, but the profile supports a modest CPU experiment: affected callers contain only **0.35% of startup and 2.21% of command sampled cycles**, including all their useful work. No speedup or RSS improvement has been measured. A full interprocedural project is not justified by this study.

## Current implementation and static counts

Perry already classifies helpers as `CannotCollect`, conditional `AllocNoReentry`, or `Unknown`, and already computes a transitive leaf fixed point before partitioning generated code. The missed case is concrete: the runtime annotation transfer in `function/precise_roots.rs:185–217` handles `call` but omits `invoke`. The capture contains **485,506 pre-rewrite invokes to existing `CannotCollect` helpers**. Getter/Proxy/coercion/throw paths remain potentially collecting. [Source map](state-map.md), [remaining invoke counts](results/root-shadow-summary.json).

Across **109 completed emission units** (six incomplete attempts excluded), LLVM emits **2,044,994 statepoints after rewriting; 2,041,090 remain after optimization**:

| Callee category | Post-optimization GC points |
|---|---:|
| Runtime: existing `CannotCollect` contract | 453,009 |
| Runtime: newly reviewed leaf candidates | 16,447 |
| Runtime: reviewed potentially allocating/reentrant | 476,333 |
| Runtime: unresolved effects | 854,978 |
| Static generated/user functions | 82,109 |
| Dynamic calls and dispatch wrappers | 156,208 |
| Unclassified externals | 2,006 |
| **Total** | **2,041,090** |

The existing and new runtime populations total **469,456 points (23.00%)** and **1,944,315 GC-live operands**. These are static opportunities, not execution counts or removable machine instructions. LLVM relocate intrinsics and empty inline assembly are excluded from this callee table. Adding the 48 new runtime summaries to the offline direct-call proof establishes 103 additional generated functions, but reaches only **58 remaining user-call statepoints**; no samples landed in their callers. This model leaves indirect targets unresolved and is not a devirtualization study. [Complete census](results/emission-summary.json).

Before rewriting, 77,818 LLVM definitions use native roots, seven retain shadow frames, and 23,039 have neither observed mechanism. After rewriting, 77,822 definitions carry the native GC strategy. The remaining definitions must not all be labeled shadow fallback.

## Top 20 leaf candidates

Ranked by **all post-optimization call sites among helpers with residual GC points**; the GC-point column shows the remaining opportunity. “Existing” means the compiler already asserts `CannotCollect`; it does not mean every body received a new independent audit here. There are 38 candidates with residual points, including only 18 of the 48 newly reviewed helpers.

| Helper | All call sites | GC-point sites | Basis |
|---|---:|---:|---|
| `js_write_barrier_root_nanbox` | 532,333 | 97,323 | Existing |
| `js_closure_get_capture_bits` | 277,331 | 149,470 | Existing |
| `js_implicit_this_set` | 180,455 | 32,405 | Existing |
| `js_write_barrier_slot_validated_parent` | 92,848 | 19,909 | Existing |
| `js_string_addref_if_heap_string` | 87,154 | 29,221 | Existing |
| `js_box_set_bits` | 85,284 | 51,564 | Existing |
| `js_closure_set_capture_bits` | 70,878 | 4,506 | Existing |
| `js_write_barrier` | 63,527 | 45,824 | Existing |
| `js_closure_set_box_capture_ptr` | 60,229 | 4,600 | Existing |
| `js_box_alloc_bits` | 56,618 | 558 | Existing |
| `js_write_barrier_slot` | 42,607 | 3,043 | Existing |
| `js_object_get_own_field_or_undef` | 42,375 | 11,890 | Existing |
| `js_transition_ic_spill_append` | 23,282 | 1,635 | Existing |
| `js_implicit_this_get` | 13,951 | 147 | Existing |
| `js_string_equals` | 13,230 | 12,940 | New |
| `js_array_note_numeric_write` | 2,238 | 550 | Existing |
| `js_string_index_of_from` | 1,767 | 1,746 | New |
| `js_typed_feedback_closure_direct_call_guard` | 1,661 | 335 | Existing |
| `js_string_index_of` | 511 | 511 | New |
| `js_string_compare` | 431 | 411 | New |

The [per-helper audit](results/runtime-helpers.csv) covers **895 source-identified runtime helpers**: 15 classified never allocating, 51 potentially allocating and 829 unclear, with reasons and locations. **72 were reviewed in depth; 823 remain unreviewed and conservative.** This is not a closed proof for every export. Native Rust allocation is distinct from Perry collection: a helper can allocate native storage and still qualify as a GC leaf. [Full ranking](results/leaf-candidates-ranked.csv), [unresolved externals](results/unresolved-external.csv).

## Workload and hot regions

Three successful offline runs of **“Explain this project.”** perform two actual Read operations (`package.json`, `src/index.ts`) and consume a 2,852-character streamed answer. All runs use sandbox HOME/configuration directories. Profiles use actual instruction pointers, `cycles:u` at 999 Hz, and exact binary/GC-map joins; independent perf reports reconcile all samples with zero loss.

| Measurement | Startup | Command after Enter |
|---|---:|---:|
| Process CPU, three rows | 0.97 / 1.13 / 0.95 s | 1.31 / 1.27 / 1.23 s |
| Self cycles in all affected callers | 0.35% | 2.21% |
| Confirmed loops containing candidate calls | 0.04% | 0.94% |

Peak RSS is **634.90 / 622.93 / 633.95 MiB**. The loop analysis covers ten of the twenty hottest candidate callers; indirect branches leave ten unresolved. Caller, loop and block coverage overlap. These are **region coverage, not savings**: helper bodies still execute, spill/reload instructions were not isolated, and sampling cannot price secondary cache effects. Typing between phases is excluded; the command window ends after the reply plus a 0.5-second tail. [Exact metrics](results/report-metrics.json), [machine-region evidence](results/machine-loop-coverage.json).

## Barriers, metadata and limits

The stricter post-rewrite analysis proves **64,511 of 194,616 explicit heap-barrier sites (33.15%)** in native statepoint functions refer to same-function fresh allocations with **no intervening emitted statepoint**. Its denominator independently matches the primary call parser. The other 130,105 parents remain unresolved; allocation invokes and phi/relocate aliases are conservatively declined. This is a lower bound on freshness, not a young-generation proof. [Actual-statepoint windows](results/fresh-statepoint-windows.json).

A separate pre-rewrite effect-based analysis finds 68,784 fresh-origin sites among 230,418 reachable barriers; the 48 new summaries add **zero**. Those windows can cross redundant emitted statepoints, and the phase/scope differs, so the two counts must not be subtracted. Fresh owners can already be old or published; incremental shading, layout notes and string-sharing effects remain necessary. Existing value/generation guards also mean a static barrier site may never call the helper.

The final binary contains **24,009,616 bytes (22.90 MiB) of `.perry_gcmap`**, describing 72,681 functions and 1,995,600 return-PC records. Raw LLVM stack maps have been consumed into this format; final-map and earlier IR counts differ. Shadow metadata uses a **32-byte TLS state plus a 1-byte guard**, with dynamic 16-byte entries; seven emitted frames request 13,985 slots in aggregate, not simultaneously. No metadata-byte or RSS saving is inferred from the eligible-site percentage. [Metadata census](results/metadata-summary.json), [ELF TLS symbols](results/shadow-tls.json).

Soundness findings: four existing `AllocNoReentry` exports—`js_array_length`, `js_array_push_f64`, `js_array_slice_values`, `js_array_indexOf_jsvalue`—contain JS-reentry routes; do not extend that conditional contract on its name alone. Leaf annotations must preserve exceptional control flow and must not imply `nounwind`. Native callback registration leaves `js_value_typeof_tag` unresolved. The large existing-contract population needs review before annotation, and fresh-barrier removal needs additional generation/marking proofs. [Audit detail](runtime-audit.md), [refined raw-access proofs](audit-v3/source-receipt.json).

Only observation code was added on `diag/cc-gc-leaf-census-20260911`; no GC point or barrier was elided and nothing was committed to main. The report/STATUS branch is `diag/cc-gc-leaf-report-20260911`. [Build identity, validation and retained failures](MEASUREMENT_NOTES.md).
