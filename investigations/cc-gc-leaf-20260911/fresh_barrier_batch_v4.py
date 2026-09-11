#!/usr/bin/env python3
"""Stream completed pre-RS4GC functions through the frozen barrier census.

Run only while owning the campaign lock. No optimization or native build.
"""
import argparse
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import re
import sys
import callsite_census as emission
import fresh_barrier_census_v4 as barrier


def validate_layout(triple, layout):
    if triple != 'x86_64-unknown-linux-gnu' or not isinstance(layout, str) or not layout.startswith('e-'):
        raise ValueError('pointer-alias observer requires bound little-endian x86_64 Linux layout')
    widths = {0: 64}  # LLVM DataLayout's default pointer specification.
    nonintegral = set()
    for component in layout.split('-'):
        if component.startswith('p'):
            m = re.fullmatch(r'p(\d*):(\d+):(\d+)(?::\d+)*', component)
            if not m:
                raise ValueError('unsupported pointer datalayout component: ' + component)
            widths[int(m[1] or 0)] = int(m[2])
        elif component.startswith('ni:'):
            nonintegral.update(int(x) for x in component[3:].split(':'))
    if widths[0] != 64 or widths.get(1, widths[0]) != 64 or nonintegral.intersection({0, 1}):
        raise ValueError('AS0/AS1 are not proved integral 64-bit pointers')


def function_texts(lines, digest, require_layout=False):
    pending, start = None, None
    triple = layout = None
    for number, line in enumerate(lines, 1):
        digest.update(line.encode('utf-8'))
        if line.startswith('target triple = '):
            triple = json.loads(line.split('=', 1)[1])
        elif line.startswith('target datalayout = '):
            layout = json.loads(line.split('=', 1)[1])
        if line.startswith('define '):
            if require_layout:
                validate_layout(triple, layout)
                require_layout = False
            if pending is not None:
                raise ValueError(f'nested/unterminated function before line {number}')
            pending, start = [line], number
        elif pending is not None:
            pending.append(line)
        if pending is not None and line.strip() == '}':
            yield start, number, ''.join(pending)
            pending = None
    if pending is not None:
        raise ValueError(f'unterminated final function at line {start}')


def analyze_one(text, start, extra, noncollecting):
    narrow = barrier.analyze(text, extra, noncollecting)
    join_kill = barrier.analyze(text, extra, noncollecting, local_aliases=True)
    result = barrier.analyze(text, extra, noncollecting, local_aliases=True, intersect_joins=True)
    assert narrow['strict_barrier_sites'] == result['strict_barrier_sites']
    if len(result['functions']) != 1:
        raise ValueError('one streamed function did not decode as exactly one function')
    fn = result['functions'][0]
    # Strict hit rows share the strict function's objects. Adjust them once;
    # the separate hypothetical hit rows have their own objects.
    for row in fn.get('barriers', []) + result['extra_leaf_hits']:
        row['line'] += start - 1
        if row['allocation_origin']:
            name, line, callee = row['allocation_origin'].rsplit(':', 2)
            row['allocation_origin'] = f'{name}:{int(line) + start - 1}:{callee}'
    return {'function': fn['function'], 'definition_line': start,
            'excluded': fn.get('excluded', []),
            'reachable_blocks': fn.get('reachable_blocks'),
            'join_blocks_killing_facts': fn.get('join_blocks_killing_facts'),
            'join_policy': fn.get('join_policy'),
            'join_blocks': fn.get('join_blocks'),
            'strict_barrier_sites': result['strict_barrier_sites'],
            'strict_fresh_origin_sites': result['strict_fresh_origin_sites'],
            'strict_unresolved_parent_sites': result['strict_unresolved_parent_sites'],
            'extra_leaf_fresh_origin_sites': result['extra_leaf_fresh_origin_sites'],
            'narrow_strict_fresh_origin_sites': narrow['strict_fresh_origin_sites'],
            'narrow_extra_leaf_fresh_origin_sites': narrow['extra_leaf_fresh_origin_sites'],
            'join_kill_strict_fresh_origin_sites': join_kill['strict_fresh_origin_sites'],
            'join_kill_extra_leaf_fresh_origin_sites': join_kill['extra_leaf_fresh_origin_sites'],
            'alias_ledger': fn.get('alias_ledger'),
            'barriers': fn.get('barriers', []), 'strict_hits': result['strict_hits'],
            'extra_leaf_hits': result['extra_leaf_hits']}


