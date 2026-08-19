# Perry cons strings: staged implementation design

Status: design for GitHub issue #8394. No cons-string producer should land
until the reader and FFI prerequisites below are complete.

## Decision

Implement this as a sequence of reviewable PRs, not one PR.

The representation itself is small. The safe migration is not. Perry exposes
`*const StringHeader` throughout the runtime and stdlib, and many consumers
derive the payload address directly with `header + size_of::<StringHeader>()`.
If even one of those consumers receives a cons node before it is migrated, it
will interpret child pointers as text and silently return a wrong answer.

The first implementation slice should therefore be reader centralization and
an enforcement ratchet, with no cons producers. The first producer comes only
after every path that can observe a general string value either accepts a flat
string explicitly or flattens through a rooted helper.

This is stricter than enabling cons nodes only in `js_string_concat`: a direct
concat result can flow into any string method, property key, collection, JSON
path, regex path, native call, or stdlib FFI before another runtime helper has
a chance to normalize it.

## Survey

The survey was made at `92f036a7b` on 2026-08-19.

| Surface | Finding |
| --- | ---: |
| Runtime files with explicit `StringHeader` payload pointer arithmetic, excluding tests | 174 files / 356 sites |
| Stdlib files with the same pattern, excluding tests | 54 files / 82 sites |
| Runtime/stdlib calls to `string_data`, `string_as_str`, or `str_bytes_from_jsvalue`, excluding tests | 53 files / 192 sites |
| `extern "C"` APIs with a `StringHeader` parameter on one line | 59 files / 170 APIs |
| Codegen files that explicitly read `StringHeader.byte_len` or inline payload bytes | 2 files / 9 references |

These counts deliberately overlap. They establish the lower bound and the
clusters to migrate; they are not an estimate of independent functions.

The direct-reader census is reproducible with:

```sh
rg -n 'add\(std::mem::size_of::<(?:crate::(?:string::)?|super::)?StringHeader>\(\)\)|add\(size_of::<(?:crate::(?:string::)?|super::)?StringHeader>\(\)\)' \
  crates/perry-runtime/src --glob '*.rs' -g '!*test*'

rg -n 'add\(std::mem::size_of::<(?:perry_runtime::)?StringHeader>\(\)\)|add\(size_of::<(?:perry_runtime::)?StringHeader>\(\)\)' \
  crates/perry-stdlib/src --glob '*.rs' -g '!*test*'
```

### Current representation and compiler assumptions

- `StringHeader` is a 20-byte prefix: `utf16_len`, `byte_len`, `capacity`,
  `refcount`, and `flags`.
- Codegen reads `utf16_len` at offset 0 for `.length`.
- Codegen's `charCodeAt` ASCII fast path also reads `byte_len` at offset 4 and
  payload bytes at offset 20.
- The string-literal equality fast path reads `byte_len`, the first byte, and
  the last byte inline before falling back to `js_string_equals`.
- Heap strings use `STRING_TAG`; short strings use `SHORT_STRING_TAG`.
  `is_any_string()` accepts both.
- `js_get_string_pointer_unified` and `js_jsvalue_to_string` return a raw heap
  pointer. Both already allocate when materializing SSO, so the GC checker
  correctly treats the unified helper as a collection point.
- `GC_TYPE_STRING` is a movable, pointer-free leaf. It is also used by a few
  compatibility residents with layouts other than `StringHeader`, including
  symbols and JSON-tape scratch storage. It cannot be changed globally into a
  traced payload type.

### Reader clusters

The migration is broader than `crates/perry-runtime/src/string/`:

- string methods, comparison, equality, slicing, indexing, locale, I/O,
  interning, append, and concat;
- object property keys, shapes, typed feedback, proxies, maps, sets, arrays,
  and formatting;
- JSON parsing/stringifying and lazy-tape storage;
- regular expressions and replacement callbacks;
- Buffer, filesystem, process, networking, URL, inspector, and native-module
  code;
- 54 perry-stdlib modules, including database, HTTP, crypto, framework, and
  compression adapters;
- generated inline header/payload reads and native ABI lowering.

This is the silent-corruption blast radius that makes a producer-first patch
unsafe.

## Representation

### Language value tag

A cons string uses the existing `STRING_TAG`. It is still an ECMAScript string,
so `JSValue::is_string()`, `is_any_string()`, truthiness, root decoding, and
NaN-boxed stores should not need another tag branch.

A new NaN-box tag is rejected. It would repeat the SSO consumer migration and
make every string type test participate in a storage detail.

### GC type and layout

Add `GC_TYPE_CONS_STRING` after the current `GC_TYPE_REGEXP` and extend the GC
type table. Leave `GC_TYPE_STRING` pointer-free.

The proposed node preserves `StringHeader` as its prefix:

