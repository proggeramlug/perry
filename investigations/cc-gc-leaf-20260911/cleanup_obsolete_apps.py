#!/usr/bin/env python3
"""Remove only this campaign's superseded, singly linked cc experiments."""
import hashlib,json,os,stat,subprocess,time
from pathlib import Path
BASE=Path('/root/cc-perf-native-recv-0909/cc-control')
OUT=Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
LOCK=Path('/root/rig9831/lock')
NAMES="""app-arg1h4 app-argsnap4 app-arrayiter8 app-asciigcdiag8 app-asciiname10 app-asciislice7 app-buftls4 app-desc0b4 app-direct app-direct4 app-dispatch2cut5 app-field4 app-gcdiag7 app-gcfloor5 app-gctypereuse12 app-glread4 app-hcopy5 app-hstack4 app-ic4 app-iterator18 app-iterroot5 app-key4 app-knownlive12 app-layow4 app-metadata19 app-own4 app-parentgate10 app-pmeth5 app-preroot4 app-record17 app-recvkind9 app-regextest7 app-regmap4 app-regneg4 app-regress15 app-regress16 app-rootslot4 app-rxarg04 app-rxcache5 app-rxhdr4 app-rxshare4 app-segbirth5 app-segments4 app-segshape11 app-string4 app-strroot4 app-tag4 app-ways4 app-wrap app-wrap4 app-zero20""".split()
KEEP={'app-testdispatch25':'230e33392fded4dc8ddb7c4ea49ca86e2f1a7201a84ccdc98b56b5c72666d98d','app-project23':'1e078dd1316dc1606dee2396c8419e1b449300b9220d92960f77edf8404f6338'}
def sha(p):
 with p.open('rb') as f: return hashlib.file_digest(f,'sha256').hexdigest()
def free():
 s=os.statvfs(BASE);return s.f_bavail*s.f_frsize
def save(x): (OUT/'cleanup-receipt.json').write_text(json.dumps(x,indent=2)+'\n')
def main():
 OUT.mkdir(exist_ok=True)
 assert not (OUT/'cleanup-receipt.json').exists()
 LOCK.mkdir();owner=f'cc-gcleaf-owned-cleanup {os.getpid()}';(LOCK/'owner').write_text(owner+'\n')
 try:
  candidates=[BASE/n for n in NAMES]
  assert len(set(candidates))==len(candidates)
  snapshot={str(p):p.lstat() for p in candidates}
  assert all(stat.S_ISREG(s.st_mode) and s.st_nlink==1 for s in snapshot.values())
  paths=set(snapshot);busy=[]
  for q in Path('/proc').iterdir():
   if not q.name.isdigit():continue
   try:
    exe=os.readlink(q/'exe');cwd=os.readlink(q/'cwd')
    argv=(q/'cmdline').read_bytes().split(b'\0')
    mapped=(q/'maps').read_text()
    if exe in paths or any(b.decode(errors='replace') in paths for b in argv) or any(p in mapped for p in paths):
     busy.append({'pid':int(q.name),'exe':exe,'cwd':cwd})
   except (FileNotFoundError,PermissionError,ProcessLookupError):pass
  assert not busy,busy
  for line in subprocess.check_output(['ps','-eo','pid=,comm=,args='],text=True).splitlines():
   f=line.split(None,2)
   assert not(len(f)==3 and (f[1] in ('cargo','rustc') or (f[1]=='perry' and 'compile' in f[2].split()))),line[:250]
  kept={n:sha(BASE/n) for n in KEEP};assert kept==KEEP
  r={'purpose':'reclaim superseded own campaign binaries for GC-leaf diagnostic build; current/preceding retained apps and all source/measurement records preserved','started_utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),'free_before':free(),'preserved':kept,'removed':[]};save(r)
  for p in candidates:
   before=snapshot[str(p)];now=p.lstat()
   assert (now.st_dev,now.st_ino,now.st_size,now.st_mtime_ns,now.st_nlink)==(before.st_dev,before.st_ino,before.st_size,before.st_mtime_ns,1)
   digest=sha(p);p.unlink()
   r['removed'].append({'path':str(p),'sha256':digest,'bytes':before.st_size,'allocated_bytes':before.st_blocks*512,'inode':before.st_ino})
   save(r)
   print('REMOVED',p.name,flush=True)
  r.update(free_after=free(),allocated_bytes_removed=sum(x['allocated_bytes'] for x in r['removed']),completed_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()))
  assert {n:sha(BASE/n) for n in KEEP}==KEEP
  save(r);print('CLEANUP_DONE',r['allocated_bytes_removed'],r['free_after'],flush=True)
 finally:
  if (LOCK/'owner').read_text().strip()==owner:(LOCK/'owner').unlink();LOCK.rmdir()
if __name__=='__main__':main()
