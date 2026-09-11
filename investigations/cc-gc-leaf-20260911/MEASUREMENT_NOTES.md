# Measurement identity and limits

This is a measurement-only investigation of the retained cc `app-testdispatch25` source, not an optimization comparison or a result for current main. The [short report](REPORT.md) contains the verdict. No GC point or barrier was removed.

## Source and binary

Perry branch: `diag/cc-gc-leaf-census-20260911`. Base: `f09f7db0fc684553dd4c0f736765d29328441dcc`. Commit `ded170cb3` restores the exact retained 20-file source overlay; commit `093fdc027` adds the observation transport only. The retained overlay's SHA256 is `a317db60d2719571a1fbd12948b1869a5d941f351b76277b88dcc9b64a31094c`; all 156 source-receipt files were checked. The paused regex factory-elision work is excluded. Later commits contain analysis, evidence and records.

The compile-time flag `PERRY_GC_LEAF_CENSUS_DIR` captures lossless LLVM bitcode before statepoint rewriting, after rewriting and after optimization. With the flag absent, it adds no serialization, file work or runtime code. No effect table, root-selection policy, optimizer pipeline or runtime behavior was changed for the observation. Caches are bypassed explicitly; the diagnostic flag's cache exclusion alone does not bypass them.

The Linux build uses LLVM 22, the retained shipping-archive feature graph, `PERRY_NO_CACHE=1`, retained segment projection, preserved symbols, and no `PERRY_GC_SAFEPOINT_ONLY` contract. Inherited `PERRY_*` settings are cleared before the explicit recipe is applied. The full diagnostic compile exits zero after **13m29.70s**; this includes capture overhead and is not normal compiler performance. Exact command, environment and archive hashes are preserved in the evidence archive.

| Artifact | SHA256 |
|---|---|
| Original cc bundle | `bc3358282800e3e99daa8e71ac5b7b1566bd0d7ca7eb94f714a7859365d3163f` |
| Compiler | `d4d3f4678374fb3d452b5d5e55dad6b0c27e242d2037395dd3081e601d1929c5` |
| Measured binary, 438,563,920 bytes | `b907d616caf8eea350543185de24fc2af1426090fc58161ee49952e6980314f7` |
| Measured `.text`, 302,634,802 bytes | `46ac1cdb3d9b4ab65b493228155a55a33cf1fbf6122245bd16853ee4f19b4a95` |
| `.perry_gcmap`, 24,009,616 bytes | `2107ca98c8f2fd20ca770a04e1497b5ea7868033e81d7cfb0c40e703f8a309bd` |

The off/on fixture prints `ept!:8` in both arms and has hash-identical `.text` and GC-map sections. The full diagnostic cc and prior retained cc have identical GC-map bytes and identical text lengths, **but their text hashes differ**. No full-application byte-equivalence or off/on CPU comparison is claimed. All reported profiles use the exact new binary above. [Compile binding](results/compile-binding.json), [actual section comparison](results/retained-section-comparison.json).

## Static analyses and controls

The census admits 109 complete emission units and excludes six incomplete attempts. It rejects duplicate successful definition sets and binds completion to the successful outer compile. Three snapshots per accepted unit are decoded with matching LLVM 22. The complete text mirror is 28,819,825,806 bytes and remains on the box. Static call sites are never substituted for invocation counts.

The final parser is `parser-v4/callsite_census.py`. Its 13 controls pass, including the reproduced quoted-string lexer error. Six workers operate on disjoint units. Parallel and sequential processing of the actual compiled fixture agree on every decoded output row and complete summary: 74 post-rewrite and 77 post-optimization statepoints. Three compiler diagnostic tests also pass, including bitcode reparsing and incomplete/reordered-stage rejection.

The final primary summary SHA256 is `8e00414d90541d5236390ed602051dea6cd5da3069db938f27e5c1e12976ce2f`; its compressed block ledger is `643a28d39eb44f8ea07d5985db0b22bd3de6f94cd74c9ca0b02cc6f1ebcae92d`. The derived existing-plus-new leaf coverage independently reconciles per-callee counts against that ledger; it is labeled derived coverage, not another compilation.

The final audit keeps the frozen v2 proof input, SHA256 `b933c0702c5dc2fe2d266c2e0f99f47c8323a108ae5ac11144f4f4000d35af27`. The [v3 refinement](audit-v3/README.md) reviews three already-classified helpers without changing either existing effect membership or the 48 new candidates. Thus the original static/profile join remains valid. The 895-row final runtime CSV classifies every source-identified emitted helper, but explicitly leaves 823 without an independent body audit. It is not a transitive proof for those helpers.

The actual-statepoint barrier analyzer clears facts at **every emitted statepoint**, including redundant points to existing leaf helpers. It recognizes 14 audited allocation returns; an allocator's result establishes an origin only on the admitted direct-call form. A later `gc.result` cannot restore an origin killed by another statepoint. CFG joins require the same origin; allocation invokes and phi/select/relocate aliases remain unresolved. Normalized text is dataflow input only and is never compiled or executed. Six controls pass, including disabling the statepoint kill and delayed-result cases. An actual compiled fixture agrees with the independent parser on five explicit barriers and establishes two fresh origins. All 77,822 native-strategy functions are accounted for; zero native functions are excluded. [Final window counts](results/fresh-statepoint-windows.json).

