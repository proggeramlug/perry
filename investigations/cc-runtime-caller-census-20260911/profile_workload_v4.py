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
import re
import select
import shutil
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
PROMPT = "Explain this project."

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


def process_snapshot(pid):
    proc = Path("/proc") / str(pid)
    exe, cwd = os.readlink(proc / "exe"), os.readlink(proc / "cwd")
    argv = [os.fsdecode(x) for x in (proc / "cmdline").read_bytes().split(b"\0") if x]
    # /proc stat field 22; the comm field can itself contain spaces/parentheses.
    fields = (proc / "stat").read_text().rsplit(")", 1)[1].split()
    return {"pid": pid, "start_ticks": int(fields[19]), "exe": exe,
            "cwd": cwd, "argv": argv}


def require_identity(observed, expected):
    for key in ("pid", "start_ticks", "exe", "cwd", "argv"):
        if key in expected and observed[key] != expected[key]:
            raise RuntimeError(f"owned process {observed['pid']} identity mismatch: {key}")
    return observed


def check_process(pid, expected, cwd=None, argv=None, start_ticks=None):
    identity = {"pid": pid, "exe": str(Path(expected).resolve())}
    if cwd is not None:
        identity["cwd"] = str(Path(cwd).resolve())
    if argv is not None:
        identity["argv"] = argv
    if start_ticks is not None:
        identity["start_ticks"] = start_ticks
    return require_identity(process_snapshot(pid), identity)


def finish_owned_popen(process, owner, first_signal, timeout=15):
    """Recheck exact child identity before each signal, including escalation."""
    checks = []
    if process.poll() is None:
        checks.append(require_identity(process_snapshot(process.pid), owner))
        process.send_signal(first_signal)
        try:
            process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            checks.append(require_identity(process_snapshot(process.pid), owner))
            process.send_signal(signal.SIGKILL)
            process.wait(timeout=timeout)
    return {"exit": process.returncode, "ownership_checks": checks}


def stop_owned_app(pid, pre_exec, app):
    # This unreaped direct child cannot have its PID reused. Still validate both
    # its birth identity and exact argv/cwd before sending a signal.
    try:
        ended, status = os.waitpid(pid, os.WNOHANG)
    except ChildProcessError:
        return {"already_reaped": True}
    if ended == pid:
        return {"already_exited": True, "wait_status": status}
    observed = process_snapshot(pid)
    alternatives = [pre_exec, dict(pre_exec, exe=str(app), argv=[str(app)])]
    if not any(all(observed[k] == expected[k] for k in
                   ("pid", "start_ticks", "exe", "cwd", "argv"))
               for expected in alternatives):
        raise RuntimeError(f"owned app {pid} matches neither pre-exec nor app identity")
    os.kill(pid, signal.SIGKILL)
    _, status = os.waitpid(pid, 0)
    return {"process_before_stop": observed, "wait_status": status}


