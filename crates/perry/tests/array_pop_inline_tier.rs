//! The inline plain-array `pop` tier (`perry-codegen/src/expr/array_pop.rs`)
//! mirrors `js_array_pop_f64`'s fast-path admission; every case the runtime
//! declines must still reach it and behave as Node does: holes, a frozen
//! array, a non-writable `length`, an Array subclass, a non-array receiver, an
//! accessor in the popped slot, and a polluted `Array.prototype`.
//!
//! Two pre-existing runtime gaps are deliberately NOT pinned here (they are
//! identical before and after the inline tier, which routes both to the
//! runtime): popping a hole yields `NaN` where Node yields `undefined`, and
//! `"abc".pop()` through an erased field does not throw.
use std::path::PathBuf;
use std::process::{Command, Output};

fn perry_bin() -> PathBuf {
    PathBuf::from(env!("CARGO_BIN_EXE_perry"))
}

fn compile_and_run(source: &str) -> Output {
    let dir = tempfile::tempdir().expect("tempdir");
    let entry = dir.path().join("main.js");
    let output = dir.path().join("main_bin");
    std::fs::write(&entry, source).expect("write entry");
    let compile = Command::new(perry_bin())
        .current_dir(dir.path())
        .arg("compile")
        .arg(&entry)
        .arg("-o")
        .arg(&output)
        .arg("--no-auto-optimize")
        .output()
        .expect("run perry compile");
    assert!(
        compile.status.success(),
        "perry compile failed\nstdout:\n{}\nstderr:\n{}",
        String::from_utf8_lossy(&compile.stdout),
        String::from_utf8_lossy(&compile.stderr)
    );
    Command::new(&output).output().expect("run compiled binary")
}

/// One program, one line of output, compared against what Node prints for
/// the same source. Every `take()` goes through the erased-field `pop` route
/// that carries the inline tier.
#[test]
fn every_case_the_inline_pop_tier_declines_still_matches_node() {
    let run = compile_and_run(
        r#"
class Stack { items = []; take() { return this.items.pop(); } }
const out = [];
const s = new Stack();
for (let i = 0; i < 40; i++) s.items.push(i);
out.push(s.take(), s.take(), s.items.length);
const e = new Stack(); out.push(String(e.take()), e.items.length);
const h = new Stack(); h.items = [1, , 3]; out.push(h.take()); h.take(); out.push(h.items.length);
const f = new Stack(); f.items = Object.freeze([1, 2]);
try { f.take(); out.push("no-throw"); } catch (err) { out.push(err.constructor.name, f.items.length); }
const nw = new Stack(); nw.items = [1, 2]; Object.defineProperty(nw.items, "length", { writable: false });
try { nw.take(); out.push("no-throw"); } catch (err) { out.push(err.constructor.name, nw.items.length); }
class Sub extends Array {}
const sub = new Stack(); sub.items = Sub.of(7, 8, 9); out.push(sub.take(), sub.items.length, sub.items instanceof Sub);
const acc = new Stack(); acc.items = [1, 2, 3]; Object.defineProperty(acc.items, "2", { get() { return "g"; }, configurable: true });
out.push(acc.take(), acc.items.length);
Array.prototype[1] = "proto"; const pol = new Stack(); pol.items = [0, , 2]; out.push(pol.take(), pol.take(), pol.items.length); delete Array.prototype[1];
console.log(out.join(" "));
"#,
    );
    assert!(
        run.status.success(),
        "the program must exit cleanly\nstdout:\n{}\nstderr:\n{}",
        String::from_utf8_lossy(&run.stdout),
        String::from_utf8_lossy(&run.stderr)
    );
    assert_eq!(
        String::from_utf8_lossy(&run.stdout),
        "39 38 38 undefined 0 3 1 TypeError 2 TypeError 2 9 2 true g 2 2 proto 1\n"
    );
}
