#!/usr/bin/env python3
"""Run the unchanged barrier-v4 observer over six disjoint unit shards."""
import argparse
from collections import Counter
import json
import multiprocessing
from pathlib import Path
import shutil
import fresh_barrier_batch_v4 as batch

def run_shard(args):
    captures, audit, output, llvm_dis, text = args
    return batch.run(captures, audit, output, llvm_dis, text)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--captures', type=Path, required=True)
    p.add_argument('--helper-audit', type=Path, required=True)
    p.add_argument('--text-root', type=Path)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--llvm-dis', default='/usr/lib/llvm-22/bin/llvm-dis')
    a = p.parse_args()
    a.output.mkdir()
    attempts, abandoned = batch.emission.read_attempts(a.captures)
    shard_count = min(6, len(attempts))
    roots = []
    for i in range(shard_count):
        root = a.output / f'inputs-{i}'
        root.mkdir(); roots.append(root)
    for i, attempt in enumerate(attempts):
        directory = attempt['directory']
        (roots[i % shard_count] / directory.name).symlink_to(directory.resolve(), target_is_directory=True)
    tasks = [(root, a.helper_audit, a.output / f'part-{i}', a.llvm_dis, a.text_root) for i, root in enumerate(roots)]
    with multiprocessing.get_context('fork').Pool(shard_count) as pool:
        parts = pool.map(run_shard, tasks)
    result = dict(parts[0])
    units = [unit for part in parts for unit in part['units']]
    units.sort(key=lambda unit: unit['attempt'])
    assert [u['attempt'] for u in units] == sorted(x['directory'].name for x in attempts)
    for unit in units:
        original = a.captures / unit['attempt']
        assert unit['complete_sha256'] == batch.emission.sha(original / 'complete.json')
        assert unit['attempt_sha256'] == batch.emission.sha(original / 'attempt.json')
    for key in ('totals', 'unresolved_parent_reasons', 'unresolved_parent_definition_opcodes'):
        counts = Counter()
        for part in parts: counts.update(part[key])
        result[key] = dict(counts)
    for key in ('helper_audit_sha256', 'cannot_collect_summary_count', 'extra_hypothesis_summary_count', 'analyzers'):
        assert all(part[key] == result[key] for part in parts), key
    for name in ('cannot-collect.json', 'extra-48.json'):
        assert len({part['files'][name]['sha256'] for part in parts}) == 1
        shutil.copyfile(a.output / 'part-0' / name, a.output / name)
    with (a.output / 'functions.jsonl.gz').open('xb') as dest:
        for i in range(shard_count):
            with (a.output / f'part-{i}' / 'functions.jsonl.gz').open('rb') as source:
                shutil.copyfileobj(source, dest)
    result.update(units=units, completed_attempts=len(attempts), incomplete_attempts_excluded=abandoned,
                  status='partial-static-barrier-census' if any(p['status'].startswith('partial') for p in parts) else 'complete-static-barrier-census',
                  parallel_observer_sha256=batch.emission.sha(__file__), shard_count=shard_count,
                  aggregation='disjoint original attempt identities; unchanged v4 function analysis; concatenated gzip members')
    result['files'] = {name: {'sha256': batch.emission.sha(a.output / name), 'bytes': (a.output / name).stat().st_size}
                       for name in ('functions.jsonl.gz', 'cannot-collect.json', 'extra-48.json')}
    (a.output / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'status': result['status'], 'totals': result['totals']}, sort_keys=True))
    return 2 if result['status'].startswith('partial') else 0

if __name__ == '__main__':
    raise SystemExit(main())
