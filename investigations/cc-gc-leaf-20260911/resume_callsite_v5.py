#!/usr/bin/env python3
"""Resume exact completed emission after the versioned LLVM string-lexer fix."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import traceback

STAGE = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
RUN = STAGE / 'callsite-execution-v5'
OUT = STAGE / 'callsite-v5'
LOCK = Path('/root/rig9831/lock')
EXPECTED = {
 'parser-parallel-proof-v2/result.json': '28bd7273e585e27e4e0ab19a442b8ff79fc3424ef5c9a02bb1bf3ac687650cdd',
 'parser-v4/callsite_census.py': 'e0f69e82b5f854df5cbde93289b799c63fd48d8e7076c529463df10ae0377dd8',
 'helper-audit-v2.csv': 'b933c0702c5dc2fe2d266c2e0f99f47c8323a108ae5ac11144f4f4000d35af27',
 'callsite-execution-v2/conversion.json': '478ae2300261fd4d97918e48e709b265a178dce0b15333ead62c5aa17d47efde',
 'callsite-execution-v2/failure.json': '5296011a6b69c15573df33ce05d6a476bd5113d9a31a325f418cfde640a53451',
 'compile-v2/COMPILE_COMPLETE.json': '5dc8f0483949c20e9f93f751455646584970c20c903b1faf63cfd77d15170169',
 'callsite_supplement_v1.py': '6b3031b0092d0071e6e0f9c6da3d4236255142380d82f79c9edd08ca80c6f3f2',
}
child = None


def sha(path):
 with Path(path).open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()


def save(name, value):
 (RUN/name).write_text(json.dumps(value,indent=2)+'\n')


def command(argv, label):
 global child
 row={'argv':list(map(str,argv)),'cwd':str(STAGE),'started_ns':time.time_ns()}
 with (RUN/(label+'.log')).open('x') as stream:
  child=subprocess.Popen(argv,cwd=STAGE,stdout=stream,stderr=subprocess.STDOUT)
  row['pid']=child.pid;save(label+'.command.json',row);print('START',label,child.pid,flush=True)
  row['exit']=child.wait();row['finished_ns']=time.time_ns();save(label+'.command.json',row)
  child=None;print('EXIT',label,row['exit'],flush=True)
  if row['exit']:raise RuntimeError((label,row['exit']))


def main():
 deadline=time.monotonic()+7200
 previous=None
 while True:
  try:LOCK.mkdir();break
  except FileExistsError:
   try:current=(LOCK/'owner').read_text().strip()
   except FileNotFoundError:current='<publication pending>'
   if current!=previous:print('WAIT_CAMPAIGN_LOCK',current,flush=True);previous=current
   assert time.monotonic()<deadline,'campaign lock wait expired'
   time.sleep(10)
 owner=f'cc-gcleaf-callsite-v5 {os.getpid()}'
 (LOCK/'owner').write_text(owner+'\n');print('LOCK_ACQUIRED',owner,flush=True)
 try:
  for name,expected in EXPECTED.items():assert sha(STAGE/name)==expected,name
  assert not OUT.exists(),'preserve earlier result'
  conversion=json.loads((STAGE/'callsite-execution-v2/conversion.json').read_text())
  assert conversion['status']=='complete' and len(conversion['files'])==327
  for row in conversion['files']:assert Path(row['output']).stat().st_size==row['output_bytes'],row['output']
  save('inputs.json',{'script_sha256':sha(__file__),'files':EXPECTED,'lock_owner':owner,'free_bytes':shutil.disk_usage(STAGE).free})
  command(['python3','-B',str(STAGE/'parser-v4/callsite_census.py'),
           '--captures',str(STAGE/'compile-v2/cc-bitcode'),
           '--helper-audit',str(STAGE/'helper-audit-v2.csv'),'--output',str(OUT),
           '--llvm-dis','/usr/lib/llvm-22/bin/llvm-dis','--text-root',str(STAGE/'cc-ir-text-v1')],'census')
  summary=json.loads((OUT/'summary.json').read_text());assert summary['status']=='complete-static-emission-census'
  converted={r['output']:r['output_sha256'] for r in conversion['files']}
  assert {r['path']:r['sha256'] for r in summary['converted_ir_receipts']}==converted
  captured={str(Path(a['directory'])/r['file']):r['sha256'] for a in summary['accepted_attempts'] for r in a['completion']['snapshots']}
  assert captured=={r['input']:r['input_sha256'] for r in conversion['files']}
  save('PRIMARY_COMPLETE.json',{'summary_sha256':sha(OUT/'summary.json'),'conversion_sha256':EXPECTED['callsite-execution-v2/conversion.json'],'time_ns':time.time_ns()})
  print('PRIMARY_CALLSITE_COMPLETE',flush=True)
  command(['python3','-B',str(STAGE/'callsite_supplement_v1.py'),'--result',str(OUT),
           '--text-root',str(STAGE/'cc-ir-text-v1'),'--audit',str(STAGE/'helper-audit-v2.csv'),
           '--parser-dir',str(STAGE/'parser-v4'),'--output',str(OUT/'root-shadow-supplement.json')],'supplement')
  sys.path.insert(0,str(STAGE));from compile_cc_v1 import sections
  retained=STAGE.parent/'cc-control/app-testdispatch25'
  before=sections(retained)
  after=json.loads((STAGE/'compile-v2/COMPILE_COMPLETE.json').read_text())['sections']
  save('retained-section-comparison.json',{'retained_path':str(retained),'retained_sections':before,
       'diagnostic_sections':after,'equal':before==after,
       'reader_sha256':sha(STAGE/'compile_cc_v1.py'),'lock_owner':owner,
       'diagnostic_completion_sha256':EXPECTED['compile-v2/COMPILE_COMPLETE.json'],
       'scope':'actual .text and .perry_gcmap section contents; no second compile'})
  save('result.json',{'status':'complete','summary_sha256':sha(OUT/'summary.json'),
       'supplement_sha256':sha(OUT/'root-shadow-supplement.json'),
       'section_comparison_sha256':sha(RUN/'retained-section-comparison.json'),
       'free_bytes':shutil.disk_usage(STAGE).free,'completed_ns':time.time_ns()})
  print('CALLSITE_CENSUS_COMPLETE',flush=True)
 finally:
  if child is not None and child.poll() is None:print('RETAIN_LOCK_UNCERTAIN_OWNED_CHILD',child.pid,flush=True)
  elif (LOCK/'owner').read_text().strip()==owner:
   (LOCK/'owner').unlink();LOCK.rmdir();print('LOCK_RELEASED',flush=True)


if __name__=='__main__':
 try:main()
 except BaseException as exc:
  save('failure.json',{'type':type(exc).__name__,'message':str(exc),'traceback':traceback.format_exc(),
       'pid':os.getpid(),'active_child_pid':child.pid if child is not None and child.poll() is None else None,'time_ns':time.time_ns()})
  raise
