#!/usr/bin/env python3
"""Strict actual-IP self census for profile_workload.py's monotonic phases.

The initial text grammar is provisional until a real installed-perf export is
bound by the coordinator. No callchains, native execution or binary reads.
"""
import argparse
from collections import Counter, defaultdict
import csv
import gzip
import hashlib
import json
from pathlib import Path
import re
import sys

FORMAT = 'pid-tid-time-period-event-ip-symoff-dso-v1'
FORMAT_STATUS = 'provisional-awaiting-installed-perf-sample'
FIELDS = 'pid,tid,time,event,ip,sym,symoff,dso,period'
LINE = re.compile(
    r'^\s*(?P<pid>\d+)/(?P<tid>\d+)\s+(?P<sec>\d+)\.(?P<ns>\d{9}):\s+'
    r'(?P<period>\d+)\s+(?P<event>\S+):\s+(?P<ip>(?:0x)?[0-9a-fA-F]+)\s+'
    r'(?P<symbol>.+)\s+\((?P<dso>[^\r\n]+)\)\s*$')
SYMOFF = re.compile(r'^(?P<name>.+)\+0x(?P<offset>[0-9a-fA-F]+)$')
MAP = re.compile(r'^(?P<start>[0-9a-f]+)-(?P<end>[0-9a-f]+) '
                 r'(?P<perms>[r-][w-][x-][ps]) (?P<offset>[0-9a-f]+) '
                 r'(?P<major>[0-9a-f]+):(?P<minor>[0-9a-f]+)\s+'
                 r'(?P<inode>\d+)(?:\s+(?P<path>.*))?$')
PHASES = ('before_startup', 'startup', 'between_phases', 'command', 'after_command')
SCOPES = ('main_thread', 'other_target_thread', 'foreign_pid')
METRICS = ('samples', 'period')


class InputError(ValueError):
    pass


def require(value, message):
    if not value:
        raise InputError(message)


def sha(path):
    with Path(path).open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()


def load_json(path):
    return json.loads(Path(path).read_text())


def open_text(path):
    return gzip.open(path, 'rt', encoding='utf-8', errors='strict') if str(path).endswith('.gz') else Path(path).open(encoding='utf-8', errors='strict')


def integer(value, name, minimum=0):
    require(type(value) is int and value >= minimum, f'{name} must be an integer >= {minimum}')
    return value


def parse_line(line, ordinal):
    require(line.endswith('\n'), f'line {ordinal}: missing final newline; export may be truncated')
    if line == '\n':
        return None
    m = LINE.fullmatch(line[:-1])
    require(m is not None, f'line {ordinal}: unsupported perf text layout: {line[:180]!r}')
    d = m.groupdict()
    row = {k: int(d[k]) for k in ('pid', 'tid', 'period')}
    require(row['pid'] > 0 and row['tid'] > 0 and row['period'] > 0,
            f'line {ordinal}: nonpositive pid/tid/period')
    row.update(time_ns=int(d['sec']) * 1_000_000_000 + int(d['ns']),
               ip=int(d['ip'], 16), event=d['event'], dso=d['dso'])
    require(row['ip'] < 1 << 64, f'line {ordinal}: IP exceeds u64')
    symbol = d['symbol'].strip()
    match = SYMOFF.fullmatch(symbol)
    if match:
        row.update(symbol=match['name'], offset=int(match['offset'], 16), unknown=False)
        require(row['offset'] <= row['ip'], f'line {ordinal}: symbol offset exceeds IP')
    else:
        require(symbol in ('[unknown]', '[unknown kernel.kallsyms]') or re.fullmatch(r'(?:0x)?[0-9a-fA-F]+', symbol),
                f'line {ordinal}: missing or unsupported symbol offset: {symbol!r}')
        row.update(symbol=symbol, offset=None, unknown=True)
    return row