```rust
#[repr(C)]
struct ConsString {
    header: StringHeader,          // offsets 0..20; .length remains valid
    boundary: u32,                 // fills pointer-alignment padding
    lone_surrogate_count: u32,     // exact, for O(1) flag composition
    left: *mut StringHeader,       // traced and rewritten
    right: *mut StringHeader,      // traced and rewritten
    flat: *mut StringHeader,       // nullable cached flat result; traced
}
```

The `boundary` word records at least:

- whether the logical string begins with a lone low surrogate;
- whether it ends with a lone high surrogate;
- whether it is empty.

Those summaries are composable in O(1). They are needed because Perry stores
WTF-8 and canonicalizes a high-surrogate/low-surrogate pair formed across a
concat boundary. Such a join changes two three-byte sequences into one
four-byte UTF-8 scalar. Therefore the node's exact `byte_len` is:

```text
left.byte_len + right.byte_len - (boundary_forms_pair ? 2 : 0)
```

`utf16_len` remains the sum of the children. `lone_surrogate_count` is the sum
of the child counts minus two when the boundary forms a pair, and the existing
`STRING_FLAG_HAS_LONE_SURROGATES` bit is derived from whether that count is
non-zero. This keeps `flags` exact even when the joined pair was the only pair
of lone surrogates in the children. Flat children derive the count with an
O(payload) scan only at the first flat-to-cons boundary; if that scan is
measurable, a later layout revision can cache the count in flat headers. It
must not be replaced by `left.flags | right.flags`, which is wrong when the
join eliminates the last two lone surrogates. A naive sum of byte lengths is
also a wrong answer for non-ASCII strings and must be covered by tests.

Representation discrimination should use the GC header's object type, not a
new `StringHeader.flags` bit. Existing code propagates `flags` with bitwise OR;
a representation bit could accidentally turn an ordinary flat result into a
fake cons node. Static `PERRY_EMPTY_STRING` is not GC-managed, so
`is_cons_string` must classify the address before looking behind the user
pointer.

### GC tracing

`GC_TYPE_CONS_STRING` is movable and pointer-bearing. Add a dedicated layout
kind and rewrite descriptor that enumerate the three raw pointer slots in the
same order for marking, copying preflight, evacuation rewriting, dirty-slot
scanning, and verification.

The cache is a real third edge. A side table is rejected: because cons nodes
move, it would require a mutable-root scanner, relocation rekeying, dead-owner
cleanup, and synchronization while still leaving the children to trace.

Node construction must:

1. root both children before allocating the node;
2. allocate `GC_TYPE_CONS_STRING`;
3. re-read both child handles after allocation;
4. initialize all three edge slots before publishing the node;
5. carry `GC_STORE_AUDIT(INIT)` evidence for those birth stores.

### Flattening and caching

The central allocating operation should be:

```rust
fn js_string_ensure_flat(s: *const StringHeader) -> *mut StringHeader
```

Its contract:

- invalid, static-empty, and flat inputs return a flat pointer directly;
- a cons with a cached `flat` edge returns that edge;
- otherwise it roots the top node, allocates exactly one flat string of the
  stored canonical `byte_len`, re-reads the rooted node, and copies leaves in
  logical order;
- traversal is iterative, never recursive, so a deeply left- or right-nested
  rope cannot overflow the native stack;
- traversal recognizes cached flat subtrees;
- the copy loop emits canonical UTF-8 directly when a WTF-8 surrogate pair
  crosses a leaf boundary; it must not call the current allocating
  `canonicalize_surrogate_pairs` after the destination allocation;
- after filling the result, it re-reads the top-node handle and publishes the
  cache with a verified GC-slot write barrier;
- the returned flat string has `refcount = 0`, so `js_string_append` cannot
  mutate a value shared by the cache.

Publishing `flat` is an old-to-young store when a cons node has survived but
its first flatten result is new. The store needs a runtime helper that performs
the raw slot write and `runtime_write_barrier_gc_slot` together, plus
`GC_STORE_AUDIT(BARRIERED)` and a static/sabotage test. Behavioural GC tests
alone cannot prove a write barrier exists.

The top cons node must be rooted before the destination allocation. Holding it
in a Rust local is not a root. Once the destination is allocated, the iterative
copy must call no Perry allocator or user code. Rust `Vec` growth for the
explicit traversal stack does not trigger Perry GC, but reserving from a stored
depth or leaf-count bound is preferable.

Flattening only the top node is sufficient. Caching every nested node would add
stores and barriers to a one-shot materialization without improving the common
case.

## Reader API and rooting contract

Changing `string_data(s) -> *const u8` to allocate internally is unsafe. A
two-string operation can flatten `a`, collect and move unrooted `b`, then read a
stale `b`. The helper API must make operand rooting explicit.

Introduce flat-only primitives and rooted adapters:

