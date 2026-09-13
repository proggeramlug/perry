import json
import os
from pathlib import Path
import re
import statistics
import subprocess
import time

root = Path('/tmp/def/two-tier/ab')
root.mkdir(exist_ok=True)
(root / 'perry.json').write_text('{}')
source = Path('.10151-measure/perf.ts').read_text()
(root / 'hot.ts').write_text(source)
(root / 'probe.ts').write_text(Path('.10151-measure/probe.ts').read_text())
bins = {
    'ordinary': Path('/tmp/def/two-tier/ordinary-bin'),
    'original_pr': Path('/tmp/def/verified-bin'),
    'revised': Path('/tmp/def/two-tier/revised-bin'),
}
results = {}
for label, binary in bins.items():
    results[label] = {}
    for case in ['hot', 'probe']:
        started = time.monotonic()
        with (root / f'{label}-{case}.log').open('w') as log:
            proc = subprocess.run(
                ['/usr/bin/time', '-v', 'timeout', '600', str(binary / 'perry'),
                 'compile', f'{case}.ts', '--no-auto-optimize', '--output', f'./{label}-{case}',
                 '--cache-dir', f'cache-{label}-{case}'], cwd=root, stdout=log, stderr=log,
                env={**os.environ, 'PERRY_RUNTIME_DIR': str(binary), 'PERRY_CODEGEN_PROGRESS': 'all'})
        elapsed = time.monotonic() - started
        print(label, case, proc.returncode, f'{elapsed:.2f}s', flush=True)
        if proc.returncode:
            print((root / f'{label}-{case}.log').read_text()[-6000:], flush=True)
        proc.check_returncode()
        results[label][f'{case}_compile_seconds'] = elapsed
        results[label][f'{case}_executable_bytes'] = (root / f'{label}-{case}').stat().st_size
    results[label]['probe_stdout'] = subprocess.check_output([str(root / f'{label}-probe')], text=True)

assert len({v['probe_stdout'] for v in results.values()}) == 1, results
print('Semantic probe stdout identical for all three variants', flush=True)
for round in range(5):
    for label in (list(bins) if round % 2 == 0 else list(reversed(bins))):
        output = subprocess.check_output([str(root / f'{label}-hot')], text=True)
        print(round, label, output.strip(), flush=True)
        matches = re.fullmatch(r'table_ms (\d+) recs_ms (\d+) (.+)\n', output)
        assert matches, output
        results[label].setdefault('table_ms', []).append(int(matches[1]))
        results[label].setdefault('recs_ms', []).append(int(matches[2]))
        results[label]['checksum'] = matches[3]
assert len({v['checksum'] for v in results.values()}) == 1, results
for result in results.values():
    for metric in ['table_ms', 'recs_ms']:
        result[metric + '_median'] = statistics.median(result[metric])
(root / 'results.json').write_text(json.dumps(results, indent=2))
print(json.dumps(results, indent=2), flush=True)
