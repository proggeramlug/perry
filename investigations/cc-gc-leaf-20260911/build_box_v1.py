#!/usr/bin/env python3
"""Explicit build-only phase for observational GC-leaf census. No optimization."""
import hashlib,json,os,shutil,subprocess,time
from pathlib import Path
STAGE=Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
SOURCE=Path('/root/worktrees/cc-gc-leaf-census-0911')
TARGET=STAGE/'target'
LOCK=Path('/root/rig9831/lock')
def sha(p):
 with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def free():return shutil.disk_usage(STAGE).free
def run(cmd,name,env):
 available=free();assert available>=12*1024**3,('below 12GiB before Cargo',available)
 record={'argv':cmd,'cwd':str(SOURCE),'free_before':available,'started_utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime())}
 save(STAGE/(name+'.command.json'),record);print('START',name,available,flush=True)
 with (STAGE/(name+'.log')).open('x') as f:
  r=subprocess.run(cmd,cwd=SOURCE,env=env,stdout=f,stderr=subprocess.STDOUT)
 record.update(exit=r.returncode,free_after=free(),finished_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()));save(STAGE/(name+'.command.json'),record)
 print('EXIT',name,r.returncode,free(),flush=True);assert r.returncode==0,(name,r.returncode)
def main():
 assert not (STAGE/'BUILD_COMPLETE.json').exists()
 LOCK.mkdir();owner=f'cc-gcleaf-diagnostic-build-v1 {os.getpid()}';(LOCK/'owner').write_text(owner+'\n')
 try:
  receipt=json.loads((STAGE/'build-source-v1.json').read_text())
  assert sha(STAGE/'base.tar.gz')==receipt['base_archive_sha256']
  overlay=STAGE/'cc-gcleaf-overlay-20260911.tar.gz';assert sha(overlay)==receipt['overlay_archive_sha256']
  SOURCE.mkdir()
  subprocess.run(['tar','-xzf',str(STAGE/'base.tar.gz'),'-C',str(SOURCE)],check=True)
  subprocess.run(['tar','-xzf',str(overlay),'-C',str(SOURCE)],check=True)
  for x in receipt['overlay_files']:assert sha(SOURCE/x['path'])==x['sha256'],x['path']
  print('SOURCE_VERIFIED',len(receipt['overlay_files']),flush=True)
  env=dict(os.environ)
  for k in list(env):
   if k.startswith('PERRY_'):env.pop(k)
  env.update(PATH='/root/.cargo/bin:/usr/lib/llvm-22/bin:/usr/bin:/bin',CARGO_TARGET_DIR=str(TARGET),PERRY_BUILD_COMMIT='cc-native-recv-0909',LLVM_SYS_221_PREFIX='/usr/lib/llvm-22')
  packages=['perry','perry-runtime-static','perry-stdlib-static','perry-wasm-host']+sorted(p.name for p in (SOURCE/'crates').glob('perry-ext-*') if p.is_dir())
  cmd=['nice','-n19','cargo','build','--locked','--offline','--release','-j4']
  for package in packages:cmd+=['-p',package]
  cmd+=['--features','perry-runtime/wasm-host']
  run(cmd,'build-shipping-graph',env)
  artifacts=[TARGET/'release/perry']+sorted((TARGET/'release').glob('libperry*.a'))
  identities={str(x.relative_to(STAGE)):{'sha256':sha(x),'bytes':x.stat().st_size} for x in artifacts}
  assert len(identities)>3
  save(STAGE/'shipping-identities.json',identities)
  run(['nice','-n19','cargo','test','--locked','--offline','--release','-j4','-p','perry-codegen','--lib','gc_leaf_census::tests','--','--test-threads=1'],'test-diagnostic-module',env)
  log=(STAGE/'test-diagnostic-module.log').read_text()
  for name in ('complete_attempt_preserves_every_ir_byte_and_stage','abandoned_retry_and_missing_stage_cannot_be_complete','out_of_order_or_existing_snapshot_cannot_be_complete'):
   assert 'test gc_leaf_census::tests::'+name+' ... ok' in log,name
  assert '3 passed; 0 failed' in log
  for rel,r in identities.items():assert sha(STAGE/rel)==r['sha256'],rel
  save(STAGE/'BUILD_COMPLETE.json',{'status':'shipping graph built and three diagnostic module tests passed','source_receipt_sha256':sha(STAGE/'build-source-v1.json'),'artifacts':identities,'free_bytes':free()})
  print('BUILD_COMPLETE',flush=True)
 finally:
  if (LOCK/'owner').read_text().strip()==owner:(LOCK/'owner').unlink();LOCK.rmdir()
if __name__=='__main__':main()
