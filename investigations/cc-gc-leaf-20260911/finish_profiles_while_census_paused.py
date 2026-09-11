#!/usr/bin/env python3
"""Pause our exact census worker, finish profiles serially, then resume it."""
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import time

r = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
worker = 3692183
coordinator = 3692063


def identity(pid):
    p = Path('/proc') / str(pid)
    return {'argv': p.joinpath('cmdline').read_bytes().split(b'\0')[:-1],
            'cwd': str(p.joinpath('cwd').resolve()),
            'stat': p.joinpath('stat').read_text().rsplit(')', 1)[1].split()}


def save(path, data):
    path.write_text(json.dumps(data, indent=2) + '\n')


def invoke(argv, name):
    row = {'command': list(map(str, argv)), 'started_ns': time.time_ns()}
    out, err = r / (name + '.txt'), r / (name + '.stderr')
    with out.open('x') as stdout, err.open('x') as stderr:
        process = subprocess.run(argv, cwd=r, stdout=stdout, stderr=stderr)
    row.update(exit=process.returncode, stdout_sha256=hashlib.sha256(out.read_bytes()).hexdigest())
    save(r / (name + '.command.json'), row)
    assert process.returncode == 0, (name, process.returncode)


before = identity(worker)
assert before['argv'][:3] == [b'python3', b'-B', str(r / 'parser-v3/callsite_census.py').encode()]
assert before['cwd'] == str(r)
assert before['stat'][1] == str(coordinator)
lock = Path('/root/rig9831/lock/owner')
owner = f'cc-gcleaf-callsite-v4 {coordinator}'
assert lock.read_text().strip() == owner
os.kill(worker, signal.SIGSTOP)
for attempt in range(100):
    after = identity(worker)
    if after['stat'][0] == 'T':
        break
    time.sleep(.05)
else:
    raise RuntimeError('census did not stop')
save(r / 'profile-analysis-serialization.json', {
    'worker_pid': worker, 'coordinator_pid': coordinator, 'lock_owner': owner,
    'worker_argv': [os.fsdecode(x) for x in before['argv']], 'worker_cwd': before['cwd'],
    'state_after_SIGSTOP': after['stat'][0], 'paused_ns': time.time_ns(),
    'purpose': 'run exact profiles and perf exports without competing census CPU',
})
perf = (Path('/usr/lib/linux-tools') / os.uname().release / 'perf').resolve()
os.environ['PATH'] = str(perf.parent) + ':' + os.environ['PATH']
try:
    for i in (2, 3):
        label = f'profile-v4-{i}'
        invoke(['python3', '-B', str(r / 'profile_workload_v4.py'), '--app',
                str(r / 'compile-v2/cc-diagnostic'), '--label', label, '--port',
                str(10550 + i), '--out', str(r / label)], label + '-capture')
    for i in (1, 2, 3):
        label = f'profile-v4-{i}'
        assert json.loads((r / label / 'run.json').read_text())['pass']
        invoke([str(perf), 'script', '--ns', '-i', str(r / label / 'profile.data'), '-F',
                'pid,tid,time,event,ip,sym,symoff,dso,period'], label + '/samples-v2')
        invoke([str(perf), 'report', '--stdio', '--no-children', '--show-total-period',
                '--show-nr-samples', '--sort=comm,dso,symbol', '--field-separator=,',
                '--percent-limit=0', '-i', str(r / label / 'profile.data')], label + '/self-report')
    save(r / 'PROFILE_COMPLETE-v4.json', {'status': 'complete', 'profiles': 3,
                                         'names': [f'profile-v4-{i}' for i in (1, 2, 3)]})
finally:
    after = identity(worker)
    assert after['argv'] == before['argv'] and after['cwd'] == before['cwd']
    assert after['stat'][19] == before['stat'][19]
    assert lock.read_text().strip() == owner
    os.kill(worker, signal.SIGCONT)
    save(r / 'profile-analysis-resumed.json', {'worker_pid': worker, 'resumed_ns': time.time_ns()})
