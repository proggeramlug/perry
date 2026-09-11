#!/usr/bin/env python3
"""Source inventory, not an emitted-call census or an effect inference engine.

The explicit reviewed rows below are human source audits. All other declarations
and literal direct-call names remain unclear. No production annotations change.
"""
import collections
import csv
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
CG = ROOT / "crates/perry-codegen/src"
RT = ROOT / "crates/perry-runtime/src"
SOURCES = {}

def read(path):
    path = Path(path)
    data = path.read_bytes()
    SOURCES[str(path.relative_to(ROOT))] = hashlib.sha256(data).hexdigest()
    return data.decode()

def uncomment(src):
    # Preserve literal strings and line numbers; inventory is intentionally lexical.
    pat = r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/'
    return re.sub(pat, lambda m: m[0] if m[0].startswith('"') else re.sub(r'[^\n]', ' ', m[0]), src)

def loc(path, src, offset):
    return f"{path.relative_to(ROOT)}:{src.count(chr(10), 0, offset) + 1}"

decls, calls, defs = (collections.defaultdict(list) for _ in range(3))
for path in sorted(CG.rglob('*.rs')):
    if 'test' in path.stem or 'tests' in path.parts:
        continue
    src = uncomment(read(path))
    for m in re.finditer(r'\bdeclare_function\s*\(\s*"([A-Za-z_][\w.$]*)"', src):
        decls[m[1]].append(loc(path, src, m.start()))
    for m in re.finditer(r'\.call(?:_void|_noreturn)?\s*\(\s*(?:[^,"\n]{1,80},\s*)?"([A-Za-z_][\w.$]*)"', src):
        calls[m[1]].append(loc(path, src, m.start()))

for path in sorted(RT.rglob('*.rs')):
    if 'test' in path.stem or 'tests' in path.parts:
        continue
    src = uncomment(read(path))
    for m in re.finditer(r'\b(?:pub(?:\([^)]*\))?\s+)?(?:unsafe\s+)?extern\s+"C(?:-unwind)?"\s+fn\s+(\w+)\s*\(', src):
        defs[m[1]].append(loc(path, src, m.start()))

effect_source = uncomment(read(CG / 'gc_call_effects.rs'))
effect_body = effect_source.split('fn classify_direct_callee', 1)[1].split('=> GcCallEffect::Unknown', 1)[0]
effects = {}
for group in re.finditer(r'((?:\s*(?:\|\s*)?"[^"]+")+?)\s*=>\s*GcCallEffect::(CannotCollect|AllocNoReentry)', effect_body):
    for name in re.findall(r'"([^"]+)"', group[1]):
        effects[name] = group[2]

# allocation_class concerns any heap allocation, including Rust/libc storage.
# may_collect and may_reenter concern Perry collection / generated JS callbacks.
# A no here is an audit result under valid ABI inputs in ordinary release builds,
# not authorization to annotate a helper. Native backend uncertainties remain.
review = {}
def mark(names, allocation, managed, collect, reenter, reason, proof):
    for name in names.split():
        assert name not in review, name
        review[name] = dict(allocation_class=allocation, perry_heap_allocation=managed,
            may_collect=collect, may_reenter_js=reenter, reason=reason, proof=proof)

mark('js_nanbox_pointer js_nanbox_bigint js_nanbox_is_bigint js_nanbox_get_bigint js_nanbox_is_pointer js_nanbox_get_pointer js_nanbox_get_string_pointer js_nanbox_is_string',
     'never allocates', 'no', 'no', 'no',
     'Complete bodies only perform scalar tag tests/masks and JSValue constructors/extractors; no materialization or dynamic coercion. Excludes js_nanbox_string.',
     'value/nanbox.rs:102-264,384-392; value/jsvalue.rs:55-74,155-186,228-248,306-329')
