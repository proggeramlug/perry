#!/usr/bin/env python3
"""Bind the measured function/sections and seal only owned study evidence."""
from pathlib import Path
import hashlib
import json
import os
import struct
import subprocess
import tarfile
import time

BASE = Path(__file__).resolve().parent
LOCK = Path('/root/rig9831/lock')


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def save(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + '\n')


def section_data(path):
    with path.open('rb') as stream:
        head = stream.read(64)
        assert head[:6] == b'\x7fELF\x02\x01'
        at = struct.unpack_from('<Q', head, 40)[0]
        size, count, names_index = struct.unpack_from('<HHH', head, 58)
        assert size == 64 and names_index < count
        stream.seek(at)
        records = [struct.unpack('<IIQQQQIIQQ', stream.read(64)) for _ in range(count)]
        names = records[names_index]
        stream.seek(names[4])
        strings = stream.read(names[5])
        result = {}
        for row in records:
            name = strings[row[0]:strings.index(b'\0', row[0])].decode()
            if name in ['.text', '.perry_gcmap']:
                stream.seek(row[4])
                data = stream.read(row[5])
                assert len(data) == row[5]
                result[name] = {'address': row[3], 'offset': row[4], 'bytes': row[5],
                                'sha256': hashlib.sha256(data).hexdigest()}
        assert set(result) == {'.text', '.perry_gcmap'}
        return result


def main():
    measure = json.loads((BASE / 'measure-v2.execution.json').read_text())
    assert measure['status'] == 'complete' and len(measure['rows']) == 13
    launch = json.loads((BASE / 'measure-launch.json').read_text())
    assert not (Path('/proc') / str(launch['pid'])).exists()
    deadline = time.monotonic() + 1800
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            assert time.monotonic() < deadline, 'seal lock deadline'
            time.sleep(5)
    owner = f'cc-own-read-cache-finish-v1 {os.getpid()}'
    (LOCK / 'owner').write_text(owner + '\n')
    try:
        for name, digest in json.loads((BASE / 'inputs.json').read_text()).items():
            assert sha(BASE / name) == digest, name
        command = ['/usr/bin/python3', '-B', str(BASE / 'analyze_pair_v2.py'), '--raw', str(BASE), '--out', str(BASE / 'results-v2')]
        with (BASE / 'analysis.log').open('x') as log:
            result = subprocess.run(command, cwd=BASE, stdout=log, stderr=subprocess.STDOUT)
        save(BASE / 'analysis.execution.json', {'argv': command, 'exit_code': result.returncode, 'owner': owner})
        assert result.returncode == 0, (BASE / 'analysis.log').read_text()
        build = json.loads((BASE / 'build.execution.json').read_text())
        assert build['status'] == 'complete'
        source = json.loads((BASE / 'source-receipt.json').read_text())
        for relative, digest in source['files'].items():
            assert sha(Path('/root/worktrees/cc-own-read-cache-0911') / relative) == digest
        receipt = {'status': 'complete', 'binary': {}}
        for arm in ['control', 'candidate']:
            app = Path(build['pair'][arm]['path'])
            assert sha(app) == build['pair'][arm]['sha256']
            sections = section_data(app)
            symbols = subprocess.check_output(['/usr/lib/llvm-22/bin/llvm-nm', '-S', '--defined-only', app], text=True)
            assert 'PERRY_PROPERTY_READ_CENSUS' not in symbols
            assert 'own_read_cache_tests' not in symbols and 'own_read_cache4HITS' not in symbols
            assert ('own_read_cache' in symbols) == (arm == 'candidate')
            matches = [row.split() for row in symbols.splitlines()
                       if row.split() and row.split()[-1] == 'js_object_get_field_by_name']
            assert len(matches) == 1 and len(matches[0]) == 4
            address, length = (int(x, 16) for x in matches[0][:2])
            text = sections['.text']
            assert text['address'] <= address and address + length <= text['address'] + text['bytes']
            with app.open('rb') as stream:
                stream.seek(text['offset'] + address - text['address'])
                code = stream.read(length)
            assert len(code) == length
            disassembly = BASE / ('getter-' + arm + '.asm')
            with disassembly.open('x') as output:
                subprocess.run(['/usr/lib/llvm-22/bin/llvm-objdump', '--disassemble-symbols=js_object_get_field_by_name',
                                '--no-show-raw-insn', app], stdout=output, check=True)
            receipt['binary'][arm] = {'sha256': sha(app), 'sections': sections,
                                     'getter': {'address': address, 'bytes': length,
                                                'sha256': hashlib.sha256(code).hexdigest(),
                                                'disassembly_sha256': sha(disassembly)},
                                     'test_counter_present': False}
        assert receipt['binary']['control']['getter']['sha256'] != receipt['binary']['candidate']['getter']['sha256']
        save(BASE / 'binary-verification.json', receipt)
        # Preserve ordinary metadata/statistics and scripts, never target binaries,
        # Cargo/cache directories, or HOME/configuration contents.
        files = {p for p in BASE.iterdir() if p.is_file() and (p.suffix in
                 ['.json', '.log', '.py', '.diff', '.ts', '.asm'] or p.name == 'source-overlay.tar.gz') and not p.name.startswith('evidence-')}
        for directory in [*[f'v2-row-{arm}-{i}' for arm, count in [('control', 5), ('candidate', 5), ('node', 3)]
                                             for i in range(1, count + 1)], 'results-v2']:
            files.update(p for p in (BASE / directory).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
        entries = [{'path': str(p.relative_to(BASE)), 'bytes': p.stat().st_size, 'sha256': sha(p)}
                   for p in sorted(files)]
        manifest = {'status': 'sealed-complete-pair-evidence', 'files': entries,
                    'file_count': len(entries), 'bytes': sum(r['bytes'] for r in entries),
                    'lock_owner': owner}
        manifest_path = BASE / 'evidence-manifest-v1.json'
        save(manifest_path, manifest)
        archive = BASE / 'evidence-v1.tar.gz'
        assert not archive.exists()
        with tarfile.open(archive, 'w:gz') as tar:
            for row in entries:
                tar.add(BASE / row['path'], arcname=row['path'])
            tar.add(manifest_path, arcname=manifest_path.name)
        seal = {'status': 'complete', 'archive_sha256': sha(archive), 'archive_bytes': archive.stat().st_size,
                'file_count': len(entries), 'uncompressed_bytes': manifest['bytes']}
        save(BASE / 'seal-v1.json', seal)
        print(json.dumps({'seal': seal, 'binary': receipt}, indent=2))
    finally:
        assert (LOCK / 'owner').read_text().strip() == owner
        (LOCK / 'owner').unlink()
        LOCK.rmdir()


if __name__ == '__main__':
    main()
