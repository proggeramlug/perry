#!/usr/bin/env python3
from pathlib import Path
from collections import Counter, defaultdict
import csv
import hashlib
import json
import re

from probe_census_v2 import parse_maps, validate_counts

BASE = Path(__file__).resolve().parent
RAW = BASE / 'raw'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    aggregate = defaultdict(Counter)
    binding_counts = Counter()
    per_row, field_sites = [], []
    inputs = {}
    bindings = json.loads((RAW / 'bindings-v1.json').read_text())
    for index in (1, 2, 3):
        root = RAW / f'cc-row-v1-{index}'
        run = json.loads((root / 'run.json').read_text())
        execution = json.loads((RAW / f'cc-row-v1-{index}.execution.json').read_text())
        assert execution['status'] == 'complete' and run['pass']
        assert run['cleanup_errors'] == [] and 'error' not in run
        assert run['application_sha256'] == bindings['binary_sha256']
        counts = json.loads((root / 'counts.json').read_text())
        assert validate_counts(parse_maps(root / 'bpf.jsonl')) == counts
        for name, digest in execution['inputs'].items():
            assert sha(RAW / name) == digest, name
        symbols_path = RAW / f'symbols-v2-{index}/summary.json'
        symbols = json.loads(symbols_path.read_text())
        assert symbols['status'] == 'complete-conservative-return-continuation-join'
        assert symbols['binary_sha256'] == bindings['binary_sha256']
        assert symbols['got_bindings_sha256'] == sha(RAW / 'bindings-v1.json')
        for name, digest in symbols['inputs'].items():
            assert sha(root / name) == digest
        for owner in symbols['owners']:
            assert sha(symbols_path.parent / owner['disassembly']) == owner['sha256']
        lookup = {(r['phase'], r['return_pc']): r for r in counts['rows']}
        assert len(lookup) == len(symbols['rows'])
        for row in symbols['rows']:
            assert all(row[key] == value for key, value in lookup[(row['phase'], row['return_pc'])].items())
            binding_counts[row.get('call_binding', row['binding'])] += row['entries']
            name = re.sub(r'perry_runtime\[[0-9a-f]+\]::', 'perry_runtime::',
                          row.get('owner_demangled', row.get('owner_symbol', row['binding'])))
            aggregate[(row['phase'], name)].update({key: row[key] for key in
                ['entries', 'true', 'false', 'same_address_as_previous_at_site']})
            if row['phase'] == 3 and name == 'js_object_get_field_by_name':
                field_sites.append({'row': index, 'offset': row['owner_offset'],
                                    'entries': row['entries'], 'true': row['true'],
                                    'false': row['false'], 'call_binding': row['call_binding']})
        phases = {}
        for phase in (1, 3):
            rows = [r for r in counts['rows'] if r['phase'] == phase]
            total = sum(r['entries'] for r in rows)
            assert total == counts['total_entries'][str(phase)]
            phases[str(phase)] = {'entries': total, 'true': sum(r['true'] for r in rows),
                                  'false': sum(r['false'] for r in rows),
                                  'same_address_as_previous_at_site': sum(r['same_address_as_previous_at_site'] for r in rows)}
        per_row.append({'row': index, 'phases': phases, 'max_depth': counts['max_depth'],
                        'instrumented_cpu': run['instrumented_cpu']})
        for p in [root / 'run.json', root / 'counts.json', symbols_path]:
            inputs[str(p.relative_to(RAW))] = sha(p)
    phase_totals = defaultdict(Counter)
    for (phase, name), values in aggregate.items():
        phase_totals[phase].update(values)
    ranking = []
    for (phase, name), values in aggregate.items():
        ranking.append({'phase': phase, 'caller_body': name, **values,
                        'entry_share_percent': 100 * values['entries'] / phase_totals[phase]['entries'],
                        'negative_percent': 100 * values['false'] / values['entries']})
    ranking.sort(key=lambda r: (r['phase'], -r['entries'], r['caller_body']))
    observations = json.loads((RAW / 'filter-observation-v1.execution.json').read_text())
    assert observations['status'] == 'complete'
    for name, digest in observations['inputs'].items():
        assert sha(RAW / name) == digest
    filter_rows = []
    for index in (1, 2, 3):
        root = RAW / f'filter-row-v1-{index}'
        run = json.loads((root / 'run.json').read_text())
        assert run['pass'] and run['cleanup_errors'] == []
        assert run['application_sha256'] == bindings['binary_sha256']
        snapshots = json.loads((root / 'filter-snapshots.json').read_text())
        assert [r['phase'] for r in snapshots] == [1, 2, 3, 4]
        for snap in snapshots[1:]:
            assert snap['capacity_bits'] == bindings['filter']['bytes'] * 8
            assert sum(snap['per_word_bits_set']) == snap['bits_set']
            assert snap['all_bits_set'] == (snap['bits_set'] == snap['capacity_bits'])
        filter_rows.append({'row': index, 'bits_set_by_phase': [r.get('bits_set') for r in snapshots],
                            'capacity_bits': snapshots[-1]['capacity_bits'],
                            'observed_cpu': run['instrumented_cpu']})
        inputs[str((root / 'run.json').relative_to(RAW))] = sha(root / 'run.json')
        inputs[str((root / 'filter-snapshots.json').relative_to(RAW))] = sha(root / 'filter-snapshots.json')
    output = BASE / 'results'
    output.mkdir(exist_ok=True)
    with (output / 'caller-ranking.csv').open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(ranking[0]), lineterminator='\n')
        writer.writeheader()
        writer.writerows(ranking)
    with (output / 'property-getter-sites.csv').open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(field_sites[0]), lineterminator='\n')
        writer.writeheader()
        writer.writerows(sorted(field_sites, key=lambda r: (r['row'], r['offset'])))
    summary = {'status': 'complete-runtime-caller-census-analysis',
               'binary_sha256': bindings['binary_sha256'], 'per_row': per_row,
               'phase_totals': dict(phase_totals), 'call_binding_entries': dict(binding_counts),
               'top20_command': [r for r in ranking if r['phase'] == 3][:20],
               'filter_rows_without_BPF': filter_rows, 'source_inputs': inputs,
               'analyzer_sha256': sha(__file__), 'outputs': {name: sha(output / name)
                   for name in ['caller-ranking.csv', 'property-getter-sites.csv']}}
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({k: summary[k] for k in ['status', 'per_row', 'phase_totals',
                                             'call_binding_entries', 'filter_rows_without_BPF']}, indent=2))
    for row in summary['top20_command']:
        print(row['entries'], round(row['entry_share_percent'], 3), row['true'], row['caller_body'])


if __name__ == '__main__':
    main()
