# Completed-emission callsite census

`callsite_census.py` is an offline observer. It does not edit LLVM, helper classifications, GC policy, or generated code. Its counts are static emitted sites, not executed calls, time, allocation counts, or demonstrated removable cost.

Run only after the outer diagnostic compiler job has completed, using its fresh capture root and a separate empty output directory:

```sh
python3 callsite_census.py --captures /path/to/captures --helper-audit helper-audit.csv --output /path/to/analysis --llvm-dis /usr/lib/llvm-22/bin/llvm-dis
```

The script verifies LLVM major 22 and streams each bitcode file through `llvm-dis`. It uses multiple passes for attributes/definition inventories, call counts and offline call graphs; it does not hold every instruction or block in the whole workload in memory. Block rows are written incrementally to gzip; a single function's call/token records remain in memory. The caller must serialize this diagnostic work with other box work as usual.

A previously converted `--text-root DIR` can instead supply `<attempt>/<stage>.ll`. Original `.bc` files still must exist and match the completed manifest lengths; both bitcode and text files receive hashes. This mode does **not** independently prove the text was converted from that bitcode. Preserve exact conversion commands/tool identity if using it. Python tests use explicitly synthetic transport bytes with text mirrors and make no claim those bytes are LLVM bitcode.

## Admission and accounting

Only schema-1 `complete.json` records with `status=llvm-emission-succeeded`, matching PID/attempt metadata, a positive emitted-buffer size, and all three ordered stage files enter totals. Incomplete attempts are listed separately; absence is unavailable, never zero. One compiler PID is required. Repeated successful pre-definition sets are rejected rather than summed. Duplicate visible symbol definitions across distinct legitimate units remain represented, including functions with no calls. Completion refers to LLVM buffer emission: final codegen-unit assembly/combination/link acceptance remains a separate outer-job proof.

Direct `call`, `invoke`, and `callbr` operands are parsed independently from their arguments. Statepoint actual callees come from the **third intrinsic argument**, not the `llvm.experimental.gc.statepoint.*` wrapper or another symbol in the argument list. Multiline invokes, operand bundles, nested operand/type punctuation, aliases, quoted identifiers and inline/grouped `gc-leaf-function` attributes are handled. Declarations are never counted as call instructions. Unknown constant-expression call targets, incomplete input, missing attribute groups, unknown relocation tokens and malformed snapshot metadata raise errors; output must not be treated as complete after one.

Statepoint calls count once, under their actual callee category. Ordinary LLVM intrinsics, including `gc.relocate`, count as LLVM call instructions. `gc_live_operands` is the bundle operand count on a statepoint; it is not a distinct-object count. Relocations have two distinct metrics: the intrinsic count on the LLVM row, and the attribution to a real callee. Never add either to `callsites`. A normal relocation token maps to its statepoint; an exceptional landingpad token maps through its incoming statepoint invokes. Multiple incoming invokes with one callee still permit callee attribution; different callees remain explicitly `relocates_unattributed`. These are reported, not assigned to an arbitrary caller.

Primary categories partition all counted calls and statepoints:

- `runtime`: a finite helper-audit row has exact runtime-source definition locations.
- `static-user`: the target is defined in the captured LLVM population. Private/internal symbols have unit-qualified identities.
- `dynamic-dispatch`: explicit indirect LLVM targets plus the exact 29-name native-call/closure-call wrapper ledger embedded in the script. JSON splits the two origins. Property getters such as `js_object_get_field_ic_miss` remain ordinary runtime helpers; possible re-entry alone does not make them literal dispatch wrappers.
- `LLVM` and `inline-asm`: separate compiler bookkeeping categories.
- `nonruntime-external`: only an optional `--nonruntime-external FILE` exact-name list supplied by the caller; conflicting runtime/defined identities are rejected.
- `external-unclassified`: no runtime identity in the supplied finite audit. That audit covers runtime definitions, not all stdlib or linked symbols, so absence cannot prove non-runtime behavior.

