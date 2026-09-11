from pathlib import Path
import os
import subprocess

r = Path('/root/cc-perf-native-recv-0909/gc-leaf-census-20260911')
lock = Path('/root/rig9831/lock')
lock.mkdir()
owner = f'cc-gcleaf-retained-profile {os.getpid()}'
(lock / 'owner').write_text(owner + '\n')
try:
    subprocess.run(['python3', '-B', str(r / 'metadata_census.py'), '--elf',
                    str(r.parent / 'cc-control/app-testdispatch25'), '--output',
                    str(r / 'metadata-retained')], check=True)
    subprocess.run(['python3', '-B', str(r / 'profile_workload.py'), '--app',
                    str(r.parent / 'cc-control/app-testdispatch25'), '--label',
                    'retained1', '--port', '10559', '--out',
                    str(r / 'retained-profile1')], check=True)
    with (r / 'retained-profile1/samples.txt').open('x') as out, \
            (r / 'retained-profile1/export.log').open('x') as err:
        subprocess.run(['perf', 'script', '--ns', '--full-paths', '-i',
                        str(r / 'retained-profile1/profile.data'), '-F',
                        'pid,tid,time,event,ip,sym,symoff,dso,period'],
                       stdout=out, stderr=err, check=True)
finally:
    if (lock / 'owner').read_text().strip() == owner:
        (lock / 'owner').unlink()
        lock.rmdir()