```rust
unsafe fn flat_string_data(s: *const StringHeader) -> *const u8;
unsafe fn flat_string_bytes<'a>(s: *const StringHeader) -> &'a [u8];

fn with_flat_string<R>(s, f: impl FnOnce(*const StringHeader, &[u8]) -> R) -> R;
fn with_flat_strings<R>(a, b, f: impl FnOnce(FlatView, FlatView) -> R) -> R;
```

The one-operand adapter roots before flattening. The two-operand adapter roots
both operands before either flatten operation and re-reads handles after every
collection point. Higher-arity readers use a rooted handle array, following the
existing `concat_chain_sized` pattern.

`flat_string_data` should have debug assertions that reject
`GC_TYPE_CONS_STRING`. Its unsafe contract must say that the caller has already
established flatness and that no collection runs while the borrowed pointer is
live.

At ABI boundaries:

- `js_get_string_pointer_unified` returns a flat `StringHeader*` for heap cons
  values as well as materialized SSO values;
- `js_jsvalue_to_string` returns a flat pointer when the input is already a
  heap cons string;
- every direct `extern "C"` consumer either accepts a documented flat-only
  pointer from codegen or calls a rooted flatten adapter before reading bytes;
- codegen must treat every newly allocating flatten route as a collection
  point and re-root raw handles live across it.

Inline codegen changes:

- heap-string `.length` remains the offset-0 load and does not flatten;
- inline `charCodeAt` must guard out `GC_TYPE_CONS_STRING` before reading
  `byte_len` or payload bytes, then use the existing runtime slow path;
- literal equality may keep pointer identity and tag checks, but must guard out
  cons nodes before inline endpoint-byte loads and route them to
  `js_string_equals`;
- any future raw byte fast path must be included in the reader inventory gate.

The initially named functions resolve as follows:

| Function | Cons-string contract |
| --- | --- |
| `js_string_from_bytes` | Always constructs a flat `GC_TYPE_STRING`; no cons input exists. |
| `js_string_length` | Reads the common-prefix `utf16_len`; never flattens. |
| `js_get_string_pointer_unified` | Materializes SSO as today and flattens a heap cons before returning a raw pointer. |
| `js_jsvalue_to_string` | Returns a flat pointer for an existing cons string; other coercion semantics stay unchanged. |
| `js_string_equals` | Roots both operands before flattening either, then compares flat bytes. |
| `js_string_compare` | Uses the same two-operand rooted flatten adapter before UTF-16 ordering. |
| `js_string_concat` | Becomes the Stage 3 pilot producer; construction reads only common-prefix metadata and boundary summaries. |
| `js_string_concat_chain` | Keeps the existing fusion machinery and becomes a producer only in Stage 4. |
| `str_bytes_from_jsvalue` | Must not start allocating behind its borrowed-pointer return type; replace general uses with rooted callback/view adapters. |
| `js_string_append` | Keeps the flat unique-owner fast path; a cons destination is flattened or routed to cons construction and is never mutated in place. |
| `js_string_intern` | Flattens before hashing/interning and stores only flat canonical strings. |

## Staged landing plan

### Stage 0: reader inventory and enforcement

Land a lint script that inventories all direct `StringHeader` payload reads,
shared borrowed-byte helpers, and codegen offset constants. Start with an exact
reviewed allowlist and fail on every new site. The gate must have non-zero
floors and self-tests so an empty scan cannot pass.

Add the flat-only primitive names and rooted one-/two-/N-operand adapters, but
do not add a cons producer. Migrate `crates/perry-runtime/src/string/` first.
This is behaviour-preserving infrastructure like the successful first step of
the SSO rollout.

Exit criterion: all string-module readers use the adapters and the inventory
ratchets downward.

### Stage 1: consumer and FFI migration

Migrate the remaining clusters in independently reviewable PRs:

1. object keys, arrays, maps/sets, proxies, and typed feedback;
2. JSON and JSON tape;
3. RegExp and formatting;
4. Buffer, filesystem, process, network, URL, and native modules;
5. perry-stdlib adapters;
6. codegen inline payload reads and native ABI boundaries.

There are still no cons producers in this stage. Each PR removes its entries
from the inventory allowlist, adds focused tests, and runs the 19-program
byte-exact sweep.

Exit criterion: the only raw payload arithmetic left is inside audited
flat-only primitives and construction code; the lint rejects everything else.

### Stage 2: inert cons representation and GC proof

Add `GC_TYPE_CONS_STRING`, the node constructor, traced edges, flatten/cache
logic, barriered cache publication, heap-snapshot handling, and unit-only test
constructors. No production concat path returns a cons node yet.

Required sabotage evidence:

- deleting each left/right/flat trace edge fails a GC test or static descriptor
  assertion;
- deleting or bypassing the cache write barrier fails its static assertion;
- forcing collection between rooting and node/flat allocation does not stale
  any operand.

