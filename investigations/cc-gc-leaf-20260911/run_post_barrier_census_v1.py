#!/usr/bin/env python3
import csv
import json
import os
from pathlib import Path
import subprocess
import time
import traceback
import finish_analysis_v3 as q

q.R=q.S/'post-barrier-execution-v1'

def main():
    deadline=time.monotonic()+3600
    while not (q.S/'known-leaf-execution-v1/result.json').exists():
        assert not (q.S/'known-leaf-execution-v1/failure.json').exists()
        assert time.monotonic()<deadline
        time.sleep(10)
    while True:
        try:q.L.mkdir();break
        except FileExistsError:
            assert time.monotonic()<deadline
            time.sleep(10)
    owner=f'cc-gcleaf-post-barrier-v1 {os.getpid()}'
    (q.L/'owner').write_text(owner+'\n')
    try:
        inputs=json.loads((q.S/'post-barrier-inputs-v1.json').read_text())
        for name,digest in inputs.items():assert q.sha(q.S/name)==digest,name
        q.save('inputs.json',{'files':inputs,'owner':owner})
        import post_statepoint_barriers_v1 as p
        fixture=q.S/'compile-v2/fixture-on-bitcode/pid-3681148-attempt-0'
        mirror=q.S/'post-barrier-fixture-text-v1';(mirror/fixture.name).mkdir(parents=True)
        destination=mirror/fixture.name/'post-rs4gc.ll'
        cmd=['/usr/lib/llvm-22/bin/llvm-dis',str(fixture/'post-rs4gc.bc'),'-o',str(destination)]
        r=subprocess.run(cmd,capture_output=True,text=True);assert r.returncode==0,r.stderr
        out=q.S/'post-barrier-fixture-v1';out.mkdir()
        result=p.unit((fixture.name,mirror,out))
        assert not result['excluded'],result['excluded']
        expected=0
        source=q.S/'parser-parallel-proof-v2/v4/by-callee.csv'
        for row in csv.DictReader(source.open()):
            if row['stage']=='post-rs4gc' and row['callee'] in p.core.BARRIERS:expected+=int(row['callsites'])
        assert expected==5 and result['counts']['explicit_heap_barrier_sites']==expected
        q.save('fixture.json',{'status':'PASS','counts':result['counts'],'oracle_sha256':q.sha(source),'expected_explicit_barriers':expected,'bitcode_sha256':q.sha(fixture/'post-rs4gc.bc'),'decoded_sha256':q.sha(destination),'command':cmd})
        q.command('full',[q.S/'post_statepoint_barriers_v1.py','--primary',q.S/'callsite-v5','--text-root',q.S/'cc-ir-text-v1','--out',q.S/'post-barrier-v1'])
        result=json.loads((q.S/'post-barrier-v1/summary.json').read_text())
        q.save('result.json',{'status':'complete','census_status':result['status'],'summary_sha256':q.sha(q.S/'post-barrier-v1/summary.json'),'finished_ns':time.time_ns()})
    finally:
        if q.child is not None and q.child.poll() is None:print('RETAIN_LOCK_LIVE_CHILD',q.child.pid,flush=True)
        elif (q.L/'owner').read_text().strip()==owner:
            (q.L/'owner').unlink();q.L.rmdir()

if __name__=='__main__':
    try:main()
    except BaseException as exc:
        q.save('failure.json',{'error':str(exc),'traceback':traceback.format_exc(),'time_ns':time.time_ns()})
        raise
