#!/usr/bin/env python3
"""Bounded toy control to establish the installed attachment receipt schema."""
from pathlib import Path
import hashlib
import json
import os
import select
import signal
import subprocess
import sys
import time


def identity(pid):
    proc = Path('/proc') / str(pid)
    return {'pid': pid, 'argv': (proc / 'cmdline').read_bytes().split(b'\0')[:-1],
            'cwd': os.readlink(proc / 'cwd'), 'exe': os.readlink(proc / 'exe'),
            'start': (proc / 'stat').read_text().rsplit(')', 1)[1].split()[19]}


def stop(process, owner):
    if process is not None and process.poll() is None:
        assert identity(process.pid) == owner
        process.send_signal(signal.SIGINT)
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            assert identity(process.pid) == owner
            process.kill()
            process.wait(timeout=5)


def main():
    base = Path(__file__).resolve().parent
    output = base / 'inspection-v1'
    lock = Path('/root/rig9831/lock')
    owner = f'cc-runtime-caller-inspection-0911 {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (lock / 'owner').write_text(owner)
    app = tracer = app_owner = tracer_owner = None
    control_read = control_write = None
    try:
        output.mkdir()
        binary = output / 'toy'
        command = ['cc', '-O0', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls',
                   '-no-pie', str(base / 'toy.c'), '-o', str(binary)]
        r = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (output / 'compile.log').write_bytes(r.stdout)
        assert r.returncode == 0
        plain = subprocess.run([str(binary)], input=b'ABQ', stdout=subprocess.PIPE)
        assert plain.returncode == 0 and plain.stdout == b'A:2\nB:3\n'
        app = subprocess.Popen([str(binary)], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        app_owner = identity(app.pid)
        control_read, control_write = os.pipe()
        text = (base / 'census_template.bt').read_text()
        for old, new in {'CONTROLLER_PID': str(os.getpid()), 'CONTROL_FD': str(control_write),
                         'SUBJECT_PID': str(app.pid), 'SUBJECT_BINARY': str(binary),
                         'SUBJECT_SYMBOL': 'census_subject'}.items():
            text = text.replace(old, new)
        program = output / 'census.bt'
        program.write_text(text)
        with (output / 'bpf.jsonl').open('w') as log, (output / 'bpf.stderr').open('w') as err:
            tracer = subprocess.Popen(['bpftrace', '-f', 'json', '-kk', str(program)],
                                      stdout=log, stderr=err)
            tracer_owner = identity(tracer.pid)
            deadline = time.monotonic() + 25
            rows = []
            while time.monotonic() < deadline:
                assert tracer.poll() is None, 'tracer ended before attachment inspection'
                r = subprocess.run(['bpftool', '-j', 'perf', 'show'],
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                assert r.returncode == 0, r.stderr
                data = json.loads(r.stdout)
                rows = [row for row in data if row.get('pid') == tracer.pid]
                (output / 'own-attachments.json').write_text(json.dumps(rows, indent=2) + '\n')
                if len(rows) >= 3:
                    break
                time.sleep(0.1)
            assert len(rows) >= 3, 'no complete observable attachment inventory'
            # This first schema inspection runs no instrumented toy operations.
            # A later strict handshake must classify every required attachment.
            print(json.dumps({'status': 'schema-inspected', 'tracer_pid': tracer.pid,
                              'attachments': rows, 'plain_result': plain.stdout.decode()}))
            stop(tracer, tracer_owner)
        app.stdin.write(b'Q')
        app.stdin.flush()
        assert app.wait(timeout=5) == 0
        return 0
    finally:
        stop(tracer, tracer_owner)
        stop(app, app_owner)
        for fd in (control_read, control_write):
            if fd is not None:
                os.close(fd)
        assert (lock / 'owner').read_text() == owner
        (lock / 'owner').unlink()
        lock.rmdir()


if __name__ == '__main__':
    raise SystemExit(main())
