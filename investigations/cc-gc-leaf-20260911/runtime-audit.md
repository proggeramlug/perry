# Runtime helper allocation / collection audit — first finite pass

Source-only investigation on the retained `testdispatch25` overlay in
`cc-gc-leaf-census-0911`, rooted at `f09f7db0`. No runtime or compiler effect
annotations changed. No build, runtime test, box job, or optimization ran.

The inventory contains **3,213 literal declaration/direct-call names** and **127
reviewed entries**. Every other entry remains **unclear**. This is a declaration
and lowering-source catalog, **not** proof that cc emits or calls every entry.
The forthcoming actual emitted-callee census must select the relevant subset;
even an emitted callsite count is not a dynamic invocation count.

`helper-audit.csv` is the joinable table. `helper-audit-source.json` records source
SHA256s, counts, limitations and the candidate names. `build_helper_audit.py`
reproduces the lexical inventory and contains the explicit human-reviewed rows;
it does not infer effects from function names or absence of an `alloc` token.

## Meaning of the columns

`allocation_class` is `never allocates`, `may allocate`, or `unclear`, including
Rust/libc allocation. `perry_heap_allocation`, `may_collect` and
`may_reenter_js` are separate. A Rust `Vec` or raw variable-box allocation is
not a Perry heap allocation or a Perry safepoint. `unwinds` records an exception
edge and is not a claim that the call returns without collection.

`current_effect` copies the exact-name classification in
[`gc_call_effects.rs`](../../crates/perry-codegen/src/gc_call_effects.rs).
`CannotCollect` concerns entering the Perry collector, not all allocation.
`AllocNoReentry` becomes a leaf only when the separate
`gc_safepoint_only_contract_enabled()` condition holds; it is not an unconditional
no-collection or no-allocation statement. `Unknown` remains conservative.
The classifier's LLVM-intrinsic prefix handling is separate from these exact-name
effect rows; this audit does not propose a prefix allowlist.

Proofs of `no` assume valid existing ABI inputs and the ordinary release runtime.
They do not certify debug-panic paths, allocator interposition or host tooling.
Native numeric backend internals have deliberately **unclear** total allocation
where this source audit only closes the Perry-collection/JS-reentry question.
Only 26 reviewed entries have the stronger `never allocates` classification.

## Currently unannotated candidates with a closed Perry call route

There are **44** reviewed exports whose current effect is `Unknown` but whose
observed source routes do not enter Perry collection or generated JS. These are
audit candidates to join with emitted and measured evidence, not changes to apply.

| Family | Exact entries / source proof | Boundary |
| --- | --- | --- |
| Raw string reads | `js_get_empty_string`, `js_string_length`, `js_string_char_code_at`, `js_string_code_point_at` | Static address/header/byte reads. Character indices are already `i32`; the coercion helpers are excluded. |
| Raw string comparison/search | `js_string_compare`, `js_string_equals`, `js_string_index_of`, `js_string_index_of_from` | Already-heap `StringHeader` operands; borrowed bytes, non-owning UTF16 iteration/offset walks and `str::find`. No `Vec`, cache materialization or callback. |
| Numeric index conversion | `js_string_position_to_index` | Raw numeric `f64` truncation/clamp; no `ToNumber`. |
| Tag/representation | `js_nanbox_bigint`, `js_nanbox_get_bigint`, `js_nanbox_get_string_pointer`, `js_nanbox_is_bigint`, `js_nanbox_is_pointer`, `js_nanbox_is_string`, `js_pod_scalar_write_compatible` | Complete bodies are masks, predicates, casts and scalar range checks. String boxing on a null input is expressly excluded. |
| Strict Number predicates | `js_number_is_nan`, `js_number_is_finite`, `js_number_is_integer`, `js_number_is_safe_integer` | Tag/read-only scalar predicates; global `isNaN`/`isFinite` are different, coercing helpers. |
| Scalar numeric backend | `js_math_fround`, `js_math_clz32`, plus 22 `math.rs` exports listed individually in CSV (pow/fmod/log/trig/hyperbolic/cbrt/hypot) | No Perry/runtime coercion route. The 22 backend entries keep native allocation `unclear`; their raw numeric operation cannot call a Perry getter or collector. |

Proof locations and all transitive primitives reviewed for these families are in
the CSV, particularly `value/jsvalue.rs`, `value/nanbox.rs`, `string/mod.rs`,
`string/alloc.rs`, `string/char_ops.rs`, `string/compare.rs`,
`string/slice_ops.rs`, `builtins/numbers.rs` and `math.rs`.

Do not infer that raw string helpers make their whole lowering leaf: the
preceding `js_get_string_pointer_unified` can materialize an SSO string or convert
a number. Likewise `js_string_compare_value` explicitly creates a decimal heap
string and owned bytes for numeric inputs. Helper boundaries matter.

