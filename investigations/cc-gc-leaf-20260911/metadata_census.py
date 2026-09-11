#!/usr/bin/env python3
"""Read bounded ELF metadata and decode the complete emitted PGCM v5 section.

Authorities: perry-codegen/src/gc_map.rs:705-822,1007-1117 and runtime
gc/roots/stack_maps_decode.rs + stack_maps_lazy.rs (RecordWalk/SlotIter).
No executable text reads, whole-binary hash, disassembler or runtime execution.
"""
import argparse
from collections import Counter
import gzip
import hashlib
import json
import os
from pathlib import Path
import struct
import sys

MAGIC = b'PGCM'
VERSION = 5
HEADER = struct.Struct('<4sBBHII')
FUNCTION64 = struct.Struct('<QII')
FUNCTION32 = struct.Struct('<III')
U32 = struct.Struct('<I')
U64 = struct.Struct('<Q')
ELF_HEADER = struct.Struct('<16sHHIQQQIHHHHHH')
SECTION = struct.Struct('<IIQQQQIIQQ')
SYMBOL = struct.Struct('<IBBHQQ')
RELA = struct.Struct('<QQq')
REL = struct.Struct('<QQ')
U64_MAX = (1 << 64) - 1


class FormatError(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise FormatError(message)


def unpack(fmt, data, offset, end=None):
    limit = len(data) if end is None else end
    require(0 <= offset <= limit and fmt.size <= limit - offset,
            f'truncated {fmt.format} at offset {offset:#x}, end {limit:#x}')
    return fmt.unpack_from(data, offset)


def varint(data, cursor, end):
    value = 0
    start = cursor
    for shift in range(0, 70, 7):
        require(cursor < end, f'truncated varint at {start:#x}')
        byte = data[cursor]
        cursor += 1
        require(shift != 63 or byte <= 1, f'varint exceeds u64 at {start:#x}')
        value |= (byte & 127) << shift
        if byte < 128:
            require(cursor - start == 1 or byte != 0,
                    f'noncanonical varint at {start:#x}')
            return value, cursor
    raise FormatError(f'varint exceeds ten bytes at {start:#x}')


def slots(data, cursor, end, count):
    require(count <= end - cursor, 'slot count exceeds remaining stream bytes')
    result = []
    previous = 0
    for _ in range(count):
        value, cursor = varint(data, cursor, end)
        tag = value & 3
        require(tag != 3 and value >> 2 <= 0xffffffff, 'invalid slot tag/delta width')
        if tag == 2:
            reg, cursor = varint(data, cursor, end)
            require(reg <= 0xffff, 'explicit DWARF register exceeds u16')
        else:
            # Literal AArch64 DWARF numbers even in x86 ELF, by source design.
            reg = (29, 31)[tag]
        zigzag = value >> 2
        delta = (zigzag >> 1) ^ -(zigzag & 1)
        previous = ((previous + delta + (1 << 31)) & 0xffffffff) - (1 << 31)
        result.append([reg, previous])
    return result, cursor


def decode_pgcm(data, pointer_bytes=8, on_function=None, on_record=None,
                on_payload=None, address_check=None, relocated_offsets=()):
    require(pointer_bytes in (4, 8), 'unsupported pointer width')
    function_format = FUNCTION64 if pointer_bytes == 8 else FUNCTION32
    totals = Counter({key: 0 for key in (
        'blobs', 'blob_bytes', 'padding_bytes', 'records', 'repeat_records',
        'function_entries', 'functions_with_records', 'payloads',
        'encoded_root_locations', 'encoded_derived_locations',
        'root_location_occurrences', 'derived_location_occurrences')})
    root_histogram = Counter()
    derived_histogram = Counter()
    function_addresses = set()
    address_slots = set()
    blobs = []
    base = 0
    while base < len(data):
        padding_start = base
        while base < len(data) and data[base] == 0:
            base += 1
        totals['padding_bytes'] += base - padding_start
        if base == len(data):
            break
        require(base % 8 == 0, f'PGCM blob is not 8-byte aligned at {base:#x}')
        magic, version, reserved, flags, fn_count, length = unpack(HEADER, data, base)
        require(magic == MAGIC, f'nonzero bytes outside PGCM blob at {base:#x}')
        require(version == VERSION, f'unsupported PGCM version {version}')
        require(reserved == 0 and flags in (0, 1), 'unsupported reserved byte/flags')
        require(bool(flags & 1) == (pointer_bytes == 8), 'PGCM/ELF pointer-width mismatch')
        end = base + length
        table = base + HEADER.size
        stream_offsets = table + fn_count * function_format.size
        instructions = stream_offsets + fn_count * U32.size
        require(HEADER.size <= length and instructions <= end <= len(data),
                f'invalid PGCM total_len/function table at {base:#x}')
        functions = [unpack(function_format, data, table + i * function_format.size, end)
                     for i in range(fn_count)]
        record_total = sum(f[2] for f in functions)
        stream_base = instructions + record_total * U32.size
        require(stream_base <= end, 'instruction-offset array exceeds blob')
        cursor = stream_base
        record_index = 0
        blob_id = totals['blobs']
        totals['blobs'] += 1
        totals['blob_bytes'] += length
        for fn_index, (address, stack_size, record_count) in enumerate(functions):
            address_slots.add(table + fn_index * function_format.size)
            recorded_offset, = unpack(U32, data, stream_offsets + fn_index * U32.size, end)
            require(stream_base + recorded_offset == cursor,
                    f'function stream offset mismatch in blob{blob_id}/function{fn_index}')
            if address_check:
                address_check(address, None)
            fn_id = f'{blob_id}:{fn_index}'
            previous_payload = None
            fn_roots = Counter()
            fn_derived = Counter()
            fn_repeat = 0
            pc_min = pc_max = None
            for ordinal in range(record_count):
                offset, = unpack(U32, data, instructions + record_index * U32.size, stream_base)
                record_index += 1
                pc = address + offset
                require(pc <= (1 << (8 * pointer_bytes)) - 1, 'return PC addition overflow')
                if address_check:
                    address_check(address, pc)
                payload_start = cursor
                word, cursor = varint(data, cursor, end)
                repeated = bool(word & 1)
                if repeated:
                    require(word == 1, 'repeat record is not encoder-canonical word1')
                    require(previous_payload is not None, 'first record of function repeats')
                    payload = previous_payload
                    totals['repeat_records'] += 1
                    fn_repeat += 1
                else:
                    root_count = word >> 2
                    require(root_count <= 0xffffffff, 'root count exceeds u32')
                    roots, cursor = slots(data, cursor, end, root_count)
                    derived = []
                    if word & 2:
                        count, cursor = varint(data, cursor, end)
                        require(0 < count <= 0xffffffff and count <= end - cursor,
                                'derived count empty, too wide or beyond remaining bytes')
                        bases = []
                        for _ in range(count):
                            index, cursor = varint(data, cursor, end)
                            require(index < root_count, 'derived base index outside this root list')
                            bases.append(index)
                        locations, cursor = slots(data, cursor, end, count)
                        derived = [[index, *loc] for index, loc in zip(bases, locations)]
                    payload = {'payload_id': f'{blob_id}:{payload_start - base}',
                               'section_offset': payload_start, 'roots': roots, 'derived': derived}
                    previous_payload = payload
                    totals['payloads'] += 1
                    totals['encoded_root_locations'] += len(roots)
                    totals['encoded_derived_locations'] += len(derived)
                    if on_payload:
                        on_payload(payload)
                nr, nd = len(payload['roots']), len(payload['derived'])
                totals['records'] += 1
                totals['root_location_occurrences'] += nr
                totals['derived_location_occurrences'] += nd
                fn_roots[nr] += 1
                fn_derived[nd] += 1
                root_histogram[nr] += 1
                derived_histogram[nd] += 1
                pc_min = pc if pc_min is None else min(pc_min, pc)
                pc_max = pc if pc_max is None else max(pc_max, pc)
                if on_record:
                    on_record({'function_id': fn_id, 'ordinal': ordinal,
                               'return_pc': hex(pc), 'function_address': hex(address),
                               'instruction_offset': offset, 'root_count': nr,
                               'derived_count': nd, 'payload_id': payload['payload_id'],
                               'repeat': repeated})
            totals['function_entries'] += 1
            totals['functions_with_records'] += bool(record_count)
            function_addresses.add(address)
            if on_function:
                on_function({'function_id': fn_id, 'blob': blob_id, 'function_index': fn_index,
                             'address': hex(address), 'stack_size': stack_size,
                             'record_count': record_count, 'repeat_records': fn_repeat,
                             'root_count_distribution': dict(sorted(fn_roots.items())),
                             'derived_count_distribution': dict(sorted(fn_derived.items())),
                             'root_location_occurrences': sum(n * count for n, count in fn_roots.items()),
                             'derived_location_occurrences': sum(n * count for n, count in fn_derived.items()),
                             'first_return_pc': hex(pc_min) if pc_min is not None else None,
                             'last_return_pc': hex(pc_max) if pc_max is not None else None})
        require(record_index == record_total and cursor == end,
                f'unconsumed or truncated record stream in blob{blob_id}: {cursor:#x} != {end:#x}')
        blobs.append({'blob': blob_id, 'section_offset': base, 'bytes': length,
                      'functions': fn_count, 'records': record_total,
                      'stream_bytes': end - stream_base})
        # Padding is validated explicitly by the next iteration (not skipped).
        base = end
    require(totals['blobs'] > 0, 'no PGCM blob found')
    require(set(relocated_offsets) <= address_slots,
            'relocation modifies a field other than a function-address word')
    require(totals['blob_bytes'] + totals['padding_bytes'] == len(data), 'section byte reconciliation failed')
    return {'format': 'PGCM', 'version': VERSION, 'pointer_bytes': pointer_bytes,
            'section_bytes': len(data), **dict(totals),
            'unique_function_addresses': len(function_addresses),
            'root_count_distribution': dict(sorted(root_histogram.items())),
            'derived_count_distribution': dict(sorted(derived_histogram.items())), 'blob_details': blobs}


def cstring(data, at):
    require(0 <= at < len(data), 'string-table offset out of bounds')
    end = data.find(b'\0', at)
    require(end >= 0, 'unterminated string-table entry')
    return data[at:end].decode('utf-8', errors='backslashreplace')


class ElfMetadata:
    def __init__(self, path):
        self.path = Path(path)
        self.file = self.path.open('rb')
        self.before = os.fstat(self.file.fileno())
        self.reads = []
        try:
            self._initialize()
        except BaseException:
            self.file.close()
            raise

    def _initialize(self):
        header = self.read(0, ELF_HEADER.size, 'ELF header')
        ident, self.kind, self.machine, version, _, _, shoff, _, ehsize, _, _, shsize, shnum, shnames = ELF_HEADER.unpack(header)
        require(ident[:7] == b'\x7fELF\x02\x01\x01' and version == 1,
                'requires ELF64 little-endian version1')
        require(self.kind in (2, 3), 'requires linked ET_EXEC or ET_DYN, not relocatable object')
        require(self.machine in (62, 183), 'unsupported ELF machine (requires x86_64 or AArch64)')
        require(ehsize == ELF_HEADER.size and shsize == SECTION.size and shoff >= ehsize,
                'unsupported ELF header/section entry sizes')
        first = SECTION.unpack(self.read(shoff, SECTION.size, 'section header0'))
        if shnum == 0:
            shnum = first[5]
        if shnames == 0xffff:
            shnames = first[6]
        require(shnum > 0 and shnames < shnum, 'invalid ELF section table counts')
        raw = self.read(shoff, shnum * SECTION.size, 'section headers')
        self.sections = []
        for i in range(shnum):
            name, typ, flags, addr, offset, size, link, info, align, entry = SECTION.unpack_from(raw, i * SECTION.size)
            self.sections.append({'index': i, 'name_offset': name, 'type': typ, 'flags': flags,
                                  'address': addr, 'offset': offset, 'size': size, 'link': link,
                                  'info': info, 'alignment': align, 'entry_size': entry})
        names_sec = self.sections[shnames]
        require(names_sec['type'] == 3, 'section-name table is not STRTAB')
        names = self.read_section(names_sec)
        for section in self.sections:
            section['name'] = cstring(names, section['name_offset'])
        maps = [s for s in self.sections if s['name'] == '.perry_gcmap']
        require(len(maps) == 1, 'expected one .perry_gcmap section')
        self.gcmap = maps[0]
        require(self.gcmap['type'] == 1 and self.gcmap['flags'] & 2 and self.gcmap['size'] > 0,
                'GC map must be nonempty allocated PROGBITS')
        require(self.gcmap['address'] % 8 == 0 and self.gcmap['offset'] % 8 == 0
                and self.gcmap['alignment'] >= 8, 'GC map lacks emitted eight-byte alignment')
        self.exec_ranges = [(s['address'], s['address'] + s['size']) for s in self.sections
                            if s['type'] == 1 and s['flags'] & 4 and s['flags'] & 2]

    def read(self, offset, size, purpose):
        require(0 <= offset <= self.before.st_size and 0 <= size <= self.before.st_size - offset,
                f'{purpose} lies outside ELF file')
        self.file.seek(offset)
        data = self.file.read(size)
        require(len(data) == size, f'short read of {purpose}')
        self.reads.append({'purpose': purpose, 'offset': hex(offset), 'bytes': size,
                           'sha256': hashlib.sha256(data).hexdigest()})
        return data

    def read_section(self, section):
        return self.read(section['offset'], section['size'], section.get('name', 'section names'))

    def symbols(self):
        tables = [s for s in self.sections if s['type'] == 2]
        require(tables, 'ELF has no full SYMTAB; do not substitute nearest symbol guesses')
        result = {}
        for table in tables:
            require(table['entry_size'] == SYMBOL.size and table['size'] % SYMBOL.size == 0,
                    'invalid ELF64 symbol entry size')
            require(table['link'] < len(self.sections), 'symbol string-table index out of range')
            strings = self.sections[table['link']]
            require(strings['type'] == 3, 'symbol names do not link to STRTAB')
            raw = self.read_section(table)
            names = self.read_section(strings)
            for at in range(0, len(raw), SYMBOL.size):
                name, info, other, section_index, address, size = SYMBOL.unpack_from(raw, at)
                if info & 15 != 2 or section_index == 0:
                    continue
                require(section_index != 0xffff, 'extended symbol section index unsupported')
                result.setdefault(address, []).append({'name': cstring(names, name),
                                                       'size': size, 'binding': info >> 4,
                                                       'visibility': other & 3})
        return result

    def resolved_map(self):
        raw = self.read_section(self.gcmap)
        data = bytearray(raw)
        start = self.gcmap['address']
        end = start + self.gcmap['size']
        relative_type = {62: 8, 183: 1027}[self.machine]
        relocated = {}
        # RELR requires a different decoder. Refuse it explicitly, even if a
        # particular image might not use it for this section.
        require(not any(s['type'] == 19 and s['size'] for s in self.sections),
                'packed RELR relocations present; unsupported, cannot prove map words')
        allowed = {'.rela.dyn', '.rel.dyn', '.rela.perry_gcmap', '.rel.perry_gcmap'}
        for sec in self.sections:
            if sec['type'] not in (4, 9) or sec['size'] == 0:
                continue
            if sec['name'] not in allowed:
                require(sec['info'] != self.gcmap['index'],
                        f'unsupported relocation section targets GC map: {sec["name"]}')
                require(0 < sec['info'] < len(self.sections),
                        f'uninspected relocation section has no distinct target: {sec["name"]}')
                continue
            fmt = RELA if sec['type'] == 4 else REL
            require(sec['entry_size'] == fmt.size and sec['size'] % fmt.size == 0,
                    'invalid relocation entry width')
            relbytes = self.read_section(sec)
            for at in range(0, len(relbytes), fmt.size):
                row = fmt.unpack_from(relbytes, at)
                address, info = row[:2]
                if address >= end or address + U64.size <= start:
                    continue
                require(address >= start, 'relocation partially overlaps start of GC map')
                offset = address - start
                require(offset + U64.size <= len(data) and offset not in relocated,
                        'overlapping/duplicate or truncated map relocation')
                require(info >> 32 == 0 and (info & 0xffffffff) == relative_type,
                        f'unsupported GC-map relocation type/symbol {info:#x}')
                old, = unpack(U64, data, offset)
                value = (row[2] & U64_MAX) if len(row) == 3 else old
                # Offline linked VMA: B=0. Runtime ASLR bias is deliberately
                # not applied; perf mmap normalization belongs to the caller.
                U64.pack_into(data, offset, value)
                relocated[offset] = {'section': sec['name'], 'raw': hex(old), 'linked_vma': hex(value)}
        return bytes(data), {'raw_sha256': hashlib.sha256(raw).hexdigest(),
                             'linked_vma_sha256': hashlib.sha256(data).hexdigest(),
                             'relative_relocations': len(relocated)}, relocated

    def check_address(self, address, pc):
        require(any(lo <= address < hi for lo, hi in self.exec_ranges),
                f'function word {address:#x} is outside executable sections')
        if pc is not None:
            require(any(lo <= address < hi and address <= pc <= hi for lo, hi in self.exec_ranges),
                    f'return PC {pc:#x} is outside function executable section')

    def identity(self):
        after = os.fstat(self.file.fileno())
        fields = ('st_dev', 'st_ino', 'st_size', 'st_mtime_ns', 'st_ctime_ns')
        require(all(getattr(self.before, k) == getattr(after, k) for k in fields),
                'ELF changed during metadata census')
        return {'path': str(self.path), 'size': after.st_size, 'inode': str(after.st_ino),
                'device': str(after.st_dev), 'mtime_ns': str(after.st_mtime_ns),
                'ctime_ns': str(after.st_ctime_ns), 'elf_type': self.kind,
                'machine': self.machine, 'whole_binary_hashed': False}


def jsonline(stream, row):
    stream.write(json.dumps(row, separators=(',', ':')) + '\n')


def run(path, output):
    output.mkdir(parents=True, exist_ok=False)
    elf = ElfMetadata(path)
    try:
        symbols = elf.symbols()
        data, section_identity, relocations = elf.resolved_map()
        unmapped = 0
        functions_path = output / 'functions.jsonl.gz'
        records_path = output / 'records.tsv.gz'
        payloads_path = output / 'payloads.jsonl.gz'
        with gzip.open(functions_path, 'wt', compresslevel=1) as functions, \
                gzip.open(records_path, 'wt', compresslevel=1) as records, \
                gzip.open(payloads_path, 'wt', compresslevel=1) as payloads:
            columns = ['function_id', 'ordinal', 'return_pc', 'function_address',
                       'instruction_offset', 'root_count', 'derived_count', 'payload_id', 'repeat']
            records.write('\t'.join(columns) + '\n')
            def function(row):
                nonlocal unmapped
                matches = symbols.get(int(row['address'], 16), [])
                row['exact_address_symbols'] = matches
                unmapped += not bool(matches)
                jsonline(functions, row)
            def record(row):
                records.write('\t'.join(str(int(row[c])) if c == 'repeat' else str(row[c])
                                        for c in columns) + '\n')
            result = decode_pgcm(data, on_function=function, on_record=record,
                                 on_payload=lambda row: jsonline(payloads, row),
                                 address_check=elf.check_address, relocated_offsets=relocations)
        result.update({'status': 'complete', 'elf': elf.identity(),
                       'gcmap_section': elf.gcmap, 'section_identity': section_identity,
                       'function_entries_without_exact_symbol': unmapped,
                       'read_receipts': elf.reads,
                       'bytes_read_including_repeated_header': sum(r['bytes'] for r in elf.reads),
                       'pc_coordinate': 'linked ELF virtual address; add verified runtime load bias for perf',
                       'counts_are': 'static map entries, preserving duplicate addresses and repeated live sets',
                       'locations_are': 'DWARF register plus signed frame offset; derived rows also name base index',
                       'files': {p.name: {'bytes': p.stat().st_size,
                                         'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
                                 for p in (functions_path, records_path, payloads_path)}})
        (output / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
        return result
    finally:
        elf.file.close()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--elf', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True, help='new owned directory; never overwritten')
    args = ap.parse_args()
    try:
        result = run(args.elf, args.output)
    except FileExistsError as exc:
        # In particular, never write failure.json into somebody else's or a
        # previously completed output directory after mkdir refuses it.
        print(str(exc), file=sys.stderr)
        return 2
    except (FormatError, OSError, struct.error) as exc:
        # Preserve partial gzip files but never publish a success summary.
        if args.output.is_dir() and not (args.output / 'summary.json').exists():
            (args.output / 'failure.json').write_text(json.dumps({'status': 'failed', 'error': str(exc)}) + '\n')
        print(str(exc), file=sys.stderr)
        return 2
    print(json.dumps({key: result[key] for key in ('section_bytes', 'blobs', 'function_entries',
                                                'records', 'root_location_occurrences',
                                                'derived_location_occurrences')}))
    return 0


if __name__ == '__main__':
    sys.exit(main())