class Perf:
    def __init__(self, pid, out):
        self.out = out
        self.control = self.ack = self.log = self.process = None
        self.owner = None
        self.closed = False
        self.handshakes = []
        self.stop_record = None
        perf_exe = Path(shutil.which("perf") or "/usr/bin/perf").resolve()
        self.command = [
            str(perf_exe), "record", "-e", "cycles:u", "-F", "999",
            "-k", "CLOCK_MONOTONIC", "--no-buildid-cache", "--delay=-1",
        ]
        control_read = ack_write = None
        try:
            control_read, self.control = os.pipe()
            self.ack, ack_write = os.pipe()
            self.log = (out / "perf.log").open("w")
            self.command += [f"--control=fd:{control_read},{ack_write}",
                             "-p", str(pid), "-o", str(out / "profile.data")]
            self.process = subprocess.Popen(
                self.command, stdout=self.log, stderr=subprocess.STDOUT,
                pass_fds=(control_read, ack_write),
            )
            os.close(control_read)
            os.close(ack_write)
            control_read = ack_write = None
            self.owner = check_process(self.process.pid, perf_exe,
                                       cwd=Path.cwd(), argv=self.command)
            self.send("enable")
        except BaseException as error:
            self.constructor_error = repr(error)
            # The caller never receives this object if __init__ raises.
            # Constructor-local teardown is therefore mandatory.
            try:
                self.stop(disable=False)
            except BaseException:
                pass  # stop records its own error without hiding this failure.
            raise
        finally:
            for fd in (control_read, ack_write):
                if fd is not None:
                    os.close(fd)

    def send(self, command):
        os.write(self.control, (command + "\n").encode())
        ready, _, _ = select.select([self.ack], [], [], 30)
        if not ready:
            raise RuntimeError(("perf acknowledgment timeout", command, self.process.poll()))
        ack = os.read(self.ack, 128)
        if ack not in (b"ack\n", b"ack\n\0"):
            raise RuntimeError(("perf acknowledgment mismatch", command, ack, self.process.poll()))
        self.handshakes.append({
            "command": command, "ack": "ack", "ack_hex": ack.hex(), "monotonic_ns": time.monotonic_ns(),
        })

    def stop(self, disable=True):
        if self.closed:
            return self.stop_record
        errors, cleanup = [], None
        try:
            if self.process is not None and self.process.poll() is None:
                if disable:
                    try:
                        self.send("disable")
                    except BaseException as error:
                        errors.append({"disable": repr(error)})
                try:
                    if self.owner is None:
                        # Popen's exec handshake succeeded, but initial identity
                        # capture failed. Never signal an unverified process.
                        self.owner = check_process(self.process.pid, Path(self.command[0]),
                                                   cwd=Path.cwd(), argv=self.command)
                    cleanup = finish_owned_popen(self.process, self.owner, signal.SIGINT, 15)
                except BaseException as error:
                    errors.append({"termination": repr(error)})
        finally:
            for fd in (self.control, self.ack):
                if fd is not None:
                    os.close(fd)
            self.control = self.ack = None
            if self.log is not None:
                self.log.close()
            self.closed = True
            self.stop_record = {
                "command": self.command,
                "exit": self.process.returncode if self.process is not None else None,
                "handshakes": self.handshakes, "cleanup": cleanup, "errors": errors,
                "constructor_error": getattr(self, "constructor_error", None),
            }
            save(self.out / "perf-control.json", self.stop_record)
        if errors or self.stop_record["exit"] not in (0, -signal.SIGINT):
            raise RuntimeError(("perf stop failed", self.stop_record))
        return self.stop_record


