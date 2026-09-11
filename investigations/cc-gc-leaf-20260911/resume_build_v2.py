#!/usr/bin/env python3
"""Resume unchanged source with compiler and Wasm shipping graph separated."""
import os
import json
import time
from pathlib import Path
from build_box_v1 import STAGE, SOURCE, TARGET, LOCK, sha, save, free, run


def main():
    assert not (STAGE / "BUILD_COMPLETE.json").exists()
    assert json.loads((STAGE / "build-shipping-graph.command.json").read_text())["exit"] == 101
    LOCK.mkdir()
    owner = f"cc-gcleaf-build-v2 {os.getpid()}"
    (LOCK / "owner").write_text(owner + "\n")
    try:
        receipt = json.loads((STAGE / "build-source-v1.json").read_text())
        for item in receipt["overlay_files"]:
            assert sha(SOURCE / item["path"]) == item["sha256"], item["path"]
        env = {k: v for k, v in os.environ.items() if not k.startswith("PERRY_")}
        env.update(
            PATH="/root/.cargo/bin:/usr/lib/llvm-22/bin:/usr/bin:/bin",
            CARGO_TARGET_DIR=str(TARGET), PERRY_BUILD_COMMIT="cc-native-recv-0909",
            LLVM_SYS_221_PREFIX="/usr/lib/llvm-22",
        )
        run(["nice", "-n19", "cargo", "build", "--locked", "--offline",
             "--release", "-j4", "-p", "perry"], "v2-build-compiler", env)
        compiler_sha = sha(TARGET / "release/perry")
        packages = ["perry-runtime-static", "perry-stdlib-static", "perry-wasm-host"]
        packages += sorted(path.name for path in (SOURCE / "crates").glob("perry-ext-*") if path.is_dir())
        cmd = ["nice", "-n19", "cargo", "build", "--locked", "--offline", "--release", "-j4"]
        for package in packages:
            cmd += ["-p", package]
        cmd += ["--features", "perry-runtime/wasm-host"]
        run(cmd, "v2-build-shipping-archives", env)
        assert sha(TARGET / "release/perry") == compiler_sha
        artifacts = [TARGET / "release/perry"] + sorted((TARGET / "release").glob("libperry*.a"))
        identities = {
            str(path.relative_to(STAGE)): {"sha256": sha(path), "bytes": path.stat().st_size}
            for path in artifacts
        }
        save(STAGE / "shipping-identities.json", identities)
        run(["nice", "-n19", "cargo", "test", "--locked", "--offline",
             "--release", "-j4", "-p", "perry-codegen", "--lib",
             "gc_leaf_census::tests", "--", "--test-threads=1"],
            "v2-test-diagnostic-module", env)
        log = (STAGE / "v2-test-diagnostic-module.log").read_text()
        names = (
            "complete_attempt_preserves_every_ir_byte_and_stage",
            "abandoned_retry_and_missing_stage_cannot_be_complete",
            "out_of_order_or_existing_snapshot_cannot_be_complete",
        )
        for name in names:
            assert "test gc_leaf_census::tests::" + name + " ... ok" in log, name
        assert "3 passed; 0 failed" in log
        for rel, row in identities.items():
            assert sha(STAGE / rel) == row["sha256"], rel
        save(STAGE / "BUILD_COMPLETE.json", {
            "status": "separate compiler and shipping graph built; three diagnostic tests passed",
            "source_receipt_sha256": sha(STAGE / "build-source-v1.json"),
            "artifacts": identities, "free_bytes": free(),
            "completed_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        })
        print("BUILD_COMPLETE", flush=True)
    finally:
        if (LOCK / "owner").read_text().strip() == owner:
            (LOCK / "owner").unlink()
            LOCK.rmdir()


if __name__ == "__main__":
    main()
