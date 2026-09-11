#!/usr/bin/env python3
"""Preserve bound v1; apply eight explicit source-audit conclusions to a copy."""
import csv
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = HERE.parent / 'helper-audit.csv'
BASE_SHA = 'be08f9ca8842aa0df27be602013e57261f067798461da09e29c6f540b4fbc48a'
assert hashlib.sha256(BASE.read_bytes()).hexdigest() == BASE_SHA
rows = list(csv.DictReader(BASE.open()))
fields = list(rows[0])
by_name = {row['helper']: row for row in rows}
changes = []

def update(name, allocation, managed, collect, reentry, reason, proof):
    row = by_name[name]
    before = dict(row)
    row.update(audit_status='reviewed', allocation_class=allocation,
               perry_heap_allocation=managed, may_collect=collect,
               may_reenter_js=reentry, reason=reason, proof=proof)
    assert before['current_effect'] == row['current_effect']
    changes.append({'helper': name, 'before': before, 'after': dict(row)})

raw_proof = ('object/field_get_set/accessors.rs:18-83; object/live_slots.rs:52-57; '
             'object/shapes.rs:634-655,868-875,1512-1516; object/shapes_store.rs:178-191,313-340; '
             'object/spill.rs:42-50,90-117,355-369; value/addr_class.rs:237-249; '
             'buffer/header.rs:487-489; state.rs:53-61,106-129; '
             'object/descriptor_state.rs:118-128; object/mod.rs:520-574; '
             'object/field_get_set.rs:249-253; object/exotic_expando.rs:115-120; '
             'object/shapes.rs:377-388; tls_hot.rs:282-325,634-655,840-942; '
             'arena/block.rs:330-368,403-410,435-437,549-565; arena/page_meta/mod.rs:460-495')
for name in ('js_object_get_field', 'js_object_get_field_f64'):
    update(name, 'may allocate', 'no', 'no', 'no',
           'V2 complete raw indexed read: shape-stamp and slab reads, inline slot load or spill/legacy map read; no getter/Proxy/coercion. Legacy spill mode environment read, cold RuntimeState Box/Vec and HotTls initialization can allocate native memory/initial arena backing, but create no managed cell and never collect. Null-pointer diagnostic is native I/O only. Valid ObjectHeader ABI required.',
           raw_proof + '; object/field_get_set/field_ops.rs:257-260')
update('js_object_get_own_field_or_undef', 'may allocate', 'no', 'no', 'no',
       'V2 closes existing CannotCollect premise: scalar receiver/class/key-array validation, dense raw key-slot reads, SSO stack or heap byte comparison, then the closed indexed/spill read. No generic Array access, accessor invocation, materialization or shape mint. Cold state/TLS/arena backing may allocate native storage only.',
       'object/object_ops/accessors.rs:120-219; object/object_ops.rs:56-100; string/compare.rs:245-275; ' + raw_proof)
update('js_object_get_class_id', 'may allocate', 'no', 'no', 'no',
       'V2 closes existing CannotCollect premise: scalar handle/address tests, process idle latches, per-agent Set/Map contains_key lookups and header/class-id loads. Those registry readers never insert managed values or invoke callbacks. Cold HotKey slot registration/HotTls backing can allocate native memory; no managed-cell creation or GC.',
       'object/field_get_set/field_ops.rs:206-237; set.rs:179-180,237-246,271-299; map.rs:365-366,382-392,427-460; '
       'value/addr_class.rs:181-217,237-249; buffer/header.rs:487-489; tls_hot.rs:282-325,634-655,840-942; '
       'arena/block.rs:330-368,403-410,435-437,549-565')
eq_proof = ('value/equality.rs:21-29,40-47,52-183,194-214; bigint/compare.rs:105-118; bigint/mod.rs:175-193; '
            'string/mod.rs:804-825; value/jsvalue.rs:257-299; value/addr_class.rs:288-369; '
            'symbol.rs:149-159; arena/page_meta/mod.rs:932-958; gc/malloc.rs:200-213,508-534; '
            'gc/types.rs:710-714,1061-1068; tls_hot.rs:282-325,634-655,840-942; '
            'arena/block.rs:330-368,403-410,435-437,549-565')
for name in ('js_jsvalue_equals', 'js_jsvalue_same_value_zero'):
    update(name, 'may allocate', 'no', 'no', 'no',
           'V2 complete strict/SameValueZero route: numeric/tag operations, fixed BigInt limb-array compare, borrowed heap/stack SSO bytes, and bounded forwarding-header reads. The tracked-header tail may activate/grow native MallocState.set via ensure_set_built and initialize native TLS/arena backing; it does not call gc_malloc or a collector, materialize strings/BigInts, coerce, or invoke JS. Not a never-native-allocating helper.',
           eq_proof)
update('js_switch_strict_equals', 'may allocate', 'may', 'may', 'no',
       'V2 definite allocating route: the both-strings arm calls js_get_string_pointer_unified for each operand. SSO invokes materialize_to_heap -> intern_dispatch_bytes, whose miss creates a managed StringHeader. Numeric/bit arms and the strict-equality name do not establish a whole-export leaf. No coercing object callback in this export.',
       'value/nanbox.rs:337-373,274-293; string/alloc.rs:53-73; string/intern.rs:intern_dispatch_bytes; string/mod.rs:636-643')