def validate_mock_evidence(evidence):
    if len(evidence) != 3 or [row["request_ordinal"] for row in evidence] != [1, 2, 3]:
        raise RuntimeError("expected three ordered main requests")
    first, package, final = evidence
    if first["tool_result_blocks"] != 0 or first["package_seen"] or first["source_seen"]:
        raise RuntimeError("first request already contains fixture result evidence")
    if package["tool_result_blocks"] < 1 or not package["package_seen"] or package["source_seen"]:
        raise RuntimeError("package Read result missing or out of order")
    if final["tool_result_blocks"] < 2 or not final["package_seen"] or not final["source_seen"]:
        raise RuntimeError("both Read result sentinels required on final request")
    if any(row["any_tool_error"] for row in evidence):
        raise RuntimeError("Read tool returned an error")
    return evidence


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
    mock = mock_owner = perf = drv = pid = fd = pre_exec = None
    mock_command = ["python3", str(mock_path), str(port), str(out / "mock-script.json")]
    parent_identity = process_snapshot(os.getpid())
    receipt = {
        "label": label, "application": str(app), "application_sha256": sha(app),
        "fixture_sha256": fixtures, "command": PROMPT,
        "answer_characters": len(ANSWER), "sampling": "cycles:u,999Hz,CLOCK_MONOTONIC,no callchains",
        "phases": {}, "cpu": {}, "pass": False,
    }
    cleanup_errors = []
    try:
        mock = subprocess.Popen(
            mock_command, env=mock_env, stdout=mock_log, stderr=subprocess.STDOUT,
        )
        mock_owner = check_process(mock.pid, Path(shutil.which("python3")),
                                   cwd=Path.cwd(), argv=mock_command)
        time.sleep(0.8)
        if mock.poll() is not None:
            raise RuntimeError("mock failed before application")
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
            try:
                os.chdir(PROJ)
                os.sched_setaffinity(0, driver.parse_cpu_set(PIN))
                os.kill(os.getpid(), signal.SIGSTOP)
                os.execvpe(str(app), [str(app)], env)
            finally:
                os._exit(127)
        receipt["pid"] = pid
        _, status = os.waitpid(pid, os.WUNTRACED)
        if not os.WIFSTOPPED(status) or os.WSTOPSIG(status) != signal.SIGSTOP:
            raise RuntimeError(("child failed before pre-exec SIGSTOP", status))
        pre_exec = check_process(pid, Path(parent_identity["exe"]),
                                 cwd=PROJ, argv=parent_identity["argv"])
        receipt["pre_exec_process"] = pre_exec
        fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 50, 200, 0, 0))
        drv.pid, drv.fd, drv.buf, drv.log = pid, fd, b"", (out / "terminal.log").open("wb")
        perf = Perf(pid, out)
        require_identity(process_snapshot(pid), pre_exec)
        receipt["phases"]["startup_begin_ns"] = time.monotonic_ns()
        os.kill(pid, signal.SIGCONT)
        duration = drv.wait_for(r"for shortcuts", 120)
        assert duration is not None, "startup timeout"
        receipt["phases"]["startup_end_ns"] = time.monotonic_ns()
        receipt["cpu"]["startup_s"] = driver.cpu_of(pid)
        receipt["process"] = check_process(pid, app, cwd=PROJ, argv=[str(app)],
                                           start_ticks=pre_exec["start_ticks"])
        save(out / "app-maps.json", {"maps": Path(f"/proc/{pid}/maps").read_text()})
        drv.drain(1.5)
        typing_begin = len(drv.buf)
        drv.send(PROMPT)
        echoed = drv.wait_for(re.escape(PROMPT), 30, since=typing_begin)
        assert echoed is not None, "complete prompt echo not observed"
        receipt["prompt_echo_observed"] = True
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
        receipt["perf_control"] = perf.stop()
        perf = None
        evidence = [json.loads(line) for line in (out / "mock-evidence.jsonl").read_text().splitlines()]
        receipt["mock_evidence"] = evidence
        validate_mock_evidence(evidence)
        receipt["pass"] = True
    except BaseException as error:
        receipt["error"] = repr(error)
        raise
    finally:
        if perf is not None:
            try:
                receipt["perf_control"] = perf.stop()
            except BaseException as error:
                cleanup_errors.append({"perf": repr(error)})
        if pid is not None:
            try:
                if pre_exec is None:
                    # A failure between fork and stopped-state capture still
                    # owns this unreaped child. Verify its Python identity.
                    try:
                        pre_exec = check_process(pid, Path(parent_identity["exe"]),
                                                 cwd=PROJ, argv=parent_identity["argv"])
                    except FileNotFoundError:
                        pre_exec = None
                if pre_exec is not None:
                    receipt["app_cleanup"] = stop_owned_app(pid, pre_exec, app)
                else:
                    try:
                        ended, status = os.waitpid(pid, os.WNOHANG)
                        receipt["app_cleanup"] = {"ended": ended, "wait_status": status}
                    except ChildProcessError:
                        receipt["app_cleanup"] = {"already_reaped": True}
            except BaseException as error:
                cleanup_errors.append({"app": repr(error)})
        if mock is not None:
            try:
                if mock_owner is None and mock.poll() is None:
                    mock_owner = check_process(mock.pid, Path(shutil.which("python3")),
                                               cwd=Path.cwd(), argv=mock_command)
                receipt["mock_cleanup"] = finish_owned_popen(mock, mock_owner, signal.SIGTERM)
            except BaseException as error:
                cleanup_errors.append({"mock": repr(error)})
        # Each resource cleanup is independent; an identity mismatch must not
        # skip recording the original error or closing unrelated descriptors.
        for name, resource in (("mock_log", mock_log), ("terminal_log", getattr(drv, "log", None))):
            if resource is not None:
                try:
                    resource.close()
                except BaseException as error:
                    cleanup_errors.append({name: repr(error)})
        if fd is not None:
            try:
                os.close(fd)
            except BaseException as error:
                cleanup_errors.append({"pty": repr(error)})
        receipt["cleanup_errors"] = cleanup_errors
        if cleanup_errors:
            receipt["pass"] = False
        save(out / "run.json", receipt)
    if cleanup_errors:
        raise RuntimeError(("profile cleanup incomplete", cleanup_errors))
    return receipt