### Stage 3: direct `a + b` pilot

Behind an A/B knob, allow only `js_string_concat` (and the heap arm of
`js_string_concat_box` when both operands are heap strings) to return cons
nodes. Keep eager flat concatenation for empty/tiny results; create a cons when
the result is large enough or either operand is already a cons. The threshold
is a measurement result, not a guessed constant.

Do not change `js_string_concat_chain` in this stage. Measure the direct-concat
shapes and the full corpus for wall time, instructions, and RSS. Promote the
knob only if compute improves without an RSS regression.

### Stage 4: fused-chain producer

Preserve #7912's chain lowering and stack-scratch sizing. The required change
is representation, not another fusion rewrite.

For an accumulator chain such as:

```text
seen + "[" + name + "]"
```

retain the first part as the accumulated prefix, fuse the remaining pieces
into one flat suffix with the existing sizing/formatting machinery, then make
one cons node `(prefix, suffix)`. Do not copy the prefix. Ordinary short chains
with no accumulated prefix may retain the existing single flat allocation to
avoid extra nodes and RSS.

This is the stage expected to fix `rope.ts`, `rope2.ts`, and `iso_miss`.

### Stage 5: tuning and default-on decision

Tune the eager/cons threshold and any depth/leaf-count policy from interleaved
A/B data. A deep tree is safe because flattening is iterative; balancing is
optional and should be added only if a measured non-flattening operation needs
it. Remove the A/B knob after the default-on decision so two string semantics
do not drift indefinitely.

## Correctness gates

Every producer stage must pass:

```sh
CARGO_TARGET_DIR=/Users/amlug/cargo-targets/w8394 \
  cargo build --release -p perry -p perry-runtime-static -p perry-stdlib-static

CARGO_TARGET_DIR=/Users/amlug/cargo-targets/w8394 \
  cargo test --release -p perry-runtime --lib

CARGO_TARGET_DIR=/Users/amlug/cargo-targets/w8394 \
  cargo test --release -p perry --bin perry

bash scripts/run_lint_gates.sh
./scripts/run_gap_tests.sh
```

The runtime used for compiled programs must be selected with:

```sh
export PERRY_RUNTIME_DIR=/Users/amlug/cargo-targets/w8394/release
```

All 19 sources in `sweep-artifacts-0819/sources` must compile and match the
corresponding expected stdout byte-for-byte. Run this after each consumer
cluster, not only after enabling a producer.

Run both GC-root dominance modes because flattening is a collection point and
the shipping lowering uses native statepoints on this host. Also run forced
collection with varied seeds and `PERRY_GC_PROTECT_FROMSPACE_DEPTH=800`.

Required focused cases:

- empty strings and single characters;
- deeply left-nested and right-nested trees;
- flatten twice and prove the cached flat pointer/content is reused;
- flatten, then append/mutate through every supported builder path without
  changing aliases or the cached value;
- `.length` before and after flatten;
- equality and comparison between cons/flat and cons/cons values;
- non-ASCII strings, astral scalars, lone surrogates, and a high/low surrogate
  pair split across multiple rope boundaries;
- a cons and its cached flat value surviving moving minors and a full GC after
  heavy allocation;
- FFI calls receiving a value produced by direct concat and concat-chain;
- heap snapshot/debug formatting of an unflattened cons.

## Measurement protocol

Copy `rope.ts` and `rope2.ts` into the worktree and compile them with the exact
release/static-wrapper build above. Measure each of 2000, 4000, 8000, and 16000
iterations separately so `/usr/bin/time -l` reports peak RSS for the row rather
than for a mixed run.

For both `PERRY_ROPES=0` and `PERRY_ROPES=1`, report together:

- best and median wall time from interleaved repetitions;
- instructions retired from the macOS Counters instrument;
- `maximum resident set size` from `/usr/bin/time -l`.

Run `iso_miss` from `sweep-artifacts-0819/sources` best-of-seven with its stdout
checked before accepting a timing. Report the same three metrics. The current
main reference is 0.7439 seconds best-of-seven on this host.

The acceptance rule is the repository rule: minimize RSS and keep the best
compute, never trade one for the other. Cons nodes add allocation traffic, so a
wall-time win with an RSS regression is evidence for threshold/producer tuning,
not grounds to enable the representation by default.

## Why no code producer is included with this design

A producer-first patch could make the two supplied reproducers faster while
quietly corrupting an unrelated FFI, property-key, regex, JSON, or stdlib path.
The census shows that proving the negative requires a repository-wide reader
migration and an enforceable invariant, not a manual claim that the obvious
functions were updated.

Staging preserves a strong property: until Stage 3, every production string is
flat, so an unmigrated allowlisted reader remains correct. After Stage 1, the
lint makes the opposite property enforceable: every general reader is cons-safe
before the first production cons can exist.
