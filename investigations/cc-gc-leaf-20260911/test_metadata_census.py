#!/usr/bin/env python3
"""Small exact-byte PGCM/ELF witnesses, including format corruption controls."""
from pathlib import Path
import struct
import tempfile
import unittest
from unittest.mock import patch
import metadata_census as census


def blob(functions, instruction_offsets, stream_offsets, stream, ptr64=True):
    table = b''.join(struct.pack('<QII' if ptr64 else '<III', *f) for f in functions)
    offsets = b''.join(struct.pack('<I', n) for n in stream_offsets)
    pcs = b''.join(struct.pack('<I', n) for n in instruction_offsets)
    rest = table + offsets + pcs + stream
    return struct.pack('<4sBBHII', b'PGCM', 5, 0, int(ptr64), len(functions), 16 + len(rest)) + rest


def golden():
    # Independent explicit encoding: roots29:-8,31:16,7:-24; derived(base2,7:-16).
    # Followed by repeat, empty roots, then next function's root29:-16.
    first = blob([(0x1000, 64, 3), (0x1000, 32, 1), (0x2000, 0, 0)],
                 [0x10, 0x20, 0x30, 0x10], [0, 13, 15],
                 bytes.fromhex('0e 3c c1 01 be 02 07 01 02 7e 07 01 00 04 7c'))
    second = blob([(0x3000, 16, 1)], [8], [0], bytes.fromhex('04 01'))
    return first + b'\0' * ((-len(first)) % 8) + second


def elf_fixture(path, map_bytes, relative=True, relocation_type=8):
    """Small linked ELF64 with bounded sections; no compiler/linker invocation."""
    names = b'\0.shstrtab\0.text\0.perry_gcmap\0.strtab\0.symtab\0.rela.dyn\0'
    strings = b'\0one\0empty\0three\0one_alias\0'
    sym = b'\0' * 24
    for name, address, size in [('one', 0x1000, 0x100), ('empty', 0x2000, 0x100),
                                ('three', 0x3000, 0x100), ('one_alias', 0x1000, 0x100)]:
        sym += struct.pack('<IBBHQQ', strings.index(name.encode()), 0x12, 0, 2, address, size)
    data = bytearray(map_bytes)
    relocs = b''
    if relative:
        # Only first function's on-disk address is zero; explicit addend binds it.
        struct.pack_into('<Q', data, 16, 0)
        relocs = struct.pack('<QQq', 0x5000 + 16, relocation_type, 0x1000)
    sections = [('', 0, 0, 0, b'', 0, 0, 0),
                ('.shstrtab', 3, 0, 0, names, 0, 1, 0),
                ('.text', 1, 6, 0x1000, b'T' * 0x2200, 0, 16, 0),
                ('.perry_gcmap', 1, 3, 0x5000, bytes(data), 0, 8, 0),
                ('.strtab', 3, 0, 0, strings, 0, 1, 0),
                ('.symtab', 2, 0, 0, sym, 4, 8, 24),
                ('.rela.dyn', 4, 2, 0x7000, relocs, 0, 8, 24)]
    body = bytearray(b'\0' * 64)
    headers = []
    for name, typ, flags, address, payload, link, align, entry in sections:
        body.extend(b'\0' * ((-len(body)) % max(align, 1)))
        offset = len(body)
        body.extend(payload)
        headers.append(struct.pack('<IIQQQQIIQQ', names.index(name.encode()) if name else 0,
                                   typ, flags, address, offset, len(payload), link, 0, align, entry))
    body.extend(b'\0' * ((-len(body)) % 8))
    shoff = len(body)
    body.extend(b''.join(headers))
    ident = b'\x7fELF\x02\x01\x01' + b'\0' * 9
    body[:64] = struct.pack('<16sHHIQQQIHHHHHH', ident, 3, 62, 1, 0, 0, shoff, 0,
                           64, 0, 0, 64, len(headers), 1)
    path.write_bytes(body)
    return sections


