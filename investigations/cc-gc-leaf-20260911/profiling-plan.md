# Caller-side GC leaf investigation — measure first

The useful first targets are **N$6, zF6 and AF6**. Their combined actual sampled-IP self is **1,135,034,247 periods, 5.464790% of the whole Perry profile**. This is an envelope containing all their arithmetic, branches, property code, ABI argument preparation and GC bookkeeping. It is neither removable CPU nor a claim that all calls within it qualify as leaves.

## Exact evidence and ranking

The existing profile is `secret-tests/cc-perf-campaign/codex/profile_after_test_dispatch_20260910`, for app-testdispatch25 SHA256 `230e33392fded4dc8ddb7c4ea49ca86e2f1a7201a84ccdc98b56b5c72666d98d`; bundle SHA256 `bc3358282800e3e99daa8e71ac5b7b1566bd0d7ca7eb94f714a7859365d3163f`. All three Perry captures reconcile to independent perf self totals: **4,022 samples / 20,769,952,563 periods**. Re-reading every leaf export using the retained `analyze.LEAF` parser finds **45 distinct compiled function/closure/method symbols, 1,504,452,309 periods (7.243410%)**. The saved `analysis.json` top-symbol list is truncated; do not sum that list as the complete compiled population.

| Compiled symbol suffix | Samples | Self periods | Whole-profile share |
|---|---:|---:|---:|
| `perry_fn_...__u_N_24_6` (N$6) | 127 | 665,413,972 | 3.203734% |
| `perry_fn_...__zF6` | 49 | 254,894,563 | 1.227227% |
| `perry_fn_...__AF6` | 41 | 214,725,712 | 1.033829% |
| `perry_closure_...__37648` | 10 | 52,860,688 | 0.254506% |
| `perry_fn_...__YF6` | 6 | 31,618,544 | 0.152232% |
| `perry_fn_...__GW7` | 7 | 31,315,772 | 0.150774% |

`...` above abbreviates `cli_2_1_112_js`. Closure ordinal37648 needs the exact compiler symbol/HIR map before giving it a JS name. Three named hot functions hold217 actual samples; individual instruction estimates will be noisy.

Narrow callchain attribution is unsuitable: sampled symbols are absent from the entire captured chain in2,845/4,022 samples (14,695,671,659 periods). Never assign callee self CPU to a caller through those chains. Conversely, sampled-IP membership and symbol self reconciliation remain valid. These are hardware sample periods, not a count of instructions or an exact duration.

## Source and static call locations

In `claude-code-build/cli_2.1.112.js`, N$6 begins at UTF-8 byte4,010,232, line557. Its loop projects `segment`, calls `O.codePointAt(0)`, compares the code point, performs `oR_.test(O)` and `g54.default().test(O)`, then `AF6(w,A)`. AF6 begins at byte163,732, line52; it validates with `mv5`, calls zF6/YF6, and conditionally DT7. zF6 begins at byte161,264, line52; its JS consists of equality and ranges. Generic comparisons can coerce object arguments, so their surface arithmetic is not proof that the generic callable cannot collect. Audit generated fast and fallback arms separately.

Historical static machine-code evidence exists at `profile_after_projection_20260910/width.disassembly.txt`, bound by `binary-copy.json` to older app-project23 SHA256 `1e078dd1316dc1606dee2396c8419e1b449300b9220d92960f77edf8404f6338`. It contains134 call instructions in N$6, including cold branches; this is not134 calls per grapheme. Useful historical anchors (ELF VMAs, not current sample addresses):

| Call instruction | Target / source context |
|---|---|
| `0xa3db53c`, `0xa3dbd8d` | projected iterator next |
| `0xa3db78f`, `0xa3dbdf3`, `0xa3dcbea` | loop safepoint |
| `0xa3db805` | projected segment |
| `0xa3db8d2`, `0xa3db8de`, `0xa3db8e8` | string pointer/index/code-point helpers |
| `0xa3dc8f1`, `0xa3dcae1` | two generic native `.test` routes |
| `0xa3dc9ea` | generic native factory method route |
| `0xa3dcbac` | AF6 |

The actual post-test-dispatch binary has no exact local disassembly available to this audit. Root is producing it. Do not reuse the older offsets against the fresh profile merely because the function names match. Current raw leaf IPs are ASLR addresses; root must normalize each capture using that capture's executable MMAP/load bias plus ELF PT_LOAD mapping. A callchain return address is not a substitute for the sampled IP.

