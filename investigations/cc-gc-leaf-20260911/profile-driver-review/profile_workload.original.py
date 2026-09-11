#!/usr/bin/env python3
"""Startup plus two real Read operations against deterministic offline replay.

The caller must hold the campaign lock. CPU samples have no callchains.
"""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
import pty
import select
import signal
import struct
import subprocess
import termios
import time
from pathlib import Path

STAGE = Path("/root/cc-perf-native-recv-0909")
DRIVER = STAGE / "stream_linux_cpuset.py"
PROJ = Path("/tmp/tt_proj_9831")
FIXTURE = PROJ / "cc-gcleaf-fixture-0911"
PIN = "2-4,6-7,10-12,14-15"
PACKAGE = {
    "name": "cc-gc-leaf-fixture", "private": True, "type": "module",
    "scripts": {"start": "node src/index.ts", "test": "node --test"},
    "description": "Small message formatter for the offline compiler campaign",
    "censusFixture": "GCLEAF_PACKAGE_0911",
}
CODE = """export const censusFixture = "GCLEAF_SOURCE_0911";
export function formatGreeting(name: string): string {
  const clean = name.trim();
  return clean.length ? "Hello, " + clean + "!" : "Hello, friend!";
}
console.log(formatGreeting(process.argv[2] ?? ""));
"""
PROMPT = (
    "Read cc-gcleaf-fixture-0911/package.json and cc-gcleaf-fixture-0911/src/index.ts. "
    "Explain what this project does, how to run it, and what tests it needs."
)
ANSWER = """The project is a small TypeScript greeting formatter, packaged as an ES module. Its package is private and has no application dependencies. The package manifest defines a start command and a test command. The implementation exports a formatting function, reads one optional command-line argument, and prints a greeting.

The formatting function removes whitespace from the beginning and end of the supplied name. A nonempty result produces a personalized greeting. Empty input, or input consisting entirely of whitespace, produces the default greeting. The function returns a string and does not write files, access the network, or modify its input.

To run the project, use its start script with a recent Node release that can execute this TypeScript syntax. Pass a name as the command-line argument. The default path accepts a missing argument and uses an empty string before formatting. The code also exports the function so that a test can exercise the formatting independently from the command-line interface.

The manifest's test command invokes the Node test runner. There are no test files in the two files inspected. Useful tests would cover an ordinary name, leading whitespace, trailing whitespace, a blank string, whitespace-only input, and a name containing punctuation. Unicode whitespace and non-Latin names would add useful coverage without changing the intended behavior.

A few details help explain the data flow. The process argument is read once, a missing value is replaced with an empty string, and that string is passed into the formatter. The formatter computes a trimmed local string, checks its length, and chooses between the personalized and default output. Printing is kept outside the formatter, which makes the core behavior easier to test.

For a small project, the current separation is adequate. Tests can import the formatter and assert exact returned strings. A command-line test can verify that a missing argument prints the fallback greeting. Before adding additional features, document whether internal repeated whitespace should be preserved; the current implementation preserves it because trimming only affects the ends.

No build step is listed in the manifest. The start script executes the source file directly, so the runtime version is part of the project's practical requirements. If distribution to older Node releases is needed, add a separate compilation step and point the start script to its output. That is a possible future packaging change, not something performed during this inspection.

The inspected files are consistent with a deliberately minimal example. The most useful next work is a focused set of tests for the input boundaries already described. No source changes are needed to explain the current behavior, and this inspection has only read the two requested files.

GCLEAF_DONE_0911"""


def sha(path):
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def save(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + "\n")


def load_driver():
    spec = importlib.util.spec_from_file_location("frozen_stream_driver", DRIVER)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def check_process(pid, expected):
    proc = Path("/proc") / str(pid)
    exe, cwd = os.readlink(proc / "exe"), os.readlink(proc / "cwd")
    argv = (proc / "cmdline").read_bytes().split(b"\0")
    assert exe == str(expected) or (expected.name == "perf" and Path(exe).name == "perf")
    return {"pid": pid, "exe": exe, "cwd": cwd, "argc": len([x for x in argv if x])}