def validate_run(run):
    require(run.get('pass') is True and not run.get('error') and run.get('cleanup_errors') == [],
            'run did not pass with clean teardown')
    require(run.get('sampling') == 'cycles:u,999Hz,CLOCK_MONOTONIC,no callchains',
            'unsupported event/clock/callchain contract')
    pid = integer(run.get('pid'), 'run PID', 1)
    proc = run.get('process', {})
    require(proc.get('pid') == pid and proc.get('exe') == run.get('application')
            and proc.get('argv') == [run.get('application')], 'application process binding mismatch')
    require(re.fullmatch('[0-9a-f]{64}', run.get('application_sha256', '')) is not None,
            'missing application SHA256 receipt')
    pre = run.get('pre_exec_process', {})
    require(proc.get('start_ticks') == pre.get('start_ticks') and proc.get('start_ticks') is not None,
            'application birth identity mismatch')
    perf = run.get('perf_control', {})
    require(perf.get('exit') == 0 and perf.get('errors') == [] and not perf.get('constructor_error'),
            'perf recording/teardown did not complete')
    command = perf.get('command', [])
    require('--call-graph' not in command and '-g' not in command,
            'callchain capture is outside this parser contract')
    require('-k' in command and command[command.index('-k') + 1:command.index('-k') + 2] == ['CLOCK_MONOTONIC'],
            'perf command is not explicitly CLOCK_MONOTONIC')
    p = run.get('phases', {})
    bounds = [integer(p.get(key), key) for key in
              ('startup_begin_ns', 'startup_end_ns', 'command_begin_ns', 'command_end_ns')]
    require(bounds[0] < bounds[1] <= bounds[2] < bounds[3], 'phase intervals overlap, are empty or reversed')
    marker = integer(p.get('marker_ns'), 'marker_ns')
    require(bounds[2] <= marker <= bounds[3], 'completion marker is outside command phase')
    hands = perf.get('handshakes', [])
    require([h.get('command') for h in hands] == ['enable', 'disable']
            and all(h.get('ack') == 'ack' for h in hands), 'perf enable/disable handshake mismatch')
    require(integer(hands[0].get('monotonic_ns'), 'enable time') <= bounds[0]
            and integer(hands[1].get('monotonic_ns'), 'disable time') >= bounds[-1],
            'perf enable/disable does not cover phases')
    return bounds


def phase_at(stamp, bounds):
    return PHASES[sum(stamp >= bound for bound in bounds)]


def parse_maps(document):
    require(type(document.get('maps')) is str and document['maps'].endswith('\n'), 'missing complete /proc maps text')
    result = []
    previous_end = 0
    for n, line in enumerate(document['maps'].splitlines(), 1):
        m = MAP.fullmatch(line)
        require(m is not None, f'unsupported /proc maps row {n}')
        d = m.groupdict()
        row = {k: int(d[k], 16) for k in ('start', 'end', 'offset', 'major', 'minor')}
        row.update(inode=int(d['inode']), perms=d['perms'], path=d['path'] or '')
        require(previous_end <= row['start'] < row['end'] <= 1 << 64, 'overlapping or reversed process mappings')
        previous_end = row['end']
        result.append(row)
    require(result, 'empty process mapping snapshot')
    return result


def load_metadata(directory, maps, run):
    summary_path = directory / 'summary.json'
    summary = load_json(summary_path)
    require(summary.get('status') == 'complete' and summary.get('format') == 'PGCM'
            and summary.get('version') == 5, 'PGCM census incomplete or unsupported')
    identity = summary['elf']
    inode, device = int(identity['inode']), int(identity['device'])
    # The receipt is from Linux. Do not use the analyzing host's os.major:
    # Darwin's dev_t layout differs from Linux's glibc sys/sysmacros.h layout.
    major = ((device >> 8) & 0xfff) | ((device >> 32) & 0xfffff000)
    minor = (device & 0xff) | ((device >> 12) & 0xffffff00)
    appmaps = [m for m in maps if m['path'] == run['application'] and m['inode'] == inode
               and m['major'] == major and m['minor'] == minor]
    require(appmaps, 'no application mapping matches metadata file device/inode/path')
    section = summary['gcmap_section']
    offset, address = integer(section['offset'], 'GC section file offset'), integer(section['address'], 'GC section VMA')
    anchors = [m for m in appmaps if m['perms'][0] == 'r'
               and m['offset'] <= offset < m['offset'] + m['end'] - m['start']]
    biases = {m['start'] + offset - m['offset'] - address for m in anchors}
    require(len(biases) == 1, 'GC-map byte has no unique application load-bias mapping')
    bias = biases.pop()
    require(bias >= 0, 'negative application load bias unsupported')
    functions_path = directory / 'functions.jsonl.gz'
    expected = summary['files'][functions_path.name]
    require(sha(functions_path) == expected['sha256'] and functions_path.stat().st_size == expected['bytes'],
            'PGCM function output identity mismatch')
    functions = defaultdict(list)
    seen = set()
    with open_text(functions_path) as f:
        for line in f:
            row = json.loads(line)
            require(row['function_id'] not in seen, 'duplicate PGCM function ID')
            seen.add(row['function_id'])
            functions[int(row['address'], 16)].append(row)
    require(len(seen) == summary['function_entries'], 'PGCM function row count mismatch')
    return {'bias': bias, 'functions': functions, 'app_maps': appmaps,
            'receipt': {'summary_sha256': sha(summary_path), 'function_rows_sha256': expected['sha256'],
                        'load_bias': hex(bias), 'gcmap_file_offset': hex(offset), 'gcmap_linked_vma': hex(address),
                        'anchor_maps': anchors, 'method': 'same file byte: map.start + section.offset - map.offset - section.address',
                        'identity_limit': 'coordinator must bind immutable app SHA to this metadata census; no binary bytes are reread'}}


