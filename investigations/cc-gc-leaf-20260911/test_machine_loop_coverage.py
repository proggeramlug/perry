import unittest
from machine_loop_coverage import analyze, locate_ip, parse_disassembly


class MachineLoopTests(unittest.TestCase):
    def fixture(self):
        return parse_disassembly('''00000100 <test>:
 100: push %rbp
 101: mov %rsp,%rbp
 104: call 800 <candidate>
 109: add $0x1,%eax
 10c: cmp $0x9,%eax
 10f: jne 104 <test+0x4>
 111: call 900 <allocating>
 116: pop %rbp
 117: ret
Disassembly of section .fini:
''', 'test')

    def test_exact_gc_call_and_loop(self):
        r = analyze(self.fixture(), 0x118, {0x109, 0x116}, {'candidate'})
        self.assertEqual(r['loop_addresses'], {0x104, 0x109, 0x10c, 0x10f})
        self.assertEqual([row['return_pc'] for row in r['calls']], [0x109])
        self.assertTrue(locate_ip(r, 0x10a)['candidate_loop'])
        self.assertFalse(locate_ip(r, 0x111)['candidate_loop'])

    def test_changed_callee_and_map_cannot_pass(self):
        r = analyze(self.fixture(), 0x118, {0x109}, {'wrong'})
        self.assertFalse(r['calls'])
        r = analyze(self.fixture(), 0x118, {0x108}, {'candidate'})
        self.assertFalse(r['calls'])

    def test_nonloop_block_is_separate(self):
        r = analyze(self.fixture(), 0x118, {0x116}, {'allocating'})
        self.assertFalse(r['loop_addresses'])
        self.assertTrue(locate_ip(r, 0x111)['candidate_block'])
        self.assertFalse(locate_ip(r, 0x109)['candidate_block'])

    def test_unsupported_branch_and_bad_pc_fail(self):
        with self.assertRaises(ValueError):
            analyze([(0x100, 'jmp', '*%rax')], 0x102, set(), set())
        r = analyze(self.fixture(), 0x118, {0x109}, {'candidate'})
        with self.assertRaises(ValueError):
            locate_ip(r, 0x118)

    def test_prefixed_control_transfer(self):
        with self.assertRaises(ValueError):
            analyze([(0x100, 'bnd', 'jmp *%rax')], 0x103, set(), set())
        r = analyze([(0x100, 'repz', 'ret'), (0x102, 'call', '800 <candidate>'),
                     (0x107, 'ret', '')], 0x108, {0x107}, {'candidate'})
        self.assertEqual(r['reachable_instructions'], 1)
        self.assertFalse(r['calls'])


if __name__ == '__main__':
    unittest.main()