mark('js_pod_scalar_write_compatible', 'never allocates', 'no', 'no', 'no',
     'Complete body and int/uint/f32_roundtrips_exact helpers only inspect numeric tags, ranges, truncation, signs and scalar casts.',
     'value/nanbox.rs:34-95; value/jsvalue.rs:67-74,161-164')
mark('js_number_is_nan js_number_is_finite js_number_is_integer js_number_is_safe_integer',
     'never allocates', 'no', 'no', 'no',
     'Strict Number predicates inspect JSValue tag and scalar f64; unlike global isNaN/isFinite they never call ToNumber.',
     'builtins/numbers.rs:814-878; value/jsvalue.rs:67-74,161-164')
mark('js_get_empty_string js_string_length js_string_addref js_string_addref_if_heap_string',
     'never allocates', 'no', 'no', 'no',
     'Static-address return or magnitude/null/tag validation plus one header load/write. is_valid_string_ptr is two scalar tests; no string materialization.',
     'string/mod.rs:248-268; string/alloc.rs:190-221')
mark('js_string_compare js_string_equals', 'never allocates', 'no', 'no', 'no',
     'Complete comparison uses borrowed byte slices, is_ascii/from_utf8 validation and lazy encode_utf16 iterators; no Vec/collect, coercion, cache, GC or callback. Valid StringHeader ABI required.',
     'string/compare.rs:42-122; string/mod.rs:266-268,993-995')
mark('js_string_char_code_at js_string_code_point_at', 'never allocates', 'no', 'no', 'no',
     'Already-i32 index and borrowed header bytes; bounded WTF8 scalar walk, no index coercion and no character-string allocation.',
     'string/char_ops.rs:65-124,653-699; string/mod.rs:542-572,993-995,1060-1062')
mark('js_string_position_to_index', 'never allocates', 'no', 'no', 'no',
     'Raw numeric DOUBLE ABI: finite/NaN/infinity comparisons, truncation and saturating i32 conversion only; not the generic index coercion helper.',
     'string/slice_ops.rs:506-528')
mark('js_string_index_of js_string_index_of_from', 'never allocates', 'no', 'no', 'no',
     'Already-StringHeader operands and i32 index; borrowed slices and str::find plus bounded UTF16/byte offset walks. string_as_str is a borrowed view, not decoding to owned storage. No cache or materialization path.',
     'string/slice_ops.rs:429-497; string/mod.rs:542-619,993-995,1042-1062')
mark('js_math_fround js_math_clz32', 'never allocates', 'no', 'no', 'no',
     'Complete raw-f64 bodies use casts or finite/truncation/modulo/leading-zero arithmetic; no js_math_to_number call. Ordinary numeric intrinsic/libm ABI only.',
     'math.rs:159-161,219-227')
mark('js_math_pow js_math_fmod js_math_log js_math_log2 js_math_log10 js_math_sin js_math_cos js_math_tan js_math_asin js_math_acos js_math_atan js_math_atan2 js_math_cbrt js_math_expm1 js_math_log1p js_math_sinh js_math_cosh js_math_tanh js_math_asinh js_math_acosh js_math_atanh js_math_hypot',
     'unclear', 'no', 'no', 'no',
     'Complete Perry bodies are scalar f64 operations, with no Perry allocation/GC/callback route. Native compiler/libm backend internals are outside this source audit, so total native allocation is not certified never.',
     'math.rs:68-161,232-283')
mark('js_math_to_number js_math_trunc js_math_round js_math_sign js_math_imul js_math_f16round js_math_min2 js_math_max2 js_math_min_array js_math_max_array js_is_nan js_is_finite js_number_coerce',
     'may allocate', 'may', 'may', 'may',
     'Whole exported route includes js_number_coerce / js_math_to_number, with object valueOf/toString and Symbol/BigInt error paths. Array variants additionally call generic length/element access. Numeric-only callers do not certify this whole export.',
     'math.rs:9-64,180-181,294-386; builtins/numbers.rs:436-640,771-810')
