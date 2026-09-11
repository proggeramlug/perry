import csv
import io
import json
from pathlib import Path
import tempfile
import unittest
import callsite_census as c

AUDIT = {h:dict(helper=h,audit_status='reviewed',current_effect=e,may_collect='no',may_reenter_js='no',runtime_locations='crates/perry-runtime/src/fixture.rs:1') for h,e in [('js_candidate','Unknown'),('js_already','CannotCollect')]}
PRE = '''
@text = private constant [6 x i8] c"alias\\00"
@user_alias = alias void (), ptr @user_leaf
declare void @js_candidate()
declare void @js_already() #7
declare i64 @external_libc()
declare double @llvm.sqrt.f64(double)
define void @user_leaf() {
  ret void
}
define void @caller(ptr %fp) gc "statepoint-example" {
entry:
  call void @js_already()
  call void @js_candidate() #7
  invoke void @js_candidate()
    to label %next unwind label %eh
next:
  call void %fp(ptr @js_candidate)
  call void @user_leaf()
  call void @user_alias()
  %r = call i64 @external_libc()
  %s = call double @llvm.sqrt.f64(double 1.0)
  call void asm sideeffect "", ""() #7
  ret void
eh:
  %lp = landingpad token cleanup
  ret void
}
attributes #7 = { "gc-leaf-function" }
'''
POST = '''
declare void @js_candidate()
declare token @llvm.experimental.gc.statepoint.p0(i64, i32, ptr, i32, i32, ...)
declare ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token, i32, i32)
define void @caller(ptr %fp, ptr addrspace(1) %a, ptr addrspace(1) %b) gc "statepoint-example" {
entry:
  %sp = call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 123, i32 0, ptr @js_candidate, i32 0, i32 0, i32 0, i32 0) [ "gc-live"(ptr addrspace(1) %a, ptr addrspace(1) %b) ]
  %r = call ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token %sp, i32 0, i32 0)
  %si = invoke token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 124, i32 0, ptr %fp, i32 0, i32 0, i32 0, i32 0) [ "gc-live"(ptr addrspace(1) %a) ]
    to label %next unwind label %eh
next:
  %ri = call ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token %si, i32 0, i32 0)
  ret void
eh:
  %lp = landingpad token cleanup
  %re = call ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token %lp, i32 0, i32 0)
  ret void
}
'''

def get_rows(ir, pre_ir=None, nonruntime=frozenset()):
    inv=c.inventory(io.StringIO(ir)); pre=c.inventory(io.StringIO(pre_ir if pre_ir is not None else ir))
    rows={}
    for _, blockrows in c.function_counts(io.StringIO(ir),inv,pre,inv['definitions'].keys()|pre['definitions'].keys(),AUDIT,nonruntime): rows.update(blockrows)
    return rows

def metric(rows,callee,key): return sum(m[key] for r,m in rows.items() if r[-1]==callee)

def fixture_attempt(root,mirror,attempt=0,complete=True):
    directory=root/f'pid-123-attempt-{attempt}';directory.mkdir(parents=True)
    textdir=mirror/directory.name;textdir.mkdir(parents=True)
    metadata=dict(schema=1,pid=123,attempt=attempt,module='perry_native_module',target='x86_64-unknown-linux-gnu',native_roots_requested=True,optimization='3',emission='assembly',snapshot_format='llvm-bitcode')
    (directory/'attempt.json').write_text(json.dumps(metadata)); snapshots=[]
    for stage,text in zip(c.STAGES,(PRE,POST,POST)):
        # Synthetic transport bytes; supplied text mirrors are parser fixtures,
        # not an assertion that this fake transport payload is LLVM bitcode.
        payload=('test transport '+stage).encode();(directory/(stage+'.bc')).write_bytes(payload)
        (textdir/(stage+'.ll')).write_text(text);snapshots.append(dict(file=stage+'.bc',bytes=len(payload)))
    if complete:(directory/'complete.json').write_text(json.dumps(dict(schema=1,status='llvm-emission-succeeded',snapshots=snapshots,emitted_bytes=123,bounded_o0_machine_emission=False)))
    return directory

