#!/usr/bin/env python3
"""Build a runtime-only candidate against the receipt-bound retained control."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import time

STAGE = Path(__file__).resolve().parent
BASE = STAGE.parent / 'gc-leaf-census-20260911'
SOURCE = Path('/root/worktrees/cc-own-read-cache-0911')
TARGET = STAGE / 'target'
COMPILER = BASE / 'target/release/perry'
CCDIR = STAGE.parent / 'cc-control'
LOCK = Path('/root/rig9831/lock')


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def save(name, value):
    (STAGE / name).write_text(json.dumps(value, indent=2) + '\n')


def run(argv, name, env, cwd=SOURCE):
    free = shutil.disk_usage(STAGE).free
    assert free >= 12 * 1024**3, ('disk floor', free)
    record = {'argv': list(map(str, argv)), 'cwd': str(cwd), 'free_before': free,
              'started_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}
    save(name + '.command.json', record)
    print('START', name, flush=True)
    with (STAGE / (name + '.log')).open('x') as stream:
        result = subprocess.run(argv, cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT)
    record.update(exit=result.returncode, finished_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()))
    save(name + '.command.json', record)
    print('EXIT', name, result.returncode, flush=True)
    assert result.returncode == 0, (name, result.returncode)


def libraries(directory):
    return {p.name: {'sha256': sha(p), 'bytes': p.stat().st_size}
            for p in sorted(directory.glob('libperry*.a'))}


def retire_completed_owned_cache():
    old = STAGE.parent / 'plain-object-census-20260911'
    for name in ['build', 'measure']:
        launch = json.loads((old / (name + '-launch.json')).read_text())
        assert not (Path('/proc') / str(launch['pid'])).exists()
        assert json.loads((old / (name + '.execution.json')).read_text())['status'] == 'complete'
    assert sha(old / 'evidence-v1.tar.gz') == 'ae9c414990728393efb00a9ca2dc1f825755c7cd5c35b293e3f26da1d2bc649a'
    target = old / 'target'
    assert target.is_dir() and not target.is_symlink() and target.resolve() == target
    before = shutil.disk_usage(STAGE).free
    size = int(subprocess.check_output(['du', '-sb', target], text=True).split()[0])
    shutil.rmtree(target)
    save('owned-cache-retirement.json', {'path': str(target), 'apparent_bytes': size,
         'free_before': before, 'free_after': shutil.disk_usage(STAGE).free,
         'preserved': 'source, binary, scripts and sealed evidence; original control archives untouched'})


def main():
    deadline = time.monotonic() + 7200
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            assert time.monotonic() < deadline
            print('WAIT_CAMPAIGN_LOCK', flush=True)
            time.sleep(10)
    owner = f'cc-own-read-cache-build-v1 {os.getpid()}'
    (LOCK / 'owner').write_text(owner + '\n')
    result = {'status': 'running', 'owner': owner, 'pid': os.getpid()}
    save('build.execution.json', result)
    try:
        for name, digest in json.loads((STAGE / 'inputs.json').read_text()).items():
            assert sha(STAGE / name) == digest, name
        assert sha(COMPILER) == 'd4d3f4678374fb3d452b5d5e55dad6b0c27e242d2037395dd3081e601d1929c5'
        control = STAGE.parent / 'property-key-dispatch-20260911/cc-control'
        assert sha(control) == '5560e04fe7016923d098ea70d254cb8edd3252c9973282aca40ff62d3415bf97'
        originals = libraries(BASE / 'target/release')
        retire_completed_owned_cache()
        seed = STAGE.parent / 'own-data-census-20260911/target'
        seed_bytes = int(subprocess.check_output(['du', '-sb', seed], text=True).split()[0])
        assert shutil.disk_usage(STAGE).free >= seed_bytes + 14 * 1024**3
        SOURCE.mkdir()
        for archive in ['base.tar.gz', 'cc-gcleaf-overlay-20260911.tar.gz', 'cc-gcleaf-source-v3.tar.gz']:
            subprocess.run(['tar', '-xzf', BASE / archive, '-C', SOURCE], check=True)
        retained = json.loads((BASE / 'build-source-v3.json').read_text())
        for row in retained['overlay_files']: assert sha(SOURCE / row['path']) == row['sha256']
        receipt = json.loads((STAGE / 'source-receipt.json').read_text())
        for name, digest in receipt['base_files'].items():
            assert (sha(SOURCE / name) if (SOURCE / name).exists() else None) == digest, name
        subprocess.run(['tar', '-xzf', STAGE / 'source-overlay.tar.gz', '-C', SOURCE], check=True)
        for name, digest in receipt['files'].items(): assert sha(SOURCE / name) == digest, name
        subprocess.run(['cp', '-a', '--reflink=auto', seed, TARGET], check=True)
        assert (seed / 'release/libperry_runtime.a').stat().st_ino != (TARGET / 'release/libperry_runtime.a').stat().st_ino
        env = {k: v for k, v in os.environ.items() if not k.startswith('PERRY_')}
        env.update(PATH='/root/.cargo/bin:/usr/lib/llvm-22/bin:/usr/bin:/bin',
                   CARGO_TARGET_DIR=str(TARGET), PERRY_BUILD_COMMIT='cc-native-recv-0909',
                   LLVM_SYS_221_PREFIX='/usr/lib/llvm-22', RUST_TEST_THREADS='1')
        tests = ['nice', '-n19', 'cargo', 'test', '--locked', '--offline', '--release', '-j4',
                 '-p', 'perry-runtime', '--lib', 'object::own_read_cache::tests', '--', '--test-threads=1']
        run(tests, 'focused-tests', env)
        assert '9 passed; 0 failed' in (STAGE / 'focused-tests.log').read_text()
        shipping = json.loads((BASE / 'v2-build-shipping-archives.command.json').read_text())['argv']
        run(shipping, 'shipping', env)
        candidate = libraries(TARGET / 'release')
        save('libraries.json', {'control': originals, 'candidate': candidate})
        assert candidate['libperry_runtime.a'] != originals['libperry_runtime.a']
        pair = {}
        for arm in ['control', 'candidate']:
            home = STAGE / ('compile-home-' + arm)
            (home / '.claude').mkdir(parents=True)
            compile_env = {k: v for k, v in os.environ.items() if not k.startswith('PERRY_')}
            directory = BASE / 'target/release' if arm == 'control' else TARGET / 'release'
            compile_env.update(HOME=str(home), CLAUDE_CONFIG_DIR=str(home / '.claude'),
                PATH=env['PATH'], PERRY_RUNTIME_DIR=str(directory), PERRY_KEEP_SYMBOLS='1',
                PERRY_DISABLE_BUILD_CACHE='1', PERRY_CACHE_DIR=str(STAGE.parent / 'property-key-dispatch-20260911/object-cache'),
                PERRY_SEGMENTS_PROJECT='1', PERRY_SEGVIEW='0', PERRY_SEGMENTS_PROJECT_DIAG='1',
                PERRY_REGEX_ENGINE='default', PERRY_REGEX_DIAG='0')
            save(arm + '-compile-env.json', {k:v for k,v in compile_env.items()
                if k.startswith('PERRY_') or k in ['HOME', 'CLAUDE_CONFIG_DIR', 'PATH']})
            fixture = STAGE / ('fixture-' + arm)
            run([COMPILER, 'compile', '--no-auto-optimize', '--enable-wasm-runtime', STAGE / 'semantic_fixture.ts', '-o', fixture],
                'compile-fixture-' + arm, compile_env, CCDIR)
            run([fixture], 'run-fixture-' + arm, compile_env, STAGE)
            if arm == 'control': run(['/usr/bin/node', '--experimental-strip-types', STAGE / 'semantic_fixture.ts'], 'run-fixture-node', compile_env, STAGE)
            assert (STAGE / ('run-fixture-' + arm + '.log')).read_bytes() == (STAGE / 'run-fixture-node.log').read_bytes(), ('fixture mismatch', arm)
            if arm == 'control':
                app = control
            else:
                app = STAGE / 'cc-candidate'
                assert sha(CCDIR / 'cli_2.1.112.js') == 'bc3358282800e3e99daa8e71ac5b7b1566bd0d7ca7eb94f714a7859365d3163f'
                run(['/usr/bin/time', '-v', 'nice', '-n19', COMPILER, 'compile', '--no-auto-optimize',
                     '--enable-wasm-runtime', CCDIR / 'cli_2.1.112.js', '-o', app], 'compile-cc', compile_env, CCDIR)
                nm = subprocess.check_output(['/usr/lib/llvm-22/bin/llvm-nm', '-S', '--defined-only', app], text=True)
                assert 'PERRY_PROPERTY_READ_CENSUS' not in nm and 'own_read_cache4HITS' not in nm
            pair[arm] = {'path': str(app), 'sha256': sha(app), 'bytes': app.stat().st_size,
                         'fixture_sha256': sha(fixture), 'fixture_output_sha256': sha(STAGE / ('run-fixture-' + arm + '.log'))}
            assert libraries(directory) == (originals if arm == 'control' else candidate)
        for name, digest in receipt['files'].items(): assert sha(SOURCE / name) == digest, name
        assert sha(control) == '5560e04fe7016923d098ea70d254cb8edd3252c9973282aca40ff62d3415bf97'
        result.update(status='complete', pair=pair, compiler_sha256=sha(COMPILER),
                      source_receipt_sha256=sha(STAGE / 'source-receipt.json'))
        print('BUILD_COMPLETE', flush=True)
    except BaseException as error:
        result.update(status='failed', error=repr(error))
        raise
    finally:
        save('build.execution.json', result)
        assert (LOCK / 'owner').read_text().strip() == owner
        (LOCK / 'owner').unlink(); LOCK.rmdir()


if __name__ == '__main__': main()