mark('js_nanbox_string js_get_string_pointer_unified js_string_materialize_to_heap js_string_new_sso js_string_from_bytes js_string_from_bytes_with_capacity js_string_builder_new',
     'may allocate', 'may', 'may', 'no',
     'Null-string boxing, SSO materialization/cache miss, numeric-to-string or explicit string construction reaches Perry string allocation. Existing-header/short-value hot arms do not cover the complete helper.',
     'value/nanbox.rs:123-133,274-325; string/alloc.rs:8-10,53-73,90-108,137-155,180-183; string/mod.rs:636-656')
mark('js_string_slice js_string_substring js_string_substr js_string_concat js_string_append js_string_append_known_heap',
     'may allocate', 'may', 'may', 'unclear',
     'String-producing route can call string_copy_range, string_storage_alloc or js_string_from_bytes. Empty/same/reused-buffer branches do not make the export leaf. Conservatively keep may-GC; not an audit of every coercion tail.',
     'string/slice_ops.rs:9-129; string/concat.rs:623; string/append.rs:30,194; string/alloc.rs:137-155')
mark('js_string_compare_value', 'may allocate', 'may', 'may', 'no',
     'number_bytes explicitly invokes js_number_to_string and copies bytes to owned Vec before borrowed comparison. Non-number arms are noncoercing views, not user callbacks.',
     'string/compare.rs:139-213')
mark('js_string_index_to_i32 js_string_end_index_to_i32 js_array_splice_delete_count',
     'may allocate', 'may', 'may', 'may',
     'Nonnumeric input takes js_number_coerce; object coercion can invoke JS and exceptions allocate. A scalar result does not imply a scalar-only call.',
     'string/char_ops.rs:21-57; array/splice_slice.rs:165-193; builtins/numbers.rs:436-640')
mark('js_array_length js_array_get_length', 'may allocate', 'may', 'may', 'may',
     'Proxy arm allocates length key, calls js_proxy_get then js_number_coerce; ordinary object arm calls by-name getter/coercion. Typed pointer spelling does not exclude those expressly supported arms. Existing AllocNoReentry rationale is stale for the complete export.',
     'array/indexing.rs:194-345,349-351; array/header.rs:984-999; proxy/get.rs:7-77')
mark('js_array_indexOf_jsvalue', 'may allocate', 'may', 'may', 'may',
     'from_index_to_integer invokes ToNumber; exotic element loop uses array_spec_has_index/get; BigInt typed-array read can construct BigInt. Strict equality itself does not eliminate these effects. Existing AllocNoReentry rationale does not cover current body.',
     'array/search.rs:25-32,83-177')
mark('js_array_slice_values js_array_slice', 'may allocate', 'may', 'may', 'may',
     'slice_values coerces raw start/end using js_number_coerce then constructs result. slice additionally has typed-array and exotic element routes. Keep complete export may-GC independent of existing AllocNoReentry entry.',
     'array/splice_slice.rs:165-288')
mark('js_array_push_f64 js_array_push_f64_spec',
     'may allocate', 'may', 'may', 'may',
     'Complete routes include Proxy get/set, array-like object method/set paths, descriptor-aware fallback and grow allocation. In-capacity ordinary-array fast arm is not whole-export evidence. Existing AllocNoReentry needs callsite contract proof.',
     'array/push_pop.rs:654-708,764-928')
mark('js_array_push_u31_with_length', 'may allocate', 'may', 'may', 'unclear',
     'Resolved plain-array push can grow. Unlike js_array_push_f64, this entry explicitly declines cleaned-null/exotic receivers without calling Proxy/spec fallback. No reentry counterexample claimed; subclass-fast/resolved tails not completely audited here, so preserve AllocNoReentry separately without expanding its proof.',
     'array/push_pop.rs:764-835')
