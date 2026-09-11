#!/usr/bin/env python3
from pathlib import Path
import datetime
import json
import os

from filter_workload_v1 import run, save, sha


def main():
    base = Path(__file__).resolve().parent
    status = base / 'filter-observation-v1.execution.json'
    assert not status.exists()
    lock = Path('/root/rig9831/lock')
    owner = f'cc-runtime-handle-filter-0911 {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (lock / 'owner').write_text(owner)
    record = {'status': 'started', 'pid': os.getpid(), 'owner': owner.strip(),
              'started': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'rows': [],
              'inputs': {name: sha(base / name) for name in
                         ['filter_workload_v1.py', 'filter_observer.py', 'bindings-v1.json', 'run_filter_v1.py']}}
    save(status, record)
    try:
        app = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911/compile-v2/cc-diagnostic')
        expected = 'b907d616caf8eea350543185de24fc2af1426090fc58161ee49952e6980314f7'
        assert sha(app) == expected
        for row in (1, 2, 3):
            out = base / f'filter-row-v1-{row}'
            result = run(app, f'handle-filter-v1-{row}', 10671 + row, out)
            assert result['pass'] and result['application_sha256'] == expected
            snapshots = json.loads((out / 'filter-snapshots.json').read_text())
            assert [s['phase'] for s in snapshots] == [1, 2, 3, 4]
            assert all(s['capacity_bits'] > 0 and 0 < s['bits_set'] <= s['capacity_bits']
                       for s in snapshots[1:])
            record['rows'].append({'row': row, 'snapshots': snapshots,
                                   'observed_cpu': result['instrumented_cpu']})
            save(status, record)
            print(json.dumps({'row': row, 'bits_set': [s.get('bits_set') for s in snapshots],
                              'capacity_bits': snapshots[-1]['capacity_bits']}), flush=True)
        assert sha(app) == expected
        record['status'] = 'complete'
        return 0
    except BaseException as error:
        record.update(status='failed', error=repr(error))
        raise
    finally:
        record['finished'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        save(status, record)
        assert (lock / 'owner').read_text() == owner
        (lock / 'owner').unlink()
        lock.rmdir()


if __name__ == '__main__':
    raise SystemExit(main())