## Existing effect descriptions requiring attention

Four complete exported bodies currently labeled `AllocNoReentry` contain explicit
user-code routes. This is a source finding, not a reproduced application failure,
and does not establish whether the current cc compilation activates the
conditional leaf rule or reaches those arms.

| Export | Concrete route in current runtime |
| --- | --- |
| `js_array_length` | `array/indexing.rs:240` allocates the `length` key, calls `js_proxy_get`, then `js_number_coerce`. Its ordinary-object arm at `:313` also calls a by-name getter and coercion. `array_ptr_as_proxy` explicitly admits the registered Proxy representation; a typed pointer signature does not exclude it. |
| `js_array_push_f64` | `array/push_pop.rs:669` handles Proxy length/get/set and `:703` invokes the generic object push route. These are part of this export, not a distinct user-call-only wrapper. |
| `js_array_slice_values` | `array/splice_slice.rs:165` coerces start/end via `js_number_coerce`. The called slice body additionally reads constructor/species and can get exotic indices (`:250` onward). |
| `js_array_indexOf_jsvalue` | `array/search.rs:25` coerces `fromIndex`; its loop at `:159` uses `array_spec_has_index/get` for exotic arrays. Strict comparison alone is not a whole-helper proof. |

`js_array_push_u31_with_length` is **not** included in that finding. Its actual
body explicitly returns null on an unowned/exotic receiver rather than calling
the Proxy/spec path (`array/push_pop.rs:817`). Its whole subclass/resolved call
graph remains incompletely audited here; the table preserves that distinction.

The `js_ctor_return_override` classifier comment says it inspects values and
calls nothing, but `class_return.rs:124` has a derived-primitive TypeError arm.
`collection_iter.rs:146` constructs a managed message and Error then throws.
This disproves the comment's no-allocation premise; it does not independently
disprove a conditional no-JS-reentry contract for an exception-only arm.

The classifier already documents and correctly avoids a second bad inference:
`js_box_get_bits` is in the older dominance checker's `NONCOLLECTING` inventory,
but TDZ calls `js_throw_reference_error_tdz`, creating a message and ReferenceError
before unwinding (`box.rs:972`, `error.rs:1088`). The trusted-named variants retain
that TDZ arm. Neither inventory membership nor a `get` spelling is proof.

## Conservative retained categories

Generic by-name getters, field IC misses, native method/value dispatch, Proxy
operations, coercing numeric/string-index conversions, throwing helpers and
string construction/concat/slice remain may-collect. Even
`js_array_get_f64_unchecked` has descriptor and out-of-bounds prototype fallbacks;
`js_array_is_array` can create an Error for a revoked Proxy. Dense/common arms do
not characterize all supported inputs.

The raw indexed `js_object_get_field`, existing own-field/class probes, and full
strict-equality helpers remain **unclear in this audit** because their complete
descriptor/overflow/registry/BigInt/forwarding tails were not independently
closed. Their existing annotations are recorded without being blindly inherited.
`js_value_typeof_tag` also remains unclear: its classifier can invoke a dynamically
installed `stream_handle_kind_probe`. That finite callback target set must be
audited before treating this as a tag-only helper. `js_math_random` leaves the
dependency-owned RNG initialization/reseed route unaudited.

Conversely, `js_box_alloc_bits`, `js_i32_box_alloc`, `js_bool_box_alloc` and the
temp-root push/set examples can allocate native cells, TLS maps or a mark queue
without creating a Perry object or invoking JS. They demonstrate why allocator
counts and root/statepoint bookkeeping counts must remain separate.

## Measurement join and limits

The dynamic columns are deliberately blank pending exact emitted/runtime
evidence. The preserved historical helper counts are in the sibling secret-tests
record `cc-perf-campaign/codex/runtime_helper_usage_20260911/existing-counts.md`.
Its current-nearest TESTDISPATCH26 counters have a cumulative main-thread window
including startup and part of the turn; they cannot be substituted for fresh
entry counts. The pre-projection Segmenter counts are obsolete for ranking this
retained binary.

Join the new actual-callee inventory on the exact `helper` token. Separately show
static calls, pre/post statepoint counts, dynamic entries if instrumented, and
ordinary CPU/RSS. Neither sample weight nor static calls are dynamic frequency;
none of the present data prices a GC-leaf optimization or promises a speedup.

The scanner recognizes literal `declare_function` and literal builder `call`
forms, not computed names or indirect targets. It excludes test-named files but
may retain inline `cfg(test)` lexical sections, duplicate platform declarations
and declarations from optional packages. Non-runtime or unresolved definitions
remain in the catalog as unclear. All conclusions above use manually read bodies,
not that lexical filter. No broad CI or behavioral claims accompany this report.
