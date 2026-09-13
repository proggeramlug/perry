## Summary

Fix multi-MB JSON defines that never finish LLVM code generation, while preserving ordinary lowering and static property layouts for mid-size records (Option 2 from the review).

The original 4,623,800-byte OpenCode snapshot expanded into 395 synthetic classes and 772,701,328 bytes of saved LLVM IR across 30 units. HIR-to-LLVM emission took roughly 11 seconds; the last LLVM unit did not finish in 600 seconds. Its entry function reached 8,445,662 instructions, with peak RSS of 13,667,064 KiB. The stall is in LLVM after literal expansion, not an AST-to-HIR lowering loop.

## Changes

- Flat arrays of primitives (numbers, strings, booleans, null): compact lowering at **1,024 value nodes or 64 KiB of string content**.
- Other JSON-compatible object/array literals: compact lowering at **24,576 value nodes or 1 MiB of key/string content**. Mid-size records retain ordinary lowering and static shapes.
- Thresholds count AST values and UTF-8 content, independently of function instruction budgets. A nested record/array anywhere in a candidate prevents admission to the lower tier.
- Keep `Expr::JsonParse(Expr::String(...))` at the original evaluation site, matching the JSON-import intrinsic from #8418. Each evaluation creates a fresh value; untaken branches do not parse. Existing define substitution, `typeof` folding, and both define-dependent cache keys are unchanged.
- Preserve key order, duplicate last-write behavior, escaping and negative zero. JavaScript-specific semantics (prototype setters, holes, spreads, effects, unsupported strings, non-finite values) retain ordinary lowering.
- Add coverage for both threshold tiers, direct lowering of 400 typed records and a 64 KiB record, plus a reproducible benchmark generator. Update CLI documentation and the issue's changelog fragment.

The record-array cutoff was measured using the exact regressing shape (`id`, `name`, `tags`, `w`), with a freshly built ordinary-lowering control equivalent to base `8a058e2053`:

| Records | Literal bytes | Value nodes | Ordinary no-link compile | Compact no-link compile |
| ---: | ---: | ---: | ---: | ---: |
| 4,800 | 307,740 | 33,601 | 475.17 s | 0.35 s |
| 6,400 | 412,540 | 44,801 | >600 s, timeout | 0.37 s |

At 6,400 records, emission completed in 4.5 seconds with approximately 85.1 MiB estimated IR and a 1,446,386-instruction function before optimization; four of five LLVM units completed within a second. The remaining unit timed out. The selected node threshold switches this shape at **3,511 records**, 27% below the eight-minute case and 45% below the timeout. It is 24 times the old node threshold; the text threshold is 16 times larger.

## Related issue

Fixes #10151

## Test plan

All builds and tests ran through `./remote.sh` on the Linux host with LLVM 22.1.8. None ran on the Mac. The compiler and matching runtime/stdlib archives were copied together out of the shared Cargo target. The ordinary control was built with the compact hook removed; the final compiler uses the code in this revision. Both link the same runtime/stdlib sources and archives.

Final build/check commands (inside `./remote.sh`):

```sh
export PERRY_BUILD_COMMIT=62bc84338176825534
cargo build --release -p perry -p perry-runtime-static -p perry-stdlib-static
mkdir -p /tmp/def/two-tier/final-bin
cp "$CARGO_TARGET_DIR/release/perry" "$CARGO_TARGET_DIR/release/libperry_runtime.a" "$CARGO_TARGET_DIR/release/libperry_stdlib.a" /tmp/def/two-tier/final-bin/
export PERRY_BIN=/tmp/def/two-tier/final-bin/perry
export PERRY_RUNTIME_DIR=/tmp/def/two-tier/final-bin
cargo test -p perry-hir --lib
cargo test --release -p perry --test issue_10151_large_json_define -- --nocapture
cargo test -p perry-hir --test shape_inference nested_object_literal_lowers_in_linear_time -- --nocapture
cargo fmt --all -- --check
./scripts/check_file_size.sh
python3 scripts/check_test_registration.py
python3 scripts/check_node_version_consistency.py --list
```

- Release build succeeded (existing runtime dead-code and Redis future-compatibility warnings).
- HIR: **411 passed, 1 ignored**, including all ten JSON-literal unit tests (2.35 s).
- Compile/run regressions: **4 passed** (6.32 s), including >1 MiB data, cache invalidation, CLI undefined override, small/mid-size direct lowering, fresh nested values, shadowed JSON, array mutations, negative zero, duplicate keys and escaping.
- Deep-literal regression passed (1.46 s). Formatting, file-size policy, registration and Node-version consistency passed.

