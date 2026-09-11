import unittest
from unittest.mock import patch
import fresh_barrier_census_v3 as c


def fn(body):
    return 'define void @fixture() {\nentry:\n' + body + '\nret void\n}\n'


BODY = '''%root = alloca ptr addrspace(1), align 8
%a = call i64 @js_object_alloc(i32 0, i32 2)
%p = inttoptr i64 %a to ptr addrspace(1)
store ptr addrspace(1) %p, ptr %root, align 8
%reload = load ptr addrspace(1), ptr %root, align 8
%bits = ptrtoint ptr addrspace(1) %reload to i64
%same = call i64 asm "", "=r,0"(i64 %bits) #0
call void @js_write_barrier(i64 %same, i64 7)'''


class AliasTests(unittest.TestCase):
    def test_exact_root_slot_and_identity_roundtrip(self):
        r = c.analyze(fn(BODY), local_aliases=True)
        self.assertEqual((r['strict_barrier_sites'], r['strict_fresh_origin_sites']), (1, 1))
        self.assertEqual(r['functions'][0]['alias_ledger']['admitted_scalar_allocas'], ['%root'])
        self.assertEqual(r['functions'][0]['alias_ledger']['exact_tied_identity_calls'], 1)
        self.assertEqual(c.analyze(fn(BODY))['strict_unresolved_parent_sites'], 1)

    def test_collection_clears_saved_slot_fact(self):
        b = BODY.replace('%reload =', 'call void @may_collect()\n%reload =')
        self.assertEqual(c.analyze(fn(b), local_aliases=True)['strict_fresh_origin_sites'], 0)
        r = c.analyze(fn(b), extra=['may_collect'], local_aliases=True)
        self.assertEqual((r['strict_fresh_origin_sites'], r['extra_leaf_fresh_origin_sites']), (0, 1))

    def test_slot_escape_volatile_and_aliases_decline(self):
        for b in (BODY.replace('%a =', 'call void @observe(ptr %root)\n%a ='),
                  BODY.replace('store ptr addrspace(1)', 'store volatile ptr addrspace(1)'),
                  BODY.replace('%a =', '%alias = getelementptr i8, ptr %root, i64 0\n%a =')):
            r = c.analyze(fn(b), local_aliases=True)
            self.assertEqual(r['strict_fresh_origin_sites'], 0)
            self.assertIn('%root', r['functions'][0]['alias_ledger']['declined_scalar_allocas'])

    def test_overwrite_and_width_changing_cast_do_not_recover_identity(self):
        b = BODY.replace('%reload =', 'store ptr addrspace(1) null, ptr %root, align 8\n%reload =')
        self.assertEqual(c.analyze(fn(b), local_aliases=True)['strict_fresh_origin_sites'], 0)
        for space in (270, 271, 272, 2):
            b = f'%a = call i64 @js_object_alloc(i32 0, i32 2)\n%p = inttoptr i64 %a to ptr addrspace({space})\n%b = ptrtoint ptr addrspace({space}) %p to i64\ncall void @js_write_barrier(i64 %b, i64 7)'
            self.assertEqual(c.analyze(fn(b), local_aliases=True)['strict_fresh_origin_sites'], 0)
        b = '%a = call i64 @js_object_alloc(i32 0, i32 2)\n%p = inttoptr i64 %a to ptr\n%short = ptrtoint ptr %p to i32\n%q = inttoptr i32 %short to ptr\n%b = ptrtoint ptr %q to i64\ncall void @js_write_barrier(i64 %b, i64 7)'
        self.assertEqual(c.analyze(fn(b), local_aliases=True)['strict_fresh_origin_sites'], 0)

    def test_nonidentical_asm_and_join_do_not_keep_facts(self):
        for assembly in ('asm "nop", "=r,0"', 'asm sideeffect "", "=r,0"', 'asm "", "=r,r"'):
            b = BODY.replace('asm "", "=r,0"', assembly)
            self.assertEqual(c.analyze(fn(b), local_aliases=True)['strict_fresh_origin_sites'], 0)
        b = BODY.replace('%reload =', 'br i1 true, label %a1, label %a2\na1:\nbr label %join\na2:\nbr label %join\njoin:\n%reload =')
        self.assertEqual(c.analyze(fn(b), local_aliases=True)['strict_fresh_origin_sites'], 0)

    def test_sabotage_empty_asm_contract_and_false_collection_summary_fail(self):
        with patch.object(c, 'TIED_IDENTITY', c.re.compile(r'(?!)')):
            with self.assertRaises(AssertionError):
                self.assertEqual(c.analyze(fn(BODY), local_aliases=True)['strict_fresh_origin_sites'], 1)
        b = BODY.replace('%reload =', 'call void @must_collect()\n%reload =')
        with self.assertRaises(AssertionError):
            self.assertEqual(c.analyze(fn(b), noncollecting=['must_collect'], local_aliases=True)['strict_fresh_origin_sites'], 0)


if __name__ == '__main__':
    unittest.main()
