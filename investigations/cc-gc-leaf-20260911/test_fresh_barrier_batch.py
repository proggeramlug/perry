import hashlib
import io
import unittest
import fresh_barrier_batch as batch


class BarrierBatchTests(unittest.TestCase):
    def test_stream_preserves_line_offsets_and_whole_text_hash(self):
        text = '; module\n\ndefine void @a() {\nentry:\n%a = call i64 @js_object_alloc(i32 0, i32 1)\ncall void @js_write_barrier(i64 %a, i64 7)\nret void\n}\n'
        h = hashlib.sha256()
        values = list(batch.function_texts(io.StringIO(text), h))
        self.assertEqual(h.hexdigest(), hashlib.sha256(text.encode()).hexdigest())
        self.assertEqual((values[0][0], values[0][1]), (3, 8))
        r = batch.analyze_one(values[0][2], values[0][0], [], [])
        self.assertEqual(r['strict_fresh_origin_sites'], 1)
        self.assertEqual(r['strict_hits'][0]['line'], 6)
        self.assertEqual(r['strict_hits'][0]['allocation_origin'], 'a:5:js_object_alloc')
        self.assertEqual(r['barriers'][0]['line'], 6)

    def test_extra_arm_and_unsupported_function_remain_separate(self):
        text = 'define void @a() {\nentry:\n%a = call i64 @js_object_alloc(i32 0, i32 1)\ncall void @candidate()\ncall void @js_write_barrier(i64 %a, i64 7)\nret void\n}\n'
        r = batch.analyze_one(text, 101, ['candidate'], [])
        self.assertEqual((r['strict_fresh_origin_sites'], r['extra_leaf_fresh_origin_sites']), (0, 1))
        self.assertEqual(r['extra_leaf_hits'][0]['line'], 105)
        bad = 'define void @b() {\nentry:\nindirectbr ptr null, [label %done]\ndone:\nret void\n}\n'
        self.assertTrue(batch.analyze_one(bad, 201, [], [])['excluded'])

    def test_truncation_and_nested_definition_do_not_become_complete(self):
        for text in ('define void @a() {\nret void\n', 'define void @a() {\ndefine void @b() {\n}\n'):
            with self.assertRaises(ValueError):
                list(batch.function_texts(io.StringIO(text), hashlib.sha256()))


if __name__ == '__main__':
    unittest.main()
