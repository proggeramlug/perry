#!/usr/bin/env python3
"""Rebuild compiler after correcting diagnostic bitcode transport."""
import json
import os
import subprocess
import time
from build_box_v1 import STAGE, SOURCE, TARGET, LOCK, sha, save, free, run


def main():
    deadline = time.monotonic() + 7200
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            assert time.monotonic() < deadline, 'campaign lock wait exceeded two hours'
            time.sleep(10)
    owner = f'cc-gcleaf-build-v4 {os.getpid()}'
    (LOCK / 'owner').write_text(owner + '\n')
    try:
        old = json.loads((STAGE / 'build-source-v2.json').read_text())
        new = json.loads((STAGE / 'build-source-v3.json').read_text())
        for row in old['overlay_files']:
            assert sha(SOURCE / row['path']) == row['sha256'], row['path']
        allowed = {'crates/perry-codegen/src/gc_leaf_census.rs',
                   'crates/perry-codegen/src/inprocess/optimize_emit.rs'}
        old_by_path = {row['path']: row for row in old['overlay_files']}
        for row in new['overlay_files']:
            if row['sha256'] != old_by_path[row['path']]['sha256']:
                assert row['path'] in allowed, row['path']
                incoming = STAGE / 'source-v3' / row['path']
                assert sha(incoming) == row['sha256'], row['path']
                (SOURCE / row['path']).write_bytes(incoming.read_bytes())
        for row in new['overlay_files']:
            assert sha(SOURCE / row['path']) == row['sha256'], row['path']
        shipping = json.loads((STAGE / 'shipping-identities.json').read_text())
        for relative, row in shipping.items():
            assert sha(STAGE / relative) == row['sha256'], relative
        env = {k: v for k, v in os.environ.items() if not k.startswith('PERRY_')}
        env.update(PATH='/root/.cargo/bin:/usr/lib/llvm-22/bin:/usr/bin:/bin',
                   CARGO_TARGET_DIR=str(TARGET), PERRY_BUILD_COMMIT='cc-native-recv-0909',
                   LLVM_SYS_221_PREFIX='/usr/lib/llvm-22')
        run(['nice', '-n19', 'cargo', 'build', '--locked', '--offline', '--release',
             '-j4', '-p', 'perry'], 'v4-build-compiler', env)
        compiler = TARGET / 'release/perry'
        shipping['target/release/perry'] = {'sha256': sha(compiler), 'bytes': compiler.stat().st_size}
        run(['nice', '-n19', 'cargo', 'test', '--locked', '--offline', '--release',
             '-j4', '-p', 'perry-codegen', '--lib', 'gc_leaf_census::tests',
             '--', '--test-threads=1'], 'v4-test-diagnostic-module', env)
        log = (STAGE / 'v4-test-diagnostic-module.log').read_text()
        for name in ('complete_attempt_preserves_every_ir_byte_and_stage',
                     'abandoned_retry_and_missing_stage_cannot_be_complete',
                     'out_of_order_or_existing_snapshot_cannot_be_complete'):
            assert 'test gc_leaf_census::tests::' + name + ' ... ok' in log, name
        assert '0 failed' in log
        for relative, row in shipping.items():
            assert sha(STAGE / relative) == row['sha256'], relative
        save(STAGE / 'BUILD_COMPLETE-v4.json', {
            'status': 'corrected diagnostic compiler built; focused module tests pass; unchanged shipping archives reused',
            'source_receipt_sha256': sha(STAGE / 'build-source-v3.json'),
            'runtime_source_receipt_sha256': sha(STAGE / 'build-source-v1.json'),
            'artifacts': shipping, 'free_bytes': free(),
        })
        print('BUILD_COMPLETE_V4', flush=True)
    finally:
        if (LOCK / 'owner').read_text().strip() == owner:
            (LOCK / 'owner').unlink()
            LOCK.rmdir()
    result = subprocess.run(['python3', '-B', str(STAGE / 'compile_cc_v3.py')])
    save(STAGE / 'emission-v3-result.json', {'exit': result.returncode})
    raise SystemExit(result.returncode)


if __name__ == '__main__':
    main()
