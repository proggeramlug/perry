#!/usr/bin/env python3
"""Validate observation-only codegen, then compile original cc with snapshots."""
import hashlib
import json
import os
import shutil
import struct
import subprocess
import time
from pathlib import Path

STAGE = Path("/root/cc-perf-native-recv-0909/gc-leaf-census-20260911")
SOURCE = Path("/root/worktrees/cc-gc-leaf-census-0911")
CONTROL_DIR = Path("/root/cc-perf-native-recv-0909/cc-control")
LOCK = Path("/root/rig9831/lock")
COMPILER = STAGE / "target/release/perry"
FIXTURE = STAGE / "diagnostic_fixture.ts"
JS = CONTROL_DIR / "cli_2.1.112.js"
OUT = STAGE / "compile-v1"


def sha(path):
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def save(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + "\n")


def sections(path):
    with Path(path).open("rb") as stream:
        header = stream.read(64)
        assert header[:6] == b"\x7fELF\x02\x01"
        offset = struct.unpack_from("<Q", header, 40)[0]
        size, count, names_index = struct.unpack_from("<HHH", header, 58)
        assert size == 64 and 0 < names_index < count
        stream.seek(offset)
        records = [struct.unpack("<IIQQQQIIQQ", stream.read(64)) for _ in range(count)]
        names = records[names_index]
        stream.seek(names[4])
        names = stream.read(names[5])
        result = {}
        for record in records:
            end = names.index(b"\0", record[0])
            name = names[record[0]:end].decode()
            if name in (".text", ".perry_gcmap"):
                stream.seek(record[4])
                data = stream.read(record[5])
                assert len(data) == record[5]
                result[name] = {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
        assert set(result) == {".text", ".perry_gcmap"}
        return result


def command(argv, name, env, cwd=CONTROL_DIR):
    assert shutil.disk_usage(STAGE).free >= 12 * 1024**3, "below 12 GiB before compiler"
    row = {
        "argv": list(map(str, argv)), "cwd": str(cwd),
        "started_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "compiler_sha256": sha(COMPILER),
        "diagnostic_directory": env.get("PERRY_GC_LEAF_CENSUS_DIR"),
        "cache_bypassed": env.get("PERRY_NO_CACHE") == "1",
    }
    save(OUT / (name + ".command.json"), row)
    print("START", name, row["started_utc"], flush=True)
    with (OUT / (name + ".log")).open("x") as log:
        result = subprocess.run(argv, cwd=cwd, env=env, stdout=log, stderr=subprocess.STDOUT)
    row.update(exit=result.returncode,
               finished_utc=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
    save(OUT / (name + ".command.json"), row)
    print("EXIT", name, result.returncode, flush=True)
    assert result.returncode == 0, (name, result.returncode)


def environment(label):
    env = {k: v for k, v in os.environ.items() if not k.startswith("PERRY_")}
    home = Path("/tmp/tt_home_gcleaf_compile0911_" + label)
    assert not home.exists()
    home.mkdir()
    config = home / ".claude"
    config.mkdir()
    env.update(
        HOME=str(home), CLAUDE_CONFIG_DIR=str(config),
        PATH="/root/.cargo/bin:/usr/lib/llvm-22/bin:/usr/bin:/bin",
        PERRY_RUNTIME_DIR=str(STAGE / "target/release"),
        PERRY_KEEP_SYMBOLS="1", PERRY_NO_CACHE="1",
        PERRY_SEGMENTS_PROJECT="1", PERRY_SEGVIEW="0",
        PERRY_SEGMENTS_PROJECT_DIAG="1",
        PERRY_REGEX_ENGINE="default", PERRY_REGEX_DIAG="0",
    )
    return env


def verify_archives(identities):
    for relative, row in identities.items():
        assert sha(STAGE / relative) == row["sha256"], relative


def main():
    complete = json.loads((STAGE / "BUILD_COMPLETE.json").read_text())
    deadline = time.monotonic() + 7200
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            assert time.monotonic() < deadline, "campaign lock wait exceeded two hours"
            print("WAIT_CAMPAIGN_LOCK", flush=True)
            time.sleep(10)
    owner = f"cc-gcleaf-emission-v1 {os.getpid()}"
    (LOCK / "owner").write_text(owner + "\n")
    try:
        OUT.mkdir()
        verify_archives(complete["artifacts"])
        assert sha(JS) == "bc3358282800e3e99daa8e71ac5b7b1566bd0d7ca7eb94f714a7859365d3163f"
        receipt = json.loads((STAGE / "build-source-v2.json").read_text())
        for row in receipt["overlay_files"]:
            assert sha(SOURCE / row["path"]) == row["sha256"], row["path"]
        output_rows = {}
        for arm in ("off", "on"):
            env = environment("fixture_" + arm)
            dump = OUT / ("fixture-" + arm + "-bitcode")
            assert not dump.exists()
            if arm == "on":
                env["PERRY_GC_LEAF_CENSUS_DIR"] = str(dump)
            binary = OUT / ("fixture-" + arm)
            argv = [str(COMPILER), "compile", "--no-auto-optimize",
                    "--enable-wasm-runtime", str(FIXTURE), "-o", str(binary)]
            command(argv, "fixture-" + arm, env)
            result = subprocess.run([binary], env=env, cwd=CONTROL_DIR, capture_output=True)
            assert result.returncode == 0 and result.stdout == b"ept!:8\n", (arm, result.returncode, result.stdout)
            (OUT / ("fixture-" + arm + ".stdout")).write_bytes(result.stdout)
            (OUT / ("fixture-" + arm + ".stderr")).write_bytes(result.stderr)
            output_rows[arm] = sections(binary)
            if arm == "off":
                assert not dump.exists()
            else:
                attempts = list(dump.glob("pid-*-attempt-*"))
                accepted = [p for p in attempts if (p / "complete.json").exists()]
                assert accepted
                statepoints = 0
                for attempt in accepted:
                    row = json.loads((attempt / "complete.json").read_text())
                    for snapshot in row["snapshots"]:
                        assert (attempt / snapshot["file"]).stat().st_size == snapshot["bytes"]
                    text = subprocess.check_output(
                        ["/usr/lib/llvm-22/bin/llvm-dis", str(attempt / "post-rs4gc.bc"), "-o", "-"], text=True,
                    )
                    statepoints += sum(
                        "@llvm.experimental.gc.statepoint" in line
                        and (" = call " in line or " = invoke " in line)
                        for line in text.splitlines()
                    )
                assert statepoints > 0, "diagnostic's subject never ran"
                output_rows["on_diagnostic"] = {
                    "attempts": len(attempts), "complete": len(accepted),
                    "post_rewrite_statepoints": statepoints,
                }
        assert output_rows["off"] == output_rows["on"], "diagnostic changed fixture .text or .perry_gcmap"
        save(OUT / "FIXTURE_PASS.json", {
            "expected_stdout": "ept!:8", "code_and_gcmap_equal": True,
            "results": output_rows,
        })
        verify_archives(complete["artifacts"])
        env = environment("cc")
        env["PERRY_GC_LEAF_CENSUS_DIR"] = str(OUT / "cc-bitcode")
        argv = ["/usr/bin/time", "-v", "nice", "-n19", str(COMPILER), "compile",
                "--no-auto-optimize", "--enable-wasm-runtime",
                str(JS), "-o", str(OUT / "cc-diagnostic")]
        command(argv, "cc-diagnostic", env)
        verify_archives(complete["artifacts"])
        binary = OUT / "cc-diagnostic"
        save(OUT / "COMPILE_COMPLETE.json", {
            "application_sha256": sha(binary), "application_bytes": binary.stat().st_size,
            "compiler_sha256": sha(COMPILER), "sections": sections(binary),
            "source_receipt_sha256": sha(STAGE / "build-source-v2.json"),
            "bitcode_dir": str(OUT / "cc-bitcode"),
            "success_marker": "full original cc compiler invocation exited zero",
        })
        print("CC_DIAGNOSTIC_COMPILE_COMPLETE", flush=True)
    finally:
        if (LOCK / "owner").read_text().strip() == owner:
            (LOCK / "owner").unlink()
            LOCK.rmdir()


if __name__ == "__main__":
    main()
