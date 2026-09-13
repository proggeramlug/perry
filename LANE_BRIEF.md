# Lane brief: fix PerryTS/perry issue #10153 — ESM named import of a CommonJS getter re-export binds to a missing `perry_fn_` symbol

You are in a git worktree of PerryTS/perry (branch `fix/cjs-getter-reexport-binding`, based on origin/main). Read the issue first: `gh issue view 10153 -R PerryTS/perry`.

## HARD RULE: never build or test on this Mac
This machine has ~12 GB of disk left. `.cargo/config.toml` in this worktree deliberately points cargo at a nonexistent target dir. Run every cargo / perry / test command through `./remote.sh '<command>'`, which syncs your current files (committed or not) to a warm Linux build host and runs the command there in the same worktree layout (cargo + LLVM 22 configured, shared warm `CARGO_TARGET_DIR`; `cargo build --release -p perry` is incremental). `$OPENCODE_SRC` on that host is an installed OpenCode v1.18.30 checkout; `$OPENCODE_SRC/packages/opencode` resolves `@babel/core@7.28.0`. Editing, reading and git happen here on the Mac.
Example: `./remote.sh 'cargo build --release -p perry && cd $OPENCODE_SRC/packages/opencode && cat > /tmp/bg.mjs <<EOF2
import { transformAsync } from "@babel/core"; console.log(typeof transformAsync); const o = await transformAsync("const a = 1;", { babelrc: false, configFile: false }); console.log(o.code);
EOF2
$CARGO_TARGET_DIR/release/perry compile /tmp/bg.mjs --output /tmp/bg --cache-dir /tmp/bg-cache && /tmp/bg'`
(the perry binary of your build is `$CARGO_TARGET_DIR/release/perry`; put the entry file inside `$OPENCODE_SRC/packages/opencode/` if resolution from /tmp does not find `@babel/core`.)

## The bug
`@opentui/solid/scripts/solid-transform.js` does `import { transformAsync } from "@babel/core"`. `@babel/core/lib/index.js` is CommonJS and exports it as a getter:
```js
Object.defineProperty(exports, "transformAsync", { enumerable: true, get: function () { return _transform.transformAsync; } });
```
Perry lowers the import as a direct call to `perry_fn_<index.js>__transformAsync` — it decided the export is a function *defined in* index.js — but the CJS wrapper for index.js defines no such function, so the final link of the whole OpenCode graph fails with exactly this one `undefined reference`. Start in `crates/perry/src/commands/compile/cjs_wrap/extract_exports.rs` (and its callers in `cjs_wrap/mod.rs`, plus wherever ESM named imports of CJS modules are classified as static function bindings vs namespace reads). The defineProperty-getter shape is what `@babel/plugin-transform-modules-commonjs` emits for every `export { x } from "./y"`, so treat the whole family: `Object.defineProperty(exports, "name", { get })`, `Object.defineProperty(exports, "name", { value })`, and exports assigned inside functions / after the fact.

## Deliverables
1. Root cause in the PR description (2–3 sentences: how the export got classified, why the symbol was never emitted).
2. The fix: such exports must be *value* exports read through the module namespace at use time (getter-aware live binding); calls go through the read value. Do not special-case `@babel/core`.
3. Regression tests: a CJS fixture with the Babel getter re-export shape imported by an ESM caller via `import { x }` and via `import * as ns; ns.x()`, exercised by an end-to-end compile test under `crates/perry/tests/` in the style of the existing `source_graph_export_regressions.rs` / `issue_*` tests, plus a unit test in `cjs_wrap` if the classification lives there. Must fail before the fix (link error or wrong value) and pass after.
4. Verification on the build host: the repro above prints `function` and `const a = 1;`; `cargo test -p perry --test source_graph_export_regressions`, your new tests, `cargo test -p perry --bin perry cjs_wrap`, `cargo fmt --all -- --check`, `./scripts/check_file_size.sh`. Report the exact commands and results.
5. Commit, `git push -u fork fix/cjs-getter-reexport-binding`, open a PR against PerryTS/perry `main` with `gh pr create` following `CONTRIBUTING.md` and the recent PR template (Summary / Changes / Related issue `Fixes #10153` / Test plan / Checklist), plus a `changelog.d/10153-<slug>.md` fragment like the neighbours. Do not bump versions or edit CHANGELOG.md.

## Notes
- File-size policy: keep files under the cap enforced by `./scripts/check_file_size.sh`; split rather than grow.
- CI runners are unreliable; your evidence is the remote command output.
- Keep the change minimal and general; if the correct behaviour needs a runtime helper, follow the existing "new native function" wiring conventions in the crate (declarations in `runtime_decls`, etc.).
