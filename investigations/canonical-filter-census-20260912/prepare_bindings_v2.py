#!/usr/bin/env python3
"""Bind the census counter statics (arm A: canonical owner on RegistryAddrIndex) in the owned binary by exact ELF symbol.

Every variable is named, its size is taken from the symbol table rather than
guessed, and the binary is pinned by digest. A missing or ambiguous symbol is a
failure: a census that silently reads the wrong address reports zeros, which
greps identically to "the instrument never ran".
"""
from pathlib import Path
import json
import subprocess
import sys

WANTED = {
    'CALLS': 'u64',
    'FILTER_PASS': 'u64',
    'RESOLVED': 'u64',
    'ADMITS': 'u64',
    'RETIRES': 'u64',
    'LIVE': 'i64',
    # The canonical owner now holds a `RegistryAddrIndex`, whose bit array is a
    # field rather than a bare static, so its occupancy comes from the armed
    # diag dump instead of an external read. The other three still carry a plain
    # filter and are read here unchanged.
    'SYMBOL_ADDR_FILTER': 'bitmap',
    'CLASS_PROTOTYPE_ADDR_FILTER': 'bitmap',
    'BUFFER_LIKE_ADDR_FILTER': 'bitmap',
}
MODULE = 'canonical_filter'


def sha(path):
    import hashlib
    digest = hashlib.sha256()
    with open(path, 'rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            digest.update(block)
    return digest.hexdigest()


def main():
    binary = Path(sys.argv[1])
    out = Path(sys.argv[2])
    assert not out.exists(), out
    listing = subprocess.run(['nm', '-S', '--defined-only', str(binary)],
                             capture_output=True, text=True, check=True).stdout
    rows = []
    for line in listing.splitlines():
        parts = line.split()
        if len(parts) != 4:
            continue
        address, size, kind, name = parts
        if kind.lower() not in ('b', 'd'):
            continue
        rows.append((int(address, 16), int(size, 16), name))
    variables = {}
    for short, kind in WANTED.items():
        if short.endswith('_ADDR_FILTER'):
            matches = [r for r in rows if short in r[2]]
        else:
            # The counters are module-private statics: require the module name
            # in the mangled symbol so an unrelated CALLS/LIVE cannot match.
            matches = [r for r in rows if MODULE in r[2] and r[2].split('.')[0].endswith(short)]
        assert len(matches) == 1, (short, [m[2] for m in matches])
        address, size, name = matches[0]
        expected = 128 if kind == 'bitmap' else 8
        assert size == expected, (short, size, expected)
        variables[short] = {'symbol': name, 'address': address, 'bytes': size, 'kind': kind}
    out.write_text(json.dumps({'binary': str(binary), 'binary_sha256': sha(binary),
                               'variables': variables}, indent=1) + '\n')
    print(json.dumps({k: hex(v['address']) for k, v in variables.items()}, indent=1))


if __name__ == '__main__':
    raise SystemExit(main())
