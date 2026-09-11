#!/usr/bin/env python3
"""Small parser/dataflow witnesses; no runtime or collector correctness claim."""
import unittest
from unittest.mock import patch
import fresh_barrier_census as census


def module(body):
    return 'define void @fixture(ptr %callback) {\nentry:\n' + body + '\n}\n'


ALLOC = '%a = call i64 @js_object_alloc(i32 0, i32 2)'
WB = 'call void @js_write_barrier_slot(i64 %a, i64 0, i64 7)'


class FreshBarrierTests(unittest.TestCase):
    def test_positive_cast_chain_and_single_predecessor(self):
        ir = module(ALLOC + '''
%p = inttoptr i64 %a to ptr
%i = ptrtoint ptr %p to i64
%d = bitcast i64 %i to double
%b = bitcast double %d to i64
br label %store
store:
call void @js_write_barrier_slot(i64 %b, i64 0, i64 7)
ret void''')
        r = census.analyze(ir)
        self.assertEqual((r['strict_barrier_sites'], r['strict_fresh_origin_sites']), (1, 1))

    def test_collecting_call_kills_but_extra_leaf_is_separate(self):
        ir = module(ALLOC + '\ncall void @candidate_reader()\n' + WB + '\nret void')
        r = census.analyze(ir, ['candidate_reader'])
        self.assertEqual((r['strict_fresh_origin_sites'], r['extra_leaf_fresh_origin_sites']), (0, 1))

    def test_real_second_allocation_kills_first_only(self):
        ir = module(ALLOC + '\n%b = call i64 @js_array_alloc(i32 2)\n' + WB +
                    '\ncall void @js_write_barrier(i64 %b, i64 7)\nret void')
        r = census.analyze(ir)
        self.assertEqual((r['strict_barrier_sites'], r['strict_fresh_origin_sites']), (2, 1))

    def test_join_loop_load_and_unknown_alias_decline(self):
        ir = module(ALLOC + '''
br i1 true, label %left, label %right
left:
br label %join
right:
br label %join
join:
call void @js_write_barrier(i64 %a, i64 7)
%loaded = load i64, ptr null
call void @js_write_barrier(i64 %loaded, i64 7)
%shifted = add i64 %a, 8
call void @js_write_barrier(i64 %shifted, i64 7)
br i1 true, label %join, label %done
done:
ret void''')
        r = census.analyze(ir)
        self.assertEqual((r['strict_barrier_sites'], r['strict_fresh_origin_sites']), (3, 0))

    def test_indirect_call_cannot_borrow_argument_callee_identity(self):
        ir = module(ALLOC + '\ncall void %callback(ptr @candidate_reader)\n' + WB + '\nret void')
        r = census.analyze(ir, ['candidate_reader'])
        self.assertEqual((r['strict_fresh_origin_sites'], r['extra_leaf_fresh_origin_sites']), (0, 0))

    def test_leaf_marker_alone_is_not_collection_proof_and_unreachable_excluded(self):
        ir = 'attributes #3 = { "gc-leaf-function" }\n' + module(ALLOC + '''
call void @reader() #3
call void @js_write_barrier(i64 %a, i64 7)
ret void
dead:
call void @js_write_barrier(i64 %a, i64 7)
ret void''')
        r = census.analyze(ir)
        self.assertEqual((r['strict_barrier_sites'], r['strict_fresh_origin_sites']), (1, 0))
        r = census.analyze(ir, noncollecting=['reader'])
        self.assertEqual((r['strict_barrier_sites'], r['strict_fresh_origin_sites']), (1, 1))

    def test_allocating_invoke_result_never_reaches_unwind_as_fresh(self):
        ir = module('''%old = call i64 @js_array_alloc(i32 2)
%a = invoke i64 @js_object_alloc(i32 0, i32 2)
to label %normal unwind label %failure
normal:
call void @js_write_barrier(i64 %a, i64 7)
ret void
failure:
call void @js_write_barrier(i64 %old, i64 7)
ret void''')
        r = census.analyze(ir)
        self.assertEqual((r['strict_barrier_sites'], r['strict_fresh_origin_sites']), (2, 0))

    def test_cached_singleton_is_not_an_allocation_origin(self):
        r = census.analyze(module('%a = call i64 @js_closure_alloc_singleton(ptr null)\n' + WB + '\nret void'))
        self.assertEqual(r['strict_fresh_origin_sites'], 0)

    def test_unsupported_terminator_is_explicit(self):
        r = census.analyze(module(ALLOC + '\nindirectbr ptr null, [label %done]\ndone:\nret void'))
        self.assertTrue(r['functions'][0]['excluded'])
        self.assertEqual(r['strict_barrier_sites'], 0)

    def test_sabotage_missing_allocator_breaks_positive_witness(self):
        ir = module(ALLOC + '\n' + WB + '\nret void')
        self.assertEqual(census.analyze(ir)['strict_fresh_origin_sites'], 1)
        with patch.object(census, 'ALLOCATORS', set()):
            with self.assertRaises(AssertionError):
                self.assertEqual(census.analyze(ir)['strict_fresh_origin_sites'], 1)

    def test_sabotage_false_leaf_breaks_collecting_negative_witness(self):
        ir = module(ALLOC + '\ncall void @must_collect()\n' + WB + '\nret void')
        self.assertEqual(census.analyze(ir)['strict_fresh_origin_sites'], 0)
        with patch.object(census, 'BOOKKEEPING', census.BOOKKEEPING | {'must_collect'}):
            with self.assertRaises(AssertionError):
                self.assertEqual(census.analyze(ir)['strict_fresh_origin_sites'], 0)


if __name__ == '__main__':
    unittest.main()
