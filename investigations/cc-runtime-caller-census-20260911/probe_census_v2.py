#!/usr/bin/env python3
"""Count a single owned helper by return continuation; no sampled CPU claims."""
from pathlib import Path
from collections import Counter
import hashlib
import json
import os
import re
import shutil
import signal
import struct
import subprocess
import time

from profile_workload_v4 import check_process, finish_owned_popen, save

HERE = Path(__file__).resolve().parent
RUNTIME_SYMBOL = '_RNvNtNtCscI5nJwKNRh4_13perry_runtime2gc6malloc27gc_malloc_header_is_tracked'


def target_info(binary, symbol):
    """Read exact ELF64 little-endian x86-64 function bytes and file offset."""
    binary = Path(binary).resolve()
    with binary.open('rb') as stream:
        before = os.fstat(stream.fileno())
        header = stream.read(64)
        assert header[:6] == b'\x7fELF\x02\x01'
        values = struct.unpack('<16sHHIQQQIHHHHHH', header)
        assert values[2] == 62 and values[1] in (2, 3)
        shoff, shsize, shnum = values[6], values[11], values[12]
        assert shsize == 64 and shnum > 0

        def read(offset, length):
            assert 0 <= offset <= before.st_size and 0 <= length <= before.st_size - offset
            stream.seek(offset)
            data = stream.read(length)
            assert len(data) == length
            return data

        sections = [struct.unpack('<IIQQQQIIQQ', read(shoff + i * shsize, 64))
                    for i in range(shnum)]
        matches = []
        for section in sections:
            if section[1] != 2:
                continue
            assert section[9] == 24 and section[5] % 24 == 0
            strings_section = sections[section[6]]
            assert strings_section[1] == 3
            strings = read(strings_section[4], strings_section[5])
            raw = read(section[4], section[5])
            for offset in range(0, len(raw), 24):
                name, info, _, index, address, size = struct.unpack_from('<IBBHQQ', raw, offset)
                if info & 15 != 2 or index == 0:
                    continue
                end = strings.find(b'\0', name)
                assert end >= name
                if strings[name:end].decode() == symbol:
                    matches.append((index, address, size))
        assert len(matches) == 1, (symbol, matches)
        index, address, size = matches[0]
        section = sections[index]
        assert section[2] & 4 and size > 0
        assert section[3] <= address and address + size <= section[3] + section[5]
        offset = section[4] + address - section[3]
        code = read(offset, size)
        assert code[0] == 0x55, 'entry probe only admits an actual one-byte push rbp'
        stream.seek(0)
        digest = hashlib.file_digest(stream, 'sha256').hexdigest()
        after = os.fstat(stream.fileno())
        assert (before.st_ino, before.st_size, before.st_mtime_ns, before.st_ctime_ns) == (
            after.st_ino, after.st_size, after.st_mtime_ns, after.st_ctime_ns)
    return {'binary': str(binary), 'symbol': symbol, 'address': address, 'offset': offset,
            'size': size, 'first_byte': code[0], 'function_sha256': hashlib.sha256(code).hexdigest(),
            'binary_sha256': digest, 'device': before.st_dev, 'inode': before.st_ino}


def validate_attachments(rows, target, tracer_pid):
    owned = [row for row in rows if row.get('pid') == tracer_pid]
    expected = Counter({('uprobe', target['binary'], target['offset']): 1,
                        ('uretprobe', target['binary'], target['offset']): 1,
                        ('tracepoint', 'sys_enter_write', None): 1})
    actual = Counter()
    for row in owned:
        kind = row['fd_type']
        if kind in ('uprobe', 'uretprobe'):
            actual[(kind, row['filename'], row['offset'])] += 1
        elif kind == 'tracepoint':
            actual[(kind, row['tracepoint'], None)] += 1
        else:
            raise ValueError('unexpected attachment kind')
        if row['fd'] < 0 or row['prog_id'] <= 0:
            raise ValueError('invalid live attachment descriptor')
    if actual != expected or len({row['prog_id'] for row in owned}) != 3:
        raise ValueError('incomplete, extra or duplicate attachment set')
    if len({row['fd'] for row in owned}) != 3:
        raise ValueError('duplicate attachment descriptors')
    return owned


def parse_maps(path):
    maps = {}
    for line in Path(path).read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row['type'] == 'attached_probes':
            continue
        if row['type'] != 'map':
            raise ValueError('unexpected tracer output type: ' + row['type'])
        for key, value in row['data'].items():
            if key in maps:
                raise ValueError('duplicate map snapshot')
            maps[key] = value
    return maps


def map_rows(value):
    if value is None:
        return []
    assert isinstance(value, dict), value
    result = []
    for key, count in value.items():
        assert isinstance(count, int) and count >= 0
        assert re.fullmatch(r'\[?[0-9]+(?:,\s*[0-9]+)*\]?', key), key
        result.append((tuple(map(int, key.strip('[]').split(','))), count))
    return result