mark('js_array_get_f64 js_array_get_f64_unchecked js_array_get_element js_array_get_element_f64 js_array_numeric_get_f64_unboxed',
     'may allocate', 'may', 'may', 'may',
     'Descriptor, hole/out-of-bounds prototype or polymorphic fallback reaches generic property access. Even unchecked/numeric exports retain fallback branches. No global leaf classification from their dense hot paths.',
     'array/indexing.rs:355-650; array/indexing_support.rs:15-24; proxy/get.rs:7-77')
mark('js_array_is_array', 'may allocate', 'may', 'may', 'unclear',
     'Explicit Proxy unwrap rejects revoked proxies through an allocating TypeError. Its ordinary header probe is insufficient as whole-export proof; no callable trap is required for this counterexample.',
     'array/is_array.rs:6-80; proxy.rs:567-582; collection_iter.rs:146-150')
mark('js_native_call_value js_native_call_method js_native_call_method_by_id js_native_call_method_str_key js_native_call_method_value js_typed_feedback_native_call_method js_typed_feedback_native_call_method_by_id',
     'may allocate', 'may', 'may', 'may',
     'Dynamic dispatch can invoke arbitrary generated JS, Proxy apply/get, accessor or native constructor routes; plain successful RegExp.test arm does not cover whole dispatcher. by-id/feedback wrappers ultimately forward to same method dispatcher.',
     'closure/dispatch/value_call.rs:31-106; object/native_call_method.rs:500-536,660,1206; typed_feedback/guards.rs:853-917')
mark('js_object_get_field_by_name js_object_get_field_by_name_f64 js_object_get_field_ic js_object_get_field_ic_miss js_value_length_f64 js_value_length_property_f64 js_value_length_property_ic_f64 js_proxy_get',
     'may allocate', 'may', 'may', 'may',
     'Complete getter/IC route can delegate to Proxy traps, accessor callbacks, native property synthesis or allocating property materialization. IC hit/read-only arms do not certify misses; retain may-GC.',
     'object/field_get_set/get_field_by_name.rs:26-112; object/field_get_set/ic_miss.rs:9-51,535,1144; value/dynamic_object.rs:19,254,275; proxy/get.rs:7-77')
mark('js_box_get_bits js_box_get_bits_named js_box_get_bits_trusted js_box_get_bits_trusted_named js_throw_reference_error_tdz',
     'may allocate', 'may', 'may', 'unwinds',
     'TDZ path creates message string and ReferenceError then js_throw. Read wrapper/trusted registry premise does not remove TDZ. NONCOLLECTING inventory is not proof; current direct effect correctly stays Unknown.',
     'box.rs:972-1102; error.rs:1088-1098')
mark('js_ctor_return_override', 'may allocate', 'may', 'may', 'unwinds',
     'Derived constructor returning non-object/non-undefined invokes throw_type_error, which constructs string+TypeError then throws. Existing AllocNoReentry is conditional, not never-allocation proof; its calls-nothing comment is stale.',
     'object/class_registry/construct/class_return.rs:114-131; collection_iter.rs:146-150')
mark('js_box_alloc_bits js_i32_box_alloc js_bool_box_alloc',
     'may allocate', 'no', 'no', 'no',
     'Uses std::alloc::alloc for raw fixed-size non-Perry cells and native TLS registry insertion; optional JSValue root barrier only marks/enqueues. No MALLOC_STATE object allocation or generated JS invocation.',
     'box.rs:669-783; gc_call_effects.rs:213-250 (existing audit authority, corroborated allocation body)')
mark('js_gc_temp_root_push js_gc_temp_root_set',
     'may allocate', 'no', 'no', 'no',
     'TLS Vec push/maybe native initialization and root barrier mark queue may grow system storage. No managed object allocation or synchronous collector invocation; reuses existing rooted-stack/barrier contract.',
     'gc/roots/temp_roots.rs:107-150; gc/barrier/mod.rs:1068-1120,1858-1865; gc/trace.rs:679-683; gc_call_effects.rs:74-127')
