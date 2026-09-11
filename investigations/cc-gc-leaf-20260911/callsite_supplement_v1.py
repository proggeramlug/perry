#!/usr/bin/env python3
"""Add all-definition root denominators and pre-IR shadow/requested-slot facts.

Run only under the campaign lock. Does not revise the frozen primary census.
Requested-slot sums are static emitted capacity requests, not concurrent RSS.
"""
import argparse
from collections import Counter
import csv
import hashlib
import json
from pathlib import Path
import re
import sys


def sha(path):
    with Path(path).open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()


def supplement(result, text, audit_path, parser_dir, output):
    if output.exists():
        raise ValueError('preserve previous supplement')
    sys.path.insert(0, str(parser_dir))
    import callsite_census as c
    summary = json.loads((result / 'summary.json').read_text())
    assert summary['status'] == 'complete-static-emission-census'
    assert sha(audit_path) == summary['helper_audit_sha256'], 'helper audit changed'
    assert sha(parser_dir / 'callsite_census.py') == summary['analyzer_sha256'], 'primary parser changed'
    mirrors = {r['path']: r['sha256'] for r in summary['converted_ir_receipts']}
    audit = c.read_audit(audit_path)
    counts = Counter()
    with (result / 'definitions.csv').open(newline='') as f:
        definitions = list(csv.DictReader(f))
    pre = {(r['attempt'], r['symbol']): r for r in definitions if r['stage'] == 'pre-rs4gc'}
    assert len(pre) == sum(r['stage'] == 'pre-rs4gc' for r in definitions)
    for r in definitions:
        counts[(r['stage'], r['pre_root_mode'])] += 1
    shadow = []
    invokes = Counter()
    files = []
    for attempt in summary['accepted_attempts']:
        unit = Path(attempt['directory']).name
        ir = text / unit / 'pre-rs4gc.ll'
        digest = sha(ir)
        assert digest == mirrors[str(ir)], 'pre-IR mirror changed since primary census'
        files.append({'path': str(ir), 'sha256': digest})
        with ir.open() as f:
            for kind, fn, block, line, record in c.records(f):
                if kind != 'call':
                    continue
                result_name, op, callee, args, suffix = c.call_parts(record)
                if not callee.startswith('@'):
                    continue
                symbol = c.name(callee)
                row = audit.get(symbol, {})
                if op == 'invoke' and row.get('current_effect') == 'CannotCollect':
                    invokes[symbol] += 1
                if symbol not in {'js_shadow_frame_enter', 'js_shadow_frame_push'}:
                    continue
                assert len(args) == 1, (unit, fn, line, 'unexpected shadow entry ABI')
                match = re.fullmatch(r'i32\s+(\d+)', args[0])
                shadow.append({'attempt': unit, 'caller': fn, 'block': block, 'line': line,
                               'callee': symbol, 'requested_slots': int(match[1]) if match else None,
                               'operand': args[0], 'pre_root_mode': pre[(unit, fn)]['pre_root_mode']})
    known_leaf_rows = []
    with (result / 'by-callee.csv').open(newline='') as f:
        for row in csv.DictReader(f):
            if audit.get(row['callee'], {}).get('current_effect') == 'CannotCollect':
                for key in c.METRICS:
                    row[key] = int(row[key])
                if row['statepoints'] or row['callee'] in invokes:
                    known_leaf_rows.append(row)
    data = {
        'schema': 1, 'status': 'complete', 'script_sha256': sha(__file__),
        'primary_summary_sha256': sha(result / 'summary.json'),
        'definitions_sha256': sha(result / 'definitions.csv'),
        'parser_sha256': sha(parser_dir / 'callsite_census.py'),
        'helper_audit_sha256': sha(audit_path),
        'definition_root_modes': [{'stage': s, 'root_mode': m, 'functions': n}
                                  for (s, m), n in sorted(counts.items())],
        'pre_total_definitions': len(pre),
        'shadow_entry_callsites': len(shadow),
        'shadow_requested_slots_static_sum': sum(r['requested_slots'] or 0 for r in shadow),
        'shadow_nonconstant_requests': sum(r['requested_slots'] is None for r in shadow),
        'shadow_entry_functions': len({(r['attempt'], r['caller']) for r in shadow}),
        'shadow_requests': shadow,
        'pre_known_cannot_collect_invokes': dict(sorted(invokes.items())),
        'known_cannot_collect_rewrite_rows': known_leaf_rows,
        'ir_inputs': files,
        'limitations': [
            'All-definition root denominators include zero-call functions; root modes describe pre-RS4GC strategy, not simultaneously active frames.',
            'Slot sums are static requested capacities across emitted entry calls, not allocation execution counts or simultaneous RSS.',
            'Only actual helper call instructions are counted. Inlined shadow stores are not helper calls or automatically GC points.',
            'Known CannotCollect invoke counts are pre-IR syntax. Actual surviving statepoints are reported independently from post-RS4GC/post-opt rows; no per-site lineage is asserted.',
        ],
    }
    output.write_text(json.dumps(data, indent=2) + '\n')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--result', type=Path, required=True)
    p.add_argument('--text-root', type=Path, required=True)
    p.add_argument('--audit', type=Path, required=True)
    p.add_argument('--parser-dir', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    supplement(a.result, a.text_root, a.audit, a.parser_dir, a.output)
