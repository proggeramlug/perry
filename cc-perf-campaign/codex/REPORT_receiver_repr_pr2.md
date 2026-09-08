# Receiver representation PR 2: recovery and semantic stop

Recorded 2026-09-08 08:59 CEST (clock read on the coordination Mac).

## Result

The lane is incomplete. Timers and text are already committed and pushed by the
predecessor. Common, Fetch, and symbols remain uncommitted. This recovery found
representation inconsistencies in Common and collector ownership/rooting
problems in Fetch, so it does not publish another family as independently ready.
These findings come from the source paths below; no newly compiled runtime
failure or CPU/RSS result is claimed.

No cargo command, bundle compile, relink, or cc run was started during this
recovery. The coordinator reserved perrymaster for the existing queue and asked
this lane to remain code-only until that queue completes. The Mac had 29 GB
available when inspected; disk is not the current reason validation is pending.

## The two Git views must not be confused

Worktree: `/Users/amlug/projects/perry/agent-trees/native-recv`.

The ordinary `.git` file points into the shared Perry repository and still
reports `f8349661e`, the old timers WIP. The predecessor made a private Git
directory, `.git-native-recv/`, for its completed commits. Continue with:

```sh
git --git-dir=.git-native-recv status --short
git --git-dir=.git-native-recv log --oneline -4
```

Private branch and fork branch: `perf/receiver-repr-wrap-live-families`.

| Family | Implementation SHA | State |
| --- | --- | --- |
| Timers | `9fcd96d1c90fdfa430b2a56fb16e2d159567529e` | Pushed; required cargo gates pending |
| Text | `f04a0b5a746399bc5ed41b9fc1e40279296db70c` | Pushed; required cargo gates pending |
| Common | None | Preserve WIP; direct publisher audit incomplete |
| Fetch | None | Preserve WIP; semantic stop below |
| Global symbols | None | Preserve WIP; held behind earlier families |

The two predecessor commit messages explicitly record that cargo was skipped
because space was below the 12 GB floor. They are not validation evidence.
`git ls-remote fork refs/heads/perf/receiver-repr-wrap-live-families` returned
the text SHA above before this report commit.

The `.native-recv-runtime-tests.log` failure is dated September 7 03:59 and is
stale: its missing test export `buffer::js_buffer_register_external` is present
under `#[cfg(test)]` in the current `buffer/mod.rs:72-77`. The adjacent archive
log records rc=0 but is also not evidence for the current working diff.

## Timers and text already published

Both use nonmoving `GC_TYPE_NATIVE_HANDLE` cells and the weak per-agent
`(provider,id)` interner in `native_handle/canonical.rs`. Registry ids stay leaf
metadata. The timer wrapper is borrowed: collecting the JS wrapper removes its
weak identity entry without cancelling a live scheduled timer. The TextEncoder
wrapper represents the existing stateless sentinel. TextDecoder wrappers are
owned and their finalizer removes the decoder's registry state.

The predecessor adapted
`gc::tests::runtime_roots::hook_dispatch_handles::test_bound_timer_dispatch_roots_args_during_async_hook_init_gc`
to call `canonical_timer_id` before the raw-id snapshot helper
(`hook_dispatch_handles.rs:120`). This is the expected migration-shaped test
adaptation.

Each family has managed-header, copying-minor identity, and finalization tests
in `timer/tests_inline.rs` and `text.rs`. Their presence is not a green result:
the full gates and sabotage runs remain pending. No sabotage was performed
during this recovery.

## Common: direct constructor and chain result disagree

The WIP migrates native-table result rows to
`NR_GCPTR.managed_common_handle()` and the corresponding materializer calls
`js_canonical_common_handle_value`. It adds `NA_HANDLE_ID`, static receiver
unwrapping, dynamic callback adapters, and common/FFI registry retirement.
The selected policy is borrowed wrappers, keeping provider close/drop APIs in
charge of the actual resources. The per-provider ownership audit is unfinished.

At least one direct codegen publisher was missed:

* `lower_call/builtin.rs:423-424` calls
  `js_event_emitter_new_with_options` and pointer-boxes the returned integer
  directly.