Every category metric is reconciled against the stage total. Already leaf-annotated ordinary helpers remain ordinary call rows with `leaf_callsites`; they are not counted as actual statepoints.

## Outputs

- `summary.json`: stage/category/root-mode totals, exact input hashes, accepted and incomplete attempts, wrapper ledger, candidate rankings and offline inference limits.
- `by-callee.csv`: `stage,category,callee` plus metrics.
- `by-caller.csv`: `stage,attempt,caller,root_mode` plus metrics; caller identities remain unit-bound.
- `by-block.csv.gz`: `attempt,stage,caller,block,root_mode,category,callee` plus metrics. Attributed relocation rows can have zero callsites.
- `definitions.csv`: `stage,attempt,symbol,linkage_scope,pre_root_mode`; includes **every** definition, including zero-call functions. Profile joins must audit duplicate symbols against the complete `post-opt` population, not only functions that appear in candidate rows.
- `newly-proven-functions.csv`: `hypothesis,function_identity`, with attempt-qualified identities.
- `post-opt-hypothesis-targets.csv`: `hypothesis,callee_identity,attempt,caller,statepoints,gc_live_operands`. Exact caller symbols support a profile coverage join; sampled caller self cost is not the overhead of these sites.

Root mode is the pre-rewrite function's `gc "statepoint-example"` strategy, otherwise observed shadow helpers, otherwise `no-root-mechanism-observed`. New optimizer-created functions remain `post-created-unclassified`. A module's requested native-root flag cannot classify all its functions because individual shadow fallbacks exist.

## Offline leaf hypothesis

The runtime-only candidate predicate is exactly `audit_status=reviewed`, `may_collect=no`, `may_reenter_js=no`, `current_effect=Unknown` (44 names in the supplied audit at implementation time). Top 20 are ranked by pre-rewrite emitted calls, with already annotated calls and actual post-rewrite/post-opt statepoints kept separate. Already classified reviewed helpers have a separate list. Allocation labels are not used as a proxy for collection.

The fixed point uses actual pre-IR calls. Existing leaf attributes, LLVM intrinsics and the existing `CannotCollect` table form the baseline; the augmented arm adds only those reviewed Unknown runtime summaries. Unknown/indirect/unmarked-asm/poll/throw/unaudited external edges reject a function and propagate rejection through direct callers. Pure recursive components are retained. No `AllocNoReentry` safepoint-only contract is newly assumed.

Two graph scopes are reported: unit-local, and cross-unit resolution of unique externally visible definitions. Private/internal names are unit-qualified; ambiguous visible definitions remain unresolved. These are structural hypotheses, not a final-link/interposition proof. Export/import metadata and actual final symbol binding would be needed before implementing a cross-module optimization.

Native snapshots are already partitioned and repeat `perry_native_module` as their module name. Their units do not retain original source-module membership. Unit-local inference is therefore a lower bound; the cross-unit arm includes both original same-module partitions (where codegen already has module-wide inference) and distinct source modules. Do not call every cross-unit result a missing whole-program optimization.

Post-opt target rows distinguish `direct-reviewed-runtime`, `new-local-user` (same-unit edge), `new-unique-visible-user` (propagation of the added summaries), `existing-proof-user` (baseline unique-visible graph), and `full-unique-visible-user` (augmented graph). These arms overlap. They must not be summed. Statepoint counts/live operands establish a static opportunity to investigate, not a CPU saving.

## Validation

Eight focused Python tests pass. They cover call/invoke/indirect/alias/asm separation; actual third-operand statepoint extraction with a callee-change counterfactual; normal/exceptional relocation association; native/shadow/unobserved modes; missing attributes/unsupported targets/truncation; exact dispatch ledger; pure recursive components versus collecting exits; private same-name separation and ambiguous visible definitions; same-unit versus cross-unit opportunity rows; completed/incomplete/duplicate attempts; malformed metadata/changed byte lengths; and retention of zero-call definitions. No Rust build, real binary execution, LLVM tool execution or box job was run by this lane for these parser tests.
