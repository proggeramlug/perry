#!/usr/bin/env python3
"""Reconcile the declared pairs against each complete workload receipt."""
from pathlib import Path
from collections import defaultdict
from copy import deepcopy
import argparse
import csv
import hashlib
import json
import statistics

from paired_workload_v2 import validate_mock_evidence


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def validate(record, base):
    assert record['status'] == 'complete', 'measurement is incomplete'
    for name, digest in record['inputs'].items():
        assert sha(base / name) == digest, name
    expected = []
    for index in range(1, 6):
        order = ['control', 'candidate'] if index % 2 else ['candidate', 'control']
        if index <= 3:
            order.insert(index - 1, 'node')
        expected.extend((arm, index) for arm in order)
    assert [(r['arm'], r['row']) for r in record['rows']] == expected, 'missing/reordered row'
    build = json.loads((base / 'build.execution.json').read_text())
    assert build['status'] == 'complete'
    common_fixture = None
    output = []
    for ordinal, item in enumerate(record['rows'], 1):
        arm, index = item['arm'], item['row']
        path = base / f'v2-row-{arm}-{index}' / 'run.json'
        assert item['order'] == ordinal
        assert sha(path) == item['run_sha256'], str(path)
        run = json.loads(path.read_text())
        assert run['pass'] and run['cleanup_errors'] == [] and 'error' not in run
        assert run['process_cpu'] == item['cpu'], 'CPU record disagrees with raw receipt'
        assert run['vmhwm_mb'] == item['vmhwm_mb']
        assert run['counter_control']['kind'] == 'controller-timestamps-only'
        assert [r['phase'] for r in run['counter_control']['phases']] == [1, 2, 3, 4]
        assert run['instrumentation'] == 'controller phase timestamps only; no perf/BPF or runtime counters'
        assert run['prompt_echo_observed']
        validate_mock_evidence(run['mock_evidence'])
        if common_fixture is None:
            common_fixture = run['fixture_sha256']
        assert run['fixture_sha256'] == common_fixture
        expected_sha = record['node']['sha256'] if arm == 'node' else build['pair'][arm]['sha256']
        assert run['application_sha256'] == expected_sha
        phases = run['phases']
        times = [phases[key] for key in ['startup_begin_ns', 'startup_end_ns', 'command_begin_ns', 'marker_ns', 'command_end_ns']]
        assert all(a < b for a, b in zip(times, times[1:]))
        startup, command = item['cpu']['startup_s'], item['cpu']['command_s']
        assert startup > 0 and command > 0 and item['vmhwm_mb'] > 0
        output.append({'arm': arm, 'row': index, 'order': ordinal,
                       'startup_cpu_s': startup, 'command_cpu_s': command,
                       'startup_plus_command_cpu_s': startup + command,
                       'command_wall_s': (phases['command_end_ns'] - phases['command_begin_ns']) / 1e9,
                       'peak_rss_mib': item['vmhwm_mb'], 'before_load1': item['before']['load'][0],
                       'after_load1': item['after_load'][0], 'run_sha256': item['run_sha256']})
    return output


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--raw', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    record = json.loads((args.raw / 'measure-v2.execution.json').read_text())
    rows = validate(record, args.raw)
    controls = []
    missing = deepcopy(record)
    missing['rows'].pop()
    wrong_cpu = deepcopy(record)
    wrong_cpu['rows'][0]['cpu']['command_s'] += 0.01
    for name, invalid in [('missing-real-row', missing), ('modified-real-CPU', wrong_cpu)]:
        try:
            validate(invalid, args.raw)
        except AssertionError as error:
            controls.append({'name': name, 'rejected': str(error)})
        else:
            raise AssertionError('counterfactual accepted: ' + name)
    arms = defaultdict(list)
    for row in rows:
        arms[row['arm']].append(row)
    metrics = ['startup_cpu_s', 'command_cpu_s', 'startup_plus_command_cpu_s', 'command_wall_s', 'peak_rss_mib']
    summaries = {arm: {metric: {'values': [r[metric] for r in entries],
                              'min': min(r[metric] for r in entries),
                              'max': max(r[metric] for r in entries),
                              'median': statistics.median(r[metric] for r in entries)}
                       for metric in metrics} for arm, entries in arms.items()}
    paired = []
    for index in range(1, 6):
        control = next(r for r in arms['control'] if r['row'] == index)
        candidate = next(r for r in arms['candidate'] if r['row'] == index)
        paired.append({'row': index, **{metric + '_change_percent': 100 * (candidate[metric] / control[metric] - 1)
                                       for metric in metrics}})
    minimum_changes = {metric: 100 * (summaries['candidate'][metric]['min'] / summaries['control'][metric]['min'] - 1)
                       for metric in metrics}
    args.out.mkdir(exist_ok=True)
    for name, data in [('rows.csv', rows), ('paired-changes.csv', paired)]:
        with (args.out / name).open('w', newline='') as stream:
            writer = csv.DictWriter(stream, fieldnames=list(data[0]), lineterminator='\n')
            writer.writeheader()
            writer.writerows(data)
    summary = {'status': 'complete-13-row-reconciliation', 'arms': summaries, 'paired_changes': paired,
               'candidate_vs_control_minimum_change_percent': minimum_changes,
               'node': record['node'], 'controls': controls, 'analyzer_sha256': sha(__file__),
               'inputs': {name: sha(args.raw / name) for name in ['measure-v2.execution.json', 'build.execution.json']},
               'outputs': {name: sha(args.out / name) for name in ['rows.csv', 'paired-changes.csv']}}
    (args.out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
