#!/usr/bin/env python3
"""Five interleaved Perry pairs and three Node rows, after the exact build."""
from pathlib import Path
import datetime
import json
import os
import subprocess
import time

from paired_workload_v2 import run, save, sha, selftest, process_snapshot, require_started_app

BASE = Path(__file__).resolve().parent
LOCK = Path('/root/rig9831/lock')


def main():
    status = BASE / 'measure-v2.execution.json'
    assert not status.exists()
    birth = process_snapshot(os.getpid())
    record = {'status': 'waiting-for-build', 'process': birth, 'rows': [],
              'inputs': {name: sha(BASE / name) for name in
                         ['paired_workload_v2.py', 'phase_recorder.py', 'measure_pair_v2.py']}}
    save(status, record)
    deadline = time.monotonic() + 14400
    while True:
        build = json.loads((BASE / 'build.execution.json').read_text())
        if build['status'] == 'complete':
            break
        assert build['status'] != 'failed', build
        owner = json.loads((BASE / 'build-launch.json').read_text())
        observed = process_snapshot(owner['pid'])
        assert all(observed[key] == owner[key] for key in ['pid', 'start_ticks', 'argv', 'cwd'])
        assert time.monotonic() < deadline, 'build observation deadline reached'
        print('BUILD_LIVE', owner['pid'], flush=True)
        time.sleep(10)
    owner = f'cc-own-read-cache-measure-v1 {os.getpid()}\n'
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            assert time.monotonic() < deadline, 'measurement lock deadline reached'
            print('WAIT_CAMPAIGN_LOCK', flush=True)
            time.sleep(10)
    (LOCK / 'owner').write_text(owner)
    try:
        record.update(status='running', owner=owner.strip(),
                      started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
        save(status, record)
        controls = selftest()
        assert controls['pass']
        from copy import deepcopy
        before = {'pid': 123, 'start_ticks': 456, 'exe': '/usr/bin/python3', 'cwd': '/tmp/owned-fixture', 'argv': ['driver']}
        titled = dict(before, exe='/usr/bin/node', argv=['claude'])
        argv = ['/usr/bin/node', '/tmp/owned-fixture/cli.js']
        assert require_started_app(titled, before, Path('/usr/bin/node'), argv, ['claude']) == titled
        rejected = []
        for key, value in [('pid', 124), ('start_ticks', 457), ('exe', '/usr/bin/other'), ('cwd', '/tmp/elsewhere'), ('argv', ['unrelated'])]:
            changed = deepcopy(titled)
            changed[key] = value
            try:
                require_started_app(changed, before, Path('/usr/bin/node'), argv, ['claude'])
            except RuntimeError:
                rejected.append(key)
            else:
                raise AssertionError('invalid identity accepted: ' + key)
        try:
            require_started_app(titled, before, Path('/usr/bin/node'), argv)
        except RuntimeError:
            rejected.append('undeclared-title')
        else:
            raise AssertionError('title allowed without explicit declaration')
        controls['argv_transition_rejections'] = rejected
        save(BASE / 'driver-controls-v2.json', controls)
        apps = {arm: Path(item['path']) for arm, item in build['pair'].items()}
        for arm, app in apps.items():
            assert sha(app) == build['pair'][arm]['sha256']
        node = Path('/usr/bin/node').resolve()
        bundle = Path('/root/cc-perf-native-recv-0909/cc-control/cli_2.1.112.js')
        record['node'] = {'path': str(node), 'version': subprocess.check_output([node, '--version'], text=True).strip(),
                          'sha256': sha(node), 'bundle_sha256': sha(bundle)}
        assert record['node']['bundle_sha256'] == 'bc3358282800e3e99daa8e71ac5b7b1566bd0d7ca7eb94f714a7859365d3163f'
        ordinal = 0
        for row in range(1, 6):
            order = ['control', 'candidate'] if row % 2 else ['candidate', 'control']
            if row <= 3:
                order.insert(row - 1, 'node')
            for arm in order:
                ordinal += 1
                label = f'own-read-cache-v1-{arm}-{row}'
                out = BASE / f'v2-row-{arm}-{row}'
                before = {'load': os.getloadavg(), 'at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat()}
                app = node if arm == 'node' else apps[arm]
                result = run(app, label, 10800 + ordinal, out, [bundle] if arm == 'node' else [], ['claude'] if arm == 'node' else None)
                assert result['pass'] and result['cleanup_errors'] == [], (arm, row)
                assert result['counter_control']['kind'] == 'controller-timestamps-only'
                assert [x['phase'] for x in result['counter_control']['phases']] == [1, 2, 3, 4]
                item = {'arm': arm, 'row': row, 'order': ordinal, 'before': before,
                        'after_load': os.getloadavg(), 'cpu': result['process_cpu'],
                        'vmhwm_mb': result['vmhwm_mb'], 'run_sha256': sha(out / 'run.json')}
                record['rows'].append(item)
                save(status, record)
                print('ROW_COMPLETE', json.dumps(item), flush=True)
        for arm, app in apps.items():
            assert sha(app) == build['pair'][arm]['sha256']
        assert sha(node) == record['node']['sha256']
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
