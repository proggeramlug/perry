#!/usr/bin/env python3
"""Three census rows: classification entries, filter passes, resolved wrappers.

Counts only. The binary carries armed counters, so its CPU is not comparable
with the ordinary arms and no CPU or RSS claim may be derived from this run.
"""
from pathlib import Path
import datetime
import json
import os

from census_workload_v1 import run, save, sha


def main():
    base = Path(__file__).resolve().parent
    status = base / 'census-observation-v1.execution.json'
    assert not status.exists()
    lock = Path('/root/rig9831/lock')
    owner = f'canonical-filter-census-rows-20260912 {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (lock / 'owner').write_text(owner)
    app = base / 'cc-census'
    expected = sha(app)
    record = {'status': 'started', 'pid': os.getpid(), 'owner': owner.strip(),
              'application': str(app), 'application_sha256': expected,
              'started': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'rows': [],
              'inputs': {name: sha(base / name) for name in
                         ['census_workload_v1.py', 'counter_observer.py', 'bindings-v1.json',
                          'run_census_v1.py']}}
    save(status, record)
    try:
        for row in (1, 2, 3):
            out = base / f'census-row-v1-{row}'
            result = run(app, f'canon-census-v1-{row}', 10771 + row, out)
            assert result['pass'], result
            assert result['application_sha256'] == expected
            snapshots = json.loads((out / 'counter-snapshots.json').read_text())
            assert [s['phase'] for s in snapshots] == [1, 2, 3, 4]
            for snapshot in snapshots[1:]:
                values = snapshot['values']
                # A zero classification count means the instrument did not run;
                # accepting it would report "no cost" for an armed counter.
                assert values['CALLS'] > 0, snapshot
                assert values['FILTER_PASS'] <= values['CALLS'], snapshot
                assert values['RESOLVED'] <= values['FILTER_PASS'], snapshot
            record['rows'].append({'row': row, 'snapshots': snapshots,
                                   'instrumented_cpu': result['instrumented_cpu']})
            save(status, record)
            final = snapshots[-1]['values']
            print(json.dumps({'row': row, 'calls': final['CALLS'],
                              'filter_pass': final['FILTER_PASS'],
                              'resolved': final['RESOLVED'], 'admits': final['ADMITS'],
                              'retires': final['RETIRES'], 'live': final['LIVE'],
                              'bits_set': final['CANONICAL_HANDLE_ADDR_FILTER']['bits_set'],
                              'instrumented_cpu': result['instrumented_cpu']}), flush=True)
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
