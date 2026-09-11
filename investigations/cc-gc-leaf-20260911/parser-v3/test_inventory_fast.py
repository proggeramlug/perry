import importlib.util
import io
from pathlib import Path
import unittest
import callsite_census as fast
from test_callsite_census import PRE, POST

spec=importlib.util.spec_from_file_location('prior_inventory',Path(__file__).resolve().parents[1]/'parser-v2/callsite_census.py')
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)


class InventoryFastTests(unittest.TestCase):
    def test_headers_roots_aliases_and_boundaries_match(self):
        shadow='''declare ptr @js_shadow_frame_enter(i32)
define void @shadow() {
entry:
 %frame = invoke ptr @js_shadow_frame_enter(i32 3)
 to label %next unwind label %eh
next:
 call void @other(ptr @js_shadow_fake)
 ret void
eh:
 %lp = landingpad token cleanup
 ret void
}
'''
        for ir in [PRE,POST,PRE+shadow]:
            self.assertEqual(fast.inventory(io.StringIO(ir)),old.inventory(io.StringIO(ir)))
        found=fast.inventory(io.StringIO(shadow))
        self.assertEqual(found['shadow'],{'shadow'})
        counterfactual=shadow.replace('@js_shadow_frame_enter','@other_frame_enter')
        self.assertEqual(fast.inventory(io.StringIO(counterfactual))['shadow'],set())
        for ir in ['define void @broken() {\n ret void\n',shadow.replace('to label %next unwind label %eh','')]:
            with self.assertRaises(ValueError):fast.inventory(io.StringIO(ir))

    def test_unrelated_call_validation_is_still_mandatory_later(self):
        ir='''define void @bad() {
 call void inttoptr (i64 1 to ptr)()
 ret void
}
'''
        fast.inventory(io.StringIO(ir))
        with self.assertRaisesRegex(ValueError,'unsupported'):
            list(fast.records(io.StringIO(ir)))


if __name__=='__main__':unittest.main()
