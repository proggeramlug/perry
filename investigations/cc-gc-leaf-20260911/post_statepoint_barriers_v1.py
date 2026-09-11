#!/usr/bin/env python3
"""Conservative fresh-origin census between actual rewritten statepoints.

Builds a dataflow-only text view. This view is never compiled or executed.
Every actual statepoint clears facts, even when its callee is CannotCollect.
Only an allocator call-token fact can flow through its actual gc.result.
Allocator invoke returns and relocated/phi aliases remain unresolved.
"""
import argparse
from collections import Counter
import csv
import gzip
import hashlib
import json
import multiprocessing
from pathlib import Path
import re
import sys
sys.path.insert(0,str(Path(__file__).parent/'parser-v4'))
import callsite_census as c
import fresh_barrier_post_core_v1 as core
from fresh_barrier_batch_v4 import function_texts

HEAP_BARRIER = re.compile(r'@"?(?:js_write_barrier_slot_validated_parent|js_write_barrier_slot|js_write_barrier)(?![A-Za-z0-9_])')

def normalize(text):
    lines=text.splitlines(True)
    records=[r for r in c.records(iter(lines)) if r[0]=='call']
    tokens={}; replacements={}; safe=set(); original_points=[]
    for _,fn,block,line,record in records:
        lhs,op,target,args,suffix=c.call_parts(record)
        symbol=c.name(target) if target.startswith('@') else target
        if symbol.startswith('llvm.experimental.gc.statepoint.'):
            assert lhs and len(args)>=5
            callee=c.value_token(args[2]); name=c.name(callee) if callee.startswith('@') else '<indirect>'
            match=re.fullmatch(r'i32 (\d+)',args[3]);assert match
            actual=args[5:5+int(match[1])];assert len(actual)==int(match[1])
            tokens[lhs]=(name,op)
            outcallee=callee if callee.startswith('@') else '@__census_indirect_boundary'
            unwind=''
            if op=='invoke':
                m=re.search(r'\bto label\s+%'+c.NAME+r'\s+unwind label\s+%'+c.NAME,suffix);assert m
                unwind=' '+m[0]
            replacements[line]=(f'  {lhs} = {op} i64 {outcallee}('+', '.join(actual)+')'+unwind+'\n',True)
            original_points.append({'line':line,'callee':name,'block':block})
    for _,fn,block,line,record in records:
        lhs,op,target,args,suffix=c.call_parts(record)
        symbol=c.name(target) if target.startswith('@') else target
        if symbol.startswith('llvm.experimental.gc.result.'):
            assert lhs and len(args)==1
            token=c.value_token(args[0]);assert token in tokens
            allocator,_=tokens[token]
            if allocator in core.ALLOCATORS:
                replacements[line]=(f'  {lhs} = bitcast i64 {token} to i64\n',False)
            else:
                replacements[line]=(f'  {lhs} = call i64 @__census_result_unknown()\n',False)
                safe.add('__census_result_unknown')
        elif line not in replacements:
            # In a GC-strategy function after RS4GC, these are not statepoints.
            if target.startswith('@'):safe.add(symbol)
    ends={}
    for _,fn,block,line,record in records:
        joined=c.uncomment(lines[line-1]);end=line
        while not c.call_complete(joined):
            joined+=' '+c.uncomment(lines[end]);end+=1
        ends[line]=end
    output=[]; forced=set(); origin_lines={}; i=1
    while i<=len(lines):
        if i in replacements:
            replacement,is_point=replacements[i]
            next_line=len(output)+1
            if is_point:forced.add(next_line)
            origin_lines[next_line]=i
            output.append(replacement);i=ends[i]+1
        else:
            origin_lines[len(output)+1]=i
            output.append(lines[i-1]);i+=1
    return ''.join(output),forced,safe,origin_lines,original_points

def analyze_function(text):
    normalized,points,safe,origin_lines,original_points=normalize(text)
    core.FORCED_COLLECT_LINES=frozenset(points)
    parsed,groups,declared=core.parse(normalized)
    assert len(parsed)==1
    result=core.analyze_function(parsed[0],groups,declared,set(),safe,True,True)
    for row in result.get('barriers',[]):row['original_function_line']=origin_lines[row['line']]
    return result,original_points

def unit(args):
    name,text_root,out=args
    source=text_root/name/'post-rs4gc.ll';digest=hashlib.sha256();tot=Counter();excluded=[]
    target=out/(name+'.jsonl.gz')
    with source.open() as lines,gzip.open(target,'wt',compresslevel=1) as stream:
        for start,end,text in function_texts(lines,digest,require_layout=True):
            tot['functions_seen']+=1
            if 'gc "statepoint-example"' not in text.splitlines()[0]:
                tot['outside_native_strategy_functions']+=1;continue
            tot['native_strategy_functions']+=1
            if not HEAP_BARRIER.search(text):
                tot['native_functions_without_heap_barrier_reference']+=1;continue
            try:
                result,points=analyze_function(text)
                if result.get('excluded'):raise ValueError('; '.join(result['excluded']))
                tot['analyzed_functions']+=1
                bars=result.get('barriers',[])
                tot['explicit_heap_barrier_sites']+=len(bars)
                hits=[r for r in bars if r['allocation_origin']]
                tot['fresh_with_no_intervening_statepoint']+=len(hits)
                tot['unresolved_parent_sites']+=len(bars)-len(hits)
                stream.write(json.dumps({'function':result['function'],'definition_line':start,'sites':len(bars),'fresh_sites':len(hits),'hits':hits},separators=(',',':'))+'\n')
            except (ValueError,AssertionError,KeyError,IndexError) as exc:
                row={'definition_line':start,'header':text.splitlines()[0],'error':str(exc)}
                excluded.append(row);stream.write(json.dumps({'excluded':row})+'\n')
    result={'attempt':name,'counts':dict(tot),'excluded':excluded,'source_sha256':digest.hexdigest(),'source':str(source),'rows_sha256':c.sha(target)}
    (out/(name+'.summary.json')).write_text(json.dumps(result,indent=2)+'\n')
    print('POST_BARRIER_UNIT',name,dict(tot),flush=True)
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--primary',type=Path,required=True);p.add_argument('--text-root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir()
    primary=json.loads((a.primary/'summary.json').read_text());assert primary['status']=='complete-static-emission-census'
    tasks=[(Path(r['directory']).name,a.text_root,a.out) for r in primary['accepted_attempts']]
    with multiprocessing.get_context('fork').Pool(6) as pool:units=pool.map(unit,tasks)
    hashes={r['path']:r['sha256'] for r in primary['converted_ir_receipts']};tot=Counter()
    for u in units:assert u['source_sha256']==hashes[u['source']];tot.update(u['counts'])
    result={'status':'partial' if any(u['excluded'] for u in units) else 'complete-conservative-native-statepoint-window-census','totals':dict(tot),'units':units,'primary_summary_sha256':c.sha(a.primary/'summary.json'),'analyzers':{Path(p).name:c.sha(p) for p in (__file__,core.__file__,c.__file__)},'limits':['Native GC-strategy functions only; shadow fallback is separate.','Post-RS4GC, before final optimization; all actual statepoints kill facts, including redundant leaf-helper points.','Only audited direct-call allocator tokens survive through gc.result; invoke allocator results and phi/select/relocate aliases remain unresolved.','Fresh origins are a conservative lower bound, not proven young objects or justified barrier removals.','Normalized dataflow views are never compiled or executed.']}
    (a.out/'summary.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'status':result['status'],'totals':dict(tot)},indent=2))

if __name__=='__main__':main()
