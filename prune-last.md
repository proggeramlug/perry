Perry #10180 — validation in progress

Rule: collection tracks named export demand to a fixed point in `crates/perry/src/commands/compile/collect_modules/reexport_prune.rs`.
An unused re-export is postponed only when its exporting file and target's complete static dependency tree have package sideEffects contracts permitting omission.
Pure import/export-list barrels are normalized to equivalent re-exports; imports used by module code and genuine bare imports stay.
Later importers can reactivate edges. Namespace/dynamic imports retain full runtime exports and live aliases.
Unknown patterns, CommonJS, unresolved dependencies, and missing contracts retain modules. Omitted sources and package contracts invalidate build caches when changed.
Controls documented in `docs/src/cli/flags.md`: `PERRY_NO_REEXPORT_PRUNE=1` disables; `PERRY_COLLECT_ONLY=1` writes audit.json/module-graph.json without codegen.

| OpenCode v1.18.30 | Before | After |
|---|---:|---:|
| Collected modules | 7,897 | 6,863 |
| Eager / deferred | 2,433 / 5,464 | 2,223 / 4,640 |
| Bun reference inputs | 4,063 | 4,063 |
| Binary bytes | 1,297,524,704 | pending |
| .text bytes | 1,121,948,546 | pending |
| --version user CPU | 1.9 s | pending |
| --help user CPU | 28 s | pending |

Reduction: 1,034 modules (13.1%), including 210 eager modules (8.6%). Paired before/after collection uses the supplied flags; before CPU is the provided lane baseline, before size is the existing baseline binary.
Package reductions vs the paired audit: provider 648→147; provider-utils 1,012→795; Remeda 170→30; Smithy types 65→12; AWS types 40→1; OpenAI SDK 154→134; OpenAI-compatible SDK 90→70; other packages remove 44.
Bun comparison: those packages have 6 / 11 / 24 / 1 / 0 / 4 / 5 inputs respectively. Bun often uses bundled dist files where Perry uses source files, so raw counts differ in granularity.
All 15 Prettier and 257 Babel modules were already deferred and remain so; TypeScript has no collected source modules (native binding).
All 952 directly imported web-UI asset wrappers remain deferred. Dynamic provider subgraphs remain compiled.

Checks passed: 42 source-graph integration tests (17 new), one glob unit test, four build-cache tests, cargo fmt --all -- --check, scripts/check_file_size.sh, Node-version consistency.
Coverage includes sibling/disable A/B; effect order; star/rename chains; later imports; dynamic namespace/deferred init; live counter mutation; metadata arrays/external effects; cycles/unknown globs; cache invalidation; types/default-only stars; forwarding aliases/live mutation/bare imports; loader attributes (named default file import stays a path).
Prior full gap suite (Node 26.5.1): 769 passed, 10 output mismatches, zero compile failures/crashes in the full host run; the strict snapshot gate failed.
Six mismatches match the snapshot. The four additional mismatches (Map.groupBy/string, DisposableStack, iterator patching, HTTP2 callback rooting) reproduce on a freshly built pristine bb9aa5a641 compiler.
HTTP2 hits occupied port 443 on the host; in a private network namespace it times out after 10 s on both base and pruning builds. Its callback rung remains unverified.
Final-revision gap suite is running. The first OpenCode attempt was stopped during collection to add the loader-attribute guard; no code generation ran.
Full compile is queued behind PID 3168193, limited to 3 module jobs / 2 codegen-unit jobs; five CLI checks are queued after it.
Five CLI ladder comparisons and startup CPU: pending.
PR URL: pending.

Limitations: does not meet the issue's within-10%-of-Bun count target; no purity inference without sideEffects, namespace-property narrowing, package-version deduplication, or dynamic-code splitting. Validity of package sideEffects declarations is trusted.
OpenCode models/run runtime rungs are outside this lane due to #10222. Tracker: #10107.