class Perf:
    def __init__(self, pid, out):
        self.out = out
        control_read, self.control = os.pipe()
        self.ack, ack_write = os.pipe()
        self.log = (out / "perf.log").open("w")
        self.command = [
            "perf", "record", "-e", "cycles:u", "-F", "999",
            "-k", "CLOCK_MONOTONIC", "--no-buildid-cache", "--delay=-1",
            f"--control=fd:{control_read},{ack_write}",
            "-p", str(pid), "-o", str(out / "profile.data"),
        ]
        self.process = subprocess.Popen(
            self.command, stdout=self.log, stderr=subprocess.STDOUT,
            pass_fds=(control_read, ack_write),
        )
        os.close(control_read)
        os.close(ack_write)
        self.handshakes = []
        self.send("enable")

    def send(self, command):
        os.write(self.control, (command + "\n").encode())
        ready, _, _ = select.select([self.ack], [], [], 30)
        assert ready, ("perf acknowledgment timeout", command, self.process.poll())
        ack = os.read(self.ack, 128)
        assert ack == b"ack\n", (command, ack, self.process.poll())
        self.handshakes.append({
            "command": command, "ack": "ack", "monotonic_ns": time.monotonic_ns(),
        })

    def stop(self):
        if self.process.poll() is None:
            self.send("disable")
            check_process(self.process.pid, Path("/usr/bin/perf"))
            self.process.send_signal(signal.SIGINT)
            self.process.wait(timeout=30)
        os.close(self.control)
        os.close(self.ack)
        self.log.close()
        save(self.out / "perf-control.json", {
            "command": self.command, "exit": self.process.returncode,
            "handshakes": self.handshakes,
        })
        assert self.process.returncode == 0, self.process.returncode


def observed_mock(out):
    path = STAGE / "mockapi2.py"
    assert sha(path) == "1c6419b6aa2f8c7d9ba982bca4ad9ff326448b30fd54c35f77a9d384c6aebb19"
    source = path.read_text()
    needle = "        turn = None\n"
    insertion = """        if main:
            blocks = [b for m in req.get('messages', []) if isinstance(m, dict) for b in (m.get('content') if isinstance(m.get('content'), list) else []) if isinstance(b, dict) and b.get('type') == 'tool_result']
            serialized = json.dumps(blocks)
            evidence = {'request_ordinal': idx['i'] + 1, 'tool_result_blocks': len(blocks), 'package_seen': 'GCLEAF_PACKAGE_0911' in serialized, 'source_seen': 'GCLEAF_SOURCE_0911' in serialized, 'any_tool_error': any(b.get('is_error', False) for b in blocks)}
            with open(os.environ['GCLEAF_MOCK_EVIDENCE'], 'a') as evidence_file:
                evidence_file.write(json.dumps(evidence) + '\\n')
"""
    assert source.count(needle) == 1
    source = source.replace(needle, insertion + needle)
    compile(source, "observed_mock.py", "exec")
    result = out / "observed_mock.py"
    result.write_text(source)
    return result


def prepare_fixture():
    expected = {"package.json": json.dumps(PACKAGE, indent=2) + "\n", "src/index.ts": CODE}
    FIXTURE.mkdir(exist_ok=True)
    for name, body in expected.items():
        path = FIXTURE / name
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            assert path.read_text() == body, path
        else:
            path.write_text(body)
    return {name: sha(FIXTURE / name) for name in expected}


