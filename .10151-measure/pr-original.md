## Summary

A multi-MB JSON define expanded into hundreds of synthetic constructors and millions of LLVM instructions. Large JSON-compatible literals now lower to a serialized string plus the existing JSON parse intrinsic, at the original evaluation site.

Root cause measured with the installed OpenCode snapshot (4,623,800 bytes, 213 providers): AST/HIR literal expansion produced 395 synthetic classes; HIR-to-LLVM emission completed in roughly 11 seconds, but LLVM did not finish the last unit within 600 seconds. The entry function reached 8,445,662 instructions. `PERRY_SAVE_LL` captured 772,701,328 bytes across 30 units, including a 660,991,186-byte entry unit. The prolonged stall is in LLVM after literal expansion, not an AST-to-HIR lowering loop. Peak RSS was 13,667,064 KiB.

## Changes

- Select the compact path at 1,024 value nodes or 64 KiB of UTF-8 key/string data, independently of LLVM instruction budgets.
- Emit `Expr::JsonParse(Expr::String(...))`, as JSON imports do after #8418. Parsing remains at the expression's original evaluation site, so each evaluation creates a fresh value and untaken branches do not parse.
- Keep the parser's scope-aware define substitution and `typeof` folding ahead of this optimization. Both cache keys still include the effective define map.
- Serialize AST values directly, preserving key order, duplicates, escaping and negative zero. Fall back for prototype setters, holes, spreads, effects, non-finite values, unsupported strings, and excessive nesting.
- Add six lowering unit tests, four compile/run regressions with a 60-second compile deadline, documentation and `changelog.d/10151-large-json-define.md`.

## Related issue

Fixes #10151

## Test plan

All builds and tests ran on the Linux host through `./remote.sh`; none ran on the Mac. The host has LLVM 22.1.8. The reproduction uses the actual installed OpenCode snapshot, copied into `/tmp/def/perry.json` as the JavaScript expression for `BIG`.

Baseline commands (before the fix):

```sh
cd /tmp/def
/usr/bin/time -v timeout 600 env PERRY_CODEGEN_PROGRESS=1 PERRY_SAVE_LL=/tmp/def/before-ll "$CARGO_TARGET_DIR/release/perry" compile main.ts --output ./main --no-auto-optimize --cache-dir ./cache-before
mkdir -p /tmp/def/profile-ll
/usr/bin/time -v timeout 90 env PERRY_CODEGEN_PROGRESS=all PERRY_SAVE_LL=/tmp/def/profile-ll ./perry-before compile main.ts --no-link --output before.o --no-auto-optimize --cache-dir cache-profile
```

Both timed out (exit 124). The diagnostic run saved the IR and phase timings above.

Fixed build and regression commands:

```sh
export PERRY_BUILD_COMMIT=$(git rev-parse HEAD)
cargo build --release -p perry -p perry-runtime-static -p perry-stdlib-static
mkdir -p /tmp/def/verified-bin
cp "$CARGO_TARGET_DIR/release/perry" "$CARGO_TARGET_DIR/release/libperry_runtime.a" "$CARGO_TARGET_DIR/release/libperry_stdlib.a" /tmp/def/verified-bin/
export PERRY_BIN=/tmp/def/verified-bin/perry
export PERRY_RUNTIME_DIR=/tmp/def/verified-bin
cargo test --release -p perry --test issue_10151_large_json_define -- --nocapture
cargo test -p perry-hir --lib
cargo fmt --all -- --check
./scripts/check_file_size.sh
python3 scripts/check_node_version_consistency.py --list
python3 scripts/check_test_registration.py
cd /tmp/def
/usr/bin/time -v timeout 60 env PERRY_CODEGEN_PROGRESS=all PERRY_SAVE_LL=/tmp/def/after-ll "$PERRY_BIN" compile main.ts --output ./main-after --no-auto-optimize --cache-dir ./cache-after-final
./main-after
```

