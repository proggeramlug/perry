#!/usr/bin/env python3
"""Exact-name audit join; retain all stages, unresolved symbols and input metrics."""
import argparse
import csv
import hashlib
import io
import json
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
STAGES = ('pre-rs4gc', 'post-rs4gc', 'post-opt')
METRICS = ('callsites', 'statepoints', 'leaf_callsites', 'gc_live_operands',
           'gc_relocate_intrinsics', 'relocates_attributed', 'relocates_unattributed')
INPUT_FIELDS = ('stage', 'category', 'callee') + METRICS
CATEGORIES = {'static-user', 'runtime', 'dynamic-dispatch', 'LLVM', 'inline-asm',
              'nonruntime-external', 'external-unclassified'}


def read_input(text):
    reader = csv.DictReader(io.StringIO(text))
    if reader.fieldnames != list(INPUT_FIELDS):
        raise ValueError('unexpected by-callee schema: ' + repr(reader.fieldnames))
    rows, seen = [], set()
    for row in reader:
        if None in row or any(value is None for value in row.values()):
            raise ValueError('malformed CSV row')
        key = tuple(row[x] for x in ('stage', 'category', 'callee'))
        if key in seen:
            raise ValueError('duplicate stage/category/callee: ' + repr(key))
        seen.add(key)
        if row['stage'] not in STAGES or row['category'] not in CATEGORIES or not row['callee']:
            raise ValueError('invalid stage/category/callee: ' + repr(key))
        for name in METRICS:
            if not row[name].isascii() or not row[name].isdecimal():
                raise ValueError('nonnegative integer required: ' + name)
        rows.append(row)
    if {row['stage'] for row in rows} != set(STAGES):
        raise ValueError('all three completed census stages required')
    return rows


def join(rows, audit):
    audit_fields = [field for field in next(iter(audit.values())) if field != 'helper']
    result = []
    for original in rows:
        row = dict(original)
        found = audit.get(row['callee'])
        row['audit_match'] = 'exact-symbol' if found else 'unmatched'
        row['runtime_source_identity'] = 'yes' if found and found['runtime_locations'] else 'unresolved'
        row.update({field: found[field] if found else '' for field in audit_fields})
        if not found:
            row.update(audit_status='unreviewed', current_effect='unclassified',
                       allocation_class='unclear', perry_heap_allocation='unclear',
                       may_collect='unclear', may_reenter_js='unclear',
                       reason='No exact audit entry; category is retained without inferring runtime identity or effects.')
        row['reviewed_unannotated_no_collect'] = str(bool(
            found and found['runtime_locations'] and found['audit_status'] == 'reviewed'
            and found['current_effect'] == 'Unknown' and found['may_collect'] == 'no'
            and found['may_reenter_js'] == 'no')).lower()
        result.append(row)
    return result


def totals(rows):
    return {stage: {'rows': sum(row['stage'] == stage for row in rows),
                    **{metric: sum(int(row[metric]) for row in rows if row['stage'] == stage)
                       for metric in METRICS}} for stage in STAGES}


