//! Regression: constructor inheritance must include computed static data fields
//! for both property reads and `in`, for Symbol and string keys.

use std::path::PathBuf;
use std::process::Command;
use std::sync::Once;

fn perry_bin() -> PathBuf {
    PathBuf::from(env!("CARGO_BIN_EXE_perry"))
}

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../..")
        .canonicalize()
        .expect("canonicalize workspace root")
}

fn runtime_dir() -> PathBuf {
    static BUILD_RUNTIME: Once = Once::new();
    BUILD_RUNTIME.call_once(|| {
        let cargo = std::env::var_os("CARGO").unwrap_or_else(|| "cargo".into());
        let build = Command::new(cargo)
            .current_dir(workspace_root())
            .arg("build")
            .arg("-p")
            .arg("perry-runtime-static")
            .arg("-p")
            .arg("perry-stdlib-static")
            .output()
            .expect("build static runtime archives");
        assert!(
            build.status.success(),
            "static runtime build failed\nstdout:\n{}\nstderr:\n{}",
            String::from_utf8_lossy(&build.stdout),
            String::from_utf8_lossy(&build.stderr)
        );
    });
    let target = std::env::var_os("CARGO_TARGET_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|| workspace_root().join("target"));
    target.join("debug")
}

#[test]
fn subclass_inherits_computed_static_data_fields() {
    let dir = tempfile::tempdir().expect("tempdir");
    let entry = dir.path().join("main.ts");
    let output = dir.path().join("main_bin");
    std::fs::write(
        &entry,
        r#"
const brand = Symbol.for("perry.static-symbol-inheritance");
const stringBrand = "~perry/static-string-inheritance";
class Parent {
  static [brand] = brand;
  static [stringBrand] = stringBrand;
}
class Child extends Parent {}
function makeParent() {
  return class GeneratedParent {
    static [brand] = brand;
    static [stringBrand] = stringBrand;
  };
}
const GeneratedParent = makeParent();
class GeneratedChild extends GeneratedParent {}
console.log(brand in Parent, Parent[brand] === brand, stringBrand in Parent, Parent[stringBrand] === stringBrand);
console.log(brand in Child, Child[brand] === brand, stringBrand in Child, Child[stringBrand] === stringBrand);
console.log(brand in GeneratedParent, GeneratedParent[brand] === brand, stringBrand in GeneratedParent, GeneratedParent[stringBrand] === stringBrand);
console.log(brand in GeneratedChild, GeneratedChild[brand] === brand, stringBrand in GeneratedChild, GeneratedChild[stringBrand] === stringBrand);
"#,
    )
    .expect("write entry");

    let compile = Command::new(perry_bin())
        .current_dir(dir.path())
        .arg("compile")
        .arg(&entry)
        .arg("-o")
        .arg(&output)
        .arg("--no-cache")
        .env("PERRY_NO_AUTO_OPTIMIZE", "1")
        .env("PERRY_RUNTIME_DIR", runtime_dir())
        .output()
        .expect("run perry compile");
    assert!(
        compile.status.success(),
        "perry compile failed\nstdout:\n{}\nstderr:\n{}",
        String::from_utf8_lossy(&compile.stdout),
        String::from_utf8_lossy(&compile.stderr)
    );

    let run = Command::new(&output)
        .current_dir(dir.path())
        .output()
        .expect("run compiled binary");
    assert!(
        run.status.success(),
        "compiled binary failed\nstdout:\n{}\nstderr:\n{}",
        String::from_utf8_lossy(&run.stdout),
        String::from_utf8_lossy(&run.stderr)
    );
    assert_eq!(
        String::from_utf8_lossy(&run.stdout),
        "true true true true\ntrue true true true\ntrue true true true\ntrue true true true\n"
    );
}