def run(captures, audit_path, output, llvm_dis, text_root=None):
    output.mkdir(parents=True, exist_ok=False)
    attempts, abandoned = emission.read_attempts(captures)
    audit_sha = emission.sha(audit_path)
    audit = emission.read_audit(audit_path)
    noncollecting = sorted(name for name, row in audit.items() if row['current_effect'] == 'CannotCollect')
    extra = sorted(name for name, row in audit.items() if row['current_effect'] == 'Unknown'
                   and row['audit_status'] == 'reviewed' and row['may_collect'] == 'no'
                   and row['may_reenter_js'] == 'no')
    if len(extra) != 48:
        raise ValueError(f'expected the specifically authorized 48-summary population; got {len(extra)}')
    if not noncollecting:
        raise ValueError('explicit CannotCollect population is empty')
    (output / 'cannot-collect.json').write_text(json.dumps(noncollecting, indent=2) + '\n')
    (output / 'extra-48.json').write_text(json.dumps(extra, indent=2) + '\n')
    totals, units = Counter(), []
    unresolved_opcodes, unresolved_reasons = Counter(), Counter()
    rows_path = output / 'functions.jsonl.gz'
    with gzip.open(rows_path, 'wt', compresslevel=1) as rows:
        for attempt in attempts:
            directory = attempt['directory']
            bc = directory / 'pre-rs4gc.bc'
            unit = {'attempt': directory.name, 'stage': 'pre-rs4gc', 'bitcode_sha256': emission.sha(bc),
                    'attempt_sha256': emission.sha(directory / 'attempt.json'),
                    'complete_sha256': emission.sha(directory / 'complete.json'),
                    'counts': Counter(), 'errors': []}
            ir_hash = hashlib.sha256()
            try:
                with emission.llvm_lines(bc, llvm_dis, text_root) as lines:
                    for start, end, text in function_texts(lines, ir_hash, require_layout=True):
                        unit['counts']['functions_encountered'] += 1
                        try:
                            row = analyze_one(text, start, extra, noncollecting)
                        except (ValueError, KeyError, TypeError, IndexError) as error:
                            row = {'function': None, 'definition_line': start,
                                   'excluded': [str(error)], 'header': text.splitlines()[0]}
                        row.update(attempt=directory.name, last_line=end)
                        if row['excluded']:
                            unit['counts']['functions_excluded'] += 1
                        else:
                            unit['counts']['functions_admitted'] += 1
                            for name in ('strict_barrier_sites', 'strict_fresh_origin_sites', 'extra_leaf_fresh_origin_sites',
                                         'strict_unresolved_parent_sites', 'narrow_strict_fresh_origin_sites',
                                         'narrow_extra_leaf_fresh_origin_sites', 'join_kill_strict_fresh_origin_sites',
                                         'join_kill_extra_leaf_fresh_origin_sites'):
                                unit['counts'][name] += row[name]
                            for site in row['barriers']:
                                if site['unresolved_parent']:
                                    unresolved_reasons[site['unresolved_parent']] += 1
                                    unresolved_opcodes[site['parent_definition_opcode'] or '<no SSA definition>'] += 1
                        rows.write(json.dumps(row, separators=(',', ':')) + '\n')
            except (ValueError, OSError) as error:
                unit['errors'].append(str(error))
            unit['decoded_text_sha256'] = ir_hash.hexdigest()
            unit['complete_text_consumed'] = not unit['errors']
            if text_root:
                unit['mirror_path'] = str(text_root / directory.name / 'pre-rs4gc.ll')
            if unit['counts']['functions_encountered'] == 0:
                unit['errors'].append('no function definitions encountered; unavailable, not zero')
            for name in ('functions_encountered', 'functions_excluded', 'functions_admitted',
                         'strict_barrier_sites', 'strict_fresh_origin_sites', 'extra_leaf_fresh_origin_sites',
                         'strict_unresolved_parent_sites', 'narrow_strict_fresh_origin_sites',
                         'narrow_extra_leaf_fresh_origin_sites', 'join_kill_strict_fresh_origin_sites',
                         'join_kill_extra_leaf_fresh_origin_sites'):
                unit['counts'].setdefault(name, 0)
            assert unit['counts']['functions_encountered'] == unit['counts']['functions_admitted'] + unit['counts']['functions_excluded']
            totals.update(unit['counts'])
            units.append(unit)
            print(json.dumps({'attempt': directory.name, **unit['counts'], 'errors': unit['errors']}), flush=True)
    if emission.sha(audit_path) != audit_sha:
        raise ValueError('helper audit changed during analysis')
    partial = any(u['errors'] or u['counts']['functions_excluded'] for u in units)
    result = {'schema': 1, 'status': 'partial-static-barrier-census' if partial else 'complete-static-barrier-census',
              'measurement': 'reachable explicit barrier sites in admitted functions; not executions or valid elisions',
              'totals': dict(totals), 'completed_attempts': len(attempts),
              'unresolved_parent_reasons': dict(unresolved_reasons),
              'unresolved_parent_definition_opcodes': dict(unresolved_opcodes),
              'incomplete_attempts_excluded': abandoned, 'units': units,
              'cannot_collect_summary_count': len(noncollecting), 'extra_hypothesis_summary_count': len(extra),
              'helper_audit_sha256': audit_sha,
              'analyzers': {p.name: emission.sha(p) for p in (Path(__file__), Path(barrier.__file__), Path(emission.__file__))},
              'llvm_dis': {'path': llvm_dis, 'sha256': emission.sha(llvm_dis)} if not text_root else None,
              'files': {p.name: {'sha256': emission.sha(p), 'bytes': p.stat().st_size}
                        for p in (rows_path, output / 'cannot-collect.json', output / 'extra-48.json')},
              'limits': ['generation and publication of fresh allocator returns remain unknown',
                         'joins retain only identical origins across every reachable predecessor; possibly collecting calls kill freshness',
                         'layout, incremental barriers and string sharing are not claimed removable',
                         'excluded functions/units are unavailable, not zero-barrier observations',
                         'admitted counts in a failed unit remain partial; do not infer its full denominator',
                         'only explicit direct barrier ABIs; hidden helper stores and already omitted barriers are outside this denominator',
                         'root must bind successful full compile and accepted emitted units to exact application']}
    (output / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--captures', type=Path, required=True)
    p.add_argument('--helper-audit', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--llvm-dis', default='/usr/lib/llvm-22/bin/llvm-dis')
    p.add_argument('--text-root', type=Path)
    a = p.parse_args()
    result = run(a.captures, a.helper_audit, a.output, a.llvm_dis, a.text_root)
    return 2 if result['status'].startswith('partial') else 0


if __name__ == '__main__':
    sys.exit(main())
