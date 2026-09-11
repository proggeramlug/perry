#!/usr/bin/env python3
"""Derive runtime self cost from the completed GC-leaf profiles, without reruns."""
from collections import Counter, defaultdict
import csv
import gzip
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
STUDY = HERE.parent / 'cc-gc-leaf-20260911'
sys.path.insert(0, str(STUDY))
from machine_loop_coverage import parse_disassembly


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def region_for(offset, regions):
    matches = [name for name, ranges in regions.items()
               if any(start <= offset < end for start, end in ranges)]
    if len(matches) != 1:
        raise ValueError(f'offset {offset} has {len(matches)} regions')
    return matches[0]


def require_equal(actual, expected):
    if actual != expected:
        raise ValueError('independent self/IP totals disagree')


def main():
    request = json.loads((HERE / 'disassembly-request.json').read_text())
    execution = json.loads((HERE / 'disassembly/execution.json').read_text())
    assert execution['status'] == 'complete'
    assert execution['binary_sha256'] == request['binary_sha256']
    assert execution['request_sha256'] == sha(HERE / 'disassembly-request.json')
    assert execution['script_sha256'] == sha(HERE / 'capture_disassembly.py')
    assert execution['elf_reader_sha256'] == sha(STUDY / 'metadata_census.py')
    for relative, digest in request['profile_inputs'].items():
        assert sha(HERE.parent.parent / relative) == digest, relative
    metric = json.loads((STUDY / 'results/report-metrics.json').read_text())
    names = {row['symbol']: row for row in execution['functions']}
    instructions = {}
    for function in execution['functions']:
        path = HERE / 'disassembly' / function['disassembly']
        assert sha(path) == function['sha256']
        aliases = [row['name'] for row in function['aliases']]
        found = []
        for name in aliases:
            try:
                found.append(parse_disassembly(path.read_text(), name))
            except ValueError as error:
                if not str(error).startswith('no instructions for exact symbol '):
                    raise
        assert len(found) == 1, (function['symbol'], len(found))
        rows = found[0]
        assert rows[0][0] == function['start']
        assert rows[-1][0] < function['start'] + function['size']
        instructions[function['symbol']] = {address: (mnemonic, operands)
                                             for address, mnemonic, operands in rows}

    focus = 'perry_runtime::gc::malloc::gc_malloc_header_is_tracked'
    function = names[focus]
    assert function['size'] == 367
    # These boundaries are observations of this exact 367-byte function.
    # They are not a generic classifier, emitted constants, or an optimization.
    regions = {'entry_return': [[0, 22], [283, 296]],
               'tls_resolution': [[22, 86], [296, 344]],
               'borrow_and_ensure_dispatch': [[86, 112], [278, 283], [344, 367]],
               'hash_lookup': [[112, 278]]}
    for offset in range(function['size']):
        region_for(offset, regions)
    for ranges in regions.values():
        for start, end in ranges:
            assert function['start'] + start in instructions[focus]
            assert end == function['size'] or function['start'] + end in instructions[focus]

    totals = defaultdict(Counter)
    symbols = defaultdict(Counter)
    per_row = []
    points = defaultdict(Counter)
    inputs = {}
    for index in range(1, 4):
        root = STUDY / 'results' / f'profile-{index}'
        self_path, ip_path = root / 'self.csv', root / 'by-ip.csv.gz'
        for path in [self_path, ip_path, root / 'summary.json',
                     root / 'perf-self-reconciliation.json', root / 'run.json']:
            inputs[str(path.relative_to(HERE.parent))] = sha(path)
        run = json.loads((root / 'run.json').read_text())
        assert run['pass']
        assert json.loads((root / 'perf-self-reconciliation.json').read_text())['status'] == 'PASS'
        expected = Counter()
        with self_path.open(newline='') as stream:
            for row in csv.DictReader(stream):
                if row['phase'] not in ('startup', 'command') or row['scope'] == 'foreign_pid':
                    continue
                key = (row['phase'], row['scope'], row['dso'], row['symbol'])
                for field in ('samples', 'period'):
                    expected[(key, field)] += int(row[field])
                    totals[row['phase']][field] += int(row[field])
                    symbols[(row['phase'], row['symbol'])][field] += int(row[field])
        actual = Counter()
        with gzip.open(ip_path, 'rt', newline='') as stream:
            for row in csv.DictReader(stream):
                if row['phase'] not in ('startup', 'command') or row['scope'] == 'foreign_pid':
                    continue
                key = (row['phase'], row['scope'], row['dso'], row['symbol'])
                for field in ('samples', 'period'):
                    actual[(key, field)] += int(row[field])
                if row['symbol'] not in names:
                    continue
                function = names[row['symbol']]
                address = int(row['linked_ip'], 16)
                assert address - int(row['symbol_offset']) == function['start']
                assert address in instructions[row['symbol']], (row['symbol'], hex(address))
                assert row['dso'] == request['binary']
                points[(row['phase'], row['symbol'], address)].update(
                    samples=int(row['samples']), period=int(row['period']))
        require_equal(actual, expected)
        # The reconciliation must reject a one-period deletion from real data.
        sabotage = actual.copy()
        key = next(key for key in sabotage if key[1] == 'period')
        sabotage[key] -= 1
        try:
            require_equal(sabotage, expected)
        except ValueError:
            pass
        else:
            raise AssertionError('one-period deletion was accepted')
        row_totals = defaultdict(Counter)
        row_focus = defaultdict(Counter)
        for (key, field), value in expected.items():
            row_totals[key[0]][field] += value
            if key[3] == focus:
                row_focus[key[0]][field] += value
        per_row.append({'row': index, 'phase_totals': dict(row_totals),
                        'focus': {phase: {**value, 'phase_percent':
                                  100 * value['period'] / row_totals[phase]['period']}
                                  for phase, value in row_focus.items()},
                        'exact_self_ip_reconciliation': 'PASS',
                        'one_period_deletion_rejected': True})
    require_equal(dict(totals), metric['phase_target_totals'])
    region_totals = defaultdict(Counter)
    for (phase, symbol, address), values in points.items():
        if symbol == focus:
            region_totals[(phase, region_for(address - names[focus]['start'], regions))].update(values)
    for phase in totals:
        require_equal(sum(value['period'] for (p, _), value in region_totals.items() if p == phase),
                      symbols[(phase, focus)]['period'])
    negative_regions = {**regions, 'duplicate': [[0, 22]]}
    try:
        region_for(0, negative_regions)
    except ValueError:
        pass
    else:
        raise AssertionError('ambiguous region was accepted')

    output = HERE / 'results'
    output.mkdir(exist_ok=True)
    symbol_rows = [{'phase': phase, 'symbol': symbol, **value,
                    'phase_percent': 100 * value['period'] / totals[phase]['period']}
                   for (phase, symbol), value in symbols.items()]
    symbol_rows.sort(key=lambda row: (row['phase'], -row['period'], row['symbol']))
    with (output / 'self-ranked.csv').open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=['phase', 'symbol', 'samples', 'period', 'phase_percent'],
                                lineterminator='\n')
        writer.writeheader()
        writer.writerows(symbol_rows)
    with (output / 'selected-instructions.csv').open('w', newline='') as stream:
        writer = csv.writer(stream, lineterminator='\n')
        writer.writerow(['phase', 'symbol', 'linked_ip', 'symbol_offset', 'instruction',
                         'samples', 'period', 'phase_percent', 'focus_region'])
        for (phase, symbol, address), value in sorted(points.items()):
            writer.writerow([phase, symbol, hex(address), address - names[symbol]['start'],
                             ' '.join(instructions[symbol][address]), value['samples'], value['period'],
                             100 * value['period'] / totals[phase]['period'],
                             region_for(address - names[symbol]['start'], regions) if symbol == focus else ''])
    result = {'status': 'complete-derived-runtime-self-analysis', 'prior_goal_turn': 'progress',
              'scope': 'existing profile samples and exact disassembly; no new workload or source optimization',
              'binary_sha256': request['binary_sha256'], 'phase_totals': dict(totals), 'per_row': per_row,
              'top20': {phase: [row for row in symbol_rows if row['phase'] == phase][:20] for phase in totals},
              'selected_helpers': [row for row in symbol_rows if row['symbol'] in names],
              'focus_region_ranges': regions,
              'focus_regions': [{'phase': phase, 'region': region, **value,
                                 'phase_percent': 100 * value['period'] / totals[phase]['period'],
                                 'focus_percent': 100 * value['period'] / symbols[(phase, focus)]['period']}
                                for (phase, region), value in sorted(region_totals.items())],
              'ambiguous_region_control': 'rejected',
              'inputs': inputs, 'analyzer_sha256': sha(__file__),
              'disassembly_receipt_sha256': sha(HERE / 'disassembly/execution.json'),
              'outputs': {name: sha(output / name)
                          for name in ['self-ranked.csv', 'selected-instructions.csv']}}
    (output / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'status': result['status'], 'symbols': len(symbol_rows),
                      'selected_sampled_instructions': len(points),
                      'focus_regions': result['focus_regions'], 'per_row': per_row}, indent=2))


if __name__ == '__main__':
    main()