The separate effect-based pre-rewrite analysis admits 100,863 definitions and declines one multiline string-initializer definition. Independent complete parsing confirms that excluded function contains **zero** explicit heap-barrier calls. Its 230,418 reachable sites exclude 221 sites in unreachable blocks counted by the all-block parser. These semantic windows can cross redundant statepoints; they must not be subtracted from the later actual-statepoint windows. The parallel wrapper preserves the original core and agrees with sequential results on two synthetic copies of the real fixture; dropping a shard defeats equality. [Denominator reconciliation](results/barrier-denominators.json), [semantic-window result](results/fresh-effect-windows.json).

## Workload and profile interpretation

Each run starts cc in an owned sandbox HOME/configuration directory and an owned two-file project. The prompt is `Explain this project.` The offline mock drives three ordered requests with zero, one and two returned tool results, checks distinct file sentinels from actual Reads, then streams a 2,852-character answer in 50-character chunks. No owner's configuration or credentials are used.

Startup spans pre-exec continuation to the prompt. The command spans Enter to the completed reply plus a 0.5-second tail; typing between those phases is excluded. CPU figures come from process accounting; peak RSS is per-process VmHWM, not an optimization delta. Sampling uses `cycles:u`, 999 Hz, monotonic boundaries and the retained CPU affinity. All three rows are serialized against campaign builds/analysis; the static census worker is explicitly stopped by verified PID during the last two profile rows, then resumed.

Independent `perf report` self totals reconcile the entire captures with zero loss:

| Row | Samples | Integer periods |
|---|---:|---:|
| 1 | 5,187 | 23,751,808,510 |
| 2 | 4,913 | 23,824,563,349 |
| 3 | 5,334 | 23,357,918,114 |

Whole-capture totals include between-phase work. The aggregated startup denominator is 3,071 samples / 14,788,892,043 periods; command is 3,683 / 18,920,915,610. Actual instruction addresses are joined to exact executable mappings, ELF symbol sizes and compact GC-map return PCs. There are no dynamic helper-entry counters or trustworthy callchain attribution in this study. [Aggregates](results/report-metrics.json), [row 1](results/profile-1/run.json), [row 2](results/profile-2/run.json), [row 3](results/profile-3/run.json).

Machine-loop analysis examines the twenty hottest candidate callers. Ten admit a normal CFG; ten contain unresolved indirect branches. An eligible call must match an exact candidate target and a following PC present in the actual GC map. Loop regions come from CFG strongly connected components; no arbitrary instruction window is called spill/reload overhead. Affected-call instruction samples are zero, which does not imply zero executions. Loop, block and whole-caller coverage overlap and must not be summed. Whole-caller cost includes useful computation; helper bodies continue running after hypothetical elision. Secondary cache/code-size effects and cold paths remain unpriced.

## Preserved corrections

Failed attempts remain in the record: a combined compiler/shipping Cargo graph fails at link and is replaced by the retained separate graph; the diagnostic fixture first lacks the required textual-IR NUL; then an Inkwell API sentinel makes saved bitcode invalid until the transport and reparse control are corrected. The initial LLVM lexer mistakes a quoted `alias` for syntax. A fixture comparison initially requests absent text stages before switching to the actual bitcode. The incomplete serial census is deliberately stopped after identity checks and replaced only after exact parser agreement.

An initial profile rejects perf's NUL-terminated acknowledgment before application execution. Another lacks the owned project before exec. A longer-prompt attempt reaches startup then exits with SIGSEGV before any mock request; no GC-elision change or cause is inferred. A completed shorter-prompt attempt is initially rejected for perf's requested SIGINT status. The final driver admits that status only after acknowledged shutdown, with independent export/reconciliation. This perf version rejects `script --full-paths`; the corrected ordinary export already supplies the full verified DSO paths. Failed attempts are not relabeled successful.

A later static-only denominator reconciliation was initially started without taking the campaign lock. Root identifies and stops its own exact process, observes the lock free, acquires it, then resumes and completes the pass. This occurs after all workload profiles; no study timing row overlaps it. No claim is made about lock ownership before that observation. Both the omission and correction are retained. The initial TLS query searches `SHADOW_STACK`; source inspection corrects it to the actual variable `SHADOW`, yielding 32 bytes plus the separate one-byte guard. An empty query result is not a zero-size result.

## Evidence and reproduction

The [sealed evidence archive](evidence/report-evidence-v1.tar.gz) is 41,842,804 bytes, SHA256 `d45036a383dd96caad8507995fd430196abd08f634aaa35bac7584fec1c1f0e1`. Its [manifest](evidence/manifest.json) lists 433 files totaling 249,171,000 uncompressed bytes; every extracted file was hash-verified locally. It contains full ledgers, per-unit barrier results, profile exports and disassembly, build/compile bindings and execution receipts. Curated report data live in `results/`; the observational scripts are beside this note. The uncompressed duplicate is ignored, not committed.

On `root@perrymaster.skelpo.net`, the experiment root is `/root/cc-perf-native-recv-0909/gc-leaf-census-20260911`. The exact binary is `compile-v2/cc-diagnostic`; bitcode is under `compile-v2/cc-bitcode`; accepted static output is `callsite-v5`; strict barrier output is `post-barrier-v1`. The archive is also retained at that root. Large binary/IR captures are receipt-bound on the box and intentionally absent from git.

To reproduce analysis, verify the archive hash, extract into a new owned directory, verify every manifest entry, and use the recorded commands/input bindings. `report_metrics_v1.py` regenerates the displayed aggregates from curated results. Rebuilding or resampling requires the recorded shipping graph, sandbox recipe and campaign lock; none is needed to inspect this completed result. No broad CI or main-branch merge was performed.