def classify(symbol, unknown, is_app, runtime_names):
    if unknown:
        return 'unknown_symbol'
    if not is_app:
        return 'other_dso'
    if symbol in runtime_names:
        return 'runtime_helper_source_bound'
    if symbol.startswith(('perry_fn_', 'perry_closure_', 'perry_method_')):
        return 'compiled_function_prefix'
    if symbol.startswith('js_'):
        return 'runtime_export_prefix_only'
    return 'other_application_symbol'


def read_audit(path):
    if path is None:
        return {}, None
    with path.open(newline='') as f:
        rows = list(csv.DictReader(f))
    require(rows and {'helper', 'runtime_locations', 'current_effect', 'audit_status',
                      'may_collect', 'may_reenter_js'} <= rows[0].keys(), 'unsupported helper audit columns')
    require(len({r['helper'] for r in rows}) == len(rows), 'duplicate helper audit symbol')
    return {r['helper']: r for r in rows}, sha(path)


def csv_rows(path, required):
    with open_text(path) as f:
        reader = csv.DictReader(f)
        require(reader.fieldnames is not None and set(required) <= set(reader.fieldnames),
                f'unsupported columns: {path.name}')
        rows = list(reader)
    require(all(None not in r and all(v is not None for v in r.values()) for r in rows),
            f'truncated or extra CSV fields: {path.name}')
    return rows


def load_callsites(directory, audit_sha):
    """Exact source identities, never infer unit uniqueness from candidate rows."""
    summary_path = directory / 'summary.json'
    summary = load_json(summary_path)
    require(summary.get('status') == 'complete-static-emission-census', 'callsite census is incomplete')
    require(audit_sha is not None and summary.get('helper_audit_sha256') == audit_sha,
            'callsite/helper-audit identity mismatch')
    names = ('post-opt-hypothesis-targets.csv', 'definitions.csv')
    receipts = {}
    for name in names:
        require(name in summary.get('outputs', {}), f'callsite census lacks complete identity output: {name}')
        expected = summary['outputs'][name]
        path = directory / name
        require(sha(path) == expected['sha256'] and path.stat().st_size == expected['bytes'],
                f'callsite output identity mismatch: {name}')
        receipts[name] = expected
    definitions = defaultdict(set)
    for row in csv_rows(directory / names[1], ('stage', 'attempt', 'symbol', 'linkage_scope', 'pre_root_mode')):
        require(row['stage'] in ('pre-rs4gc', 'post-rs4gc', 'post-opt'), 'unknown definition stage')
        if row['stage'] != 'post-opt':
            continue
        require(row['attempt'] and row['symbol'], 'empty definition identity')
        require(row['attempt'] not in definitions[row['symbol']], 'duplicate post-opt definition identity')
        definitions[row['symbol']].add(row['attempt'])
    targets = defaultdict(list)
    seen = set()
    for row in csv_rows(directory / names[0], ('hypothesis', 'callee_identity', 'attempt', 'caller', 'statepoints', 'gc_live_operands')):
        require(row['hypothesis'] in ('direct-reviewed-runtime', 'new-local-user', 'new-unique-visible-user',
                                      'existing-proof-user', 'full-unique-visible-user'), 'unknown hypothesis arm')
        require(row['attempt'] in definitions.get(row['caller'], ()), 'target caller absent from complete definitions')
        identity = tuple(row[k] for k in ('hypothesis', 'callee_identity', 'attempt', 'caller'))
        require(identity not in seen, 'duplicate hypothesis target row')
        seen.add(identity)
        for field in ('statepoints', 'gc_live_operands'):
            require(re.fullmatch(r'\d+', row[field]) is not None, 'noninteger static site count')
            row[field] = int(row[field])
        require(row['statepoints'] > 0, 'hypothesis target has zero surviving statepoints')
        targets[row['caller']].append(row)
    return {'definitions': definitions, 'targets': targets,
            'receipt': {'summary_sha256': sha(summary_path), 'outputs': receipts,
                        'limit': 'source-level caller identities; accepted emission-to-final-app binding remains coordinator-owned'}}


