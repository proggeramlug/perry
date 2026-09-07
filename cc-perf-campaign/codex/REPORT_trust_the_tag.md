# Trust-the-tag producer audit

## Outcome and SHA

- Branch: `fork/perf/trust-the-tag`
- Audited base: `1e1f28c66` (`perf/native-call-receiver-class`)
- Implementation SHA: none. This branch stops after the producer map, as the
  task requires when the invariant needs a representation change too large for
  one PR.
- Code change: none. This report is the only new tracked file.

The proposed production invariant is:

> Every `POINTER_TAG` JS value has a non-null payload that is the user address
> of a live Perry allocation with a readable `GcHeader` immediately before it.

That invariant is false on the audited tree. It cannot be established by a
local receiver change: several intentional, user-visible value families share
`POINTER_TAG` with managed objects. Consequently, replacing
`try_read_tracked_gc_header` with an unconditional load would turn valid Perry
programs into invalid reads. Keeping a magnitude test, registry test, page test,
or ownership test before that load would merely substitute a cheaper per-call
check and is not a cut under `BRIEF_COMMON.md`.

## How the map was bounded

The audit followed the representation at its funnels, rather than relying on
the names of current consumers:

- `JSValue::pointer` unconditionally ORs `POINTER_TAG`
  (`crates/perry-runtime/src/value/jsvalue.rs:53-62`).
- `js_nanbox_pointer` does the same for every nonzero raw `i64`, while preserving
  already-tagged values (`crates/perry-runtime/src/value/nanbox.rs:97-115`).
- codegen's `nanbox_pointer_inline` is the same unconditional OR
  (`crates/perry-codegen/src/expr/nanbox_inline.rs:8-11`). There are 347 call
  sites in 63 codegen files on this tree.
- native-module `NR_PTR` results become `NativeRep::NativeHandle`
  (`crates/perry-codegen/src/lower_call/native_module_dispatch.rs:191-230`) and
  are unconditionally pointer-boxed
  (`crates/perry-codegen/src/native_value/materialize.rs:142-168,195-207`).
  There are 372 `ret: NR_PTR` rows in 22 native-table files.

Those funnels deliberately erase whether the low 48 bits are a managed address,
an allocator-untracked address, or an integer id. The following map is exhaustive
by storage class for values which can reach the dynamic object/value surfaces;
individual `NR_PTR` call sites are instances of the mapped native-handle class,
not new representations.

## Headerless `POINTER_TAG` producer map

### 1. Integer registry handles and sentinels

These payloads are not addresses at all.