def selftest():
    records = [dict(zip(INPUT_FIELDS, (stage, category, name, *(['1'] * len(METRICS)))))
               for stage in STAGES for category, name in
               [('dynamic-dispatch', 'js_native_call_method'), ('runtime', 'js_leaf'),
                ('external-unclassified', 'missing')]]
    audit = {name: dict(helper=name, runtime_locations='runtime.rs:1', audit_status='reviewed',
                       current_effect=effect, allocation_class='unclear', perry_heap_allocation='no',
                       may_collect=collect, may_reenter_js=reentry, reason='fixture', proof='fixture')
             for name, effect, collect, reentry in [('js_leaf', 'Unknown', 'no', 'no'),
                 ('js_native_call_method', 'Unknown', 'may', 'may')]}
    def encoded(rows):
        stream = io.StringIO(); writer = csv.DictWriter(stream, fieldnames=INPUT_FIELDS)
        writer.writeheader(); writer.writerows(rows); return stream.getvalue()
    parsed = read_input(encoded(records)); joined = join(parsed, audit)
    assert totals(parsed) == totals(joined)
    assert sum(row['reviewed_unannotated_no_collect'] == 'true' for row in joined) == 3
    assert sum(row['runtime_source_identity'] == 'yes' for row in joined) == 6
    assert all(row['may_collect'] == 'unclear' and row['category'] == 'external-unclassified'
               for row in joined if row['callee'] == 'missing')
    mutations = [records + [dict(records[0])], records[3:],
                 [dict(row, callsites='-1') if i == 0 else row for i, row in enumerate(records)],
                 [dict(row, stage='before') if i == 0 else row for i, row in enumerate(records)],
                 [dict(row, category='definitely-leaf') if i == 0 else row for i, row in enumerate(records)]]
    for mutation in mutations:
        try:
            read_input(encoded(mutation))
        except ValueError:
            continue
        raise AssertionError('invalid fixture accepted')
    return {'status': 'PASS', 'positive_controls': 4, 'rejected_mutations': len(mutations),
            'scope': 'Offline join validation only; no runtime/helper behavior tested.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--by-callee', type=Path)
    parser.add_argument('--audit', type=Path, default=HERE / 'helper-audit.csv')
    parser.add_argument('--output', type=Path)
    parser.add_argument('--selftest', action='store_true')
    args = parser.parse_args()
    if args.selftest:
        print(json.dumps(selftest(), indent=2)); return
    if args.by_callee is None or args.output is None:
        parser.error('--by-callee and --output required')
    input_bytes, audit_bytes = args.by_callee.read_bytes(), args.audit.read_bytes()
    rows = read_input(input_bytes.decode())
    audit_rows = list(csv.DictReader(io.StringIO(audit_bytes.decode())))
    audit = {row['helper']: row for row in audit_rows}
    if not audit or len(audit) != len(audit_rows):
        raise ValueError('empty audit or duplicate helper names')
    joined = join(rows, audit)
    runtime = [row for row in joined if row['runtime_source_identity'] == 'yes'
               and row['category'] in ('runtime', 'dynamic-dispatch')]
    unresolved = [row for row in joined if row['category'] == 'external-unclassified']
    candidates = [row for row in runtime if row['reviewed_unannotated_no_collect'] == 'true']
    if totals(rows) != totals(joined):
        raise ValueError('input accounting changed')
    args.output.mkdir(parents=True, exist_ok=False)
    for name, subset in [('by-callee-audited.csv', joined), ('actual-runtime.csv', runtime),
                         ('unresolved-external.csv', unresolved), ('reviewed-unannotated.csv', candidates)]:
        with (args.output / name).open('w', newline='') as stream:
            writer = csv.DictWriter(stream, fieldnames=list(joined[0]))
            writer.writeheader(); writer.writerows(subset)
    receipt = {'input': str(args.by_callee.resolve()), 'input_sha256': hashlib.sha256(input_bytes).hexdigest(),
               'audit': str(args.audit.resolve()), 'audit_sha256': hashlib.sha256(audit_bytes).hexdigest(),
               'script_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
               'input_totals': totals(rows), 'all_joined_totals': totals(joined),
               'runtime_totals': totals(runtime), 'unresolved_external_totals': totals(unresolved),
               'reviewed_unannotated_totals': totals(candidates),
               'runtime_unique_helpers': len({row['callee'] for row in runtime}),
               'runtime_audit_status_rows': dict(Counter(row['audit_status'] for row in runtime)),
               'scope': 'Static emitted callsites only; not dynamic calls, runtime CPU, or proof of linked definition identity.',
               'outputs_sha256': {path.name: hashlib.sha256(path.read_bytes()).hexdigest()
                                  for path in sorted(args.output.glob('*.csv'))}}
    (args.output / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt, indent=2))


if __name__ == '__main__':
    main()