class MetadataTests(unittest.TestCase):
    def test_exact_concatenated_counts_payloads_and_duplicate_pcs(self):
        functions, records, payloads = [], [], []
        r = census.decode_pgcm(golden(), on_function=functions.append,
                               on_record=records.append, on_payload=payloads.append)
        self.assertEqual((r['blobs'], r['section_bytes'], r['padding_bytes']), (2, 154, 5))
        self.assertEqual((r['function_entries'], r['functions_with_records'],
                          r['unique_function_addresses']), (4, 3, 3))
        self.assertEqual((r['records'], r['payloads'], r['repeat_records']), (5, 4, 1))
        self.assertEqual((r['root_location_occurrences'], r['derived_location_occurrences']), (8, 2))
        self.assertEqual((r['encoded_root_locations'], r['encoded_derived_locations']), (5, 1))
        self.assertEqual(r['root_count_distribution'], {0: 1, 1: 2, 3: 2})
        self.assertEqual(payloads[0]['roots'], [[29, -8], [31, 16], [7, -24]])
        self.assertEqual(payloads[0]['derived'], [[2, 7, -16]])
        self.assertEqual(records[0]['payload_id'], records[1]['payload_id'])
        self.assertEqual([x['return_pc'] for x in records], ['0x1010', '0x1020', '0x1030', '0x1010', '0x3008'])
        self.assertEqual(functions[2]['record_count'], 0)

    def test_32_bit_function_entry_width_and_mismatch(self):
        b = blob([(0x1000, 8, 1)], [4], [0], b'\x04\x00', ptr64=False)
        self.assertEqual(census.decode_pgcm(b, 4)['root_location_occurrences'], 1)
        with self.assertRaisesRegex(census.FormatError, 'width'):
            census.decode_pgcm(b, 8)

    def test_header_and_table_corruptions_fail(self):
        for offset, value, fmt in [(4, 4, '<B'), (5, 1, '<B'), (6, 3, '<H'),
                                   (12, 0, '<I'), (8, 0xffffffff, '<I'), (68, 12, '<I')]:
            with self.subTest(offset=offset):
                b = bytearray(golden())
                struct.pack_into(fmt, b, offset, value)
                with self.assertRaises(census.FormatError):
                    census.decode_pgcm(b)

    def test_repeat_does_not_cross_function_boundary(self):
        b = blob([(0x1000, 8, 1), (0x2000, 8, 1)], [4, 4], [0, 2], b'\x04\x00\x01')
        with self.assertRaisesRegex(census.FormatError, 'first record'):
            census.decode_pgcm(b)

    def test_derived_base_and_slot_corruption_fail(self):
        for stream in [b'\x01', b'\x03', b'\x04\x03', b'\x06\x00\x01\x01\x00',
                       b'\x04\x02\x80\x80\x04', b'\x06\x00\x00', b'\x80' * 10,
                       b'\x80\x00', b'\xff' * 9 + b'\x02']:
            with self.subTest(stream=stream.hex()):
                with self.assertRaises(census.FormatError):
                    census.decode_pgcm(blob([(0x1000, 8, 1)], [4], [0], stream))

    def test_nonzero_padding_tail_and_unconsumed_stream_fail(self):
        b = bytearray(golden())
        b[107] = 5
        for bad in [bytes(b), golden() + b'X',
                    blob([(0x1000, 8, 1)], [4], [0], b'\x00\x00')]:
            with self.assertRaises(census.FormatError):
                census.decode_pgcm(bad)

    def test_truncated_at_each_final_record_byte_fails(self):
        b = golden()
        for count in range(1, 10):
            with self.subTest(count=count), self.assertRaises(census.FormatError):
                census.decode_pgcm(b[:-count])

    def test_64bit_pc_overflow_and_nonaddress_relocation_fail(self):
        b = blob([(0xffffffffffffffff, 8, 1)], [4], [0], b'\x00')
        with self.assertRaisesRegex(census.FormatError, 'overflow'):
            census.decode_pgcm(b)
        with self.assertRaisesRegex(census.FormatError, 'other than'):
            census.decode_pgcm(golden(), relocated_offsets=[20])

    def test_elf_relative_relocation_symbol_aliases_and_bounded_reads(self):
        with tempfile.TemporaryDirectory(prefix='pgcm-census-fixture-') as tmp:
            p = Path(tmp) / 'fixture.elf'
            elf_fixture(p, golden())
            r = census.run(p, Path(tmp) / 'output')
            self.assertEqual(r['records'], 5)
            self.assertEqual(r['section_identity']['relative_relocations'], 1)
            self.assertEqual(r['function_entries_without_exact_symbol'], 0)
            self.assertFalse(any(x['purpose'] == '.text' for x in r['read_receipts']))
            import gzip, json
            with gzip.open(Path(tmp) / 'output/functions.jsonl.gz', 'rt') as f:
                fn = json.loads(next(f))
            self.assertEqual({x['name'] for x in fn['exact_address_symbols']}, {'one', 'one_alias'})
            self.assertNotEqual(r['section_identity']['raw_sha256'], r['section_identity']['linked_vma_sha256'])

    def test_unsupported_relocation_and_unresolved_address_fail(self):
        with tempfile.TemporaryDirectory(prefix='pgcm-census-fixture-') as tmp:
            p = Path(tmp) / 'fixture.elf'
            elf_fixture(p, golden(), relocation_type=1)
            with self.assertRaisesRegex(census.FormatError, 'unsupported GC-map relocation'):
                census.run(p, Path(tmp) / 'badreloc')
            b = bytearray(golden())
            struct.pack_into('<Q', b, 16, 0)
            elf_fixture(p, b, relative=False)
            with self.assertRaisesRegex(census.FormatError, 'outside executable'):
                census.run(p, Path(tmp) / 'badaddress')

    def test_elf_header_and_symbol_table_bounds_fail(self):
        with tempfile.TemporaryDirectory(prefix='pgcm-census-fixture-') as tmp:
            p = Path(tmp) / 'fixture.elf'
            elf_fixture(p, golden())
            original = p.read_bytes()
            shoff, = struct.unpack_from('<Q', original, 40)
            edits = [(5, 2, '<B'), (16, 1, '<H'), (40, len(original), '<Q'),
                     (shoff + 5 * 64 + 56, 16, '<Q')]
            for ordinal, (at, value, fmt) in enumerate(edits):
                broken = bytearray(original)
                struct.pack_into(fmt, broken, at, value)
                p.write_bytes(broken)
                with self.subTest(ordinal=ordinal), self.assertRaises(census.FormatError):
                    census.run(p, Path(tmp) / str(ordinal))

    def test_existing_output_is_not_overwritten(self):
        with tempfile.TemporaryDirectory(prefix='pgcm-census-fixture-') as tmp:
            out = Path(tmp) / 'existing'
            out.mkdir()
            marker = out / 'owned.txt'
            marker.write_text('preserve')
            with self.assertRaises(FileExistsError):
                census.run(Path(tmp) / 'missing.elf', out)
            self.assertEqual(marker.read_text(), 'preserve')
            self.assertEqual(len(list(out.iterdir())), 1)

    def test_sabotage_version_check_and_count_expectation_are_fail_capable(self):
        with patch.object(census, 'VERSION', 4):
            with self.assertRaisesRegex(census.FormatError, 'version'):
                census.decode_pgcm(golden())
        b = bytearray(golden())
        # Valid stream change: replacing the repeat with an empty live set
        # changes logical occurrences by3 without changing total bytes.
        b[103] = 0
        r = census.decode_pgcm(b)
        with self.assertRaises(AssertionError):
            self.assertEqual(r['root_location_occurrences'], 8)
        self.assertEqual(r['root_location_occurrences'], 5)


if __name__ == '__main__':
    unittest.main()