| Producer/owner | Construction proof | Receiver/property reachability | Disposition |
|---|---|---|---|
| Common stdlib handles (net, HTTP, crypto, databases, UI, and others) | `register_handle` returns ids from `[1, 0x40000)` (`crates/perry-stdlib/src/common/handle.rs:15-46`); `NR_PTR` then pointer-boxes them at the generic funnel above. | Native-call dispatch explicitly treats a pointer payload in this band as a handle (`crates/perry-runtime/src/object/native_call_method/handle_methods.rs:72-86`). IC miss routes the same values to handle property dispatch (`crates/perry-runtime/src/object/field_get_set/ic_miss.rs:712-737`). Therefore both method receiver and field/IC receiver are supported, common cases. | Needs a managed wrapper, or a distinct unmanaged tag plus migration of every handle consumer. |
| Fetch `Request`/`Response`/`Headers`/`Blob` | One shared id allocator covers `[0x40000, 0xE0000)` (`crates/perry-stdlib/src/fetch/mod.rs:74-97,223-230`); `handle_to_f64` calls `js_nanbox_pointer` (`:381-386`). | The field/IC and native-call handle routes above are the mechanism for type-erased/computed access; the fetch source comments name that requirement (`:86-94`). | Same as common handles. A wrapper must preserve registry identity and subclass backing. |
| zlib streams | The allocator returns ids in `[0xE0000, 0xF0000)` (`crates/perry-stdlib/src/zlib.rs:666-678,722-730`); native `NR_PTR` rows and local dispatch helpers expose pointer-tagged values. | `.write`, `.end`, `.on`, `.pipe`, and `.flush` intentionally enter the generic small-handle method route. | Same as common handles. |
| revocable `Proxy` | `js_proxy_new` stores a `ProxyEntry` in a side vector and returns `POINTER_TAG | encoded_id` in `[0xF0000, 0x100000)` (`crates/perry-runtime/src/proxy.rs:130-159,450-483`). | Generic get is explicitly handled in IC miss (`crates/perry-runtime/src/object/field_get_set/ic_miss.rs:724-735`); calls and all other Proxy operations likewise use the encoded id. | A proxy wrapper is a semantic/GC redesign: the registry currently owns and traces target/handler slots. |
| Timers | `NEXT_TIMER_ID` begins at 1 and is unbounded (`crates/perry-runtime/src/timer.rs:398-405,529-534`); all timer constructors use `nanbox_pointer_inline` (`crates/perry-codegen/src/lower_call/extern_timers.rs:95-140,179-234`). The runtime also constructs `POINTER_TAG | id` for callback `this` (`crates/perry-runtime/src/timer.rs:474-520`). | Timeout properties and methods are explicitly served from the field/IC paths (`crates/perry-runtime/src/object/field_get_set/ic_miss.rs:738-754`) and native dispatch. These are ordinary JS-visible receivers. The unbounded counter can also cross the nominal 1 MiB handle ceiling, so magnitude is not a permanent representation proof. | Needs a managed Timeout object or its own tag. Merely retaining `< 0x100000` is both a per-call check and incomplete. |
| `TextEncoder`/`TextDecoder` | Encoder is sentinel id 1; decoders are registry ids, documented as pointer-tagged (`crates/perry-runtime/src/text.rs:99-131`), and codegen boxes them directly (`crates/perry-codegen/src/expr/string_regex_proc.rs:506-524`). | Dynamic calls are explicitly recovered in `native_call_method` (`crates/perry-runtime/src/object/native_call_method.rs:1691-1728`), with field and IC mirrors. | Needs managed wrappers or an unmanaged tag. |
| TUI state/hook/widget handles | State allocation returns a vector index, including 0 (`crates/perry-runtime/src/tui/state.rs:97-104`); hook handles document `NR_PTR` boxing (`crates/perry-runtime/src/tui/hooks.rs:526-550`). Other TUI/native rows use the same `NR_PTR` representation. | The values expose `.get`, `.set`, `.exit`, and other receiver methods, so type erasure reaches the dynamic receiver tower. | Needs wrappers/tag and a consumer migration. The zero-valued state handle also demonstrates that inline pointer boxing can manufacture the null-pointer-tag bit pattern. |
| Null/failed `i64` results | `nanbox_pointer_inline` and the `NR_PTR` materializer have no zero branch (`crates/perry-codegen/src/expr/nanbox_inline.rs:8-11`; `crates/perry-codegen/src/native_value/materialize.rs:142-151`). `js_nanbox_pointer` does convert zero to `TAG_NULL`, but the two hot codegen funnels do not (`crates/perry-runtime/src/value/nanbox.rs:102-114`). | A failed or zero-returning producer can therefore flow as a pointer-shaped JS value into any dynamic receiver, field, IC, or array path. Existing null-pointer sanitizers in field stores are evidence of this representation (`crates/perry-runtime/src/object/field_get_set/field_ops.rs:10-25,137`). | Every pointer-boxing funnel needs a typed null policy; a receiver-side check is not a cut. |

The central band map records the same intentional aliasing and its owners
(`crates/perry-runtime/src/value/addr_class.rs:1-39`). Small handles are frequent
on native integrations; this audit did not add another counter because there is
no candidate implementation to price, and a counter on the receiver would not
resolve which of hundreds of producers minted the value.

### 2. High-address Rust `Box` handles

`AsyncHook` and `AsyncResource` are the decisive counterexample to a
small-handle-only fix. Their public handles are actual `Box::into_raw` system
heap addresses, registered in side sets and pointer-tagged like objects
(`crates/perry-runtime/src/async_hooks.rs:169-185`). The two producers are
`js_async_hooks_create_hook` (`:549-563`) and
`new_async_resource_with_public_value` (`:1209-1240`).

They are supported native-call receivers after static type is lost: the generic
tower must consult their registries before its GC-header read
(`crates/perry-runtime/src/object/native_call_method.rs:2228-2248`). An
`AsyncResource` is also a field/IC receiver
(`crates/perry-runtime/src/object/field_get_set/ic_miss.rs:585-608`). Thus an
unconditional header read fails even after every small integer handle is
separated.

Disposition: move these payloads into dedicated GC types or reuse/extend the
managed `GC_TYPE_NATIVE_HANDLE` wrapper. The existing wrapper already allocates
a real header and stores the foreign pointer as leaf metadata
(`crates/perry-runtime/src/native_handle.rs:155-200`), but it is currently the
manifest native-library ABI, not a drop-in representation for the legacy
AsyncHook registries.