class CensusTests(unittest.TestCase):
    def test_fixed_point_scopes_recursion_and_collecting_exit(self):
        a = '''declare void @js_candidate()
define internal void @same() {
 call void @js_candidate()
 ret void
}
define void @wrap() {
 call void @same()
 ret void
}
define void @across() {
 call void @public_b()
 ret void
}
define void @cycle_a() {
 call void @cycle_b()
 ret void
}
define void @cycle_b() {
 call void @cycle_a()
 call void @js_candidate()
 ret void
}
'''
        b = '''declare void @js_candidate()
define internal void @same() {
 call void @js_gc_loop_safepoint()
 ret void
}
define void @public_b() {
 call void @js_candidate()
 ret void
}
'''
        texts={'A':a,'B':b}; inv={u:c.inventory(io.StringIO(t)) for u,t in texts.items()};visible=c.visible_definitions(inv)
        self.assertNotIn('same',visible)
        results={}
        for cross in (False,True):
            graph={}
            for u,t in texts.items():graph.update(c.effect_graph(io.StringIO(t),u,inv[u],AUDIT,inv,visible,cross))
            old=c.proven_functions(graph,'base_blocked');new=c.proven_functions(graph,'extra_blocked')-old
            self.assertEqual(old,set())
            self.assertTrue({'A::same','A::wrap','A::cycle_a','A::cycle_b','B::public_b'} <= new)
            self.assertNotIn('B::same',new)
            self.assertEqual('A::across' in new,cross)
            results[cross]=new
        # Same-unit and cross-unit target sites are distinct hypotheses.
        for target, expected_local in (('wrap', True), ('public_b', False)):
            post=POST.replace('ptr @js_candidate, i32 0','ptr @'+target+', i32 0')
            pi=c.inventory(io.StringIO(post))
            counts=c.statepoint_opportunities(io.StringIO(post),'A',pi,inv,visible,results[False],results[True],AUDIT)
            self.assertEqual(sum(v['statepoints'] for k,v in counts.items() if k[0]=='new-local-user'),int(expected_local))
            self.assertEqual(sum(v['statepoints'] for k,v in counts.items() if k[0]=='new-unique-visible-user'),1)
            self.assertTrue(all(k[2:]==('A','caller') for k in counts))
        # A poll in either member must reject the entire recursive component.
        altered=a.replace(' call void @js_candidate()\n ret void\n}\n', ' call void @js_gc_loop_safepoint()\n ret void\n}\n')
        ai=c.inventory(io.StringIO(altered)); units={**inv,'A':ai}
        graph=c.effect_graph(io.StringIO(altered),'A',ai,AUDIT,units,c.visible_definitions(units),False)
        self.assertNotIn('A::cycle_a',c.proven_functions(graph,'extra_blocked'))
        # Multiple visible definitions must not be resolved by spelling.
        duplicate=c.inventory(io.StringIO(b.replace('@public_b','@across')))
        units={**inv,'C':duplicate};v=c.visible_definitions(units)
        self.assertIsNone(c.resolve_function('B','across',units,v,True))

    def test_exact_dispatch_ledger_and_unknown_relocate_rejection(self):
        audit={**AUDIT}
        for symbol in ('js_native_call_method','js_closure_call16','js_object_get_field_ic_miss'):
            audit[symbol]=dict(runtime_locations='crates/perry-runtime/src/fixture.rs:9')
        for symbol in ('js_native_call_method','js_closure_call16'):
            self.assertEqual(c.classify('@'+symbol,set(),audit,{})[0],'dynamic-dispatch')
        self.assertEqual(c.classify('@js_object_get_field_ic_miss',set(),audit,{})[0],'runtime')
        self.assertEqual(c.classify('@js_not_in_audit',set(),audit,{})[0],'external-unclassified')
        with self.assertRaisesRegex(ValueError,'unresolved gc.relocate token'):
            get_rows(POST.replace('token %sp,','token %missing,'),PRE)

    def test_direct_indirect_invoke_alias_attributes_and_asm_are_disjoint(self):
        rows=get_rows(PRE,nonruntime={'external_libc'})
        self.assertEqual(sum(m['callsites'] for m in rows.values()),9)
        for callee,key,count in [('js_candidate','callsites',2),('js_candidate','leaf_callsites',1),('js_already','leaf_callsites',1),('user_leaf','callsites',2),('<indirect>','callsites',1),('<inline-asm>','callsites',1)]: self.assertEqual(metric(rows,callee,key),count)
        self.assertEqual({r[-2] for r in rows},{'runtime','static-user','dynamic-dispatch','LLVM','inline-asm','nonruntime-external'})
        self.assertTrue(all(r[2]=='native' for r in rows))
    def test_actual_statepoint_third_argument_and_relocate_tokens(self):
        rows=get_rows(POST,PRE)
        self.assertEqual(sum(m['callsites'] for m in rows.values()),5)
        self.assertEqual(sum(m['statepoints'] for m in rows.values()),2)
        for callee,key,count in [('js_candidate','statepoints',1),('<indirect>','statepoints',1),('js_candidate','gc_live_operands',2),('<indirect>','gc_live_operands',1),('js_candidate','relocates_attributed',1),('<indirect>','relocates_attributed',2)]: self.assertEqual(metric(rows,callee,key),count)
        self.assertEqual(sum(m['relocates_unattributed'] for m in rows.values()),0)
        # Only change the third statepoint argument: a wrapper-name or
        # first-argument parser cannot satisfy both predicates.
        altered=get_rows(POST.replace('ptr @js_candidate, i32 0','ptr %fp, i32 0'),PRE)
        self.assertEqual(metric(altered,'js_candidate','statepoints'),0)
        self.assertEqual(metric(altered,'<indirect>','statepoints'),2)
    def test_shadow_and_unobserved_are_not_conflated(self):
        ir='declare void @js_shadow_frame_enter()\ndefine void @f() {\n call void @js_shadow_frame_enter()\n ret void\n}\ndefine void @g() {\n call void @js_candidate()\n ret void\n}\n'
        rows=get_rows(ir)
        self.assertEqual({r[2] for r in rows if r[0]=='f'},{'shadow-observed'})
        self.assertEqual({r[2] for r in rows if r[0]=='g'},{'no-root-mechanism-observed'})
    def test_missing_attributes_unsupported_targets_and_truncation_reject(self):
        with self.assertRaisesRegex(ValueError,'missing attribute'):get_rows(PRE.replace('attributes #7 = { "gc-leaf-function" }',''))
        with self.assertRaisesRegex(ValueError,'unsupported'):get_rows(POST.replace('ptr @js_candidate, i32 0','ptr inttoptr (i64 42 to ptr), i32 0'),PRE)
        with self.assertRaisesRegex(ValueError,'truncated'):list(c.records(io.StringIO('define void @f() {\n call void @a(\n')))
        with self.assertRaisesRegex(ValueError,'unbalanced'):c.split_top('i64 1, ptr )')
    def test_complete_attempts_only_ranking_and_already_annotated_split(self):
        with tempfile.TemporaryDirectory() as temporary:
            tmp=Path(temporary);root=tmp/'captures';mirror=tmp/'text'
            fixture_attempt(root,mirror);fixture_attempt(root,mirror,1,complete=False)
            audit=tmp/'audit.csv'
            with audit.open('w',newline='') as f:
                w=csv.DictWriter(f,fieldnames=list(next(iter(AUDIT.values()))));w.writeheader();w.writerows(AUDIT.values())
            result=c.analyze(root,audit,tmp/'out',text_root=mirror)
            self.assertEqual(len(result['accepted_attempts']),1);self.assertEqual(len(result['excluded_incomplete_attempts']),1)
            top=result['top20_reviewed_unknown_never_collect_helpers'];self.assertEqual(len(top),1)
            self.assertEqual((top[0]['helper'],top[0]['pre_callsites'],top[0]['pre_already_annotated_leaf'],top[0]['post_opt_statepoints']),('js_candidate',2,1,1))
            self.assertEqual(result['already_classified_reviewed_never_collect_helpers'][0]['helper'],'js_already')
            self.assertEqual(result['totals']['post-rs4gc']['callsites'],5)
            with (tmp/'out'/'definitions.csv').open() as f:
                definitions=list(csv.DictReader(f))
            self.assertTrue(any(r['stage']=='pre-rs4gc' and r['symbol']=='user_leaf' for r in definitions), 'zero-call definitions must remain available for symbol ambiguity checks')
            fixture_attempt(root,mirror,2)
            with self.assertRaisesRegex(ValueError,'duplicate successful'):c.analyze(root,audit,tmp/'duplicates',text_root=mirror)
    def test_changed_record_malformed_completion_and_all_failed_are_not_zero(self):
        with tempfile.TemporaryDirectory() as temporary:
            tmp=Path(temporary);root=tmp/'captures';mirror=tmp/'text';directory=fixture_attempt(root,mirror,complete=False)
            with self.assertRaisesRegex(ValueError,'no completed'):c.read_attempts(root)
            (directory/'complete.json').write_text('{')
            with self.assertRaises(ValueError):c.read_attempts(root)
            (directory/'complete.json').write_text(json.dumps(dict(schema=1,status='llvm-emission-succeeded',snapshots=[],emitted_bytes=123,bounded_o0_machine_emission=False)))
            with self.assertRaisesRegex(ValueError,'snapshot stages'):c.read_attempts(root)
            meta=dict(schema=1,status='llvm-emission-succeeded',emitted_bytes=123,bounded_o0_machine_emission=False,snapshots=[dict(file=s+'.bc',bytes=(directory/(s+'.bc')).stat().st_size) for s in c.STAGES]);meta['snapshots'][1]['bytes']+=1
            (directory/'complete.json').write_text(json.dumps(meta))
            with self.assertRaisesRegex(ValueError,'length mismatch'):c.read_attempts(root)

if __name__=='__main__': unittest.main()
