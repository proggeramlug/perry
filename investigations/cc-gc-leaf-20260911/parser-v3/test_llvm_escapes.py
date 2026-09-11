import importlib.util
import io
from pathlib import Path
import unittest
import callsite_census as current

spec = importlib.util.spec_from_file_location('frozen_callsite_v1', Path(__file__).resolve().parents[1]/'callsite_census.py')
old = importlib.util.module_from_spec(spec); spec.loader.exec_module(old)


class LlvmEscapeTests(unittest.TestCase):
    def test_doubled_backslash_in_constant_is_not_global_alias(self):
        ir = r'''@s = private constant [9 x i8] c"\\n alias\00"
define void @actual() {
  ret void
}
'''
        with self.assertRaisesRegex(ValueError, 'unsupported global alias'):
            old.inventory(io.StringIO(ir))
        found = current.inventory(io.StringIO(ir))
        self.assertEqual(found['aliases'], {})
        self.assertEqual(list(found['definitions']), ['actual'])

    def test_real_alias_and_quoted_name_escape_remain_distinct(self):
        ir = r'''@"a\\b" = alias void (), ptr @actual
define void @actual() {
  ret void
}
'''
        self.assertEqual(current.inventory(io.StringIO(ir))['aliases'], {'a\\b':'actual'})
        self.assertEqual(current.call_parts(r'call void asm sideeffect "\\n @fake()", ""()')[2], '<inline-asm>')
        self.assertEqual(current.attr_refs(r' #1 [ "name\\#99"() ]'), {'1'})

    def test_comment_fast_case_is_exact(self):
        for line in ['  %v = call ptr @fn()\n', '; only comment\n', 'entry: ; preds = %prev\n',
                     '  call void @fn() ; note\n', '  @s = constant [2 x i8] c";\\00"\n',
                     '"quoted;string" ; comment', '', '  \n', '  ret void\n']:
            self.assertEqual(current.uncomment(line), old.uncomment(line))


if __name__ == '__main__': unittest.main()