def selftest():
    """Offline controls only: no fork, exec, real signal, cc or perf run."""
    import ast
    import copy
    import tempfile
    from unittest.mock import patch

    checked = []

    def rejects(name, callback):
        try:
            callback()
        except (RuntimeError, ValueError, KeyError):
            checked.append(name)
        else:
            raise AssertionError(f"control did not reject: {name}")

    evidence = [
        dict(request_ordinal=1, tool_result_blocks=0, package_seen=False, source_seen=False, any_tool_error=False),
        dict(request_ordinal=2, tool_result_blocks=1, package_seen=True, source_seen=False, any_tool_error=False),
        dict(request_ordinal=3, tool_result_blocks=2, package_seen=True, source_seen=True, any_tool_error=False),
    ]
    validate_mock_evidence(evidence)
    for field, value in (("package_seen", False), ("source_seen", False),
                         ("tool_result_blocks", 1), ("any_tool_error", True),
                         ("request_ordinal", 4)):
        wrong = copy.deepcopy(evidence)
        wrong[-1][field] = value
        rejects("final-" + field, lambda wrong=wrong: validate_mock_evidence(wrong))
    rejects("partial-main-requests", lambda: validate_mock_evidence(evidence[:2]))
    wrong = copy.deepcopy(evidence)
    wrong[1]["source_seen"] = True
    rejects("source-before-second-Read", lambda: validate_mock_evidence(wrong))

    owner = dict(pid=99999, start_ticks=123, exe="/test/perf", cwd="/test", argv=["/test/perf"])
    require_identity(owner, owner)
    for field in owner:
        wrong = dict(owner, **{field: "wrong"})
        rejects("owner-" + field, lambda wrong=wrong: require_identity(wrong, owner))

    class FakeProcess:
        pid = owner["pid"]
        def __init__(self):
            self.returncode, self.signals, self.waits = None, [], 0
        def poll(self):
            return self.returncode
        def send_signal(self, sig):
            self.signals.append(sig)
        def wait(self, timeout):
            self.waits += 1
            if self.waits == 1:
                raise subprocess.TimeoutExpired("fake", timeout)
            self.returncode = 0

    process = FakeProcess()
    with patch(__name__ + ".process_snapshot", return_value=owner):
        finish_owned_popen(process, owner, signal.SIGINT, 0.01)
    assert process.signals == [signal.SIGINT, signal.SIGKILL]
    checked.append("verified-timeout-escalation")
    process = FakeProcess()
    with patch(__name__ + ".process_snapshot", side_effect=[owner, dict(owner, start_ticks=124)]):
        rejects("changed-owner-before-escalation", lambda: finish_owned_popen(process, owner, signal.SIGINT, 0.01))
    assert process.signals == [signal.SIGINT]
    process = FakeProcess()
    with patch(__name__ + ".process_snapshot", return_value=dict(owner, cwd="/other")):
        rejects("wrong-owner-no-first-signal", lambda: finish_owned_popen(process, owner, signal.SIGINT, 0.01))
    assert process.signals == []

    python_owner = dict(owner, exe="/test/python", argv=["python", "driver.py"])
    for observed in (python_owner, dict(python_owner, exe="/test/app", argv=["/test/app"])):
        with patch(__name__ + ".process_snapshot", return_value=observed), \
             patch.object(os, "waitpid", side_effect=[(0, 0), (owner["pid"], 9)]), \
             patch.object(os, "kill") as kill:
            stop_owned_app(owner["pid"], python_owner, Path("/test/app"))
            kill.assert_called_once_with(owner["pid"], signal.SIGKILL)
    checked.append("pre-exec-and-app-cleanup-identities")

    with tempfile.TemporaryDirectory(prefix="cc-gcleaf-profile-offline-") as tmp:
        out = Path(tmp)
        opened = []
        real_pipe = os.pipe
        def tracked_pipe():
            result = real_pipe()
            opened.extend(result)
            return result
        with patch.object(os, "pipe", side_effect=tracked_pipe), \
             patch.object(subprocess, "Popen", return_value=FakeProcess()), \
             patch(__name__ + ".check_process", return_value=owner), \
             patch.object(Perf, "send", side_effect=RuntimeError("injected enable timeout")), \
             patch(__name__ + ".finish_owned_popen", return_value={"exit": 0}) as finish:
            rejects("constructor-enable-failure", lambda: Perf(111, out))
            assert finish.call_count == 1
        for fd in opened:
            try:
                os.fstat(fd)
            except OSError:
                pass
            else:
                raise AssertionError("constructor leaked a pipe descriptor")
        record = json.loads((out / "perf-control.json").read_text())
        assert "injected enable timeout" in record["constructor_error"]
        checked.append("constructor-failure-cleanup-and-receipt")

        perf = Perf.__new__(Perf)
        perf.out, perf.command, perf.handshakes = out, ["fake-perf"], []
        perf.closed, perf.stop_record = False, None
        perf.control, perf.ack = os.pipe()
        perf.log = (out / "stop.log").open("w")
        perf.process, perf.owner = FakeProcess(), owner
        with patch.object(Perf, "send", side_effect=RuntimeError("injected disable timeout")), \
             patch(__name__ + ".finish_owned_popen", return_value={"exit": 0}) as finish:
            rejects("disable-timeout-retained", perf.stop)
            first = perf.stop_record
            assert perf.stop() is first and finish.call_count == 1
        assert perf.log.closed and perf.control is None and perf.ack is None
        checked.append("stop-idempotence-after-error")

        # Compile and execute the exact inserted source, not a hand-retyped twin.
        tree = ast.parse(Path(__file__).read_text())
        function = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "observed_mock")
        insertion = next(n.value.value for n in function.body if isinstance(n, ast.Assign)
                         and any(isinstance(t, ast.Name) and t.id == "insertion" for t in n.targets))
        program = compile("def step(main, req, idx):\n    if True:\n" + insertion + "        turn = None\n", "exact_mock_insertion", "exec")
        namespace = {"json": json, "os": os}
        exec(program, namespace)
        evidence_file = out / "mock-evidence.jsonl"
        blocks = []
        with patch.dict(os.environ, {"GCLEAF_MOCK_EVIDENCE": str(evidence_file)}):
            for ordinal, sentinel in enumerate((None, "GCLEAF_PACKAGE_0911", "GCLEAF_SOURCE_0911")):
                if sentinel:
                    blocks.append({"type": "tool_result", "content": sentinel})
                namespace["step"](True, {"messages": [{"content": blocks}]}, {"i": ordinal})
        observed = [json.loads(line) for line in evidence_file.read_text().splitlines()]
        assert observed == evidence
        validate_mock_evidence(observed)
        checked.append("exact-insertion-literal-newline-and-two-Read-evidence")
    return {"pass": True, "controls": checked, "real_processes_launched": 0}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--app", type=Path)
    parser.add_argument("--label")
    parser.add_argument("--port", type=int)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    if args.self_test:
        print(json.dumps(selftest(), indent=2), flush=True)
    else:
        if any(value is None for value in (args.app, args.label, args.port, args.out)):
            parser.error("--app, --label, --port and --out are required for a profile")
        print(json.dumps(run(args.app.resolve(), args.label, args.port, args.out)), flush=True)