### 3. Process-global symbols

Fresh `Symbol()` values are managed (`alloc_symbol` calls `gc_malloc` with
`GC_TYPE_STRING`, `crates/perry-runtime/src/symbol.rs:869-914`). Three other
producers intentionally leak `Box<SymbolHeader>` with no GC header so identity
outlives thread arenas:

- well-known symbols: `crates/perry-runtime/src/symbol.rs:310-352`;
- the `%Intl%.[[FallbackSymbol]]`: `crates/perry-runtime/src/symbol.rs:625-656`;
- `Symbol.for`: `crates/perry-runtime/src/symbol/constructors.rs:86-121`.

Each returns `POINTER_TAG | address`. The field tail explicitly handles both
storage classes (`crates/perry-runtime/src/object/field_get_set/get_field_by_name_tail.rs:508-526`),
and the native-call receiver tests intentionally exercise a Box-leaked
`Symbol.for` value. Symbols are primitives semantically, but they still enter
the dynamic method/property classification paths for `toString`, `description`,
and well-known-key behavior.

Disposition: either a process-global pinned-header allocation understood by the
debug ownership re-derivation, or a per-agent managed wrapper around a stable
global symbol identity. A per-thread ordinary `gc_malloc` is not sufficient:
the current comments and side tables deliberately support an originating worker
arena being torn down (`crates/perry-runtime/src/symbol/constructors.rs:95-102`).

### 4. Embedder-owned external `BufferHeader`

`js_buffer_register_external(addr)` registers an arbitrary caller-owned
`BufferHeader` and returns no replacement value
(`crates/perry-runtime/src/buffer/header.rs:596-606`). A true external caller can
therefore pointer-box the same headerless address. It is a valid native-call,
field/IC, and indexed receiver because Buffer methods, properties, and byte
indexing are all registry-routed after a tracked-header miss.

The only in-repository non-test caller currently passes a buffer already
allocated by `buffer_alloc` (`crates/perry-stdlib/src/webcrypto/util.rs:897-911`),
so it is managed in-tree. The public ABI is nevertheless explicitly capable of
admitting a real headerless embedder value, and the receiver tests construct one.

Disposition: replace/deprecate the void registration ABI with a wrapper-returning
ABI and migrate external embedders. The wrapper mechanism already exists:
`buffer_alloc_foreign` creates a managed old-arena `GC_TYPE_BUFFER` whose data
remain caller-owned (`crates/perry-runtime/src/buffer/header.rs:998-1024`).

### 5. SharedArrayBuffer backing

`alloc_shared_sab` directly `alloc_zeroed`s `BufferHeader + bytes` and returns
the `BufferHeader` address, with no prefix
(`crates/perry-runtime/src/shared_sab.rs:48-88`).
`js_shared_array_buffer_new` publishes that pointer as the JS representation
(`crates/perry-runtime/src/buffer/from.rs:803-826`). The thread serializer must
check the process-global SAB registry before its header read and transmits the
raw address (`crates/perry-runtime/src/thread.rs:396-415`); deserialization
re-registers and pointer-boxes it (`:906-914`). It is therefore reachable as a
native-call receiver, field/IC receiver, and indexed/typed-view backing on every
agent using SAB.

Disposition: make the process-global allocation a backing store only. Publish a
per-agent managed `GC_TYPE_BUFFER` wrapper (the foreign-buffer machinery is the
starting point), serialize backing identity rather than wrapper address, and
rebuild a local wrapper on receive. Atomics must continue keying on the shared
data address. This requires thread transfer, teardown/finalization, view aliasing,
minor-copy, and compaction tests.

### 6. Static unresolved/null object

`NULL_OBJECT_BYTES` is a static `ObjectHeader`-shaped record with no `GcHeader`.
`js_unresolved_namespace_stub` directly returns it under `POINTER_TAG`
(`crates/perry-runtime/src/object/null_stub.rs:1-40,67-71`), and the native-call
tower also returns it from multiple supported fallbacks, including the recursion
guard (`crates/perry-runtime/src/object/native_call_method.rs:1601-1616`). User
code can retain that return and use it as a later receiver.

Disposition: replace it with a rooted/pinned managed singleton (or stop returning
an object-shaped sentinel). This case is locally fixable but does not close the
other classes.