* `perry-ext-events/src/lib.rs:992-997` still returns the registry id from that
  constructor. `register_event_emitter_handle` at `:444-459` returns an integer
  from the reserved EventEmitter range, not a wrapper address.
* `native_table/net_events.rs:1570-1575` now marks `js_event_emitter_on` as
  `NR_GCPTR.managed_common_handle()`. The provider at
  `perry-ext-events/src/lib.rs:1084` returns its raw input handle after
  installing the listener.

Consequently the source paths publish `POINTER_TAG | id` for construction and
`POINTER_TAG | wrapper_address` for the fluent return. The exact compiled
acceptance case to run before changing this family further is:

```ts
import { EventEmitter } from "node:events";
const emitter = new EventEmitter();
const result = emitter.on("event", () => {});
console.log(result === emitter); // required: true
```

This is a source-derived identity discrepancy; it has not yet been reproduced
in a compiled executable. The direct `Command` constructor at
`lower_call/builtin.rs:410-411` likewise still boxes the id returned by
`perry-stdlib/src/commander.rs:154-156`; other direct constructors must be audited
against their providers before declaring the Common producer set closed.
Do not fix the EventEmitter line alone and call that a complete producer audit.

## Fetch: allocating publication changes thread ownership and root windows

The WIP changes `fetch/mod.rs:389-395`'s `handle_to_f64` from scalar boxing to
canonical wrapper allocation. Its callers previously did not allocate a GC
cell. Two consequences require a coordinated producer migration:

1. Async response completion allocates on the worker. `fetch/mod.rs:509,580,654,744`
   and `fetch/abort_bridge.rs:235` call `handle_to_f64(response_id)` inside async
   work and pass the resulting bits to `queue_promise_resolution`. The wrapper
   then belongs to the worker's malloc registry and canonical interner, while
   the receiving JS thread attempts to interpret it using its own registries.
   These queues used to carry an integer registry id, which had no GC owner.
2. Bound-method construction now has a collection window after closure
   allocation. `fetch/headers_method_value.rs:76-81` allocates a closure and
   then calls `handle_to_f64(headers_id)` while setting capture zero;
   `fetch/dispatch.rs:292-297` does the same for FormData. Neither closure is
   held in a root across the newly allocating publication call.

The smallest existing owner-thread mechanism is
`common::queue_deferred_resolution` (`common/async_bridge.rs:427-445`). Queue
only the scalar `response_id`; its converter runs on the receiving runtime
thread and calls `handle_to_f64` there. Keep the response's native registry
state alive until that conversion. For bound methods, publish and root the
wrapper before allocating the closure, then reload the rooted wrapper for the
capture store; alternatively root the closure across wrapper publication.
Use the provider-compatible root scope for the separately compiled provider
path. Audit every `handle_to_f64` caller for the same newly introduced
allocation window and for a held registry mutex.

Two test issues are separate from the semantic findings:

* The new stdlib header test calls runtime's
  `pub(crate) try_read_tracked_gc_header`; that helper is unavailable across
  the crate boundary. Use a public canonical accessor to establish the wrapper
  and inspect its known header, or add an appropriately scoped public test ABI.
* `fetch_identity_survives_a_copying_minor` calls `gc_collect_minor` without
  forcing and asserting that a copying minor actually ran. The public
  `js_gc_force_evacuation_test_override` and `copying_minor_cycles` exist;
  use a restoring guard, root a young witness, and assert the cycle count moves.

The borrowed Fetch policy also still needs provider-by-provider evidence.
Do not claim that collecting a wrapper releases Fetch registry state: the WIP
explicitly keeps that state alive in its finalization test.

## Preserved dirty-file partition

There are 104 modified tracked files relative to the private text HEAD before
this report. No source file was changed during this recovery.

