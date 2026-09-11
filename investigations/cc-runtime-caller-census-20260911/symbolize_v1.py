#!/usr/bin/env python3
"""Resolve counted return continuations against the exact captured process map."""
from pathlib import Path
from collections import Counter
import bisect
import hashlib
import json
import os
import re
import struct
import subprocess
import sys

from metadata_census import ElfMetadata
from machine_loop_coverage import parse_disassembly
from profile_samples_v3 import parse_maps
from profile_workload_v4 import save, sha


def main():
    base = Path(__file__).resolve().parent
    row = int(sys.argv[1])
    root = base / f'cc-row-v1-{row}'
    output = base / f'symbols-v1-{row}'
    lock = Path('/root/rig9831/lock')
    owner = f'cc-runtime-callers-symbols-0911-row{row} {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (lock / 'owner').write_text(owner)
    try:
        output.mkdir()
        run = json.loads((root / 'run.json').read_text())
        target = json.loads((root / 'probe-target.json').read_text())
        counts = json.loads((root / 'counts.json').read_text())
        assert run['pass'] and counts['status'] == 'balanced-entry-return-census'
        binary = Path(run['application'])
        assert sha(binary) == run['application_sha256'] == target['binary_sha256']
        maps = parse_maps(json.loads((root / 'app-maps.json').read_text()))
        app_maps = [m for m in maps if m['path'] == str(binary)]
        assert app_maps and all(m['inode'] == target['inode'] for m in app_maps)
        with binary.open('rb') as stream:
            header = struct.unpack('<16sHHIQQQIHHHHHH', stream.read(64))
            assert header[9] == 56
            stream.seek(header[5])
            segments = [struct.unpack('<IIQQQQQQ', stream.read(56)) for _ in range(header[10])]
        page = os.sysconf('SC_PAGE_SIZE')
        biases = set()
        for mapping in app_maps:
            if 'x' not in mapping['perms']:
                continue
            matches = [segment for segment in segments
                       if segment[0] == 1 and segment[1] & 1
                       and mapping['offset'] == segment[2] // page * page]
            assert len(matches) == 1
            biases.add(mapping['start'] - matches[0][3] // page * page)
        assert len(biases) == 1
        bias = biases.pop()
        elf = ElfMetadata(binary)
        try:
            symbols = elf.symbols()
            addresses = sorted(symbols)
            result = []
            owners = {}
            for count in counts['rows']:
                pc = count['return_pc']
                admitted_maps = [m for m in app_maps if 'x' in m['perms'] and m['start'] <= pc - 1 < m['end']]
                if len(admitted_maps) != 1:
                    result.append({**count, 'binding': 'outside-exact-application-map'})
                    continue
                linked = pc - bias
                start = addresses[bisect.bisect_right(addresses, linked - 1) - 1]
                aliases = [a for a in symbols[start] if a['size'] > 0 and start <= linked - 1 < start + a['size']]
                if not aliases:
                    result.append({**count, 'linked_return_pc': linked, 'binding': 'no-enclosing-sized-symbol'})
                    continue
                assert len({a['size'] for a in aliases}) == 1
                owners[start] = {'start': start, 'size': aliases[0]['size'], 'aliases': aliases}
                result.append({**count, 'linked_return_pc': linked, 'binding': 'exact-sized-symbol',
                               'owner_start': start, 'owner_offset': linked - start,
                               'owner_symbol': aliases[0]['name']})
            names = sorted({a['name'] for value in owners.values() for a in value['aliases']})
            demangle = subprocess.run(['c++filt', '-n'], input='\n'.join(names) + '\n',
                                      stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            assert demangle.returncode == 0
            demangled = demangle.stdout.splitlines()
            assert len(demangled) == len(names)
            by_name = dict(zip(names, demangled))
            for index, (start, function) in enumerate(sorted(owners.items())):
                path = output / f'owner-{index}.disasm'
                command = ['objdump', '-d', '--no-show-raw-insn', f'--start-address={start}',
                           f"--stop-address={start + function['size']}", str(binary)]
                with path.open('w') as stream:
                    process = subprocess.run(command, stdout=stream, stderr=subprocess.PIPE, text=True)
                assert process.returncode == 0, process.stderr
                found = []
                parse_errors = []
                for alias in function['aliases']:
                    try:
                        found.append(parse_disassembly(path.read_text(), alias['name']))
                    except ValueError as error:
                        if not str(error).startswith('no instructions for exact symbol '):
                            parse_errors.append(str(error))
                function.update(disassembly=path.name, sha256=sha(path), command=command)
                if len(found) != 1 or parse_errors:
                    function['instruction_binding'] = {'status': 'unresolved', 'errors': parse_errors}
                    continue
                instructions = found[0]
                pairs = {following[0]: previous for previous, following in zip(instructions, instructions[1:])}
                function['instruction_binding'] = {'status': 'parsed'}
                for entry in result:
                    if entry.get('owner_start') != start:
                        continue
                    previous = pairs.get(entry['linked_return_pc'])
                    entry['owner_demangled'] = by_name[entry['owner_symbol']]
                    if previous is None:
                        entry['call_binding'] = 'continuation-not-an-instruction-boundary'
                        continue
                    address, mnemonic, operand = previous
                    entry['previous_instruction'] = {'address': address, 'mnemonic': mnemonic, 'operand': operand}
                    destination = re.match(r'^([0-9a-fA-F]+)\s+<', operand)
                    entry['call_binding'] = ('direct-call-to-counted-helper'
                        if mnemonic in ('call', 'callq') and destination
                        and int(destination[1], 16) == target['address'] else 'other-call-or-tail-continuation')
            record = {'status': 'complete-conservative-return-continuation-join', 'row': row,
                      'binary_sha256': target['binary_sha256'], 'load_bias': bias,
                      'rows': result, 'owners': list(owners.values()),
                      'inputs': {name: sha(root / name) for name in
                                 ['run.json', 'counts.json', 'probe-target.json', 'app-maps.json']},
                      'script_sha256': sha(__file__), 'lock_owner': owner.strip()}
            save(output / 'summary.json', record)
            top = sorted([r for r in result if r['phase'] == 3], key=lambda r: r['entries'], reverse=True)[:15]
            print(json.dumps({'status': record['status'], 'owners': len(owners), 'top': top}, indent=2))
        finally:
            elf.file.close()
        return 0
    finally:
        assert (lock / 'owner').read_text() == owner
        (lock / 'owner').unlink()
        lock.rmdir()


if __name__ == '__main__':
    raise SystemExit(main())
