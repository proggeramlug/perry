#!/usr/bin/env python3
"""Profile an immutable measured candidate; no compilation or optimization."""
from pathlib import Path
import datetime
import json
import os
import subprocess
import time

from profile_workload_v4 import run, save, sha, process_snapshot

BASE = Path(__file__).resolve().parent
APP = Path('/root/cc-perf-native-recv-0909/runtime-own-read-cache-20260911/cc-candidate')
APP_SHA = '42bfb149007b5c79d11b11d6acb7ad16008932945a78efe700c19bec9d3e513a'
SOURCE = Path('/root/worktrees/cc-own-read-cache-0911')
LOCK = Path('/root/rig9831/lock')


def invoke(command, name):
    command = list(map(str, command))
    stdout, stderr = BASE / (name + '.txt'), BASE / (name + '.stderr')
    receipt = {'command': command, 'started_ns': time.time_ns()}
    with stdout.open('x') as out, stderr.open('x') as err:
        result = subprocess.run(command, cwd=BASE, stdout=out, stderr=err)
    receipt.update(exit=result.returncode, finished_ns=time.time_ns(),
                   stdout_sha256=sha(stdout), stderr_sha256=sha(stderr))
    save(BASE / (name + '.command.json'), receipt)
    assert result.returncode == 0, (name, result.returncode)
    return receipt


def verify_source():
    source = json.loads((BASE / 'source-receipt.json').read_text())
    for name, expected in source['files'].items():
        assert sha(SOURCE / name) == expected, name
    assert sha(APP) == APP_SHA, 'measured application changed'
    return source


def competing_builds():
    found = []
    for proc in Path('/proc').iterdir():
        if not proc.name.isdecimal():
            continue
        try:
            executable = Path(os.readlink(proc / 'exe')).name
            argv = [os.fsdecode(x) for x in (proc / 'cmdline').read_bytes().split(b'\0') if x]
            if executable in ('cargo', 'rustc', 'clang', 'clang-22', 'ld', 'ld.lld', 'lld') or (
                    executable == 'perry' and 'compile' in argv):
                found.append({'pid': int(proc.name), 'executable': executable,
                              'cwd': os.readlink(proc / 'cwd'), 'argv': argv})
        except (FileNotFoundError, PermissionError, ProcessLookupError):
            continue
    return found


def main():
    status = BASE / 'execution.json'
    assert not status.exists()
    owner = f'cc-own-cache-profile-v1 {os.getpid()}\n'
    record = {'status': 'waiting-for-lock', 'process': process_snapshot(os.getpid()),
              'owner': owner.strip(), 'rows': [],
              'inputs': {p.name: sha(p) for p in BASE.iterdir()
                         if p.suffix == '.py' or p.name in ('source-receipt.json', 'script-derivation.json')}}
    save(status, record)
    deadline = time.monotonic() + 3600
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            assert time.monotonic() < deadline, 'lock observation deadline'
            print('WAIT_CAMPAIGN_LOCK', flush=True)
            time.sleep(10)
    (LOCK / 'owner').write_text(owner)
    try:
        verify_source()
        perf = (Path('/usr/lib/linux-tools') / os.uname().release / 'perf').resolve()
        assert perf.is_file(), perf
        os.environ['PATH'] = str(perf.parent) + ':' + os.environ['PATH']
        record.update(status='running', application=str(APP), application_sha256=APP_SHA,
                      perf=str(perf), perf_sha256=sha(perf),
                      perf_version=subprocess.check_output([perf, '--version'], text=True).strip(),
                      started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
        save(status, record)
        for row in (1, 2, 3):
            assert (LOCK / 'owner').read_text() == owner
            before = {'load': os.getloadavg(), 'at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat()}
            # Do not sample under a heavily loaded host even when its other work
            # does not participate in the campaign lock.
            assert before['load'][0] < 4, before
            before['competing_builds'] = competing_builds()
            assert before['competing_builds'] == [], before
            label = f'own-cache-profile-v1-{row}'
            out = BASE / f'row-{row}'
            result = run(APP, label, 10920 + row, out)
            assert result['pass'] and result['cleanup_errors'] == []
            assert result['application_sha256'] == APP_SHA
            item = {'row': row, 'before': before, 'after_load': os.getloadavg(),
                    'cpu': result['cpu'], 'vmhwm_mb': result['vmhwm_mb'],
                    'run_sha256': sha(out / 'run.json'), 'after_competing_builds': competing_builds()}
            record['rows'].append(item)
            save(status, record)
            assert item['after_competing_builds'] == [], item
            print('PROFILE_COMPLETE', json.dumps(item), flush=True)
        record['status'] = 'analyzing'
        save(status, record)
        for row in (1, 2, 3):
            out = BASE / f'row-{row}'
            invoke([perf, 'script', '--ns', '-i', out / 'profile.data', '-F',
                    'pid,tid,time,event,ip,sym,symoff,dso,period'], f'row-{row}/samples')
            invoke([perf, 'report', '--stdio', '--no-children', '--show-total-period',
                    '--show-nr-samples', '--sort=comm,dso,symbol', '--field-separator=,',
                    '--percent-limit=0', '-i', out / 'profile.data'], f'row-{row}/self-report')
            invoke(['/usr/bin/python3', '-B', BASE / 'profile_samples_v3.py',
                    '--samples', out / 'samples.txt', '--run', out / 'run.json',
                    '--maps', out / 'app-maps.json', '--output', out / 'analysis'], f'row-{row}/analyze')
            invoke(['/usr/bin/python3', '-B', BASE / 'perf_self_reconcile.py',
                    '--report', out / 'self-report.txt', '--summary', out / 'analysis/summary.json',
                    '--command-receipt', out / 'self-report.command.json',
                    '--output', out / 'reconciliation.json'], f'row-{row}/reconcile')
        verify_source()
        for name, expected in record['inputs'].items():
            assert sha(BASE / name) == expected, name
        record['status'] = 'complete'
    except BaseException as error:
        record.update(status='failed', error=repr(error))
        raise
    finally:
        record['finished_utc'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        save(status, record)
        assert (LOCK / 'owner').read_text() == owner
        (LOCK / 'owner').unlink()
        LOCK.rmdir()


if __name__ == '__main__':
    main()
