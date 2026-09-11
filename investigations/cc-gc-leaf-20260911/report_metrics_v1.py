from pathlib import Path
from collections import Counter,defaultdict
import csv,json,hashlib
base=Path(__file__).resolve().parent
r=base/'results';totals=defaultdict(Counter);coverage=defaultdict(Counter);prefix=Counter();mapself=Counter();runs=[]
for i in range(1,4):
 s=json.loads((r/f'profile-{i}/summary.json').read_text());run=json.loads((r/f'profile-{i}/run.json').read_text());assert run['pass'];runs.append({'row':i,**run['cpu'],'vmhwm_mib':run['vmhwm_mb']})
 assert json.loads((r/f'profile-{i}/perf-self-reconciliation.json').read_text())['status']=='PASS'
 for row in s['phase_scope_totals']:
  if row['phase'] in ('startup','command') and row['scope']!='foreign_pid':totals[row['phase']].update(samples=row['samples'],period=row['period'])
 for row in s['hypothesis_caller_self_coverage']:
  if row['phase'] in ('startup','command') and row['scope']!='foreign_pid':
   assert row['binding']=='exact_symbol_unique_emission_unit_coverage'
   coverage[(row['phase'],row['hypothesis'])].update(samples=row['samples'],period=row['period'])
 for row in csv.DictReader((r/f'profile-{i}/self.csv').open()):
  if row['phase'] not in ('startup','command') or row['scope']=='foreign_pid':continue
  if row['symbol'].startswith(('perry_fn_','perry_closure_','perry_method_')):prefix[row['phase']]+=int(row['period'])
  if any(k in row['symbol'] for k in ('stack_map','native_frame','shadow','statepoint','scan_native')):mapself[row['phase']]+=int(row['period'])
m=json.loads((r/'machine-loop-coverage.json').read_text());assert dict(totals)==m['phase_target_totals']
leaves=list(csv.DictReader((r/'leaf-candidates-ranked.csv').open()))
static=json.loads((r/'emission-summary.json').read_text());n=static['totals']['post-opt']['statepoints']
view=json.loads((r/'leaf-coverage-summary.json').read_text());barrier=json.loads((r/'fresh-statepoint-windows.json').read_text());roots=json.loads((r/'root-shadow-summary.json').read_text());runtime=list(csv.DictReader((r/'runtime-helpers.csv').open()))
result={'baseline_runs':runs,'phase_target_totals':dict(totals),'coverage':[{'phase':k[0],'hypothesis':k[1],**v,'sampled_cycle_percent':100*v['period']/totals[k[0]]['period']} for k,v in sorted(coverage.items())],'machine_loop_coverage':{phase:{**v,'caller_percent':100*v.get('caller_period',0)/totals[phase]['period'],'loop_percent':100*v.get('candidate_loop_period',0)/totals[phase]['period'],'block_percent':100*v.get('candidate_block_period',0)/totals[phase]['period'],'call_instruction_percent':100*v.get('candidate_call_period',0)/totals[phase]['period']} for phase,v in m['phase_region_coverage'].items()},'machine_functions_admitted':len(m['functions']),'machine_functions_unresolved':len(m['rejected_functions']),'compiled_prefix_self_percent':{phase:100*v/totals[phase]['period'] for phase,v in prefix.items()},'named_map_self_percent':{phase:100*v/totals[phase]['period'] for phase,v in mapself.items()},'runtime_helper_count':len(runtime),'runtime_allocation_classes':dict(Counter(x['allocation_class'] for x in runtime)),'runtime_review_status':dict(Counter(x['audit_status'] for x in runtime)),'remaining_leaf_candidates':len(leaves),'top20_by_gc_points':leaves[:20],'top20_by_all_call_sites':sorted(leaves,key=lambda row:(-int(row['post_opt_call_sites']),row['helper']))[:20],'pre_known_cannot_collect_invokes':sum(roots['pre_known_cannot_collect_invokes'].values()),'post_opt_gc_points':n,'leaf_point_hypotheses':{kind:{**v,'gc_point_percent':100*v['statepoints']/n} for kind,v in view['hypotheses'].items()},'statepoint_window_barriers':barrier['totals'],'fresh_barrier_site_percent':100*barrier['totals']['fresh_with_no_intervening_statepoint']/barrier['totals']['explicit_heap_barrier_sites'],'source_inputs':{str(p.relative_to(base)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [r/'emission-summary.json',r/'leaf-coverage-summary.json',r/'fresh-statepoint-windows.json',r/'machine-loop-coverage.json',r/'runtime-helpers.csv',r/'leaf-candidates-ranked.csv']}}
(r/'report-metrics.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['top20','source_inputs']},indent=2))
