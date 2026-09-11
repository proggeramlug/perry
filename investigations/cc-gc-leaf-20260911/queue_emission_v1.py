#!/usr/bin/env python3
"""Start the frozen emission phase only after this owned build succeeds."""
import json
import subprocess
import time
from pathlib import Path

ROOT = Path("/root/cc-perf-native-recv-0909/gc-leaf-census-20260911")
BUILD_PID = 3665762


def main():
    deadline = time.monotonic() + 7200
    while not (ROOT / "BUILD_COMPLETE.json").exists():
        assert time.monotonic() < deadline, "build completion wait exceeded two hours"
        proc = Path("/proc") / str(BUILD_PID)
        assert proc.exists(), "owned build ended without BUILD_COMPLETE"
        assert str(ROOT / "resume_build_v2.py").encode() in (proc / "cmdline").read_bytes()
        time.sleep(10)
    result = subprocess.run(["python3", str(ROOT / "compile_cc_v1.py")])
    (ROOT / "emission-queue-result.json").write_text(
        json.dumps({"emission_exit": result.returncode}) + "\n")
    raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()
