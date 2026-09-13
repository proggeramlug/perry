import json
import os
from pathlib import Path
import subprocess
import sys
import time

root = Path(os.environ.get('CUTOFF_ROOT', '/tmp/def/two-tier'))
root.mkdir(exist_ok=True)
binary = sys.argv[1]
for count in map(int, sys.argv[2:]):
    records = [dict(id=i, name=f'n{i}', tags=['a', f'b{i % 5}'], w=i / 4) for i in range(count)]
    literal = json.dumps(records)
    source = ('type Rec = { id: number; name: string; tags: string[]; w: number };\n'
              'const recs: Rec[] = ' + literal + ';\n'
              'let w = 0;\n'
              'for (let j = 0; j < recs.length; j++) { const q = recs[j]; w += q.w + q.tags.length + q.id; }\n'
              'console.log(recs.length, w);\n')
    path = root / f'records-{count}.ts'
    path.write_text(source)
    # Root + each record, four fields, and two tag elements.
    text_bytes = sum(11 + len(r['name']) + sum(map(len, r['tags'])) for r in records)
    print(f'BEGIN count={count} source_bytes={len(literal)} nodes={1 + count * 7} key_string_bytes={text_bytes}', flush=True)
    cmd = ['/usr/bin/time', '-v', 'timeout', os.environ.get('CUTOFF_TIMEOUT', '120'),
           binary, 'compile', str(path), '--no-link', '--no-auto-optimize',
           '--output', str(root / f'records-{count}.o'),
           '--cache-dir', str(root / f'cache-{count}')]
    started = time.monotonic()
    with (root / f'cutoff-{count}.log').open('w') as log:
        status = subprocess.run(cmd, cwd=root, stdout=log, stderr=log,
                                env={**os.environ, 'PERRY_CODEGEN_PROGRESS': 'all'}).returncode
    print(f'END count={count} status={status} elapsed={time.monotonic() - started:.2f}', flush=True)
    lines = (root / f'cutoff-{count}.log').read_text().splitlines()
    for line in lines:
        if any(word in line for word in ['instr', 'MiB', 'codegen', 'Elapsed', 'Maximum resident']):
            print(line, flush=True)
