import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import callsite_census as c
import test_callsite_census as fixtures
spec = importlib.util.spec_from_file_location('supplement', Path(__file__).with_name('supplement.py'))
s = importlib.util.module_from_spec(spec); spec.loader.exec_module(s)


class SupplementTest(unittest.TestCase):
    def test_zero_call_definition_and_shadow_request_are_separate(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); cap = root/'cap'; text = root/'text'
            fixtures.fixture_attempt(cap, text)
            ir = text/'pid-123-attempt-0/pre-rs4gc.ll'
            original = ir.read_text()
            ir.write_text(original + '''
define void @shadow(i32 %n) {
entry:
  %base = call ptr @js_shadow_frame_enter(i32 3)
  invoke void @js_already() to label %done unwind label %eh
done:
  ret void
eh:
  %lp = landingpad token cleanup
  ret void
}
''')
            audit = root/'audit.csv'
            import csv
            with audit.open('w', newline='') as f:
                w = csv.DictWriter(f, fieldnames=list(next(iter(fixtures.AUDIT.values()))))
                w.writeheader(); w.writerows(fixtures.AUDIT.values())
            c.analyze(cap, audit, root/'result', text_root=text)
            s.supplement(root/'result', text, audit, ROOT, root/'supplement.json')
            result = json.loads((root/'supplement.json').read_text())
            self.assertEqual(result['pre_total_definitions'], 3)
            self.assertEqual(result['shadow_entry_callsites'], 1)
            self.assertEqual(result['shadow_requested_slots_static_sum'], 3)
            self.assertEqual(result['pre_known_cannot_collect_invokes'], {'js_already': 1})
            modes = {r['root_mode']:r['functions'] for r in result['definition_root_modes'] if r['stage']=='pre-rs4gc'}
            self.assertEqual(modes, {'native':1, 'shadow-observed':1, 'no-root-mechanism-observed':1})
            # Counterfactual: a nonconstant request must remain unknown, not become zero.
            ir.write_text(ir.read_text().replace('js_shadow_frame_enter(i32 3)', 'js_shadow_frame_enter(i32 %n)'))
            with self.assertRaisesRegex(AssertionError, 'pre-IR mirror changed'):
                s.supplement(root/'result', text, audit, ROOT, root/'stale.json')
            c.analyze(cap, audit, root/'result2', text_root=text)
            s.supplement(root/'result2', text, audit, ROOT, root/'changed.json')
            changed = json.loads((root/'changed.json').read_text())
            self.assertEqual(changed['shadow_nonconstant_requests'], 1)
            self.assertIsNone(changed['shadow_requests'][0]['requested_slots'])
            self.assertNotEqual(result['shadow_requested_slots_static_sum'], changed['shadow_requested_slots_static_sum'])


if __name__ == '__main__': unittest.main()
