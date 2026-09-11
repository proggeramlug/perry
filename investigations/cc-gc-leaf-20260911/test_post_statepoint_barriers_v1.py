import unittest
import post_statepoint_barriers_v1 as p

def point(token,callee,args=''):
    count=0 if not args else len(args.split(','))
    return f'  %{token} = call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 0, i32 0, ptr @{callee}, i32 {count}, i32 0'+(', '+args if args else '')+', i32 0, i32 0)\n'

def fixture(between='',delayed=''):
    return ('define void @f() gc "statepoint-example" {\nentry:\n'+point('allocation','js_object_alloc')+delayed+
            '  %owner = call ptr addrspace(1) @llvm.experimental.gc.result.p1(token %allocation)\n'
            '  %bits = ptrtoint ptr addrspace(1) %owner to i64\n'+between+
            point('barrier1','js_write_barrier','i64 %bits, i64 1')+
            point('barrier2','js_write_barrier','i64 %bits, i64 1')+'  ret void\n}\n')

def count(text):
    r,_=p.analyze_function(text)
    assert not r.get('excluded'),r
    return len(r['barriers']),sum(bool(x['allocation_origin']) for x in r['barriers'])

class ActualPointTests(unittest.TestCase):
    def test_first_barrier_fresh_second_after_point_is_not(self):
        self.assertEqual(count(fixture()),(2,1))

    def test_even_known_cannot_collect_statepoint_ends_window(self):
        self.assertEqual(count(fixture(point('known','js_implicit_this_get'))),(2,0))

    def test_plain_leaf_call_preserves_window(self):
        self.assertEqual(count(fixture('  %leaf = call double @js_implicit_this_get()\n')),(2,1))

    def test_delayed_result_cannot_restore_pre_point_origin(self):
        self.assertEqual(count(fixture(delayed=point('other','js_implicit_this_get'))),(2,0))

    def test_changed_allocator_declines(self):
        self.assertEqual(count(fixture().replace('@js_object_alloc,','@unreviewed_constructor,')),(2,0))

    def test_missing_actual_point_kill_defeats_negative_control(self):
        view,forced,safe,_,_=p.normalize(fixture())
        p.core.FORCED_COLLECT_LINES=frozenset()
        functions,groups,declarations=p.core.parse(view)
        r=p.core.analyze_function(functions[0],groups,declarations,set(),safe,True,True)
        self.assertEqual(sum(bool(x['allocation_origin']) for x in r['barriers']),2)
        self.assertNotEqual(count(fixture()),(2,2))

if __name__=='__main__':unittest.main()