### 7. Bare and stale managed addresses are a separate producer contract

A bare managed address is not itself a `POINTER_TAG` value, but it prevents the
requested deletion of address ownership checks from `dispatch_primitive` and
the native-call entry. The compatibility module states that Perry still accepts
this shape and must ask allocator/side-table ownership to distinguish it from a
subnormal number (`crates/perry-runtime/src/object/native_call_method/bare_receiver.rs:1-10,59-103,105-179`).

The named historical producer defects are already closed at their producers:

- #9523 now roots a Set receiver across the allocating value and derives its raw
  `i64` only after reloading (`crates/perry-codegen/src/expr/bigint_set.rs:916-932,1172-1188`).
- #9499/#9542 root reloads pass through a zero-instruction identity barrier so
  LLVM cannot reuse a stale statepoint spill (`crates/perry-codegen/src/function/precise_roots.rs:35-70`).

Those fixes are proof of the required policy: close raw/stale values where they
are produced. Before direct-header classification can replace the current
receiver logic, the remaining compatibility acceptance must either be tied to
an enumerated producer and closed there or removed, with its moving witnesses
kept green. Defending against an arbitrary bare word in every consumer is the
same per-call work this task is meant to remove.

## Audited suspected cases which are already header-bearing

These do not require representation work; several comments in hot consumers are
stale and should not be used as proof that fallback remains necessary:

- ordinary Buffer/ArrayBuffer/Uint8Array storage uses old-arena
  `GC_TYPE_BUFFER`; foreign data already have a managed wrapper
  (`crates/perry-runtime/src/buffer/header.rs:970-1024`);
- ordinary typed arrays use old-arena `GC_TYPE_TYPED_ARRAY`
  (`crates/perry-runtime/src/typedarray/mod.rs:1019-1046`);
- NativeArena owner, typed view, and POD view payloads are all `gc_malloc`
  allocations with dedicated types (`crates/perry-runtime/src/native_arena.rs:257-286,289-342,345-398`);
- Map and Set headers are managed `GC_TYPE_MAP`/`GC_TYPE_SET`; only their element
  storage is external and that storage is not a JS value
  (`crates/perry-runtime/src/map.rs:1542-1564`;
  `crates/perry-runtime/src/set.rs:1220-1241`);
- Temporal's outer cell is managed; its nested `Box<TemporalValue>` is leaf
  payload, never independently boxed as a JS value
  (`crates/perry-runtime/src/temporal/mod.rs:175-204`);
- manifest/native-library handles already use managed `GC_TYPE_NATIVE_HANDLE`
  wrappers (`crates/perry-runtime/src/native_handle.rs:155-200`).

The wasm-host's raw instance pointer is pointer-boxed only as an internal call
adapter (`crates/perry-runtime/src/webassembly.rs:1039-1056`). Public modules are
managed Object wrappers registered to the host handle
(`crates/perry-runtime/src/webassembly.rs:395-434`), so the host allocation is
not another general JS receiver producer.

## Why none of the three choices fits one PR

### A. Managed wrappers everywhere

This is the most coherent end state, and it reuses `GC_TYPE_NATIVE_HANDLE` and
foreign-buffer machinery. It is not one receiver PR:

1. Split `NR_PTR` into at least managed-GC-pointer and opaque-native-handle
   result kinds, classifying 372 rows across 22 tables. Today the single kind
   contains both real arrays/objects/buffers and registry ids/foreign boxes.
2. Audit/migrate the 347 direct `nanbox_pointer_inline` call sites, including
   timers and text/TUI sentinels, and give zero a canonical non-pointer result.
3. Teach every `NA_PTR`/handle consumer to unwrap managed wrappers while keeping
   registry identity, lifecycle, subclass backing, Proxy tracing, and property
   expandos correct.
4. Independently migrate AsyncHook/AsyncResource, process-global symbols, SAB,
   the external-buffer ABI, and `NULL_OBJECT_BYTES` as described above.
5. Only after all producers are closed, replace hot classifiers with one header
   load and retain `try_read_tracked_gc_header` solely under `debug_assertions`
   as the #9755-style re-derivation.

That is a representation campaign spanning runtime, codegen, stdlib, extension
ABI, and moving-GC behavior, with more regression surface than a single PR.

### B. Distinct unmanaged NaN-box tag

There is no unused positive-qNaN top-16 tag in the current layout:

