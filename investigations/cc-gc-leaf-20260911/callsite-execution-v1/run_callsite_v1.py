#!/usr/bin/env python3
"""Observe completed cc emission, then serialize lossless conversion and census."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import traceback

STAGE = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
LOCK = Path('/root/rig9831/lock')
RUN = STAGE / 'callsite-execution-v1'
CAPTURES = STAGE / 'compile-v2/cc-bitcode'
COMPLETE = STAGE / 'compile-v2/COMPILE_COMPLETE.json'
OUTPUT = STAGE / 'callsite-v1'
TEXT = STAGE / 'cc-ir-text-v1'
LLVM = Path('/usr/lib/llvm-22/bin/llvm-dis')
BUILD_PID = 3679463
EXPECTED = {
    'callsite_census.py': 'e8e1db299146218d430ecc8d57d9190aed4796928d74de74da80f63004772df5',
    'helper-audit.csv': 'be08f9ca8842aa0df27be602013e57261f067798461da09e29c6f540b4fbc48a',
}
child = None


def sha(path):
    with Path(path).open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()


def save(name, data):
    (RUN / name).write_text(json.dumps(data, indent=2) + '\n')


def command(argv, label, stdout=None):
    global child
    row = {'argv': list(map(str, argv)), 'cwd': str(STAGE), 'started_ns': time.time_ns()}
    with (RUN / (label + '.stderr')).open('x') as err:
        child = subprocess.Popen(argv, cwd=STAGE, stdout=stdout, stderr=err)
        row['pid'] = child.pid
        save(label + '.command.json', row)
        print('START', label, child.pid, flush=True)
        row['exit'] = child.wait()
        row['finished_ns'] = time.time_ns()
        save(label + '.command.json', row)
        child = None
        print('EXIT', label, row['exit'], flush=True)
        if row['exit']:
            raise RuntimeError((label, row['exit']))


def main():
    deadline = time.monotonic() + 7200
    print('WAIT_FULL_CC_COMPILE', os.getpid(), flush=True)
    while not COMPLETE.exists():
        failed = STAGE / 'emission-v3-result.json'
        if failed.exists():
            row = json.loads(failed.read_text())
            if row.get('exit') != 0:
                raise RuntimeError(('outer cc emission failed; no census', row))
        proc = Path('/proc') / str(BUILD_PID)
        if not proc.exists():
            # Completion is published before the build coordinator exits.
            if COMPLETE.exists():
                break
            raise RuntimeError('build/emission coordinator ended without outer compile completion')
        assert b'resume_build_v4.py' in (proc / 'cmdline').read_bytes(), 'build PID identity changed'
        assert time.monotonic() < deadline, 'compile completion wait expired'
        time.sleep(10)
    complete_bytes = COMPLETE.read_bytes()
    completed = json.loads(complete_bytes)
    assert completed['success_marker'] == 'full original cc compiler invocation exited zero'
    assert completed['bitcode_dir'] == str(CAPTURES)
    deadline = time.monotonic() + 7200
    previous = None
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            try:
                owner = (LOCK / 'owner').read_text().strip()
            except FileNotFoundError:
                owner = '<owner publication pending>'
            if owner != previous:
                print('WAIT_CAMPAIGN_LOCK', owner, flush=True)
                previous = owner
            assert time.monotonic() < deadline, 'campaign lock wait expired'
            time.sleep(10)
    owner = f'cc-gcleaf-callsite-v1 {os.getpid()}'
    (LOCK / 'owner').write_text(owner + '\n')
    print('LOCK_ACQUIRED', owner, flush=True)
    try:
        for name, expected in EXPECTED.items():
            assert sha(STAGE / name) == expected, name
        assert COMPLETE.read_bytes() == complete_bytes, 'outer completion receipt changed while waiting'
        assert not OUTPUT.exists() and not TEXT.exists(), 'preserve previous analysis outputs'
        sys.path.insert(0, str(STAGE))
        import callsite_census as census
        accepted, excluded = census.read_attempts(CAPTURES)
        version = subprocess.check_output([LLVM, '--version'], text=True)
        assert 'LLVM version 22.' in version
        save('inputs.json', {
            'script_sha256': sha(__file__), 'inputs': EXPECTED,
            'compile_complete_sha256': sha(COMPLETE), 'compile_complete': completed,
            'llvm_dis': str(LLVM), 'llvm_dis_sha256': sha(LLVM), 'llvm_dis_version': version,
            'accepted_attempts': len(accepted), 'excluded_incomplete': excluded,
            'lock_owner': owner, 'free_bytes': shutil.disk_usage(STAGE).free,
        })
        TEXT.mkdir()
        converted = []
        for attempt in accepted:
            directory = attempt['directory']
            target = TEXT / directory.name
            target.mkdir()
            for stage in census.STAGES:
                source = directory / (stage + '.bc')
                dest = target / (stage + '.ll')
                assert shutil.disk_usage(STAGE).free >= 12 * 1024**3, 'less than 12 GiB before LLVM conversion'
                label = directory.name + '-' + stage
                command([str(LLVM), str(source), '-o', str(dest)], label)
                converted.append({'input': str(source), 'input_sha256': sha(source),
                                  'output': str(dest), 'output_sha256': sha(dest),
                                  'output_bytes': dest.stat().st_size})
                save('conversion.json', {'status': 'in-progress', 'files': converted})
        save('conversion.json', {'status': 'complete', 'files': converted})
        with (RUN / 'census.stdout').open('x') as stream:
            command(['python3', '-B', str(STAGE / 'callsite_census.py'), '--captures', str(CAPTURES),
                     '--helper-audit', str(STAGE / 'helper-audit.csv'), '--output', str(OUTPUT),
                     '--llvm-dis', str(LLVM), '--text-root', str(TEXT)], 'census', stream)
        summary = json.loads((OUTPUT / 'summary.json').read_text())
        assert summary['status'] == 'complete-static-emission-census'
        save('result.json', {'status': 'complete', 'summary_sha256': sha(OUTPUT / 'summary.json'),
                            'lock_owner': owner, 'free_bytes': shutil.disk_usage(STAGE).free,
                            'completed_ns': time.time_ns()})
        print('CALLSITE_CENSUS_COMPLETE', flush=True)
    finally:
        if child is not None and child.poll() is None:
            print('RETAIN_LOCK_UNCERTAIN_OWNED_CHILD', child.pid, flush=True)
        elif (LOCK / 'owner').read_text().strip() == owner:
            (LOCK / 'owner').unlink()
            LOCK.rmdir()
            print('LOCK_RELEASED', flush=True)


if __name__ == '__main__':
    try:
        main()
    except BaseException as exc:
        save('failure.json', {'type': type(exc).__name__, 'message': str(exc),
                              'traceback': traceback.format_exc(), 'pid': os.getpid(),
                              'active_child_pid': child.pid if child is not None and child.poll() is None else None,
                              'time_ns': time.time_ns()})
        raise
