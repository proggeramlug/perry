#!/usr/bin/env python3
from pathlib import Path
import copy
import json
import os
import select
import subprocess
import signal
import time

from probe_census import BpfCensus, parse_maps, validate_counts
from profile_workload_v4 import check_process, finish_owned_popen, save


def main():
    base = Path(__file__).resolve().parent
    out = base / 'control-v2'
    lock = Path('/root/rig9831/lock')
    owner = f'cc-runtime-caller-control-0911 {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (lock / 'owner').write_text(owner)
    child = child_owner = census = None
    try:
        out.mkdir()
        app = out / 'toy'
        command = ['cc', '-O0', '-fcf-protection=none', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls',
                   '-no-pie', str(base / 'toy.c'), '-o', str(app)]
        r = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (out / 'compile.log').write_bytes(r.stdout)
        assert r.returncode == 0
        plain = subprocess.run([str(app)], input=b'ABQ', stdout=subprocess.PIPE)
        assert plain.returncode == 0 and plain.stdout == b'A:2\nB:3\n'
        child = subprocess.Popen([str(app)], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        child_owner = check_process(child.pid, app, cwd=Path.cwd(), argv=[str(app)])
        census = BpfCensus(child.pid, out, app, 'census_subject')
        observed = b''
        for phase, command, expected in [(1, b'A', b'A:2\n'), (3, b'B', b'B:3\n')]:
            census.phase(phase)
            child.stdin.write(command)
            child.stdin.flush()
            assert select.select([child.stdout], [], [], 15)[0], 'toy output timeout'
            line = child.stdout.readline()
            assert line == expected, line
            observed += line
            census.phase(phase + 1)
        census.stop()
        counts = json.loads((out / 'counts.json').read_text())
        assert counts['total_entries'] == {'1': 5, '3': 6}
        for phase, total_true in [(1, 2), (3, 3)]:
            rows = [row for row in counts['rows'] if row['phase'] == phase]
            assert len(rows) == 2
            assert sum(row['true'] for row in rows) == total_true
            assert sum(row['same_address_as_previous_at_site'] for row in rows) == 2
        assert counts['max_depth'] == 1
        maps = parse_maps(out / 'bpf.jsonl')
        wrong = copy.deepcopy(maps)
        wrong['@total_returns']['1'] -= 1
        try:
            validate_counts(wrong)
        except AssertionError:
            mismatch = 'rejected'
        else:
            raise AssertionError('missing return counter accepted')
        child.stdin.write(b'Q')
        child.stdin.flush()
        assert child.wait(timeout=10) == 0
        save(out / 'CONTROL_PASS.json', {'status': 'PASS', 'ordinary_output': plain.stdout.decode(),
                                       'instrumented_output': observed.decode(), 'counts': counts,
                                       'missing_return_control': mismatch,
                                       'missing_attachment_control': census.record['missing_attachment_control']})
        print('PASS: exact outputs, 5/6 entries, 2/3 true, 2/2 repeated values; missing-site/return rejected')
        return 0
    finally:
        if census is not None:
            census.stop(validate=False)
        if child is not None:
            finish_owned_popen(child, child_owner, signal.SIGTERM, 10)
        assert (lock / 'owner').read_text() == owner
        (lock / 'owner').unlink()
        lock.rmdir()


if __name__ == '__main__':
    raise SystemExit(main())