mark('js_value_typeof_tag', 'unclear', 'unclear', 'unclear', 'unclear',
     'No returned heap string, but classify_value_typeof includes closure/class/typed-array registries and dynamically installed stream_handle_kind_probe function pointer. Complete target/initialization set not audited; do not certify by typeof/tag name.',
     'builtins/arithmetic.rs:classify_value_typeof,826-828')
mark('js_math_random', 'unclear', 'unclear', 'unclear', 'unclear',
     'rand::rng()->random uses a dependency-owned thread RNG; cold initialization/reseed allocator and integration not audited. Not certified from scalar return.', 'math.rs:287-290')
mark('js_object_get_field js_object_get_field_f64 js_object_get_own_field_or_undef js_object_get_class_id js_jsvalue_equals js_jsvalue_same_value_zero js_switch_strict_equals',
     'unclear', 'unclear', 'unclear', 'unclear',
     'Read-only hot body observed, but all descriptor/overflow/registry/TLS/BigInt/forwarding tails not independently closed in this bounded pass. Preserve current effect field separately; do not certify merely because existing authority or helper name says read.',
     'object/field_get_set/accessors.rs:18-83; object/object_ops/accessors.rs:120; object/field_get_set/field_ops.rs:206,257; value/equality.rs:21-185; value/nanbox.rs:337')

names = sorted(set(decls) | set(calls) | set(review))
rows = []
for name in names:
    audit = review.get(name, dict(allocation_class='unclear', perry_heap_allocation='unclear',
        may_collect='unclear', may_reenter_js='unclear',
        reason='Not transitively audited in this finite first pass; declaration or literal call spelling alone is not effect evidence.', proof=''))
    rows.append(dict(helper=name, audit_status='reviewed' if name in review else 'unreviewed',
        current_effect=effects.get(name, 'Unknown'), **audit,
        runtime_locations=';'.join(defs.get(name, [])), declaration_locations=';'.join(decls.get(name, [])),
        literal_direct_call_locations=';'.join(calls.get(name, [])),
        declaration_occurrences=len(decls.get(name, [])), literal_direct_call_occurrences=len(calls.get(name, [])),
        dynamic_calls='', dynamic_window='', dynamic_binary_sha256=''))
with (HERE/'helper-audit.csv').open('w', newline='') as file:
    writer=csv.DictWriter(file, fieldnames=list(rows[0]))
    writer.writeheader(); writer.writerows(rows)

summary = dict(inventory_helpers=len(rows), reviewed_helpers=len(review),
    declaration_helpers=len(decls), literal_direct_call_helpers=len(calls),
    reviewed_allocation_counts=dict(collections.Counter(r['allocation_class'] for r in rows if r['audit_status']=='reviewed')),
    reviewed_gc_counts=dict(collections.Counter(r['may_collect'] for r in rows if r['audit_status']=='reviewed')),
    existing_effect_counts=dict(collections.Counter(r['current_effect'] for r in rows)),
    unannotated_no_collect=[r['helper'] for r in rows if r['may_collect']=='no' and r['current_effect']=='Unknown'],
    classified_may_reenter=[r['helper'] for r in rows if r['may_reenter_js']=='may' and r['current_effect']!='Unknown'],
    source_sha256=SOURCES,
    limits=['Lexical inventory: literal declaration/call names, no computed/indirect-target expansion; test-named files excluded but inline cfg(test) sections may contribute occurrences.',
            'No dynamic frequency inference, no effect annotation change, no builds or runtime tests. Unknown is conservative, not proof a helper collects.',
            'No source cache/ABI correctness claim; read-only audit assumes valid existing ABI inputs and ordinary release runtime. Debug-panic/host instrumentation internals are not certified.'])
(HERE/'helper-audit-source.json').write_text(json.dumps(summary, indent=2, sort_keys=True)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k!='source_sha256'},indent=2))
