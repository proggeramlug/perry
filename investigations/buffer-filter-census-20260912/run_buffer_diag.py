#!/usr/bin/env python3
"""Read the shipping buffer-probe instrument on the retained control binary.

No build and no new counters: `PERRY_BUFFER_DIAG` is already in this binary.
The question is what `BUFFER_LIKE_ADDR_FILTER` is actually holding — its own
sizing note assumes 213 cumulative admissions, and the 2026-09-12 census
measured the filter ending every row with all 1,024 bits set.
"""
from pathlib import Path
import datetime
import json
import os
import sys

BASE = Path('/root/cc-perf-native-recv-0909/registry-addr-index-20260912')
sys.path.insert(0, str(BASE))
import paired_workload_v2 as workload
from paired_workload_v2 import run, save, sha

OUT = Path('/root/cc-perf-native-recv-0909/buffer-filter-census-20260912')
CONTROL = Path('/root/cc-perf-native-recv-0909/runtime-own-read-cache-20260911/cc-candidate')
LOCK = Path('/root/rig9831/lock')


def main():
    OUT.mkdir(exist_ok=True)
    diag = OUT / 'buffer-diag.txt'
    # The driver strips every PERRY_* name and sets its own, so arm the
    # instrument by adding it to that block rather than to this process.
    source = Path(BASE / 'paired_workload_v2.py').read_text()
    marker = '            PERRY_REGEX_ENGINE="default", PERRY_REGEX_DIAG="0",\n'
    assert source.count(marker) == 1
    patched = source.replace(
        marker, marker + f'            PERRY_BUFFER_DIAG="{diag}",\n', 1)
    module = BASE / 'buffer_diag_workload.py'
    module.write_text(patched)
    sys.path.insert(0, str(BASE))
    import importlib
    spec = importlib.util.spec_from_file_location('buffer_diag_workload', module)
    armed = importlib.util.module_from_spec(spec)
    sys.modules['buffer_diag_workload'] = armed
    spec.loader.exec_module(armed)

    owner = f'buffer-filter-census-20260912 {os.getpid()}\n'
    try:
        LOCK.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (LOCK / 'owner').write_text(owner)
    record = {'status': 'started', 'application': str(CONTROL),
              'application_sha256': sha(CONTROL), 'rows': [],
              'started': datetime.datetime.now(datetime.timezone.utc).isoformat()}
    try:
        for row in (1, 2):
            out = OUT / f'buffer-row-{row}'
            if diag.exists():
                diag.unlink()
            result = armed.run(CONTROL, f'buffer-diag-{row}', 10950 + row, out)
            assert result['pass'], result
            text = diag.read_text() if diag.exists() else '(no dump)'
            (out / 'buffer-diag.txt').write_text(text)
            record['rows'].append({'row': row, 'cpu': result['process_cpu'],
                                   'vmhwm_mb': result['vmhwm_mb'], 'diag': text.strip()})
            save(OUT / 'buffer-census.execution.json', record)
            print(json.dumps({'row': row, 'diag': text.strip()}), flush=True)
        record['status'] = 'complete'
        return 0
    except BaseException as error:
        record.update(status='failed', error=repr(error))
        raise
    finally:
        save(OUT / 'buffer-census.execution.json', record)
        assert (LOCK / 'owner').read_text() == owner
        (LOCK / 'owner').unlink()
        LOCK.rmdir()


if __name__ == '__main__':
    raise SystemExit(main())