def join_coverage(selves, callsites):
    if callsites is None:
        return []
    counters = defaultdict(Counter)
    for key, value in selves.items():
        phase, scope, _, _, symbol, metadata_status, _ = key
        rows = callsites['targets'].get(symbol, [])
        if not rows or scope == 'foreign_pid':
            continue
        if metadata_status != 'exact_start_and_symbol':
            status = 'unbound_no_exact_pgcm_start_and_symbol'
        elif len(callsites['definitions'][symbol]) != 1:
            status = 'ambiguous_multiple_emission_units'
        else:
            status = 'exact_symbol_unique_emission_unit_coverage'
        # One caller can contain many eligible sites and appear in several
        # overlapping hypotheses. Count its self samples ONCE per hypothesis.
        for hypothesis in {row['hypothesis'] for row in rows}:
            counters[(phase, scope, hypothesis, status)].update(value)
    return [{'phase': k[0], 'scope': k[1], 'hypothesis': k[2], 'binding': k[3], **counts(v)}
            for k, v in sorted(counters.items())]


def metadata_match(sample, metadata):
    if metadata is None:
        return 'unavailable', None, []
    if not any(m['start'] <= sample['ip'] < m['end'] and m['perms'][2] == 'x'
               for m in metadata['app_maps']):
        return 'outside_app_executable_maps', None, []
    linked_ip = sample['ip'] - metadata['bias']
    if sample['offset'] is None:
        return 'unknown_symbol_no_function_start', linked_ip, []
    start = linked_ip - sample['offset']
    rows = metadata['functions'].get(start, [])
    named = [r for r in rows if sample['symbol'] in {s['name'] for s in r['exact_address_symbols']}]
    matches = [r for r in named if any(s['name'] == sample['symbol'] and s['size'] > sample['offset']
                                       for s in r['exact_address_symbols'])]
    if matches:
        return 'exact_start_and_symbol', linked_ip, matches
    if named:
        return 'exact_symbol_but_size_unknown_or_ip_outside_symbol', linked_ip, []
    return ('address_present_symbol_mismatch' if rows else 'no_pgcm_function_at_start'), linked_ip, []


