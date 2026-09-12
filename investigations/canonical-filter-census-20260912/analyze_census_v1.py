#!/usr/bin/env python3
"""Turn the census rows into phase deltas, observed pass rates and occupancy.

The observed pass rate is measured over cc's actual address population. It is
the quantity the `(bits/capacity)^3` estimate only approximates, so both are
reported and never conflated.
"""
from pathlib import Path
import json

FILTERS = ['CANONICAL_HANDLE_ADDR_FILTER', 'SYMBOL_ADDR_FILTER',
           'CLASS_PROTOTYPE_ADDR_FILTER', 'BUFFER_LIKE_ADDR_FILTER']
COUNTERS = ['CALLS', 'FILTER_PASS', 'RESOLVED', 'ADMITS', 'RETIRES']


def main():
    base = Path(__file__).resolve().parent
    record = json.loads((base / 'census-observation-v1.execution.json').read_text())
    assert record['status'] == 'complete', record['status']
    out = {'application_sha256': record['application_sha256'], 'rows': []}
    for row in record['rows']:
        phases = {s['phase']: s for s in row['snapshots']}
        assert set(phases) == {1, 2, 3, 4}
        startup, before_enter, after = phases[2]['values'], phases[3]['values'], phases[4]['values']
        entry = {'row': row['row'], 'instrumented_cpu': row['instrumented_cpu'], 'phases': {}}
        for name, (lo, hi) in {'startup': (None, startup), 'command': (before_enter, after)}.items():
            counts = {c: hi[c] - (lo[c] if lo else 0) for c in COUNTERS}
            calls, passes, resolved = counts['CALLS'], counts['FILTER_PASS'], counts['RESOLVED']
            entry['phases'][name] = {
                **counts,
                'pass_unresolved': passes - resolved,
                'observed_pass_rate': (passes / calls) if calls else None,
                'resolved_share_of_passes': (resolved / passes) if passes else None,
                'live_at_end': hi['LIVE'],
                'filters': {f: {'bits_set': hi[f]['bits_set'],
                                'capacity_bits': hi[f]['capacity_bits'],
                                'estimated_pass_rate':
                                    (hi[f]['bits_set'] / hi[f]['capacity_bits']) ** 3}
                            for f in FILTERS},
            }
        out['rows'].append(entry)
    totals = {}
    for name in ('startup', 'command'):
        calls = sum(r['phases'][name]['CALLS'] for r in out['rows'])
        passes = sum(r['phases'][name]['FILTER_PASS'] for r in out['rows'])
        resolved = sum(r['phases'][name]['RESOLVED'] for r in out['rows'])
        totals[name] = {'CALLS': calls, 'FILTER_PASS': passes, 'RESOLVED': resolved,
                        'pass_unresolved': passes - resolved,
                        'observed_pass_rate': (passes / calls) if calls else None,
                        'resolved_share_of_passes': (resolved / passes) if passes else None}
    out['totals'] = totals
    (base / 'census-analysis-v1.json').write_text(json.dumps(out, indent=1) + '\n')
    print(json.dumps({'totals': totals,
                      'per_row_command': [{'row': r['row'],
                                           'calls': r['phases']['command']['CALLS'],
                                           'pass': r['phases']['command']['FILTER_PASS'],
                                           'resolved': r['phases']['command']['RESOLVED'],
                                           'pass_rate': r['phases']['command']['observed_pass_rate'],
                                           'live': r['phases']['command']['live_at_end'],
                                           'bits': {f: r['phases']['command']['filters'][f]['bits_set']
                                                    for f in FILTERS}}
                                          for r in out['rows']]}, indent=1))


if __name__ == '__main__':
    raise SystemExit(main())
