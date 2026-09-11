#!/usr/bin/env python3
"""Run one exact cc caller census behind the campaign lock."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import subprocess
import sys

from counter_workload_v1 import run, sha, save


def main():
    base = Path(__file__).resolve().parent
    row = int(sys.argv[1])
    assert row in (1, 2, 3)
    output = base / f'cc-row-v1-{row}'
    status = base / f'cc-row-v1-{row}.execution.json'
    assert not output.exists() and not status.exists()
    lock = Path('/root/rig9831/lock')
    owner = f'cc-runtime-caller-census-0911-row{row} {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (lock / 'owner').write_text(owner)
    record = {'status': 'started', 'pid': os.getpid(), 'row': row, 'owner': owner.strip(),
              'started': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'inputs': {name: sha(base / name) for name in
                         ['probe_census_v2.py', 'census_template.bt', 'profile_workload_v4.py',
                          'counter_workload_v1.py', 'run_census_v1.py', 'control-v3/CONTROL_PASS.json']}}
    save(status, record)
    try:
        control = json.loads((base / 'control-v3/CONTROL_PASS.json').read_text())
        assert control['status'] == 'PASS'
        app = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911/compile-v2/cc-diagnostic')
        expected = 'b907d616caf8eea350543185de24fc2af1426090fc58161ee49952e6980314f7'
        assert sha(app) == expected
        # The port is owned only after the mock actually binds; never stop a
        # pre-existing listener or reuse another task's sandbox.
        result = run(app, f'runtime-caller-v1-{row}', 10661 + row, output)
        assert result['pass'] and result['application_sha256'] == expected
        assert result['counter_control']['counts_status'] == 'balanced-entry-return-census'
        counts = json.loads((output / 'counts.json').read_text())
        assert sha(app) == expected
        record.update(status='complete', total_entries=counts['total_entries'],
                      scope='instrumented call counts only; not an ordinary CPU/RSS result')
        print(json.dumps({'status': 'complete', 'row': row, 'total_entries': counts['total_entries']}))
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
