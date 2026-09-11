"""Controller-side phase timestamps; no target probes or memory reads."""
from pathlib import Path
import json
import time


class PhaseRecorder:
    def __init__(self, pid, out, binary):
        self.pid, self.out, self.binary = pid, Path(out), str(binary)
        self.phases = []

    def phase(self, phase):
        assert phase == len(self.phases) + 1
        self.phases.append({'phase': phase, 'at_ns': time.monotonic_ns()})

    def stop(self):
        record = {'kind': 'controller-timestamps-only', 'phases': self.phases}
        (self.out / 'phase-recorder.json').write_text(json.dumps(record, indent=2) + '\n')
        return record
