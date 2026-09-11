#!/usr/bin/env python3
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import statistics
import time

STAGE=Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
RUN=STAGE/'callsite-execution-v3'
WORKER=3689341
COORDINATOR=3689340
LOCK=Path('/root/rig9831/lock')


def sha(path):
 with Path(path).open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()


def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m


def proc(pid):
 p=Path(f'/proc/{pid}')
 return {'pid':pid,'argv':[x.decode() for x in (p/'cmdline').read_bytes().split(b'\0') if x],
         'cwd':os.readlink(p/'cwd'),'state':(p/'stat').read_text().split()[2]}


row={'started_ns':time.time_ns()}; stopped=False; superseded=False
try:
 worker=proc(WORKER);coordinator=proc(COORDINATOR)
 assert worker['argv']==json.loads((RUN/'census.command.json').read_text())['argv']
 assert worker['cwd']==str(STAGE)
 assert coordinator['argv']==['python3','-B',str(STAGE/'resume_callsite_v3.py')]
 assert coordinator['cwd']==str(STAGE)
 assert (LOCK/'owner').read_text().strip()==f'cc-gcleaf-callsite-v3 {COORDINATOR}'
 assert not Path(f'/proc/{WORKER}/task/{WORKER}/children').read_text().strip()
 row.update(worker_before=worker,coordinator_before=coordinator,lock_owner=(LOCK/'owner').read_text().strip())
 os.kill(WORKER,signal.SIGSTOP);stopped=True
 for _ in range(200):
  if proc(WORKER)['state'] in ('T','t'):break
  time.sleep(.01)
 assert proc(WORKER)['state'] in ('T','t')
 source=STAGE/'cc-ir-text-v1/pid-3681178-attempt-104/post-rs4gc.ll'
 oldpath=STAGE/'parser-v2/callsite_census.py';newpath=STAGE/'callsite_fast_inventory_v3.py'
 old=load('old_inventory',oldpath);new=load('new_inventory',newpath)
 row.update(input=str(source),input_sha256=sha(source),input_bytes=source.stat().st_size,
            old_parser_sha256=sha(oldpath),new_parser_sha256=sha(newpath))
 results=[];expected=None
 for label,module in [('old',old),('new',new),('new',new),('old',old)]:
  cpu=time.process_time();wall=time.perf_counter()
  with source.open() as f:inventory=module.inventory(f)
  results.append({'arm':label,'cpu_seconds':time.process_time()-cpu,'wall_seconds':time.perf_counter()-wall})
  if expected is None:expected=inventory
  else:assert inventory==expected,'inventory mismatch'
 row.update(results=results,equal=True,
            definitions=len(expected['definitions']),declarations=len(expected['declarations']),
            aliases=len(expected['aliases']),shadow_functions=len(expected['shadow']))
 old_cpu=statistics.median(x['cpu_seconds'] for x in results if x['arm']=='old')
 new_cpu=statistics.median(x['cpu_seconds'] for x in results if x['arm']=='new')
 row['cpu_speedup']=old_cpu/new_cpu
 if row['cpu_speedup']>=2:
  row['decision']='supersede old diagnostic parser; release to already waiting profile queue'
  os.kill(WORKER,signal.SIGTERM);os.kill(WORKER,signal.SIGCONT);superseded=True;stopped=False
  for _ in range(200):
   if not Path(f'/proc/{COORDINATOR}').exists():break
   time.sleep(.02)
  row['worker_after']=proc(WORKER) if Path(f'/proc/{WORKER}').exists() else 'absent'
  row['coordinator_after']=proc(COORDINATOR) if Path(f'/proc/{COORDINATOR}').exists() else 'absent'
  row['lock_after']=(LOCK/'owner').read_text().strip() if (LOCK/'owner').exists() else None
 else:row['decision']='resume original worker; measured speedup below 2x'
 row['finished_ns']=time.time_ns()
finally:
 if stopped and not superseded:
  os.kill(WORKER,signal.SIGCONT)
 (RUN/'inventory-benchmark-v3.json').write_text(json.dumps(row,indent=2)+'\n')
print(json.dumps(row,indent=2))
