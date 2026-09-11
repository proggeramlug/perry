import json
from pathlib import Path
import tempfile
import unittest
import perf_self_reconcile as p


TEXT = """# Total Lost Samples: 0
# Samples: 4 of event 'cycles:u'
# Event count (approx.): 99
# Overhead, Samples, Period,Command,Shared Object,Symbol,IPC   [IPC Coverage]
 50.00%, 3, 9007199254740993,cc,/owned/app,[.] js_one,-      -
 50.00%, 1, 7,cc,/owned/app,[.] perry_fn_two,-      -
"""


class PerfSelfTests(unittest.TestCase):
    def test_integer_count_ignores_rounded_header_and_overhead(self):
        self.assertEqual(p.parse_report(TEXT)['totals'], {'samples': 4, 'period': 9007199254741000})

    def test_unsupported_rows_truncation_and_loss_reject(self):
        for text in (TEXT.rstrip('\n'), TEXT.replace('Samples, Period', 'Period, Samples'),
                     TEXT.replace('Total Lost Samples: 0', 'Total Lost Samples: 1'),
                     TEXT.replace(' 3, 9007199254740993', ' 3, bad'),
                     TEXT + 'truncated data\n', TEXT.replace('cycles:u', 'cycles:P')):
            with self.subTest(text=text), self.assertRaises(ValueError):
                p.parse_report(text)

    def test_omitted_or_extra_sample_fails_reconciliation(self):
        with tempfile.TemporaryDirectory() as tmp:
            d = Path(tmp)
            report, summary, command = d/'report', d/'summary', d/'command'
            report.write_text(TEXT)
            summary.write_text(json.dumps({'status': 'complete-actual-ip-self-census',
                                          'totals': {'samples': 4, 'period': 9007199254741000}}))
            command.write_text(json.dumps({'exit': 0, 'stdout_sha256': p.sha(report),
                'command': ['perf', 'report', '--stdio', '--no-children', '--show-total-period',
                            '--show-nr-samples', '--sort=comm,dso,symbol', '--field-separator=,',
                            '--percent-limit=0']}))
            self.assertEqual(p.reconcile(report, summary, command, d/'out')['status'], 'PASS')
            r = json.loads(summary.read_text()); r['totals']['samples'] -= 1
            summary.write_text(json.dumps(r))
            with self.assertRaisesRegex(ValueError, 'whole-capture mismatch'):
                p.reconcile(report, summary, command, d/'out')


if __name__ == '__main__':
    unittest.main()
