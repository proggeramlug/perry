# Lane brief: fix PerryTS/perry issue #10151 — a multi-MB JSON object literal supplied via `--define` never finishes codegen

You are in a git worktree of PerryTS/perry (branch `fix/10151-large-json-define`, based on origin/main). Read the issue first: `gh issue view 10151 -R PerryTS/perry`. Background on the define feature: `docs/src/cli/flags.md` ("Build-time defines"), landed in PR #10129 (`git log --oneline -5 -- docs/src/cli/flags.md`, and the `define` handling under `crates/perry/src/commands/compile/` and `crates/perry-hir`/`perry-transform`). Prior art for the fix shape: PR #8418 lowered JSON *imports* through `JSON.parse` of a serialized string constant instead of IR-expanding the object literal (`git log --oneline --grep 8418`, then read that change).

## HARD RULE: never build or test on this Mac
This machine has ~12 GB of disk left. `.cargo/config.toml` in this worktree deliberately points cargo at a nonexistent target dir. Run every cargo / perry / test command through `./remote.sh '<command>'`, which syncs your current files (committed or not) to a warm Linux build host and runs the command there in the same worktree layout (cargo + LLVM 22, shared warm `CARGO_TARGET_DIR`, `cargo build --release -p perry` is incremental; the perry binary is then `$CARGO_TARGET_DIR/release/perry`). `$OPENCODE_SRC` on that host is an installed OpenCode v1.18.30 checkout; a real models.dev snapshot (4.6 MB JSON) is embedded as the `OPENCODE_MODELS_DEV` define in `$OPENCODE_SRC/packages/opencode/perry.json`. Editing, reading and git happen on the Mac.

## The bug
`perry compile --define 'BIG=<4.6 MB JSON object literal>'` (or the same value in `perry.json` `define`) substitutes the literal at its use site and lowers a 4.6 MB object literal into IR. The resulting codegen unit never finishes: one `perry-llvm-unit` thread at 100 % for 25+ minutes with the progress log silent, RSS flat. `PERRY_LL_PREOPT_OPTNONE_INSTRS=8192` (per-function optnone) does not help — the literal is one expression. With `--define BIG=undefined` the same compile proceeds normally.

Standalone reproduction (do this first, on the build host):
```sh
mkdir -p /tmp/def && cd /tmp/def
curl -fsSL https://models.dev/api.json -o models.json          # ~4.6 MB; or copy the value out of $OPENCODE_SRC/packages/opencode/perry.json
cat > main.ts <<'TS'
declare const BIG: Record<string, unknown> | undefined
export const snapshot = typeof BIG === "undefined" ? undefined : BIG
console.log(snapshot ? Object.keys(snapshot).length : "no snapshot")
TS
printf '{ "define": { "BIG": %s } }\n' "$(cat models.json | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" > perry.json
time timeout 600 $CARGO_TARGET_DIR/release/perry compile main.ts --output ./main --no-auto-optimize --cache-dir ./cache   # expect: hangs / >10 min today
```
(Check how `perry.json` `define` strings are interpreted — they are JS expressions, so the JSON text itself is the expression; adjust quoting if needed.) Measure where the time goes (`PERRY_CODEGEN_PROGRESS=1`, `PERRY_SAVE_LL=<dir>` to look at the IR size for the module) before changing anything.

## Deliverables
1. Root cause in the PR description (which stage explodes: HIR lowering of the literal, IR emission, or LLVM; approximate sizes).
2. The fix: a define (or any object/array literal) above a size threshold must lower like #8418's JSON imports — embed the serialized JSON text as a string constant and materialize the value with `JSON.parse` at first use (lazy or at module init, whichever #8418 chose), keeping `typeof X === "undefined"` folding and semantics identical. Threshold by literal size/node count, independent of function instruction counts; the define value must still be part of the build and object cache keys (it already is — keep it so).
3. Regression tests: a compile test with a >1 MiB JSON define that must finish in seconds and print the right key count; a small-define test proving small literals still lower directly (no behaviour change); unit test at the lowering threshold.
4. Verification on the build host: the repro compiles in seconds; the real OpenCode define compiles (`cd $OPENCODE_SRC/packages/opencode && $CARGO_TARGET_DIR/release/perry compile src/index.ts --platform bun --no-link --output /tmp/oc.o --cache-dir /tmp/oc-cache` is the full 7,800-module graph and takes ~80 min — instead compile only `../core/src/models-dev.ts` or a small entry importing it with the same `perry.json`, `--no-link`, and show it now takes seconds); `cargo test -p perry-hir --lib`, the new tests, `cargo fmt --all -- --check`, `./scripts/check_file_size.sh`. Report the exact commands and results.
5. Commit, `git push -u fork fix/10151-large-json-define`, open a PR against PerryTS/perry `main` with `gh pr create` following `CONTRIBUTING.md` and the recent PR template (Summary / Changes / Related issue `Fixes #10151` / Test plan / Checklist), plus a `changelog.d/10151-<slug>.md` fragment like the neighbours. Do not bump versions or edit CHANGELOG.md.

## Notes
- File-size policy: keep files under the cap enforced by `./scripts/check_file_size.sh`; split rather than grow.
- CI runners are unreliable; your evidence is the remote command output.
