#!/usr/bin/env python3
"""Complete the larger existing-contract annotation-gap coverage under the lock."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time
import traceback
import finish_analysis_v3 as q

q.R=q.S/'known-leaf-execution-v1'

def main():
    deadline=time.monotonic()+7200
    upstream=q.S/'final-analysis-execution-v3'
    while not (upstream/'result.json').exists():
        assert not (upstream/'failure.json').exists(),'upstream failed'
        assert time.monotonic()<deadline,'upstream wait expired'
        time.sleep(10)
    while True:
        try:q.L.mkdir();break
        except FileExistsError:
            assert time.monotonic()<deadline,'lock wait expired'
            time.sleep(10)
    owner=f'cc-gcleaf-known-leaf-coverage-v1 {os.getpid()}'
    (q.L/'owner').write_text(owner+'\n')
    try:
        inputs=json.loads((q.S/'known-leaf-inputs-v1.json').read_text())
        for name,digest in inputs.items():assert q.sha(q.S/name)==digest,name
        q.save('inputs.json',{'files':inputs,'owner':owner,'upstream_sha256':q.sha(upstream/'result.json')})
        view=q.S/'callsite-leaf-view-v1'
        q.command('extend', [q.S/'extend_leaf_coverage_v1.py','--primary',q.S/'callsite-v5','--audit',q.S/'helper-audit-v2.csv','--out',view])
        for i in range(1,4):
            p=q.S/f'profile-v4-{i}';a=q.S/f'profile-analysis-v4-{i}'
            q.command(f'profile-{i}',[q.S/'profile_samples_v3.py','--samples',p/'samples-v2.txt','--run',p/'run.json','--maps',p/'app-maps.json','--metadata',q.S/'metadata-diagnostic','--helper-audit',q.S/'helper-audit-v2.csv','--callsites',view,'--output',a])
            q.command(f'reconcile-{i}',[q.S/'perf_self_reconcile.py','--report',p/'self-report.txt','--summary',a/'summary.json','--command-receipt',p/'self-report.command.json','--output',a/'perf-self-reconciliation.json'])
        q.command('machine-loops',[q.S/'run_machine_loop_coverage_v2.py','--elf',q.S/'compile-v2/cc-diagnostic','--compile-receipt',q.S/'compile-v2/COMPILE_COMPLETE.json','--metadata',q.S/'metadata-diagnostic','--callsites',view,'--profile',q.S/'profile-analysis-v4-1','--profile',q.S/'profile-analysis-v4-2','--profile',q.S/'profile-analysis-v4-3','--out',q.S/'machine-loop-v2'])
        cmd=['readelf','-Ws',str(q.S/'compile-v2/cc-diagnostic')]
        r=subprocess.run(cmd,capture_output=True,text=True,check=True)
        tls=[line for line in r.stdout.splitlines() if 'TLS' in line and 'SHADOW_STACK' in line]
        q.save('shadow-tls.json',{'command':cmd,'exit':r.returncode,'stderr':r.stderr,'matching_tls_symbols':tls,'binary_sha256':q.sha(q.S/'compile-v2/cc-diagnostic'),'scope':'ELF TLS symbols only; dynamic shadow buffers are separate'})
        q.save('result.json',{'status':'complete','coverage_summary_sha256':q.sha(view/'summary.json'),'machine_summary_sha256':q.sha(q.S/'machine-loop-v2/summary.json'),'finished_ns':time.time_ns()})
    finally:
        if q.child is not None and q.child.poll() is None:print('RETAIN_LOCK_LIVE_CHILD',q.child.pid,flush=True)
        elif (q.L/'owner').read_text().strip()==owner:
            (q.L/'owner').unlink();q.L.rmdir()

if __name__=='__main__':
    try:main()
    except BaseException as exc:
        q.save('failure.json',{'error':str(exc),'traceback':traceback.format_exc(),'time_ns':time.time_ns()})
        raise
