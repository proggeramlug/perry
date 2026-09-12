#!/usr/bin/env python3
"""Read only the named census counters in the owned cc process.

Same contract as `filter_observer.FilterObserver`: bounded, read-only preads of
variables named in a bindings file, with the process identity and load bias
re-derived at every phase. It stores integers, never arbitrary memory.
"""
from pathlib import Path
import json
import os
import struct
import time

from profile_samples_v3 import parse_maps
from profile_workload_v4 import check_process, process_snapshot, save, sha

HERE = Path(__file__).resolve().parent
# The arm under measurement decides which variables exist, so the bindings
# file is named by the runner rather than fixed here.
BINDINGS = HERE / os.environ.get('CENSUS_BINDINGS', 'bindings-v1.json')


class CounterObserver:
    def __init__(self, pid, out, binary):
        self.pid, self.out, self.binary = pid, Path(out), Path(binary)
        self.birth = process_snapshot(pid)['start_ticks']
        self.binding = json.loads(BINDINGS.read_text())
        assert sha(binary) == self.binding['binary_sha256']
        with self.binary.open('rb') as stream:
            header = struct.unpack('<16sHHIQQQIHHHHHH', stream.read(64))
            assert header[9] == 56
            stream.seek(header[5])
            self.segments = [struct.unpack('<IIQQQQQQ', stream.read(56)) for _ in range(header[10])]
        self.rows = []
        self.closed = False

    def _bias(self, maps):
        page = os.sysconf('SC_PAGE_SIZE')
        biases = set()
        for mapping in maps:
            if mapping['path'] != str(self.binary) or 'x' not in mapping['perms']:
                continue
            matches = [segment for segment in self.segments if segment[0] == 1
                       and segment[1] & 1 and mapping['offset'] == segment[2] // page * page]
            assert len(matches) == 1
            biases.add(mapping['start'] - matches[0][3] // page * page)
        assert len(biases) == 1
        return biases.pop()

    def phase(self, phase):
        assert [r['phase'] for r in self.rows] == list(range(1, phase))
        row = {'phase': phase, 'before_ns': time.monotonic_ns()}
        if phase != 1:
            identity = check_process(self.pid, self.binary, argv=[str(self.binary)],
                                     start_ticks=self.birth)
            document = {'maps': Path(f'/proc/{self.pid}/maps').read_text()}
            maps = parse_maps(document)
            bias = self._bias(maps)
            values = {}
            fd = os.open(f'/proc/{self.pid}/mem', os.O_RDONLY)
            try:
                for short, variable in self.binding['variables'].items():
                    linked, size = variable['address'], variable['bytes']
                    assert any(segment[0] == 1 and segment[3] <= linked
                               and linked + size <= segment[3] + segment[6]
                               for segment in self.segments), short
                    address = linked + bias
                    assert any('r' in m['perms'] and m['start'] <= address
                               and address + size <= m['end'] for m in maps), short
                    data = os.pread(fd, size, address)
                    assert len(data) == size, short
                    if variable['kind'] == 'bitmap':
                        words = struct.unpack('<' + 'Q' * (size // 8), data)
                        values[short] = {'bits_set': sum(w.bit_count() for w in words),
                                         'capacity_bits': size * 8,
                                         'all_bits_set': all(w == (1 << 64) - 1 for w in words)}
                    else:
                        fmt = '<q' if variable['kind'] == 'i64' else '<Q'
                        values[short] = struct.unpack(fmt, data)[0]
            finally:
                os.close(fd)
            check_process(self.pid, self.binary, cwd=identity['cwd'],
                          argv=[str(self.binary)], start_ticks=self.birth)
            row.update(load_bias=bias, values=values)
            save(self.out / f'counter-phase-{phase}-maps.json', document)
        row['after_ns'] = time.monotonic_ns()
        self.rows.append(row)
        save(self.out / 'counter-snapshots.json', self.rows)

    def stop(self):
        self.closed = True
        return {'kind': 'bounded-read-only-counter-snapshots', 'phases': self.rows,
                'binding_sha256': sha(BINDINGS),
                'scope': 'runtime counters armed by PERRY_CANONICAL_DIAG; counts are not CPU '
                         'and this binary is not a CPU/RSS comparison arm'}
