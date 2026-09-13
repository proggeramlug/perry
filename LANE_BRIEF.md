# Lane brief: fix PerryTS/perry issue #10152 — split-unit skeleton references a string constant's `.bytes` owned by another unit

You are working in a git worktree of PerryTS/perry (branch `fix/10152-cgu-str-bytes`, based on origin/main 5603d63d1). Read the issue text first: `gh issue view 10152 -R PerryTS/perry`.

## HARD RULE: never build or test on this Mac
This machine has 12 GB of disk left; a local cargo build would take the whole team down. `.cargo/config.toml` in this worktree points cargo at a nonexistent target dir on purpose. Every cargo / perry / test command goes through `./remote.sh '<command>'`, which syncs your current files (committed or not) to a warm build host and runs the command there in the same worktree layout. Examples:
- `./remote.sh 'cargo test -p perry-codegen --lib unit_partition'`
- `./remote.sh 'cargo build --release -p perry && PERRY_LL_SIZE_OPT=1 PERRY_LL_PREOPT_OPTNONE_INSTRS=8192 PERRY_CODEGEN_UNIT_JOBS=2 PERRY_SAVE_LL=/tmp/ll ./target/release/perry compile $OPENTUI_CORE/index.node.js --no-link --output /tmp/o.o --cache-dir /tmp/c-$$'` (mkdir /tmp/ll first)
`$OPENTUI_CORE` is the failing package directory (`@opentui/core@0.4.5`) inside an installed OpenCode v1.18.30 checkout (`$OPENCODE_SRC`) on the build host. The remote shell starts in the synced worktree with cargo/LLVM 22 configured and a shared, already-warm `CARGO_TARGET_DIR` (a release build of `-p perry` is incremental, ~1–4 min). Reading files, git, and editing happen here on the Mac as usual.

## The bug
Compiling `$OPENTUI_CORE/index.node.js` (3 modules) fails on `chunk-node-q0cwyvm9.js`:
```
[perry] codegen: chunk_node_q0cwyvm9_js: LLVM unit 1/4 failed after 0.2s: unit 0 skeleton: LLVM IR parse error:
perry_native_module:2850:135: error: use of undefined value '@chunk_node_q0cwyvm9_js_.str.67.bytes'
@chunk_node_q0cwyvm9_js_.str.67.dispatch = unnamed_addr constant { i32, i32, i64, ptr } { i32 7, i32 0, i64 -8781398128184088314, ptr @chunk_node_q0cwyvm9_js_.str.67.bytes }
```
The module is partitioned into codegen units (`crates/perry-codegen/src/codegen/mod.rs` around the `PERRY_SAVE_LL` per-unit dump, plus the unit partitioning/"skeleton" code it calls). The unit-0 skeleton emits the `.str.67.dispatch` header constant but the `.str.67.bytes` array it points to is not defined in that unit (it was assigned elsewhere or dropped). All other string constants of this 1,337-callable module partition correctly, so this is an ownership/placement rule that disagrees between the dispatch-header emitter and the bytes emitter for one class of string (find what is special about string #67: dump the units with `PERRY_SAVE_LL=<dir>`, grep `.str.67` across `<prefix>.unit*.ll`, and look at how the string is used — e.g. only from a function that was moved to another unit, a shape-key/dispatch-only use, a string that is both a property key and a literal, a deduplicated constant, etc.).

## Deliverables
1. Root cause written in the PR description in two or three sentences (what decides the owner unit of `.bytes`, what decides where `.dispatch` goes, and why they disagreed here).
2. A minimal fix in perry-codegen (do not just force every string into the skeleton unless you can show it is the right rule; keep units' object sizes stable).
3. A regression test: a reduced TS/JS module (checked in under the existing codegen test conventions, e.g. `crates/perry-codegen` unit test or `crates/perry/tests/*.rs` end-to-end compile) that reproduces the "dispatch in skeleton, bytes elsewhere" split and fails before the fix. If the split only triggers above a size threshold, use the existing env knobs (`PERRY_LL_FAST_EMIT_MAX_INSTRS`, unit thresholds) in the test to force partitioning on a small module.
4. Verification on the build host: the 3-module repro compiles (`--no-link`), `cargo test -p perry-codegen --lib` passes, `cargo fmt --all -- --check` and `./scripts/check_file_size.sh` pass. Report exact commands and results.
5. Commit on this branch, push to the `fork` remote (`git push -u fork fix/10152-cgu-str-bytes`), and open a PR against PerryTS/perry `main` with `gh pr create` following `CONTRIBUTING.md` and the PR template used by recent PRs (Summary / Changes / Related issue `Fixes #10152` / Test plan / Checklist). Add a `changelog.d/10152-<slug>.md` fragment like the neighbours. Do not bump versions or edit CHANGELOG.md.

## Notes
- Repo policy: files must stay under the size cap checked by `./scripts/check_file_size.sh`; split modules rather than growing one past it.
- CI runners are unreliable; your evidence is the remote command output, not the GitHub checks.
- If you need OpenCode context: the module is the OpenTUI node-backend chunk, reachable only under the node condition; its bun twin `chunk-bun-t2myhmwd.js` compiles fine — diffing how the two are partitioned may be a shortcut.
