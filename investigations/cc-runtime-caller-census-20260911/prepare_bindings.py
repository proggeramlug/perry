#!/usr/bin/env python3
from pathlib import Path
import json
import os
import re
import struct

from metadata_census import ElfMetadata, SYMBOL, cstring
from profile_workload_v4 import sha, save


def main():
    base = Path(__file__).resolve().parent
    lock = Path('/root/rig9831/lock')
    owner = f'cc-runtime-caller-bindings-0911 {os.getpid()}\n'
    try:
        lock.mkdir()
    except FileExistsError:
        print('not-started-lock-busy')
        return 75
    (lock / 'owner').write_text(owner)
    try:
        path = base / 'bindings-v1.json'
        assert not path.exists()
        target = json.loads((base / 'cc-row-v1-1/probe-target.json').read_text())
        binary = Path(target['binary'])
        assert sha(binary) == target['binary_sha256']
        elf = ElfMetadata(binary)
        try:
            objects = []
            for table in elf.sections:
                if table['type'] != 2:
                    continue
                raw = elf.read_section(table)
                names = elf.read_section(elf.sections[table['link']])
                for at in range(0, len(raw), SYMBOL.size):
                    name, info, other, index, address, size = SYMBOL.unpack_from(raw, at)
                    if info & 15 != 1 or index == 0:
                        continue
                    text = cstring(names, name)
                    if 'CANONICAL_HANDLE_ADDR_FILTER' in text:
                        objects.append({'symbol': text, 'address': address, 'bytes': size,
                                        'section': elf.sections[index]['name']})
            assert len(objects) == 1
            bitmap = objects[0]
            assert bitmap['bytes'] > 0 and bitmap['bytes'] % 8 == 0
            # Static storage size determines the word count; no guessed address
            # or read beyond the named runtime variable is permitted.
            bitmap['u64_words'] = bitmap['bytes'] // 8
            slots = set()
            rows = json.loads((base / 'symbols-v1-1/summary.json').read_text())['rows']
            for row in rows:
                previous = row.get('previous_instruction', {})
                operand = previous.get('operand', '')
                if previous.get('mnemonic') == 'call' and operand.startswith('*') and '(%rip)' in operand:
                    match = re.search(r'# ([0-9a-fA-F]+) <', operand)
                    if match:
                        slots.add(int(match[1], 16))
            relocations = []
            for section in elf.sections:
                if section['type'] != 4:
                    continue
                raw = elf.read_section(section)
                assert section['entry_size'] == 24 and len(raw) % 24 == 0
                for at in range(0, len(raw), 24):
                    address, info, addend = struct.unpack_from('<QQq', raw, at)
                    if address in slots:
                        relocations.append({'slot': address, 'type': info & 0xffffffff,
                                            'symbol_index': info >> 32, 'addend': addend,
                                            'is_counted_helper_relative_binding':
                                            info & 0xffffffff == 8 and info >> 32 == 0
                                            and addend == target['address']})
            assert len({row['slot'] for row in relocations}) == len(relocations)
            record = {'status': 'exact-ELF-data-and-relocation-bindings',
                      'binary_sha256': target['binary_sha256'], 'target': target,
                      'filter': bitmap, 'relocations': relocations, 'lock_owner': owner.strip(),
                      'script_sha256': sha(__file__), 'elf_reader_sha256': sha(base / 'metadata_census.py')}
            save(path, record)
            print(json.dumps(record, indent=2))
        finally:
            elf.file.close()
        return 0
    finally:
        assert (lock / 'owner').read_text() == owner
        (lock / 'owner').unlink()
        lock.rmdir()


if __name__ == '__main__':
    raise SystemExit(main())
