#!/usr/bin/env python3
"""Small local fixtures only; no perf command, native binary or child process."""
from collections import Counter
import csv
import gzip
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import profile_samples as p


APP = '/owned/app'
SYMBOL = 'perry_fn_fixture_hot'


def run_fixture():
    return {'pass': True, 'cleanup_errors': [],
            'sampling': 'cycles:u,999Hz,CLOCK_MONOTONIC,no callchains',
            'pid': 77, 'application': APP, 'application_sha256': 'a' * 64,
            'process': {'pid': 77, 'exe': APP, 'argv': [APP], 'start_ticks': 42},
            'pre_exec_process': {'start_ticks': 42},
            'phases': {'startup_begin_ns': 1_000_000_000, 'startup_end_ns': 2_000_000_000,
                       'command_begin_ns': 3_000_000_000, 'marker_ns': 3_900_000_000,
                       'command_end_ns': 4_000_000_000},
            'perf_control': {'exit': 0, 'errors': [],
                             'command': ['perf', 'record', '-e', 'cycles:u', '-F', '999', '-k', 'CLOCK_MONOTONIC'],
                             'handshakes': [{'command': 'enable', 'ack': 'ack', 'monotonic_ns': 900_000_000},
                                            {'command': 'disable', 'ack': 'ack', 'monotonic_ns': 4_100_000_000}]}}


def maps_fixture():
    return {'maps': f'00401000-00403000 r-xp 00001000 08:01 99 {APP}\n'
                    f'00408000-00409000 r--p 00006000 08:01 99 {APP}\n'}


def line(sec='1.500000000', period=13, symbol=SYMBOL + '+0x10', pid=77, tid=77, ip='401010', dso=APP):
    return f' {pid}/{tid} {sec}: {period} cycles:u: {ip} {symbol} ({dso})\n'


def metadata_fixture(directory):
    directory.mkdir()
    path = directory / 'functions.jsonl.gz'
    row = {'function_id': '0:0', 'address': '0x1000', 'stack_size': 64, 'record_count': 2,
           'root_count_distribution': {'2': 1, '3': 1},
           'exact_address_symbols': [{'name': SYMBOL, 'size': 200}]}
    with gzip.open(path, 'wt') as f:
        f.write(json.dumps(row) + '\n')
    summary = {'status': 'complete', 'format': 'PGCM', 'version': 5,
               'elf': {'inode': '99', 'device': str(0x801)},
               'gcmap_section': {'offset': 0x6100, 'address': 0x8100}, 'function_entries': 1,
               'files': {path.name: {'sha256': p.sha(path), 'bytes': path.stat().st_size}}}
    (directory / 'summary.json').write_text(json.dumps(summary))


