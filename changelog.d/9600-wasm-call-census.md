### Added

- **`PERRY_WASM_CALL_CENSUS=1` counts and times every host→wasm call.** Off by
  default and zero-cost when off: the hot path pays one relaxed `OnceLock` load
  and a not-taken branch, no clock read, no allocation, and the `atexit` hook is
  installed only when the variable is set — the same shape as
  `promise::mt_profile_enabled` and `eh_walker::diff_mode`.

  One site covers the whole surface. `webassembly::call_export_n` is the sole
  caller of the `perry_wasm_host_call_export` FFI, and all three JS-visible
  entry families converge on it: the `instance.exports.foo(...)` closure path
  (`js_wasm_export_call_0..4` → `call_captured_wasm_export`), the legacy
  `WebAssembly.callExport` intrinsic (`js_webassembly_call_export_0..4`), and
  WASI `_start`. The export name is already in scope there as the decoded
  string, so the census keys on it directly with no index→name map.

  On exit it prints per-export call counts, total time and mean nanoseconds,
  and — separately — the totals for the whole-linear-memory sync described
  below. The two are never folded together, because conflating them is what
  makes the real cost invisible.

  Motivation, measured on this branch's parent (`cli_2.1.112.js`, Apple
  Silicon, node v26.5.1 as the reference):

  | call | perry (wasmi 1.1) | node (V8) |
  | --- | --- | --- |
  | export on a module with **no** memory (`long.js` `mul`) | 513 ns | 15 ns |
  | export on a module **with** a 128 KiB memory (`llhttp_get_error_pos`) | 14,977 ns | 9 ns |
  | the same export after growing that memory to 4.3 MiB | 441,630 ns | 10 ns |

  Per-call cost is **linear in `memory.buffer.byteLength`** (×33 memory → ×29.5
  time, ≈0.11 ns/byte — a full memcpy), because
  `call_captured_wasm_export` brackets every single call with
  `sync_memory_to_wasm` / `sync_memory_from_wasm`, which copy the entire linear
  memory in **both** directions. wasmi's own interpretation is not the problem:
  in a profile of a parse loop it accounted for 1.4% of samples, while
  `buffer::view::propagate_range_to_views` plus the two
  `perry_wasm_host_instance_memory_{copy,write}` calls accounted for ~75%.

  The census exists so that this is measurable per workload rather than
  re-derived each time. It does not change the sync behaviour.

  Validated against a fixture whose call counts are fixed in advance, so the
  output is checked against ground truth rather than eyeballed — 1,000
  `llhttp_get_error_pos`, 500 `mul`, 250 `llhttp_get_errno`, 7 `get_high`,
  1 `llhttp_alloc`, 1 `llhttp_free`, across one module that has a linear
  memory and one that does not. The census reports all six exactly and
  `total_calls=1759`. With the variable unset the process writes **zero
  bytes** to stderr and its stdout is byte-identical to the instrumented run.

  That run also re-derives the headline independently, from the census's own
  two counters rather than from wall-clock ratios: 11.238 ms in the
  whole-memory sync against 1.055 ms inside the wasmi calls themselves, i.e.
  **91% of all time spent calling wasm is the memory copy**, over exactly
  1,759 syncs — one per call, which is the every-call behaviour stated
  above rather than an inference about it.
