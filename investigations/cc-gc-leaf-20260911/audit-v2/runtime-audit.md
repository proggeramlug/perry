# Runtime helper audit, v2 source closure

This supplement preserves the v1 audit bound to the running cc census. It changes
eight audit rows in a separate copy, without changing any compiler effect or
runtime source. The source receipt binds every changed row and 48 source files.
No build, runtime check or timing was performed for this audit.

| Helper | Current effect | Allocation | Perry collection / JS reentry | Conclusion |
| --- | --- | --- | --- | --- |
| `js_object_get_field` | Unknown | May allocate native storage | No / no | Raw shape, inline-slot, spill or legacy-map read; no property getter. |
| `js_object_get_field_f64` | Unknown | May allocate native storage | No / no | Wrapper of the preceding raw read. |
| `js_object_get_own_field_or_undef` | CannotCollect | May allocate native storage | No / no | Own dense key scan and raw indexed read; existing effect corroborated. |
| `js_object_get_class_id` | CannotCollect | May allocate native storage | No / no | Registry membership and scalar header/class reads; existing effect corroborated. |
| `js_jsvalue_equals` | Unknown | May allocate native storage | No / no | Borrowed string comparison, fixed BigInt limbs and bounded forwarding reads. |
| `js_jsvalue_same_value_zero` | Unknown | May allocate native storage | No / no | NaN shortcut plus the preceding strict comparison. |
| `js_switch_strict_equals` | Unknown | May allocate managed strings | May / no | The SSO string arm materializes heap strings. |
| `js_value_typeof_tag` | Unknown | Unclear | Unclear / unclear | Open native callback registrations prevent a complete export-level proof. |

The first six rows do **not** mean zero allocation. Cold `state()` initialization
creates native Box/Vec/map storage, and HotTls initialization can reserve the
first arena backing block. That initializer explicitly uses
`ArenaBlock::new -> alloc_block_no_gc`, not the block reservation route that can
invoke emergency collection. It creates backing storage without creating a
managed object cell or entering Perry collection. Strict equality can also grow
the native malloc validation set in `ensure_set_built`. The CSV separates these
facts with `allocation_class`, `perry_heap_allocation`, `may_collect` and
`may_reenter_js`.

The count of reviewed exports with `current_effect=Unknown`, `may_collect=no`
and `may_reenter_js=no` grows from 44 to **48**. These remain source-audit
candidates. No annotation has been applied, no dynamic invocation count has
been established, and no speed improvement is claimed.

## Closed routes

For indexed object reads, `object/field_get_set/accessors.rs:18` leads through
`object/live_slots.rs:52`, the shape slab lookup at `object/shapes.rs:634`, and
either a raw inline load or `object/spill.rs:355`. Slab lifting copies scalar
metadata; both spill and legacy-map reads only retrieve current entries. The
own-field helper at `object/object_ops/accessors.rs:120` validates and directly
walks the dense key array, compares heap bytes or stack SSO bytes, then uses the
same indexed reader. It does not call generic Array access or invoke an accessor.

The class probe at `object/field_get_set/field_ops.rs:206` reads Set/Map registry
membership and a coherent header/class field. The registry paths at `set.rs:271`
and `map.rs:427` do not insert managed values or call JavaScript.

`value/equality.rs:52` handles strict equality using scalar comparisons,
`bigint/compare.rs:105`'s fixed limb array comparison, and
`string/mod.rs:804`'s borrowed heap/stack byte views. Its bounded forwarding walk
at `value/equality.rs:194` reaches tracked-header validation. The native allocation
tail is `gc/malloc.rs:508`'s optional set construction, not `gc_malloc`.

The cold-state proof is anchored at `state.rs:53,106`, `tls_hot.rs:282,634,840`,
`arena/block.rs:403,435,549` and `arena/page_meta/mod.rs:460`. Exact source hashes
and the full supporting locations are in `source-receipt.json` and the CSV.

## Routes that stay conservative

`value/nanbox.rs:337` is a separate switch equality export. Its both-string arm
calls `js_get_string_pointer_unified`; an SSO operand can go through
`js_string_materialize_to_heap -> intern_dispatch_bytes` and a managed string
allocation on a miss. A borrowed-byte proof for ordinary strict equality does
not cover this export. This is consistent with its existing `Unknown` effect.

The bundled stream `typeof` target is now audited: `perry-stdlib`'s
`common/dispatch/init.rs:798` installs `streams/subclass.rs:98`'s native mutex/map
membership probe. However, `builtins/arithmetic.rs:688` also routes JS handles to
`value/handle.rs:173`'s registered `JsHandleTypeofFn`. The source tree contains the
public setter, but no closed implementation/registration target. The stream
setter itself is also an open native callback API. A proof of the bundled stream
target does not prove all accepted native registrations cannot allocate, collect
or call JS. The whole export remains unclear.

V1's four `AllocNoReentry` source discrepancies remain recorded there. They are
source findings, not reproduced crashes. Generic property/accessor/Proxy/coercion,
throwing and allocating string routes remain conservative. Proofs of `no` assume
valid existing ABI inputs and the ordinary runtime; debug/host interposition is
not independently certified.

## Joining actual emitted helpers

Run `join_actual_callees.py --by-callee EXACT/by-callee.csv --output FRESH_DIR`
when the three-stage census is complete. It preserves every input row and metric,
joins exact symbol names, includes named dynamic-dispatch wrappers with verified
runtime definitions, and keeps unresolved external symbols explicit. The receipt
binds input and audit hashes. `actual-runtime.csv` is the source-identified runtime
subset; `unresolved-external.csv` preserves missing source identities. Neither
static sites nor statepoint/relocate counts are dynamic call frequency or CPU
attribution. Blank dynamic-count columns stay blank.
