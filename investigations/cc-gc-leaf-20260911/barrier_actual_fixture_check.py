#!/usr/bin/env python3
"""Check observer liveness on exact emitted IR, without native execution."""
import hashlib
import json
from pathlib import Path
import callsite_census as emission
import fresh_barrier_census_v4 as barrier
import fresh_barrier_batch_v4 as batch


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    root = Path(__file__).resolve().parent
    directory = root / 'barrier-actual-fixture-v1'
    original = directory / 'pre-rs4gc.ll'
    expected = '1fb2ecc2ba6d144083603618176d9e065deef945d7bdd7030dbd54bcc00ecb3e'
    assert sha(original) == expected
    audit_path = root / 'audit-v2/helper-audit.csv'
    assert sha(audit_path) == 'b933c0702c5dc2fe2d266c2e0f99f47c8323a108ae5ac11144f4f4000d35af27'
    audit = emission.read_audit(audit_path)
    noncollecting = [n for n, r in audit.items() if r['current_effect'] == 'CannotCollect']
    extra = [n for n, r in audit.items() if r['current_effect'] == 'Unknown'
             and r['audit_status'] == 'reviewed' and r['may_collect'] == 'no'
             and r['may_reenter_js'] == 'no']
    assert (len(noncollecting), len(extra)) == (80, 48)
    text = original.read_text()
    # The batch's pointer-width contract is part of this real-input check.
    digest = hashlib.sha256()
    assert len(list(batch.function_texts(text.splitlines(keepends=True), digest,
                                        require_layout=True))) == 18
    assert digest.hexdigest() == expected
    anchor = '  call void @js_write_barrier_root_nanbox(i64 %r14) #11\n'
    assert anchor in text
    changed = text.replace(anchor, '  call void @hypothetical_collecting_edge()\n' + anchor, 1)
    changed += '\ndeclare void @hypothetical_collecting_edge()\n'
    results = {}
    for name, contents in [('original', text), ('collecting-arm', changed)]:
        result = barrier.analyze(contents, extra, noncollecting,
                                 local_aliases=True, intersect_joins=True)
        assert len(result['functions']) == 18
        assert not any(f.get('excluded') for f in result['functions'])
        assert result['strict_barrier_sites'] == 5
        assert result['extra_leaf_fresh_origin_sites'] == 0
        result['input_sha256'] = hashlib.sha256(contents.encode()).hexdigest()
        result['analyzer_sha256'] = sha(Path(barrier.__file__))
        result['helper_audit_sha256'] = sha(audit_path)
        results[name] = result
    assert results['original']['strict_fresh_origin_sites'] == 2
    assert results['collecting-arm']['strict_fresh_origin_sites'] == 1
    expected_lost = 'perry_fn_diagnostic_fixture_ts__exercise$spec_i32'
    hit_names = lambda r: {f['function'] for f in r['functions']
                           if any(b['allocation_origin'] for b in f.get('barriers', []))}
    assert hit_names(results['original']) - hit_names(results['collecting-arm']) == {expected_lost}
    # These assertions fail if the observer retains facts on the collecting arm.
    for name, result in results.items():
        (directory / ('observed-v4-' + name + '.json')).write_text(json.dumps(result, indent=2) + '\n')
    (directory / 'counterfactual-collecting-arm.ll').write_text(changed)
    paths = [original, audit_path, Path(__file__), Path(barrier.__file__), Path(batch.__file__),
             directory / 'counterfactual-collecting-arm.ll']
    paths += [directory / ('observed-v4-' + n + '.json') for n in results]
    receipt = {
        'schema': 1, 'status': 'PASS',
        'scope': 'real emitted IR observer liveness; counterfactual text analysis, no native execution',
        'admitted_functions': 18, 'excluded_functions': 0, 'explicit_barrier_sites': 5,
        'original_fresh_origin_sites': 2, 'collecting_arm_fresh_origin_sites': 1,
        'extra_48_sites': 0, 'lost_function': expected_lost,
        'files': [{'path': str(p.relative_to(root)), 'bytes': p.stat().st_size,
                   'sha256': sha(p)} for p in paths],
        'limits': ['static reachable sites, not dynamically executed barriers',
                   'allocation generation/publication remains unknown',
                   'no claim that generational, incremental, or layout work can be removed'],
    }
    (directory / 'v4-real-input-receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({k: v for k, v in receipt.items() if k != 'files'}, indent=2))


if __name__ == '__main__':
    main()
