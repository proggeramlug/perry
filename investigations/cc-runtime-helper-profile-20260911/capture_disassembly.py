#!/usr/bin/env python3
"""Read selected exact-binary functions under the campaign lock; run no workload."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import subprocess
import sys

from metadata_census import ElfMetadata


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def main():
    request_path, destination = map(Path, sys.argv[1:])
    request = json.loads(request_path.read_text())
    lock = Path('/root/rig9831/lock')
    owner = f'cc-runtime-helper-self-0911 {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print(json.dumps({'status': 'not-started-lock-busy'}))
        return 75
    (lock / 'owner').write_text(owner)
    try:
        destination.mkdir()
        result = {'status': 'started', 'owner': owner.strip(),
                  'started': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  'request_sha256': sha(request_path),
                  'script_sha256': sha(__file__),
                  'elf_reader_sha256': sha(Path(__file__).with_name('metadata_census.py')),
                  'functions': []}
        (destination / 'execution.json').write_text(json.dumps(result, indent=2) + '\n')
        binary = Path(request['binary'])
        assert sha(binary) == request['binary_sha256'], 'binary identity mismatch'
        elf = ElfMetadata(binary)
        try:
            symbols = elf.symbols()
            for index, function in enumerate(request['functions']):
                address = function['start']
                aliases = symbols.get(address, [])
                sizes = {row['size'] for row in aliases if row['size']}
                assert len(sizes) == 1, (function, aliases)
                size = sizes.pop()
                name = f'function-{index}.disasm'
                command = ['objdump', '-d', '--no-show-raw-insn',
                           f'--start-address={address}',
                           f'--stop-address={address + size}', str(binary)]
                with (destination / name).open('wb') as output:
                    process = subprocess.run(command, stdout=output, stderr=subprocess.PIPE)
                assert process.returncode == 0, process.stderr.decode(errors='replace')
                result['functions'].append({**function, 'size': size, 'aliases': aliases,
                                            'disassembly': name, 'sha256': sha(destination / name),
                                            'command': command})
            result['elf_identity'] = elf.identity()
            result['elf_reads'] = elf.reads
        finally:
            elf.file.close()
        assert sha(binary) == request['binary_sha256'], 'binary changed during read'
        result.update(status='complete', binary_sha256=request['binary_sha256'],
                      finished=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                      scope='static disassembly only; no new performance row')
        (destination / 'execution.json').write_text(json.dumps(result, indent=2) + '\n')
        print(json.dumps({'status': result['status'], 'functions': len(result['functions'])}))
        return 0
    finally:
        assert (lock / 'owner').read_text() == owner, 'lock ownership changed'
        (lock / 'owner').unlink()
        lock.rmdir()


if __name__ == '__main__':
    raise SystemExit(main())