| Partition | Files | Scope |
| --- | ---: | --- |
| Common | 85 | Codegen native-table/ABI changes, all changed `perry-ext-*` and FFI files, runtime native-handle/class-handle adapters, stdlib common/crypto/events/database publishers, native-result script and TSV |
| Fetch | 6 | Runtime `object/{field_get_set.rs,global_fetch.rs,global_this/fetch_globals.rs}`; stdlib `fetch/{mod.rs,dispatch.rs,tests.rs}` |
| Symbols | 11 | Runtime `gc/{dead_owner.rs,types.rs}`, `symbol.rs`, `symbol/constructors.rs`, `thread.rs`, `thread_transfer_guard_tests.rs`, `value/addr_class.rs`, `object/native_call_method.rs`, and its `bare_receiver.rs`, `bare_receiver/tests.rs`, `probe_dispatch_tests.rs` |
| Shared | 2 | `hot_diag/receiver_repr.rs` and `scripts/gc_runtime_root_holders.json`; split hunks by family |

The Common partition contains shared adapter infrastructure used by later
families; it is an audit partition, not a mechanically applicable staging list.
Pre-existing untracked receiver-class tests, design/review documents, logs,
the old changelog fragment, and the private Git directory also remain intact.
Never add the private Git directory or the stale logs to a commit.

## Checks performed and pending validation

These checks ran on the complete dirty tree, not on an independently staged
Common commit:

* `python3 scripts/native_result_ledger.py`: PASS, 371 rows / 322 providers;
  `NR_FOREIGN_PTR=4 NR_GCPTR=307 NR_HANDLE_ID=45 NR_JS_VALUE=13 NR_NULLABLE_GCPTR=2`.
* `python3 scripts/gc_runtime_root_holders.py`: PASS, 1,365 declarations,
  1,161 identity-ratcheted, 593 scanner-reached, 351 inventory-classified,
  416 frontier-pinned, 152 registered scanners.
* `python3 scripts/check_thread_locals.py`: PASS, 406 hot declarations,
  273 cold declarations in 83 recorded files, capacity 768.
* `bash scripts/check_file_size.sh`: PASS, no Rust source files exceed 2,000 lines.
* `rustfmt --check --edition 2021` on every modified tracked Rust file: PASS.
* `git --git-dir=.git-native-recv diff --check`: PASS.

The native ledger currently checks the declared result class, not completeness
of direct codegen publishers. Its green result therefore does not contradict
the Common finding above.

Perrymaster validation may start only after the exact marker
`ARM LCI-9949 DONE` occurs in `/root/armLCI-9949_9838.log`, under the existing
`/root/rig9831/lock`. The coordinator owns staging and launching this work.
No validation script was launched by this lane.

Validate the existing timer and text implementation SHAs independently first.
For each, check available disk space immediately before every Cargo command
and run the brief's full gates:

```sh
cargo test -p perry-runtime --release --lib -j6 -- --test-threads=1
cargo test -p perry-codegen --lib -j6
cargo build --release -p perry-runtime --features wasm-host -j6
cargo build --release -p perry -j6
python3 scripts/native_result_ledger.py --self-test
python3 scripts/native_result_ledger.py
python3 scripts/gc_runtime_root_holders.py
python3 scripts/check_thread_locals.py
bash scripts/check_file_size.sh
```

Compiled family tests include
`cargo test -p perry --test issue_aliased_timers_promises_global_setTimeout -j6`
and `cargo test -p perry --test text_decoder_dynamic_surface -j6`.
Build the actual static wrapper archives used by those executables and verify
their mtimes; pin `PERRY_RUNTIME_DIR` to that build's archives. The wasm-host
feature build above is a separate feature gate, not a substitute for the plain
archives consumed by ordinary compiled tests.

After Common/Fetch corrections, add the EventEmitter fluent identity fixture,
run the complete stdlib Fetch test module in addition to the runtime gate,
and exercise async response publication and bound-method creation across
copying collections. Prove each new check by its stated sabotage before using
it as a gate.

No performance request is ready. This branch changes codegen, so its eventual
cc arm requires a rebuilt bundle and a cache derived from that codegen; merely
relinking old bundle objects cannot validate the changed publishers. After all
five families pass, request the complete diagnostic line (all five old buckets
zero, wrapped buckets exercised, other buckets unchanged) and five paired 3300
rows with the same-session Node arm, load stamps, raw CPU values, and RSS.