- `0x7FF9` short string, `0x7FFA` BigInt, `0x7FFB` V8/JS handle,
  `0x7FFC` singleton namespace, `0x7FFD` pointer, `0x7FFE` int32, and `0x7FFF`
  string (`crates/perry-runtime/src/value/tags.rs:10-104`).
- `0x7FFB` is not spare: field and method paths dispatch that tag through the V8
  callback surface (`crates/perry-runtime/src/object/field_get_set/get_field_by_name.rs:1161-1175`).
- `0x7FFC` is decoded as the singleton namespace by many exact and top-16 tests;
  placing pointers in its payload would require auditing all of them.
- negative-qNaN payloads are currently numbers by construction
  (`crates/perry-runtime/src/value/jsvalue.rs:65-73`), so consuming that space is
  a cross-runtime numeric ABI change, not a local extra tag.

An unmanaged tag remains viable as a planned representation migration, but it
must update runtime, codegen, stdlib/extensions, GC root scanning, `typeof`,
truthiness/equality/coercion, serialization, and every native handle consumer.

### C. Close individual producers

This is correct for bare/stale bugs and can also remove the static null object,
but it cannot eliminate legitimate opaque ids, global symbols, external buffers,
SAB, and high-address AsyncHook boxes. It does not establish the invariant by
itself.

## Tests and sabotage plan for the representation campaign

No tests were added because this branch deliberately stops before an
implementation. The implementation PR(s) need these named, fail-capable gates:

- `pointer_tagged_values_have_directly_readable_headers_for_every_producer`:
  enumerate common/fetch/zlib/proxy/timer/text/TUI handles, AsyncHook,
  AsyncResource, fresh/global/well-known/Intl symbols, ordinary/foreign/external
  Buffer, SAB and the unresolved stub. For managed-tag values, compare the direct
  type load with the debug ownership re-derivation; for a new unmanaged tag,
  assert the header load is never entered. Sabotage: restore old boxing for the
  TextEncoder sentinel; debug must panic before a header read.
- `direct_header_debug_rederivation_panics_on_pointer_tagged_foreign_value`:
  inject one old-form high-address `Box` receiver. Sabotage: remove the debug
  `try_read_tracked_gc_header` assertion; the test must stop panicking.
- `wrapped_external_buffer_and_sab_survive_minor_copy_and_compaction`:
  retain wrapper and view across a copying minor and compaction, then classify
  and read the same bytes. Sabotage: omit the wrapper/backing root or deserialize
  the backing as the wrapper; the test must fail identity/data checks.
- Keep the eight #9937 receiver tests in
  `object/native_call_method/receiver_class_tests.rs` and
  `intl/segments_view.rs`, plus the #9523 and #9499/#9542 moving witnesses.
  Sabotage: reintroduce one pre-allocation raw receiver derivation or remove
  `ROOT_RELOAD_LAUNDER`; the existing fixtures must fail.

## Gates

- No cargo command was invoked. The requested cargo gates were not run because
  the task's explicit stop condition fired before implementation; there is no
  code artifact to compile or test.
- `cargo test -p perry-runtime --release --lib -j4 -- --test-threads=1`: not run.
- `cargo build --release -p perry-runtime --features wasm-host -j4`: not run.
- `cargo build --release -p perry -j4`: not run.
- `nm`: not run; no binary or exported symbol changed.
- No cc/performance measurement was run.

## Performance prediction and perrymaster request

This report-only branch predicts **no CPU or RSS change** and should not consume
a perrymaster run.

For the eventual completed representation change, use the task's hard
falsifiers on the same NR6 best bundle and cache:

- `addr_class::try_read_tracked_gc_header` self: 2.46% to approximately zero on
  receiver paths; its remaining production caller should be collector-side
  `layout_key_may_be_nursery` only;
- `js_native_call_method_at_site` self: at or below the base's 2.31%;
- `dispatch_primitive`: at or below 1.33%;
- Buffer/typed-array registry probes: remain at the #9937 residual 1-2 million,
  not 28 million;
- paired 3300-character turn CPU: predicted -2% to -3%, moving the receiver
  family from about 9.9% of samples toward 6%;
- RSS: unchanged is expected, with the campaign's allowed +1% to +10% envelope.

If an implementation is runtime-only, relink the best bundle against its
existing bundle cache and run the same NR6 rows; do not recompile the bundle. A
wrapper implementation that changes codegen boxing/`NR_PTR` is not runtime-only
and requires a rebuilt bundle before those rows. Report raw samples and the
denominator, the paired turn values/ratios/median, and RSS.