def collect(samples_path, run, maps, metadata=None, runtime_names=()):
    bounds = validate_run(run)
    totals, phases, scopes = Counter(), defaultdict(Counter), defaultdict(Counter)
    selves, ips = defaultdict(Counter), defaultdict(Counter)
    joins, thread_rows = defaultdict(Counter), defaultdict(Counter)
    first = last = None
    with open_text(samples_path) as f:
        for ordinal, line in enumerate(f, 1):
            row = parse_line(line, ordinal)
            if row is None:
                continue
            require(row['event'] == 'cycles:u', f'line {ordinal}: unexpected event {row["event"]}')
            phase = phase_at(row['time_ns'], bounds)
            scope = ('foreign_pid' if row['pid'] != run['pid'] else
                     'main_thread' if row['tid'] == run['pid'] else 'other_target_thread')
            # A basename is insufficient when two DSOs share it. Canonical
            # exports must use --full-paths; unknown DSO remains explicit.
            is_app = scope != 'foreign_pid' and row['dso'] == run['application']
            if is_app:
                require(any(m['path'] == run['application'] and m['perms'][2] == 'x'
                            and m['start'] <= row['ip'] < m['end'] for m in maps),
                        f'line {ordinal}: application DSO IP is outside captured executable maps')
            category = classify(row['symbol'], row['unknown'], is_app, runtime_names)
            if is_app:
                joined, linked_ip, matches = metadata_match(row, metadata)
            else:
                joined, linked_ip, matches = 'not_application_dso', None, []
            key = (phase, scope, category, row['dso'], row['symbol'], joined,
                   tuple(r['function_id'] for r in matches))
            ipkey = (phase, scope, row['pid'], row['tid'], hex(row['ip']),
                     hex(linked_ip) if linked_ip is not None else '', row['symbol'],
                     row['offset'], row['dso'], joined)
            delta = {'samples': 1, 'period': row['period']}
            totals.update(delta)
            phases[phase].update(delta)
            scopes[(phase, scope)].update(delta)
            selves[key].update(delta)
            ips[ipkey].update(delta)
            joins[(phase, joined)].update(delta)
            thread_rows[(phase, row['pid'], row['tid'])].update(delta)
            first = row['time_ns'] if first is None else min(first, row['time_ns'])
            last = row['time_ns'] if last is None else max(last, row['time_ns'])
    require(totals['samples'] > 0, 'empty sample export is unavailable, not zero')
    for metric in METRICS:
        require(sum(v[metric] for v in phases.values()) == totals[metric]
                and sum(v[metric] for v in scopes.values()) == totals[metric]
                and sum(v[metric] for v in selves.values()) == totals[metric]
                and sum(v[metric] for v in ips.values()) == totals[metric], f'{metric}: total reconciliation failed')
        for phase in PHASES:
            require(sum(v[metric] for key, v in selves.items() if key[0] == phase) == phases[phase][metric]
                    and sum(v[metric] for key, v in scopes.items() if key[0] == phase) == phases[phase][metric],
                    f'{metric}: phase reconciliation failed: {phase}')
    return {'totals': totals, 'phases': phases, 'scopes': scopes, 'selves': selves,
            'ips': ips, 'joins': joins, 'threads': thread_rows,
            'first_sample_ns': first, 'last_sample_ns': last, 'bounds': bounds}


def counts(value):
    return {m: value[m] for m in METRICS}


