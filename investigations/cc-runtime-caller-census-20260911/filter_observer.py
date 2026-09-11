#!/usr/bin/env python3
"""Read only the exact canonical-handle filter in the owned cc process."""
from pathlib import Path
import json
import os
import struct
import time

from profile_samples_v3 import parse_maps
from profile_workload_v4 import check_process, process_snapshot, save, sha

HERE = Path(__file__).resolve().parent


class FilterObserver:
    def __init__(self, pid, out, binary):
        self.pid, self.out, self.binary = pid, Path(out), Path(binary)
        self.birth = process_snapshot(pid)['start_ticks']
        self.binding = json.loads((HERE / 'bindings-v1.json').read_text())
        assert sha(binary) == self.binding['binary_sha256']
        with self.binary.open('rb') as stream:
            header = struct.unpack('<16sHHIQQQIHHHHHH', stream.read(64))
            assert header[9] == 56
            stream.seek(header[5])
            self.segments = [struct.unpack('<IIQQQQQQ', stream.read(56)) for _ in range(header[10])]
        self.rows = []
        self.closed = False

    def phase(self, phase):
        assert [r['phase'] for r in self.rows] == list(range(1, phase))
        row = {'phase': phase, 'before_ns': time.monotonic_ns()}
        if phase != 1:
            identity = check_process(self.pid, self.binary, argv=[str(self.binary)], start_ticks=self.birth)
            document = {'maps': Path(f'/proc/{self.pid}/maps').read_text()}
            maps = parse_maps(document)
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
            bias = biases.pop()
            variable = self.binding['filter']
            linked, size = variable['address'], variable['bytes']
            assert any(segment[0] == 1 and segment[3] <= linked
                       and linked + size <= segment[3] + segment[6] for segment in self.segments)
            address = linked + bias
            assert any('r' in m['perms'] and m['start'] <= address
                       and address + size <= m['end'] for m in maps)
            fd = os.open(f'/proc/{self.pid}/mem', os.O_RDONLY)
            try:
                data = os.pread(fd, size, address)
            finally:
                os.close(fd)
            assert len(data) == size
            check_process(self.pid, self.binary, cwd=identity['cwd'], argv=[str(self.binary)], start_ticks=self.birth)
            words = struct.unpack('<' + 'Q' * variable['u64_words'], data)
            row.update(load_bias=bias, variable=variable['symbol'], bytes_read=size,
                       bits_set=sum(word.bit_count() for word in words), capacity_bits=size * 8,
                       per_word_bits_set=[word.bit_count() for word in words],
                       all_bits_set=all(word == (1 << 64) - 1 for word in words))
            save(self.out / f'filter-phase-{phase}-maps.json', document)
        row['after_ns'] = time.monotonic_ns()
        self.rows.append(row)
        save(self.out / 'filter-snapshots.json', self.rows)

    def stop(self):
        self.closed = True
        return {'kind': 'bounded-read-only-filter-snapshots', 'phases': self.rows,
                'binding_sha256': sha(HERE / 'bindings-v1.json'),
                'scope': 'no BPF or runtime counters; snapshots are not an optimization comparison'}