Reproduction commands, with each snapshot stored as the JS-expression value of `BIG` in its directory's `perry.json`:

```sh
cd /tmp/def/two-tier/original-snapshot
/usr/bin/time -v timeout 60 "$PERRY_BIN" compile main.ts --output main-final --no-auto-optimize --cache-dir cache-final
./main-final
cd /tmp/def/two-tier/snapshot
/usr/bin/time -v timeout 60 "$PERRY_BIN" compile main.ts --output main-final --no-auto-optimize --cache-dir cache-final
./main-final
```

The **preserved 4,623,800-byte snapshot compiles and links in 1.52 s**, printing **213**. The installed snapshot has since refreshed to **4,637,074 bytes** (still 213 providers); it compiles and links in **1.54 s**, also printing **213**. Both use fresh caches. Peak RSS is about 410 MiB.

Real OpenCode verification keeps the installed `perry.json` unchanged and uses a temporary entry in `packages/opencode` importing `../core/src/models-dev`:

```sh
cd "$OPENCODE_SRC/packages/opencode"
/usr/bin/time -v timeout 600 env PERRY_DISABLE_BUILD_CACHE=1 PERRY_MODULE_JOBS=8 PERRY_DISABLE_WELL_KNOWN=1 PERRY_CODEGEN_PROGRESS=all "$PERRY_BIN" compile perry-10151-models.ts --platform bun --no-link --no-auto-optimize --output /tmp/def/two-tier/oc-final/main.o --cache-dir /tmp/def/oc-models-cache
```

The final compiler regenerated **`packages/core/src/models-dev.ts` in 10.6 s** (its matching object was held out of the cache to force codegen). The surrounding compile timed out at 600 s later in unrelated Effect dependency codegen. Resuming with the same final compiler and object cache completed **all 621 native modules**, exit 0, in **60.42 s**:

```sh
/usr/bin/time -v timeout 900 env -u PERRY_NO_CACHE -u PERRY_DISABLE_BUILD_CACHE PERRY_MODULE_JOBS=8 PERRY_DISABLE_WELL_KNOWN=1 PERRY_CODEGEN_PROGRESS=1 "$PERRY_BIN" compile perry-10151-models.ts --platform bun --no-link --no-auto-optimize --output /tmp/def/two-tier/oc-final/main.o --cache-dir /tmp/def/oc-models-cache
```

An additional ordinary-lowering 3,200-record probe exceeded its 180-second diagnostic timeout on the busy host. The selected threshold is a data-size heuristic below the measured 4,800/6,400-record cliff, not a universal compilation deadline for all smaller programs.

The no-link pipeline still resolves linker support archives; `PERRY_DISABLE_WELL_KNOWN=1` avoids building those unrelated archives. The temporary entry is removed afterward. The full 7,800-module application was not built.

Runtime A/B uses `benchmarks/large_json_literals/generate.py`, the exact audit fixture, separate caches, and five interleaved runs. Commands and cutoff reproduction are documented in that directory's README.

| Hot loop | Ordinary control | Final two-tier rule |
| --- | ---: | ---: |
| Separate 2,000-number array | 71 ms | 71 ms |
| Separate 400 typed records | 295 ms | 294 ms |
| Combined audit file: numbers | 290 ms | 291 ms |
| Combined audit file: records | 292 ms | 291 ms |

**Performance limitation:** the old broad rule measured 71 ms / 938 ms in the combined file. This revision restores record-read performance, but does **not** retain that combined file's numeric speedup. HIR confirms the numeric array still takes `JsonParse`; ordinary record initialization makes the same unit exceed LLVM's existing 100k-instruction O0 machine-code limit (about 622k instructions). The independent number probe shows no intrinsic runtime improvement on this host. Changing initialization/unit splitting would be additional codegen work; this revision keeps the requested two-tier scope. This limitation is reported explicitly for re-audit.

All numeric and record checksums match. The original semantic probe (mutations, key order, fresh arrays, Float64Array and Map) produced identical stdout across the ordinary control, old broad rule and revised rule. The combined file takes 58.90 s to compile under the final rule versus 60.07 s for ordinary lowering; mid-size record codegen is intentionally retained.

## Checklist

- [x] Added regression coverage for both tiers and mid-size static shapes.
- [x] Measured the record-array LLVM cutoff with margin below it.
- [x] Verified both original and current installed OpenCode defines.
- [x] Ran the requested remote build, tests and formatting/file-size checks.
- [x] Documented the A/B results, including the numeric-performance limitation.
- [x] Updated CLI docs and changelog fragment.
- [x] No version bump or edits to CLAUDE.md / CHANGELOG.md.
- [x] Read CONTRIBUTING.md and follow its PR conventions.