def write_csv(path, fields, rows):
    opener = gzip.open if str(path).endswith('.gz') else open
    with opener(path, 'wt', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(fields)
        writer.writerows(rows)


def analyze(samples_path, run_path, maps_path, output, metadata_dir=None, audit_path=None, callsite_dir=None):
    output.mkdir(parents=True, exist_ok=False)
    inputs = [samples_path, run_path, maps_path] + ([audit_path] if audit_path else [])
    before = {str(p): sha(p) for p in inputs}
    run = load_json(run_path)
    validate_run(run)
    maps = parse_maps(load_json(maps_path))
    metadata = load_metadata(metadata_dir, maps, run) if metadata_dir else None
    audit, audit_sha = read_audit(audit_path)
    callsites = load_callsites(callsite_dir, audit_sha) if callsite_dir else None
    result = collect(samples_path, run, maps, metadata,
                     {name for name, row in audit.items() if row['runtime_locations']})
    self_path = output / 'self.csv'
    ip_path = output / 'by-ip.csv.gz'
    joined_path = output / 'self-with-static-metadata.jsonl.gz'
    write_csv(self_path, ('phase', 'scope', 'category', 'dso', 'symbol', 'metadata_join', 'pgcm_function_ids') + METRICS,
              (key[:-1] + (';'.join(key[-1]),) + tuple(value[m] for m in METRICS)
               for key, value in sorted(result['selves'].items(), key=lambda pair: (-pair[1]['period'], pair[0]))))
    write_csv(ip_path, ('phase', 'scope', 'pid', 'tid', 'runtime_ip', 'linked_ip', 'symbol',
                       'symbol_offset', 'dso', 'metadata_join') + METRICS,
              (key + tuple(value[m] for m in METRICS) for key, value in sorted(result['ips'].items(), key=lambda pair: (-pair[1]['period'], str(pair[0])))))
    by_id = {row['function_id']: row for rows in metadata['functions'].values() for row in rows} if metadata else {}
    with gzip.open(joined_path, 'wt') as f:
        for key, value in sorted(result['selves'].items(), key=lambda pair: (-pair[1]['period'], pair[0])):
            row = dict(zip(('phase', 'scope', 'category', 'dso', 'symbol', 'metadata_join', 'pgcm_function_ids'), key))
            row.update(counts(value))
            row['static_pgcm_entries'] = [by_id[fn] for fn in key[-1]]
            row['static_hypothesis_targets'] = callsites['targets'].get(row['symbol'], []) if callsites else []
            row['source_definition_units'] = sorted(callsites['definitions'].get(row['symbol'], ())) if callsites else []
            f.write(json.dumps(row, separators=(',', ':')) + '\n')
    require(all(sha(p) == before[str(p)] for p in inputs), 'analysis input changed while reading')
    summary = {'schema': 1, 'status': 'complete-actual-ip-self-census', 'format': FORMAT,
               'format_validation': FORMAT_STATUS, 'analyzer_sha256': sha(Path(__file__)),
               'inputs': before, 'application': run['application'], 'application_sha256': run['application_sha256'],
               'pid': run['pid'], 'clock': 'CLOCK_MONOTONIC', 'phase_boundary_policy': '[begin,end)',
               'totals': counts(result['totals']),
               'phases': {phase: counts(result['phases'][phase]) for phase in PHASES},
               'phase_scope_totals': [{'phase': phase, 'scope': scope, **counts(result['scopes'][(phase, scope)])}
                                      for phase in PHASES for scope in SCOPES],
               'thread_totals': [{'phase': key[0], 'pid': key[1], 'tid': key[2], **counts(value)}
                                  for key, value in sorted(result['threads'].items())],
               'metadata_join_totals': [{'phase': key[0], 'join': key[1], **counts(value)}
                                        for key, value in sorted(result['joins'].items())],
               'metadata': metadata['receipt'] if metadata else None, 'helper_audit_sha256': audit_sha,
               'callsites': callsites['receipt'] if callsites else None,
               'hypothesis_caller_self_coverage': join_coverage(result['selves'], callsites),
               'first_sample_ns': result['first_sample_ns'], 'last_sample_ns': result['last_sample_ns'],
               'reconciliation': 'integer samples and summed periods reconcile across phases, scopes, self rows and IP rows',
               'limitations': [
                   'Raw installed-perf layout has not yet been supplied; grammar remains provisional.',
                   'Samples are actual IP self only. No caller ancestry or callee subtraction is used.',
                   'Captured maps are a startup-end snapshot; only its exact application mappings support PC joins.',
                   'Symbol prefixes identify naming families, not source-proved GC effects.',
                   'Static map counts are not executed spills. Affected caller self is coverage, never saved time.',
                   'A valid syntax cannot prove an exporter did not omit rows; independently reconcile perf self totals and bind exporter exit0.',
               ],
               'outputs': {p.name: {'sha256': sha(p), 'bytes': p.stat().st_size} for p in (self_path, ip_path, joined_path)}}
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    return summary


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--samples', type=Path, required=True)
    p.add_argument('--run', type=Path, required=True)
    p.add_argument('--maps', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--metadata', type=Path)
    p.add_argument('--helper-audit', type=Path)
    p.add_argument('--callsites', type=Path)
    a = p.parse_args()
    try:
        r = analyze(a.samples, a.run, a.maps, a.output, a.metadata, a.helper_audit, a.callsites)
    except FileExistsError as error:
        print(str(error), file=sys.stderr)
        return 2
    except (InputError, ValueError, OSError, KeyError, TypeError) as error:
        if a.output.is_dir() and not (a.output / 'summary.json').exists():
            (a.output / 'failure.json').write_text(json.dumps({'status': 'failed', 'error': str(error)}) + '\n')
        print(str(error), file=sys.stderr)
        return 2
    print(json.dumps(r['totals']))
    return 0


if __name__ == '__main__':
    sys.exit(main())