No retained whole-cc pre/post-RS4GC IR was found in the scoped campaign outputs. Available `.ll` artifacts under `yf6_evidence/evidence-after/` and `regexp_factory_elision_20260911/acceptance-observation-v4/compiler-bridge-diagnosis-v1/ir/` are narrow fixtures, not the current cc module. They can check analyzer behavior, not establish cc site counts.

## What the compiler already does

`gc_call_effects.rs:35` classifies direct runtime helpers; Unknown is conservative. `:507` computes a greatest fixed point over module-defined direct calls, allowing pure recursive SCCs but rejecting unknown/indirect/collecting exits. `module.rs:582` and`:717` use that set during full/split rendering. Thus there is already generated-function leaf analysis; census which actual edges still remain unknown.

There are several different sources of caller bookkeeping:

1. `codegen/mod.rs:3677` runs `root_reload::apply_to_module` before rendering. Its own `root_reload.rs:170` NON_COLLECTING table and`:350` classification can preserve loads around calls independently of the later generated-function fixed point. Record root reloads before/after this stage if their origin matters; later leaf annotations do not prove earlier loads disappear under ordinary memory aliasing rules.
2. `function/precise_roots.rs:145` retypes rooted homes as addrspace(1), removes shadow-bind/set transport and annotates audited direct calls. `:35` documents reload laundering: a zero-instruction inline-asm identity preserves root-lifetime separation. Count surrounding generated machine operations, not the textual asm itself as a runtime call.
3. LLVM RS4GC chooses actual statepoints/relocations after the compiler's transformations. `statepoint_report.rs:60` explicitly identifies the compacted assembly GC map as the authoritative static record/root-pair count. Textual call counts and roots-times-calls estimates are not actual spill counts.
4. Some huge functions use shadow frames under the relocation budget (`codegen/helpers.rs:488`); distinguish backend per function before labeling every stack store an RS4GC spill.

## Minimal discriminating measurement

Use the new diagnostic dump only for observation. It emits `pre-rs4gc.bc`, `post-rs4gc.bc`, `post-opt.bc` in unique `pid-...-attempt-...` directories. Only attempts with `complete.json` qualify; still bind them to the object units and final binary that root actually accepts. A completed backend attempt can later lose a relocation-budget retry or fail assembly/link. Same LLVM22 `llvm-dis` converts each snapshot losslessly. Record target, optimization mode, native_roots, compiler/source/archive/object identities and emitted-feature settings; do not mix recompiled IR with the older profile as though they share instruction addresses.

For the top three functions, join four layers by exact identity:

- Pre-RS4GC direct/indirect call location, emitted leaf attribute, audited effect, block/loop, argument/result types and source marker when available. Include call and invoke; preserve exceptional successors.
- Post-RS4GC actual `gc.statepoint` record and `gc-live` operands plus each resulting relocate. Keep no-live-root calls separate.
- Post-opt IR and emitted GC map, after dead/constant/inlined paths disappear. Count static sites and root pairs per function/callee; do not multiply those by grapheme count without dynamic site evidence.
- Exact final assembly return-PC and individual instructions implementing each spill/reload. Classify proven GC-home stores/reloads separately from callee-save spills, argument-stack writes, ordinary JS locals, root-shading calls and uncertain stack traffic. Do not use an arbitrary ±N-instruction window as a GC-cost attribution rule.

Then normalize the existing actual IPs and sum their periods only over the disjoint, proven instruction-address sets. Report `(proven_gc_spill_reload_periods, other_caller_periods, uncertain_periods)` and raw samples per function/capture. Overlapping sets must be rejected. A function's full self share is opportunity coverage; a callee's full self share does not disappear when a statepoint is removed. Even proven spill-instruction samples are a location estimate, not a guaranteed wall/CPU saving: changed allocation of registers and surrounding instruction scheduling require a later ordinary measured candidate.

For frequency if samples are too sparse, root may separately count executed candidate call sites in a compile-time diagnostic arm while preserving the unchanged cc row predicate. Measure counts only there; do not time that instrument. Pair dynamic site counts with actual roots/relocations at those exact sites. Do not substitute whole width-loop counts for cold coercion, missing-method or exception branches.

Fail-capable checks: corrupt one sampled period and require self reconciliation failure; substitute a callchain leaf and require failure (existing controls already do both). For the new join, shift one known return-PC or use the older binary identity and require refusal. A small positive IR fixture must create a real live root across a collecting call; an audited leaf twin must omit its statepoint while retaining the real call and answer. A planted unknown/indirect edge must break the leaf proof. These are targeted proposed checks; no native build or new profile was run by this audit.