class ProfileSamplesTests(unittest.TestCase):
    def test_exact_ns_period_and_symbol_offsets(self):
        r = p.parse_line(line(sec='12345.000000001', period=9_007_199_254_740_993), 1)
        self.assertEqual((r['time_ns'], r['period'], r['offset']), (12_345_000_000_001, 9_007_199_254_740_993, 16))
        self.assertEqual(p.parse_line(line(symbol='[unknown]'), 2)['unknown'], True)
        self.assertEqual(p.parse_line(line(symbol='core::Thing as Other::call+0x10'), 3)['symbol'], 'core::Thing as Other::call')

    def test_unsupported_truncated_callchain_and_loss_lines_rejected(self):
        for text in (line().rstrip('\n'), line(sec='1.123456'), line().replace('77/77', '77 77'),
                     line(symbol=SYMBOL), line(period=0), 'PERF_RECORD_LOST 42\n',
                     '    401000 callee+0x10 (/owned/app)\n', line().replace('13 cycles:u:', 'cycles:u: 13')):
            with self.subTest(text=text), self.assertRaises(p.InputError):
                p.parse_line(text, 1)

    def test_phase_boundaries_are_exact_half_open(self):
        b = p.validate_run(run_fixture())
        values = [999_999_999, 1_000_000_000, 1_999_999_999, 2_000_000_000,
                  2_999_999_999, 3_000_000_000, 3_999_999_999, 4_000_000_000]
        self.assertEqual([p.phase_at(x, b) for x in values],
                         ['before_startup', 'startup', 'startup', 'between_phases',
                          'between_phases', 'command', 'command', 'after_command'])

    def test_failed_or_wrong_clock_run_cannot_supply_phases(self):
        variants = []
        for key, value in [('pass', False), ('error', 'timeout'), ('cleanup_errors', ['live process']),
                           ('sampling', 'cycles:u,999Hz,CLOCK_REALTIME,no callchains')]:
            r = run_fixture(); r[key] = value; variants.append(r)
        r = run_fixture(); r['phases']['command_begin_ns'] = 1; variants.append(r)
        r = run_fixture(); r['phases']['startup_begin_ns'] = 1.0; variants.append(r)
        r = run_fixture(); r['perf_control']['errors'] = ['lost ack']; variants.append(r)
        r = run_fixture(); r['perf_control']['command'] += ['-g']; variants.append(r)
        for r in variants:
            with self.assertRaises(p.InputError):
                p.validate_run(r)

    def test_integer_totals_phase_scope_and_foreign_partition(self):
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            path = Path(tmp) / 'samples.txt'
            path.write_text(line('0.999999999', 2) + line('1.000000000', 3)
                            + line('1.999999999', 5, tid=78) + line('2.000000000', 7)
                            + line('3.000000000', 11) + line('3.500000000', 13, pid=88, tid=88)
                            + line('4.000000000', 17))
            r = p.collect(path, run_fixture(), p.parse_maps(maps_fixture()))
            self.assertEqual(dict(r['totals']), {'samples': 7, 'period': 58})
            self.assertEqual([r['phases'][name]['period'] for name in p.PHASES], [2, 8, 7, 24, 17])
            self.assertEqual(dict(r['scopes'][('command', 'foreign_pid')]), {'samples': 1, 'period': 13})
            self.assertEqual(dict(r['scopes'][('startup', 'other_target_thread')]), {'samples': 1, 'period': 5})

    def test_load_bias_uses_exact_section_byte_not_map_start_minus_offset(self):
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            directory = Path(tmp) / 'metadata'; metadata_fixture(directory)
            m = p.load_metadata(directory, p.parse_maps(maps_fixture()), run_fixture())
            self.assertEqual(m['bias'], 0x400000)
            self.assertNotEqual(m['bias'], 0x408000 - 0x6000)
            status, ip, rows = p.metadata_match(p.parse_line(line(), 1), m)
            self.assertEqual((status, ip, rows[0]['function_id']), ('exact_start_and_symbol', 0x1010, '0:0'))

    def test_metadata_mismatch_and_unresolved_symbols_stay_unbound(self):
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            directory = Path(tmp) / 'metadata'; metadata_fixture(directory)
            m = p.load_metadata(directory, p.parse_maps(maps_fixture()), run_fixture())
            row = p.parse_line(line(symbol='different+0x10'), 1)
            self.assertEqual(p.metadata_match(row, m)[0], 'address_present_symbol_mismatch')
            self.assertEqual(p.metadata_match(p.parse_line(line(symbol='[unknown]'), 1), m)[0], 'unknown_symbol_no_function_start')
            outside = p.parse_line(line(symbol=SYMBOL + '+0xc8', ip='4010c8'), 1)
            self.assertEqual(p.metadata_match(outside, m)[0], 'exact_symbol_but_size_unknown_or_ip_outside_symbol')
            bad = maps_fixture(); bad['maps'] = bad['maps'].replace('08:01 99', '08:01 100')
            with self.assertRaisesRegex(p.InputError, 'device/inode/path'):
                p.load_metadata(directory, p.parse_maps(bad), run_fixture())
            with gzip.open(directory / 'functions.jsonl.gz', 'at') as f:
                f.write('{}\n')
            with self.assertRaisesRegex(p.InputError, 'identity mismatch'):
                p.load_metadata(directory, p.parse_maps(maps_fixture()), run_fixture())

    def test_map_overlap_and_ambiguous_anchor_rejected(self):
        bad = maps_fixture(); bad['maps'] += f'00408100-00409000 r--p 00006000 08:01 99 {APP}\n'
        with self.assertRaises(p.InputError):
            p.parse_maps(bad)
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            directory = Path(tmp) / 'metadata'; metadata_fixture(directory)
            bad = maps_fixture(); bad['maps'] += f'00508000-00509000 r--p 00006000 08:01 99 {APP}\n'
            with self.assertRaisesRegex(p.InputError, 'unique'):
                p.load_metadata(directory, p.parse_maps(bad), run_fixture())

    def test_wrong_event_unmapped_app_and_empty_export_rejected(self):
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            path = Path(tmp) / 'samples.txt'
            for text in ('', line().replace('cycles:u:', 'instructions:u:'), line(ip='501010')):
                path.write_text(text)
                with self.assertRaises(p.InputError):
                    p.collect(path, run_fixture(), p.parse_maps(maps_fixture()))

    def test_self_and_joined_artifacts_reconcile_without_binary_reads(self):
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            base = Path(tmp)
            (base / 'run.json').write_text(json.dumps(run_fixture()))
            (base / 'maps.json').write_text(json.dumps(maps_fixture()))
            (base / 'samples.txt').write_text(line() + line('3.500000000', symbol='[unknown]', period=7))
            metadata_fixture(base / 'metadata')
            r = p.analyze(base / 'samples.txt', base / 'run.json', base / 'maps.json', base / 'out', base / 'metadata')
            self.assertEqual(r['totals'], {'samples': 2, 'period': 20})
            with (base / 'out/self.csv').open() as f:
                rows = list(csv.DictReader(f))
            self.assertEqual(sum(int(row['period']) for row in rows), 20)
            self.assertEqual({row['category'] for row in rows}, {'compiled_function_prefix', 'unknown_symbol'})
            with gzip.open(base / 'out/self-with-static-metadata.jsonl.gz', 'rt') as f:
                joined = [json.loads(line) for line in f]
            self.assertEqual(joined[0]['static_pgcm_entries'][0]['record_count'], 2)
            self.assertFalse(Path(APP).exists())
            with self.assertRaises(FileExistsError):
                p.analyze(base / 'samples.txt', base / 'run.json', base / 'maps.json', base / 'out')

    def test_multiple_sites_count_caller_self_once_and_ambiguity_stays_explicit(self):
        key = ('command', 'main_thread', 'compiled_function_prefix', APP, SYMBOL, 'exact_start_and_symbol', ('0:0',))
        selves = {key: Counter(samples=2, period=101)}
        c = {'definitions': {SYMBOL: {'attempt1'}},
             'targets': {SYMBOL: [{'hypothesis': 'new-local-user'}, {'hypothesis': 'new-local-user'},
                                 {'hypothesis': 'full-unique-visible-user'}]}}
        rows = p.join_coverage(selves, c)
        self.assertEqual(len(rows), 2)
        self.assertTrue(all(row['period'] == 101 for row in rows))
        c['definitions'][SYMBOL].add('attempt2')
        self.assertTrue(all(row['binding'] == 'ambiguous_multiple_emission_units' for row in p.join_coverage(selves, c)))

    def test_callsite_join_uses_complete_definition_population_including_zero_call_duplicates(self):
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            directory = Path(tmp)
            definitions = directory / 'definitions.csv'
            definitions.write_text('stage,attempt,symbol,linkage_scope,pre_root_mode\n'
                                   f'pre-rs4gc,A,{SYMBOL},visible,native\n'
                                   f'post-opt,A,{SYMBOL},visible,native\n'
                                   f'post-opt,B,{SYMBOL},unit-local,native\n')
            targets = directory / 'post-opt-hypothesis-targets.csv'
            targets.write_text('hypothesis,callee_identity,attempt,caller,statepoints,gc_live_operands\n'
                               f'direct-reviewed-runtime,helper,A,{SYMBOL},3,9\n')
            summary = {'status': 'complete-static-emission-census', 'helper_audit_sha256': 'a' * 64,
                       'outputs': {x.name: {'sha256': p.sha(x), 'bytes': x.stat().st_size} for x in (definitions, targets)}}
            (directory / 'summary.json').write_text(json.dumps(summary))
            c = p.load_callsites(directory, 'a' * 64)
            self.assertEqual(c['definitions'][SYMBOL], {'A', 'B'})
            self.assertEqual(c['targets'][SYMBOL][0]['statepoints'], 3)
            with self.assertRaisesRegex(p.InputError, 'helper-audit'):
                p.load_callsites(directory, 'b' * 64)
            targets.write_text(targets.read_text().replace(',3,9', ',30,90'))
            with self.assertRaisesRegex(p.InputError, 'identity mismatch'):
                p.load_callsites(directory, 'a' * 64)

    def test_sabotage_boundary_and_bias_checks_can_fail(self):
        with patch.object(p, 'phase_at', lambda stamp, bounds: 'startup'):
            with self.assertRaises(AssertionError):
                self.assertEqual(p.phase_at(3_500_000_000, p.validate_run(run_fixture())), 'command')
        with tempfile.TemporaryDirectory(prefix='profile-samples-fixture-') as tmp:
            directory = Path(tmp) / 'metadata'; metadata_fixture(directory)
            m = p.load_metadata(directory, p.parse_maps(maps_fixture()), run_fixture())
            m['bias'] += 0x2000  # plausible but wrong map-start-minus-offset result
            with self.assertRaises(AssertionError):
                self.assertEqual(p.metadata_match(p.parse_line(line(), 1), m)[0], 'exact_start_and_symbol')


if __name__ == '__main__':
    unittest.main()