def validate_counts(maps):
    assert maps.get('@bad_boolean', 0) == 0
    assert maps.get('@bad_return_pc', 0) == 0
    for name in ('@depth', '@entry_phase', '@return_pc', '@last_arg', '@seen', '@phase'):
        assert maps.get(name) in (None, {}, 0), ('unfinished or private scratch map', name)
    entries = dict(map_rows(maps.get('@entries')))
    returns = dict(map_rows(maps.get('@returns')))
    repeated = dict(map_rows(maps.get('@same_address')))
    phases = dict(map_rows(maps.get('@total_entries')))
    completed = dict(map_rows(maps.get('@total_returns')))
    assert set(phases) == {(1,), (3,)} and phases == completed
    assert dict(map_rows(maps.get('@markers'))) == {(i,): 1 for i in (1, 2, 3, 4)}
    for phase in (1, 3):
        assert sum(v for k, v in entries.items() if k[0] == phase) == phases[(phase,)]
        assert sum(v for k, v in returns.items() if k[0] == phase) == phases[(phase,)]
    for (phase, caller), count in entries.items():
        assert phase in (1, 3) and caller > 0 and count > 0
        assert returns.get((phase, caller, 0), 0) + returns.get((phase, caller, 1), 0) == count
        assert 0 <= repeated.get((phase, caller), 0) < count
    assert all((p, caller) in entries and answer in (0, 1) for p, caller, answer in returns)
    assert set(repeated) <= set(entries)
    return {'status': 'balanced-entry-return-census', 'total_entries':
            {str(key[0]): count for key, count in phases.items()},
            'rows': [{'phase': phase, 'return_pc': caller, 'entries': count,
                      'false': returns.get((phase, caller, 0), 0),
                      'true': returns.get((phase, caller, 1), 0),
                      'same_address_as_previous_at_site': repeated.get((phase, caller), 0)}
                     for (phase, caller), count in sorted(entries.items())],
            'max_depth': maps.get('@max_depth', 0)}


class BpfCensus:
    def __init__(self, pid, out, binary, symbol=RUNTIME_SYMBOL):
        self.pid, self.out = pid, Path(out)
        self.process = self.owner = self.log = self.errors = None
        self.read_fd = self.write_fd = None
        self.closed = False
        self.markers = []
        self.record = {'subject_pid': pid, 'controller_pid': os.getpid(), 'constructor_complete': False}
        self.target = target_info(binary, symbol)
        save(self.out / 'probe-target.json', self.target)
        try:
            self.read_fd, self.write_fd = os.pipe()
            source = (HERE / 'census_template.bt').read_text()
            for old, new in {'CONTROLLER_PID': str(os.getpid()), 'CONTROL_FD': str(self.write_fd),
                             'SUBJECT_PID': str(pid), 'SUBJECT_BINARY': self.target['binary'],
                             'SUBJECT_SYMBOL': symbol}.items():
                source = source.replace(old, new)
            script = self.out / 'census.bt'
            script.write_text(source)
            self.log = (self.out / 'bpf.jsonl').open('w')
            self.errors = (self.out / 'bpf.stderr').open('w')
            executable = str(Path(shutil.which('bpftrace')).resolve())
            # Default bpftrace map misses are zero-valued normal control flow.
            # -kk logs each expected miss; conservation and explicit invalid-PC/
            # Boolean counters validate this bounded count-only program instead.
            self.command = [executable, '-f', 'json', str(script)]
            self.process = subprocess.Popen(self.command, stdout=self.log, stderr=self.errors,
                                            env=dict(os.environ, BPFTRACE_MAX_MAP_KEYS='8192'))
            self.owner = check_process(self.process.pid, executable, cwd=Path.cwd(), argv=self.command)
            deadline = time.monotonic() + 30
            while True:
                if self.process.poll() is not None:
                    raise RuntimeError('tracer ended before attachment proof')
                process = subprocess.run(['bpftool', '-j', 'perf', 'show'],
                                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                assert process.returncode == 0, process.stderr
                raw = json.loads(process.stdout)
                own = [row for row in raw if row.get('pid') == self.process.pid]
                save(self.out / 'own-attachments.json', own)
                try:
                    validate_attachments(own, self.target, self.process.pid)
                    break
                except ValueError:
                    if time.monotonic() >= deadline:
                        raise
                    time.sleep(0.1)
            # Prove this exact observed inventory would reject one missing site.
            try:
                validate_attachments(own[:-1], self.target, self.process.pid)
            except ValueError:
                self.record['missing_attachment_control'] = 'rejected'
            else:
                raise AssertionError('missing attachment accepted')
            self.record.update(constructor_complete=True, attachments=own,
                               attachment_ready_ns=time.monotonic_ns(), command=self.command)
        except BaseException as error:
            self.record['constructor_error'] = repr(error)
            self.stop(validate=False)
            raise

    def phase(self, value):
        assert value in (1, 2, 3, 4)
        assert [row['phase'] for row in self.markers] == list(range(1, value))
        assert self.process.poll() is None
        before = time.monotonic_ns()
        assert os.write(self.write_fd, b'x' * value) == value
        self.markers.append({'phase': value, 'before_write_ns': before,
                             'after_write_ns': time.monotonic_ns()})

    def stop(self, validate=True):
        if self.closed:
            return self.record
        try:
            if self.process is not None:
                self.record['cleanup'] = finish_owned_popen(self.process, self.owner, signal.SIGINT, 15)
        finally:
            for fd in (self.read_fd, self.write_fd):
                if fd is not None:
                    os.close(fd)
            for stream in (self.log, self.errors):
                if stream is not None:
                    stream.close()
            self.closed = True
            self.record['markers'] = self.markers
            save(self.out / 'counter-control.json', self.record)
        if validate:
            assert self.record['cleanup']['exit'] == 0, self.record['cleanup']
            assert (self.out / 'bpf.stderr').read_text() == '', 'tracer warning/error; inspect preserved stderr'
            maps = parse_maps(self.out / 'bpf.jsonl')
            result = validate_counts(maps)
            save(self.out / 'counts.json', result)
            self.record['counts_status'] = result['status']
            save(self.out / 'counter-control.json', self.record)
        return self.record