def run(app, label, port, out):
    assert (Path("/root/rig9831/lock") / "owner").is_file(), "caller must own campaign lock"
    assert not out.exists()
    out.mkdir(parents=True)
    driver = load_driver()
    assert sha(DRIVER) == "af4b31df90f70baff351aeaebbb9221c2798a821f85f490f8b80fe48ac0cd1c0"
    home = Path("/tmp/tt_home_gcleaf_0911_" + label)
    assert not home.exists()
    os.environ["TT_HOME_TEMPLATE"] = str(STAGE / "tt_home_template")
    driver._tt_prepare_home(str(home))
    fixtures = prepare_fixture()
    script = [
        {"tool": "Read", "input": {"file_path": str(FIXTURE / "package.json")},
         "text": "I will inspect the package manifest."},
        {"tool": "Read", "input": {"file_path": str(FIXTURE / "src/index.ts")},
         "text": "Next I will inspect the implementation."},
        {"text": ANSWER},
    ]
    save(out / "mock-script.json", script)
    mock_env = dict(os.environ, MOCK_CHUNK="50",
                    GCLEAF_MOCK_EVIDENCE=str(out / "mock-evidence.jsonl"))
    mock_log = (out / "mock.log").open("w")
    mock_path = observed_mock(out)
    mock = subprocess.Popen(
        ["python3", str(mock_path), str(port), str(out / "mock-script.json")],
        env=mock_env, stdout=mock_log, stderr=subprocess.STDOUT,
    )
    time.sleep(0.8)
    assert mock.poll() is None, "mock failed before application"
    env = {k: v for k, v in os.environ.items() if not k.startswith("PERRY_")}
    env.update(
        HOME=str(home), CLAUDE_CONFIG_DIR=str(home / ".claude"),
        TERM="xterm-256color", TT_PIN_CPUS=PIN,
        ANTHROPIC_BASE_URL=f"http://127.0.0.1:{port}",
        ANTHROPIC_API_KEY="sk-ant-mock-0123456789abcdefghijklmno",
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1", DISABLE_TELEMETRY="1",
        DISABLE_ERROR_REPORTING="1", DISABLE_AUTOUPDATER="1", DISABLE_BUG_COMMAND="1",
        PERRY_REGEX_ENGINE="default", PERRY_REGEX_DIAG="0",
    )
    env.pop("CLAUDECODE", None)
    drv = driver.Drv.__new__(driver.Drv)
    pid, fd = pty.fork()
    if pid == 0:
        os.chdir(PROJ)
        os.sched_setaffinity(0, driver.parse_cpu_set(PIN))
        os.kill(os.getpid(), signal.SIGSTOP)
        os.execvpe(str(app), [str(app)], env)
        os._exit(127)
    _, status = os.waitpid(pid, os.WUNTRACED)
    assert os.WIFSTOPPED(status)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 50, 200, 0, 0))
    drv.pid, drv.fd, drv.buf, drv.log = pid, fd, b"", (out / "terminal.log").open("wb")
    perf = None
    receipt = {
        "label": label, "application": str(app), "application_sha256": sha(app),
        "pid": pid, "fixture_sha256": fixtures, "command": PROMPT,
        "answer_characters": len(ANSWER), "sampling": "cycles:u,999Hz,CLOCK_MONOTONIC,no callchains",
        "phases": {}, "cpu": {},
    }
    try:
        perf = Perf(pid, out)
        receipt["phases"]["startup_begin_ns"] = time.monotonic_ns()
        os.kill(pid, signal.SIGCONT)
        duration = drv.wait_for(r"for shortcuts", 120)
        assert duration is not None, "startup timeout"
        receipt["phases"]["startup_end_ns"] = time.monotonic_ns()
        receipt["cpu"]["startup_s"] = driver.cpu_of(pid)
        receipt["process"] = check_process(pid, app)
        save(out / "app-maps.json", {"maps": Path(f"/proc/{pid}/maps").read_text()})
        drv.drain(1.5)
        drv.send(PROMPT)
        drv.drain(0.5)
        cpu_before, since = driver.cpu_of(pid), len(drv.buf)
        receipt["phases"]["command_begin_ns"] = time.monotonic_ns()
        drv.send("\r")
        duration = drv.wait_for(r"GCLEAF_DONE_0911", 400, since=since)
        assert duration is not None, "command marker timeout"
        receipt["phases"]["marker_ns"] = time.monotonic_ns()
        drv.drain(0.5)
        receipt["phases"]["command_end_ns"] = time.monotonic_ns()
        receipt["cpu"]["command_s"] = driver.cpu_of(pid) - cpu_before
        receipt["vmhwm_mb"] = driver.peak_mb(pid)
        perf.stop()
        perf = None
        evidence = [json.loads(line) for line in (out / "mock-evidence.jsonl").read_text().splitlines()]
        assert len(evidence) == 3, evidence
        assert evidence[-1]["package_seen"] and evidence[-1]["source_seen"], evidence
        assert not evidence[-1]["any_tool_error"], evidence
        receipt["mock_evidence"], receipt["pass"] = evidence, True
    finally:
        if perf is not None:
            try:
                perf.stop()
            except Exception as error:
                receipt["perf_stop_error"] = repr(error)
        # Owned numeric PIDs only; inspect executable/cwd before each signal.
        try:
            receipt["process_before_stop"] = check_process(pid, app)
            os.kill(pid, signal.SIGKILL)
            os.waitpid(pid, 0)
        except FileNotFoundError:
            pass
        if mock.poll() is None:
            proc = Path("/proc") / str(mock.pid)
            assert str(mock_path).encode() in (proc / "cmdline").read_bytes()
            receipt["mock_before_stop"] = {
                "pid": mock.pid, "cwd": os.readlink(proc / "cwd"),
                "exe": os.readlink(proc / "exe"),
            }
            mock.terminate()
            mock.wait(timeout=15)
        mock_log.close()
        drv.log.close()
        os.close(fd)
        save(out / "run.json", receipt)
    return receipt


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--app", type=Path, required=True)
    parser.add_argument("--label", required=True)
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(run(args.app.resolve(), args.label, args.port, args.out)), flush=True)
