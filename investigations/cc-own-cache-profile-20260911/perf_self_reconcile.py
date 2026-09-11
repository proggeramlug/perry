#!/usr/bin/env python3
"""Strict integer reconciliation of a completed perf self report and IP census."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def require(ok, message):
    if not ok:
        raise ValueError(message)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def parse_report(text):
    require(text.endswith('\n'), 'report lacks final newline')
    fields = None
    total = {'samples': 0, 'period': 0}
    rows = 0
    lost = []
    events = []
    for ordinal, line in enumerate(text.splitlines(), 1):
        if not line.strip():
            continue
        if line.startswith('#'):
            stripped = line[1:].strip()
            if stripped.startswith('Total Lost Samples:'):
                number = stripped.removeprefix('Total Lost Samples:').strip()
                require(number.isdigit(), 'unsupported lost-sample count')
                lost.append(int(number))
            elif stripped.startswith('Samples:'):
                m = re.fullmatch(r"Samples: .+ of event '([^']+)'", stripped)
                require(m is not None, 'unsupported event header')
                events.append(m[1])
            elif stripped.startswith('Overhead,'):
                require(fields is None, 'multiple report tables are unsupported')
                fields = [x.strip() for x in stripped.split(',')]
                require(fields[:6] == ['Overhead', 'Samples', 'Period', 'Command', 'Shared Object', 'Symbol'],
                        'unsupported report field order')
                require(fields[6:] in ([], ['IPC   [IPC Coverage]']), 'unsupported trailing report fields')
            continue
        require(fields is not None, f'data before report header at {ordinal}')
        parts = [x.strip() for x in line.split(',')]
        require(len(parts) == len(fields), f'wrong report column count at {ordinal}')
        require(re.fullmatch(r'\d+\.\d+%', parts[0]) is not None,
                f'unsupported overhead field at {ordinal}')
        require(parts[1].isdigit() and parts[2].isdigit(), f'noninteger self count at {ordinal}')
        require(all(parts[i] for i in (3, 4, 5)), f'empty comm/dso/symbol at {ordinal}')
        samples, period = int(parts[1]), int(parts[2])
        require(samples > 0 and period > 0, f'nonpositive self count at {ordinal}')
        total['samples'] += samples
        total['period'] += period
        rows += 1
    require(fields is not None and rows > 0, 'missing or empty self table')
    require(lost == [0], f'missing, duplicate or nonzero lost-sample header: {lost}')
    require(events == ['cycles:u'], f'unsupported event population: {events}')
    return {'totals': total, 'self_rows': rows, 'lost_samples': 0, 'event': events[0]}


def reconcile(report, summary, command_receipt, output):
    invocation = json.loads(command_receipt.read_text())
    command = invocation.get('command', [])
    require(invocation.get('exit') == 0, 'perf self report did not exit successfully')
    for arg in ('report', '--stdio', '--no-children', '--show-total-period',
                '--show-nr-samples', '--sort=comm,dso,symbol', '--field-separator=,',
                '--percent-limit=0'):
        require(arg in command, 'missing exact report predicate: ' + arg)
    require(invocation.get('stdout_sha256') == sha(report), 'report invocation/output hash mismatch')
    result = parse_report(report.read_text())
    census = json.loads(summary.read_text())
    require(census.get('status') == 'complete-actual-ip-self-census', 'IP census incomplete')
    require(result['totals'] == census['totals'],
            f'whole-capture mismatch: report={result["totals"]}, IP={census["totals"]}')
    result.update(schema=1, status='PASS', scope='whole-capture integer self samples and periods',
                  inputs={str(p): sha(p) for p in (report, summary, command_receipt)},
                  parser_sha256=sha(Path(__file__)),
                  limitations=['phase attribution is separately bound to run.json monotonic windows',
                               'no callchain or saved-time estimate',
                               'report stderr and invocation are retained independently'])
    output.write_text(json.dumps(result, indent=2) + '\n')
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--report', type=Path, required=True)
    p.add_argument('--summary', type=Path, required=True)
    p.add_argument('--command-receipt', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    print(json.dumps(reconcile(a.report, a.summary, a.command_receipt, a.output), indent=2))


if __name__ == '__main__':
    main()
