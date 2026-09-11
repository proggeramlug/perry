#!/usr/bin/env python3
"""Serial observation-only joins and barrier/machine census after emission census."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time
import traceback

S = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
R = S / 'final-analysis-execution-v1'
L = Path('/root/rig9831/lock')
child = None

def sha(p):
    with Path(p).open('rb') as f: return hashlib.file_digest(f, 'sha256').hexdigest()

def save(name, value):
    (R / name).write_text(json.dumps(value, indent=2) + '\n')

def command(label, args, acceptable=(0,)):
    global child
    argv = ['python3', '-B', *map(str, args)]
    row = {'argv': argv, 'started_ns': time.time_ns(), 'cwd': str(S)}
    env = dict(os.environ, PYTHONPATH=str(S / 'parser-v3'))
    with (R / (label + '.log')).open('x') as f:
        child = subprocess.Popen(argv, cwd=S, env=env, stdout=f, stderr=subprocess.STDOUT)
        row['pid'] = child.pid; save(label + '.command.json', row)
        print('START', label, child.pid, flush=True)
        row['exit'] = child.wait(); row['finished_ns'] = time.time_ns()
        save(label + '.command.json', row); child = None
    print('EXIT', label, row['exit'], flush=True)
    assert row['exit'] in acceptable, (label, row['exit'])

def main():
    deadline = time.monotonic() + 7200
    while not (S / 'callsite-execution-v4/result.json').exists():
        assert not (S / 'callsite-execution-v4/failure.json').exists(), 'upstream failed'
        assert time.monotonic() < deadline, 'upstream deadline'
        time.sleep(10)
    while True:
        try: L.mkdir(); break
        except FileExistsError:
            assert time.monotonic() < deadline, 'lock deadline'
            time.sleep(10)
    owner = f'cc-gcleaf-final-analysis-v1 {os.getpid()}'
    (L / 'owner').write_text(owner + '\n')
    try:
        inputs = json.loads((S / 'final-analysis-inputs-v1.json').read_text())
        for name, value in inputs.items(): assert sha(S / name) == value, name
        save('inputs.json', {'files': inputs, 'owner': owner, 'upstream_sha256': sha(S / 'callsite-execution-v4/result.json')})
        command('audit-join', [S/'join_actual_callees_v2.py', '--by-callee', S/'callsite-v4/by-callee.csv', '--audit', S/'helper-audit-v2.csv', '--output', S/'actual-audit-v1'])
        for i in range(1, 4):
            p = S / f'profile-v4-{i}'
            a = S / f'profile-analysis-v3-{i}'
            command(f'profile-join-{i}', [S/'profile_samples_v2.py', '--samples', p/'samples-v2.txt', '--run', p/'run.json', '--maps', p/'app-maps.json', '--metadata', S/'metadata-diagnostic', '--helper-audit', S/'helper-audit-v2.csv', '--callsites', S/'callsite-v4', '--output', a])
            command(f'profile-reconcile-{i}', [S/'perf_self_reconcile.py', '--report', p/'self-report.txt', '--summary', a/'summary.json', '--command-receipt', p/'self-report.command.json', '--output', a/'perf-self-reconciliation.json'])
        command('machine-loop', [S/'run_machine_loop_coverage.py', '--elf', S/'compile-v2/cc-diagnostic', '--compile-receipt', S/'compile-v2/COMPILE_COMPLETE.json', '--metadata', S/'metadata-diagnostic', '--callsites', S/'callsite-v4', '--profile', S/'profile-analysis-v3-1', '--profile', S/'profile-analysis-v3-2', '--profile', S/'profile-analysis-v3-3', '--out', S/'machine-loop-v1'])
        command('barrier', [S/'fresh_barrier_batch_v4.py', '--captures', S/'compile-v2/cc-bitcode', '--helper-audit', S/'helper-audit-v2.csv', '--text-root', S/'cc-ir-text-v1', '--output', S/'barrier-v4'], acceptable=(0, 2))
        barrier = json.loads((S/'barrier-v4/summary.json').read_text())
        census = json.loads((S/'callsite-v4/summary.json').read_text())
        converted = {r['path']: r['sha256'] for r in census['converted_ir_receipts']}
        for unit in barrier['units']:
            if unit['complete_text_consumed']: assert unit['decoded_text_sha256'] == converted[unit['mirror_path']], unit['attempt']
        assert barrier['helper_audit_sha256'] == census['helper_audit_sha256']
        save('result.json', {'status': 'complete', 'barrier_status': barrier['status'], 'barrier_sha256': sha(S/'barrier-v4/summary.json'), 'finished_ns': time.time_ns()})
    finally:
        if child is not None and child.poll() is None:
            print('RETAIN_LOCK_LIVE_CHILD', child.pid, flush=True)
        elif (L/'owner').read_text().strip() == owner:
            (L/'owner').unlink(); L.rmdir()

if __name__ == '__main__':
    try: main()
    except BaseException as exc:
        save('failure.json', {'error': str(exc), 'traceback': traceback.format_exc(), 'time_ns': time.time_ns()})
        raise
