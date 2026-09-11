#!/usr/bin/env python3
"""Correct the test input terminator; reuse unchanged shipping artifacts."""
import json
import os
import subprocess
from build_box_v1 import STAGE, SOURCE, TARGET, LOCK, sha, save, free, run


def main():
    LOCK.mkdir()
    owner = f"cc-gcleaf-test-v3 {os.getpid()}"
    (LOCK / "owner").write_text(owner + "\n")
    try:
        assert not (STAGE / "BUILD_COMPLETE.json").exists()
        old = json.loads((STAGE / "build-source-v1.json").read_text())
        new = json.loads((STAGE / "build-source-v2.json").read_text())
        for row in old["overlay_files"]:
            assert sha(SOURCE / row["path"]) == row["sha256"], row["path"]
        relative = "crates/perry-codegen/src/gc_leaf_census.rs"
        before = (SOURCE / relative).read_bytes()
        after = (STAGE / "gc_leaf_census-test-v2.rs").read_bytes()
        prefix = b"#[cfg(test)]"
        assert before.split(prefix)[0] == after.split(prefix)[0]
        assert before.replace(b'\\n}\\n";', b'\\n}\\n\\0";', 1) == after
        (SOURCE / relative).write_bytes(after)
        for row in new["overlay_files"]:
            assert sha(SOURCE / row["path"]) == row["sha256"], row["path"]
        identities = json.loads((STAGE / "shipping-identities.json").read_text())
        for relative, row in identities.items():
            assert sha(STAGE / relative) == row["sha256"], relative
        env = {k: v for k, v in os.environ.items() if not k.startswith("PERRY_")}
        env.update(PATH="/root/.cargo/bin:/usr/lib/llvm-22/bin:/usr/bin:/bin",
                   CARGO_TARGET_DIR=str(TARGET), PERRY_BUILD_COMMIT="cc-native-recv-0909",
                   LLVM_SYS_221_PREFIX="/usr/lib/llvm-22")
        run(["nice", "-n19", "cargo", "test", "--locked", "--offline", "--release",
             "-j4", "-p", "perry-codegen", "--lib", "gc_leaf_census::tests",
             "--", "--test-threads=1"], "v3-test-diagnostic-module", env)
        log = (STAGE / "v3-test-diagnostic-module.log").read_text()
        for name in ("complete_attempt_preserves_every_ir_byte_and_stage",
                     "abandoned_retry_and_missing_stage_cannot_be_complete",
                     "out_of_order_or_existing_snapshot_cannot_be_complete"):
            assert "test gc_leaf_census::tests::" + name + " ... ok" in log, name
        assert "3 passed; 0 failed" in log
        for relative, row in identities.items():
            assert sha(STAGE / relative) == row["sha256"], relative
        save(STAGE / "BUILD_COMPLETE.json", {
            "status": "v2 shipping artifacts reused; cfg(test) NUL correction; all three diagnostic tests pass",
            "source_receipt_sha256": sha(STAGE / "build-source-v2.json"),
            "production_build_source_receipt_sha256": sha(STAGE / "build-source-v1.json"),
            "artifacts": identities, "free_bytes": free(),
        })
        print("BUILD_COMPLETE", flush=True)
    finally:
        if (LOCK / "owner").read_text().strip() == owner:
            (LOCK / "owner").unlink()
            LOCK.rmdir()
    result = subprocess.run(["python3", "-B", str(STAGE / "compile_cc_v2.py")])
    save(STAGE / "emission-v2-result.json", {"exit": result.returncode})
    raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()
