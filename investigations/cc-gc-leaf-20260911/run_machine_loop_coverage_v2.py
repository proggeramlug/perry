#!/usr/bin/env python3
"""Analyze exact GC-call loop coverage in the 20 hottest candidate callers."""
import argparse
from collections import Counter, defaultdict
import csv
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
from machine_loop_coverage import analyze, locate_ip, parse_disassembly


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--elf', type=Path, required=True)
    ap.add_argument('--compile-receipt', type=Path, required=True)
    ap.add_argument('--metadata', type=Path, required=True)
    ap.add_argument('--callsites', type=Path, required=True)
    ap.add_argument('--profile', type=Path, action='append', required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    args.out.mkdir()
    binding = json.loads(args.compile_receipt.read_text())
    assert sha(args.elf) == binding['application_sha256']
    inputs = {str(args.compile_receipt): sha(args.compile_receipt)}
    census = json.loads((args.callsites / 'summary.json').read_text())
    for name in ('definitions.csv', 'post-opt-hypothesis-targets.csv'):
        assert sha(args.callsites / name) == census['outputs'][name]['sha256']
    definitions = defaultdict(set)
    with (args.callsites / 'definitions.csv').open() as stream:
        for row in csv.DictReader(stream):
            if row['stage'] == 'post-opt':
                definitions[row['symbol']].add(row['attempt'])
    caller_targets = defaultdict(set)
    caller_static_points = Counter()
    with (args.callsites / 'post-opt-hypothesis-targets.csv').open() as stream:
        for row in csv.DictReader(stream):
            if row['hypothesis'] == 'direct-all-runtime-leaves' and int(row['statepoints']):
                caller_targets[row['caller']].add(row['callee_identity'])
                caller_static_points[row['caller']] += int(row['statepoints'])
    profiles, totals, caller_periods = [], defaultdict(Counter), Counter()
    for directory in args.profile:
        summary = json.loads((directory / 'summary.json').read_text())
        assert summary['application'] == str(args.elf)
        assert summary['application_sha256'] == binding['application_sha256']
        path = directory / 'by-ip.csv.gz'
        assert sha(path) == summary['outputs'][path.name]['sha256']
        inputs[str(path)] = sha(path)
        with gzip.open(path, 'rt') as stream:
            for row in csv.DictReader(stream):
                if row['scope'] == 'foreign_pid' or row['phase'] not in ('startup', 'command'):
                    continue
                row['samples'], row['period'] = int(row['samples']), int(row['period'])
                totals[row['phase']].update(samples=row['samples'], period=row['period'])
                if (row['dso'] == str(args.elf) and row['metadata_join'] == 'exact_start_and_symbol'
                        and row['symbol'] in caller_targets and len(definitions[row['symbol']]) == 1):
                    profiles.append(row)
                    caller_periods[row['symbol']] += row['period']
    selected = [name for name, _ in caller_periods.most_common(20)]
    metadata_summary = json.loads((args.metadata / 'summary.json').read_text())
    by_symbol = defaultdict(list)
    for name in ('functions.jsonl.gz', 'records.tsv.gz'):
        assert sha(args.metadata / name) == metadata_summary['files'][name]['sha256']
    with gzip.open(args.metadata / 'functions.jsonl.gz', 'rt') as stream:
        for line in stream:
            row = json.loads(line)
            for symbol in row['exact_address_symbols']:
                if symbol['name'] in selected:
                    by_symbol[symbol['name']].append((row, symbol))
    function_ids = {rows[0][0]['function_id'] for rows in by_symbol.values() if len(rows) == 1}
    return_pcs = defaultdict(set)
    with gzip.open(args.metadata / 'records.tsv.gz', 'rt') as stream:
        for row in csv.DictReader(stream, delimiter='\t'):
            if row['function_id'] in function_ids:
                return_pcs[row['function_id']].add(int(row['return_pc'], 16))
    results, rejected, coverage = [], [], defaultdict(Counter)
    for ordinal, symbol in enumerate(selected):
        matches = by_symbol.get(symbol, [])
        if len(matches) != 1 or matches[0][1]['size'] <= 0:
            rejected.append({'symbol': symbol, 'reason': 'no unique sized PGCM/ELF symbol'})
            continue
        function, entry = matches[0]
        command = ['objdump', '-d', '--no-show-raw-insn', '--disassemble=' + symbol, str(args.elf)]
        output = args.out / f'function-{ordinal:02}.asm'
        with output.open('x') as stream, (args.out / f'function-{ordinal:02}.stderr').open('x') as err:
            subprocess.run(command, stdout=stream, stderr=err, check=True)
        try:
            instructions = parse_disassembly(output.read_text(), symbol)
            assert instructions[0][0] == int(function['address'], 16)
            result = analyze(instructions, int(function['address'], 16) + entry['size'],
                             return_pcs[function['function_id']], caller_targets[symbol])
            if not result['calls']:
                raise ValueError('no candidate direct call bound to an exact GC return PC; unresolved, not zero opportunity')
        except (ValueError, AssertionError) as error:
            rejected.append({'symbol': symbol, 'reason': str(error), 'disassembly': output.name})
            continue
        phases = defaultdict(Counter)
        for row in profiles:
            if row['symbol'] != symbol:
                continue
            located = locate_ip(result, int(row['linked_ip'], 16))
            for kind in ('caller', 'candidate_call', 'candidate_loop', 'candidate_block'):
                if kind == 'caller' or located[kind]:
                    phases[row['phase']][kind + '_period'] += row['period']
                    phases[row['phase']][kind + '_samples'] += row['samples']
                    coverage[row['phase']][kind + '_period'] += row['period']
                    coverage[row['phase']][kind + '_samples'] += row['samples']
        results.append({'symbol': symbol, 'function_id': function['function_id'],
                        'address': function['address'], 'size': entry['size'],
                        'gc_record_count': function['record_count'], 'calls': result['calls'],
                        'post_opt_candidate_statepoints': caller_static_points[symbol],
                        'cyclic_regions_with_candidate': result['loop_regions'],
                        'reachable_instructions': result['reachable_instructions'],
                        'phases': dict(phases), 'command': command,
                        'disassembly': output.name, 'disassembly_sha256': sha(output)})
    result = {'status': 'complete-bounded-machine-region-coverage',
              'application': str(args.elf), 'application_sha256': binding['application_sha256'],
              'selected_hottest_candidate_callers': selected,
              'all_candidate_caller_periods': dict(caller_periods),
              'phase_target_totals': dict(totals), 'phase_region_coverage': dict(coverage),
              'functions': results, 'rejected_functions': rejected, 'inputs': inputs,
              'limitations': [
                  'Only20 hottest unique existing-plus-new runtime leaf candidate callers, exact PGCM symbol joins.',
                  'Normal intraprocedural machine CFG; exception/unwind transfers are not modeled.',
                  'Any undecoded/indirect branch excludes the function, never zero opportunity.',
                  'Cyclic regions are SCCs, which can contain nested or irreducible loops.',
                  'Loop/block/call samples overlap; never sum them. They are caller coverage, not savings.',
                  'No callee work is removed; no spill/reload cost or dynamic call counts inferred.',
              ]}
    (args.out / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'analyzed': len(results), 'rejected': len(rejected), 'coverage': dict(coverage)}))


if __name__ == '__main__':
    main()
