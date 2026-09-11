#!/usr/bin/env python3
"""Derive caller coverage for existing CannotCollect and new runtime leaves."""
import argparse
from collections import Counter, defaultdict
import csv
import gzip
import hashlib
import json
import os
from pathlib import Path

def sha(path):
    with Path(path).open('rb') as stream: return hashlib.file_digest(stream, 'sha256').hexdigest()

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--primary', type=Path, required=True)
    p.add_argument('--audit', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); a.out.mkdir()
    primary = json.loads((a.primary/'summary.json').read_text())
    assert primary['status'] == 'complete-static-emission-census'
    assert sha(a.audit) == primary['helper_audit_sha256']
    audit = {r['helper']:r for r in csv.DictReader(a.audit.open())}
    known = {n for n,r in audit.items() if r['current_effect']=='CannotCollect'}
    new = {n for n,r in audit.items() if r['current_effect']=='Unknown' and r['audit_status']=='reviewed' and r['may_collect']=='no' and r['may_reenter_js']=='no'}
    assert len(new)==48 and known.isdisjoint(new)
    for name in ('by-block.csv.gz','by-callee.csv','definitions.csv','post-opt-hypothesis-targets.csv'):
        assert sha(a.primary/name)==primary['outputs'][name]['sha256'], name
    rows = defaultdict(Counter); observed = Counter(); zero_live = Counter()
    with gzip.open(a.primary/'by-block.csv.gz','rt',newline='') as stream:
        for row in csv.DictReader(stream):
            if row['stage']!='post-opt' or row['category']!='runtime' or row['callee'] not in known|new:
                continue
            points=int(row['statepoints']); live=int(row['gc_live_operands'])
            if not points: continue
            observed[row['callee']] += points
            kinds=['direct-all-runtime-leaves']
            if row['callee'] in known: kinds.append('direct-known-cannot-collect')
            for kind in kinds:
                key=(kind,row['callee'],row['attempt'],row['caller'])
                rows[key].update(statepoints=points,gc_live_operands=live)
                if live==0: zero_live[kind]+=points
    expected=Counter()
    with (a.primary/'by-callee.csv').open(newline='') as stream:
        for row in csv.DictReader(stream):
            if row['stage']=='post-opt' and row['category']=='runtime' and row['callee'] in known|new:
                expected[row['callee']]+=int(row['statepoints'])
    assert observed==expected,'block and callee site totals differ'
    target=a.out/'post-opt-hypothesis-targets.csv'
    with (a.primary/target.name).open(newline='') as stream:
        original=list(csv.DictReader(stream))
    fields=['hypothesis','callee_identity','attempt','caller','statepoints','gc_live_operands']
    with target.open('x',newline='') as stream:
        writer=csv.writer(stream);writer.writerow(fields)
        for row in original:writer.writerow([row[k] for k in fields])
        for key,counts in sorted(rows.items()):writer.writerow((*key,counts['statepoints'],counts['gc_live_operands']))
    os.link(a.primary/'definitions.csv',a.out/'definitions.csv')
    counts={kind:{field:sum(v[field] for k,v in rows.items() if k[0]==kind) for field in ('statepoints','gc_live_operands')} for kind in ('direct-known-cannot-collect','direct-all-runtime-leaves')}
    result={'status':'complete-derived-leaf-coverage','source_primary_summary_sha256':sha(a.primary/'summary.json'),
            'source_by_block_sha256':primary['outputs']['by-block.csv.gz']['sha256'],
            'source_by_callee_sha256':primary['outputs']['by-callee.csv']['sha256'],
            'helper_audit_sha256':sha(a.audit),'analyzer_sha256':sha(__file__),
            'hypotheses':counts,'zero_live_points_in_zero_sum_blocks_lower_bound':dict(zero_live),
            'outputs':{name:{'sha256':sha(a.out/name),'bytes':(a.out/name).stat().st_size} for name in ('definitions.csv',target.name)},
            'limits':['Derived static coverage view; no new compilation or GC classification.','Existing CannotCollect is the compiler contract, not an independent proof of every runtime body.','Combined and separate hypotheses overlap; do not sum their CPU coverage.','Zero-live block-group total is a lower bound on zero-live statepoints.']}
    (a.out/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(counts,indent=2))

if __name__=='__main__':main()
