#!/usr/bin/env python3
"""Serial metadata census and three startup/tool-command profiles after emission."""
import json
import os
import subprocess
import time
from pathlib import Path

STAGE = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
LOCK = Path('/root/rig9831/lock')
APP = STAGE / 'compile-v2/cc-diagnostic'


def run(argv, log):
    print('START', log, time.time(), flush=True)
    with (STAGE / log).open('x') as stream:
        result = subprocess.run(argv, cwd=STAGE, stdout=stream, stderr=subprocess.STDOUT)
    print('EXIT', log, result.returncode, time.time(), flush=True)
    assert result.returncode == 0, (log, result.returncode)


def main():
    perf = (Path('/usr/lib/linux-tools') / os.uname().release / 'perf').resolve()
    with perf.open('rb') as stream:
        assert stream.read(4) == b'\x7fELF', 'use the actual perf ELF, not its distro shell launcher'
    os.environ['PATH'] = str(perf.parent) + ':' + os.environ['PATH']
    deadline = time.monotonic() + 7200
    while not (STAGE / 'compile-v2/COMPILE_COMPLETE.json').exists():
        if (STAGE / 'emission-v3-result.json').exists():
            result = json.loads((STAGE / 'emission-v3-result.json').read_text())
            assert result['exit'] == 0, ('emission failed', result)
        assert time.monotonic() < deadline, 'cc emission wait exceeded two hours'
        time.sleep(10)
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            assert time.monotonic() < deadline, 'campaign lock wait exceeded deadline'
            time.sleep(10)
    owner = f'cc-gcleaf-profile-v4 {os.getpid()}'
    (LOCK / 'owner').write_text(owner + '\n')
    try:
        for label, app in [('diagnostic', APP)]:
            run(['python3', '-B', str(STAGE / 'metadata_census.py'), '--elf', str(app),
                 '--output', str(STAGE / ('metadata-' + label))], 'metadata-' + label + '.log')
        for number in range(1, 4):
            label = f'profile{number}'
            out = STAGE / label
            # Other users may build outside this campaign; preserve a process
            # snapshot and load reading so such activity cannot be hidden.
            with (STAGE / (label + '-host-processes.txt')).open('x') as stream:
                subprocess.run(['ps', '-eo', 'pid,ppid,pcpu,etimes,comm'], stdout=stream, check=True)
            (STAGE / (label + '-host-load.json')).write_text(json.dumps({
                'loadavg': os.getloadavg(), 'monotonic_ns': time.monotonic_ns(),
                'lock_owner': owner,
            }) + '\n')
            run(['python3', '-B', str(STAGE / 'profile_workload.py'), '--app', str(APP),
                 '--label', label, '--port', str(10550 + number), '--out', str(out)],
                label + '-launch.log')
            with (out / 'samples.txt').open('x') as stream, (out / 'export.log').open('x') as log:
                subprocess.run(['perf', 'script', '--ns', '--full-paths', '-i', str(out / 'profile.data'),
                                '-F', 'pid,tid,time,event,ip,sym,symoff,dso,period'],
                               stdout=stream, stderr=log, check=True)
        (STAGE / 'PROFILE_COMPLETE.json').write_text(json.dumps({'profiles': 3, 'status': 'complete'}) + '\n')
        print('PROFILE_COMPLETE', flush=True)
    finally:
        if (LOCK / 'owner').read_text().strip() == owner:
            (LOCK / 'owner').unlink()
            LOCK.rmdir()


if __name__ == '__main__':
    main()