The compiler and matching archives are copied together because the Linux host shares its Cargo target directory with other lanes. The first linking attempt diagnosed an older runtime archive; rebuilding the wrapper crates resolved it.

- Release compiler + static archives built successfully (existing runtime dead-code warnings).
- All **4 compile/run regressions passed in 3.28 seconds**, including the >1 MiB define, changed key count through the same caches, CLI override to undefined, small direct lowering, fresh nested values, shadowed JSON, arrays, negative zero, duplicate keys and escaping.
- HIR library: **407 passed, 0 failed, 1 ignored** (0.13 seconds); all six new unit tests ran.
- `cargo test -p perry-hir --test shape_inference nested_object_literal_lowers_in_linear_time -- --nocapture`: passed (2.11 seconds), checking that the speculative JSON probe preserves the existing 6,000-level lowering bound.
- Formatting, the 2,000-line cap, Node-version consistency and test registration passed.
- Standalone reproduction: **1.48 seconds including linking**, exit 0, stdout **213**, peak RSS **419,684 KiB**. The saved IR is **6,043,184 bytes**, with **301 instruction lines and one JSON parse call**. Its object is **4,681,416 bytes**, mostly the snapshot data.

Real OpenCode verification used a small entry in `$OPENCODE_SRC/packages/opencode/perry-10151-models.ts`, with the existing `perry.json` unchanged:

```ts
import * as models from "../core/src/models-dev"
console.log(Object.keys(models).length)
```

```sh
cd "$OPENCODE_SRC/packages/opencode"
/usr/bin/time -v timeout 300 env PERRY_MODULE_JOBS=8 PERRY_CODEGEN_PROGRESS=all /tmp/def/perry-after compile perry-10151-models.ts --platform bun --no-link --no-auto-optimize --output /tmp/def/oc-models.o --cache-dir /tmp/def/oc-models-cache
/usr/bin/time -v timeout 300 env PERRY_MODULE_JOBS=8 PERRY_DISABLE_WELL_KNOWN=1 PERRY_CODEGEN_PROGRESS=1 /tmp/def/verified-bin/perry compile perry-10151-models.ts --platform bun --no-link --no-auto-optimize --output /tmp/def/oc-models.o --cache-dir /tmp/def/oc-models-cache
```

The first command generated all 621 native-module objects, including the actual **`packages/core/src/models-dev.ts` in 3.5 seconds**, but timed out after starting an unrelated HTTP archive build. Perry's current no-link path still resolves linker support archives. The second command disables that archive lookup and **exited 0 in 213.65 seconds**, filling the remaining dependency cache with the pinned compiler. The affected module's object is **5,314,904 bytes**, including the real snapshot.

The host requires npm dependencies to compile natively, so the narrow import still brings 621 modules. An attempted external-dependency shortcut was rejected; the reported result uses the actual native dependency graph. The 3.5-second timing is for the affected module, and 213.65 seconds is for the surrounding compile command.

This validates native code generation for the real module and define. The full 7,800-module OpenCode executable and its runtime model-fetch behavior were not built/tested, as requested by the lane brief.

## Checklist

- [x] Added regression coverage, including a generated >1 MiB define and structural tests at the lowering thresholds.
- [x] Updated build-time define documentation.
- [x] No workspace version bump or changes to `CLAUDE.md` / `CHANGELOG.md`.
- [x] Added a changelog fragment.
- [x] Commit follows the repository's `fix:` convention.
- [x] Read CONTRIBUTING.md and agree to the Code of Conduct.


<!-- This is an auto-generated comment: release notes by coderabbit.ai -->

## Summary by CodeRabbit

* **New Features**
  * Large JSON-compatible object and array literals, including build-time defines, are now handled efficiently while preserving evaluation behavior.
  * Repeated evaluations produce fresh values, and unused branches remain unevaluated.
  * Property ordering, escaping, numeric values, and nested JSON data are preserved.

* **Documentation**
  * Added guidance on size thresholds, runtime parsing, and cases that retain standard expression behavior.

<!-- end of auto-generated comment: release notes by coderabbit.ai -->