update('js_value_typeof_tag', 'unclear', 'unclear', 'unclear', 'unclear',
       'V2 resolves bundled stream target as native mutex/map reads only, but whole export remains unclear: JS_HANDLE calls registered JsHandleTypeofFn through js_handle_is_function; no in-repository implementation/registration target found for js_set_handle_typeof. Stream kind registration is also an open native function-pointer setter, not a sealed compiler effect contract. No unconditional leaf claim from bundled default target alone.',
       'builtins/arithmetic.rs:688-828; value/handle.rs:161-176; value/tags.rs:120; '
       'object/class_handles.rs:559-572; crates/perry-stdlib/src/common/dispatch/init.rs:798-811; '
       'crates/perry-stdlib/src/streams/subclass.rs:98-132')

with (HERE / 'helper-audit.csv').open('w', newline='') as stream:
    writer = csv.DictWriter(stream, fieldnames=fields)
    writer.writeheader(); writer.writerows(rows)

paths = '''crates/perry-runtime/src/object/object_ops/accessors.rs
crates/perry-runtime/src/object/object_ops.rs
crates/perry-runtime/src/object/field_get_set/accessors.rs
crates/perry-runtime/src/object/field_get_set/field_ops.rs
crates/perry-runtime/src/object/live_slots.rs
crates/perry-runtime/src/object/shapes.rs
crates/perry-runtime/src/object/shapes_store.rs
crates/perry-runtime/src/object/spill.rs
crates/perry-runtime/src/object/mod.rs
crates/perry-runtime/src/object/descriptor_state.rs
crates/perry-runtime/src/object/field_get_set.rs
crates/perry-runtime/src/object/exotic_expando.rs
crates/perry-runtime/src/object/class_handles.rs
crates/perry-runtime/src/state.rs
crates/perry-runtime/src/set.rs
crates/perry-runtime/src/map.rs
crates/perry-runtime/src/tls_hot.rs
crates/perry-runtime/src/fast_hash.rs
crates/perry-runtime/src/array/header.rs
crates/perry-runtime/src/arena/block.rs
crates/perry-runtime/src/arena/page_meta/mod.rs
crates/perry-runtime/src/buffer/header.rs
crates/perry-runtime/src/value/addr_class.rs
crates/perry-runtime/src/value/equality.rs
crates/perry-runtime/src/value/nanbox.rs
crates/perry-runtime/src/value/jsvalue.rs
crates/perry-runtime/src/value/handle.rs
crates/perry-runtime/src/value/tags.rs
crates/perry-runtime/src/bigint/compare.rs
crates/perry-runtime/src/bigint/mod.rs
crates/perry-runtime/src/string/compare.rs
crates/perry-runtime/src/string/mod.rs
crates/perry-runtime/src/string/alloc.rs
crates/perry-runtime/src/string/intern.rs
crates/perry-runtime/src/symbol.rs
crates/perry-runtime/src/gc/malloc.rs
crates/perry-runtime/src/gc/types.rs
crates/perry-runtime/src/gc/hot_tls.rs
crates/perry-runtime/src/gc/young_log.rs
crates/perry-runtime/src/gc/roots/runtime_handles.rs
crates/perry-runtime/src/gc/roots/temp_roots.rs
crates/perry-runtime/src/gc/shape_install.rs
crates/perry-runtime/src/gc/layout_tables.rs
crates/perry-runtime/src/gc/layout.rs
crates/perry-runtime/src/builtins/arithmetic.rs
crates/perry-stdlib/src/common/dispatch/init.rs
crates/perry-stdlib/src/streams/subclass.rs
crates/perry-codegen/src/gc_call_effects.rs'''.splitlines()
receipt = {
    'base_csv_sha256': BASE_SHA,
    'v2_csv_sha256': hashlib.sha256((HERE/'helper-audit.csv').read_bytes()).hexdigest(),
    'changed_helpers': changes,
    'unannotated_no_collect': [r['helper'] for r in rows if r['audit_status']=='reviewed'
                              and r['current_effect']=='Unknown' and r['may_collect']=='no'
                              and r['may_reenter_js']=='no'],
    'source_sha256': {p: hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in paths},
    'scope': 'Source-only; v1 and runtime/compiler effects unchanged. Valid ABI/ordinary runtime assumed. No dynamic calls or speed inferred.'
}
assert len(receipt['unannotated_no_collect']) == 48
assert hashlib.sha256(BASE.read_bytes()).hexdigest() == BASE_SHA
(HERE / 'source-receipt.json').write_text(json.dumps(receipt, indent=2)+'\n')
print(json.dumps({'base_sha256': BASE_SHA, 'v2_sha256': receipt['v2_csv_sha256'],
                  'changed_helpers': len(changes), 'unannotated_no_collect': 48}, indent=2))
