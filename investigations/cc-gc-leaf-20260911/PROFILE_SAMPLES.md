# Actual-IP profile census and static opportunity coverage

`profile_samples.py` is ready for synthetic-format review. **The installed perf export sample is still pending.** Its grammar is explicitly marked provisional; root must bind a real export and exporter exit status before treating campaign results as accepted. No real samples, native programs, builds or box jobs were run by this agent.

Root's intended export, retaining stderr and exit status separately:

```sh
perf script --ns --full-paths -F pid,tid,time,event,ip,sym,symoff,dso,period -i profile.data
```

The field list selects fields; perf determines their rendering order. The currently supported fixture grammar is one sample per line:

```text
 77/77 12345.000000001: 5242155 cycles:u: 401010 perry_fn_fixture_hot+0x10 (/owned/app)
```

Unknown symbols must be explicit `[unknown]`, `[unknown kernel.kallsyms]`, or a hexadecimal address. Named symbols require an explicit `+0xoffset`. Missing fields/newlines, timestamps without exactly nine fractional digits, nonpositive periods, unsupported event names, extra callchain lines and loss records fail instead of being skipped. Empty newline separators alone are allowed. If installed perf uses another representation, change only the independently observed grammar and add that raw witness before freezing. The parser does not infer the field order from values.

Run the analyzer into a new directory:

```sh
python3 -B investigations/cc-gc-leaf-20260911/profile_samples.py \
  --samples capture/samples.txt --run capture/run.json --maps capture/app-maps.json \
  --metadata exact-app-pgcm --helper-audit investigations/cc-gc-leaf-20260911/helper-audit.csv \
  --callsites accepted-callsite-census --output new-profile-analysis
```

`--metadata`, `--helper-audit` and `--callsites` are optional; the latter requires the same helper audit hash as the callsite census. Missing static evidence is labeled unavailable. It is not replaced by zero record counts. No binary is opened. Input, analyzer and output hashes are retained. Existing output directories are never overwritten; failures retain partial artifacts and `failure.json`, without a success summary.

## Exact phase and self accounting

The analyzer requires `run.json` success, clean app/perf teardown, exact application PID/executable/argv and birth-tick binding, explicit `CLOCK_MONOTONIC`, the two acknowledged perf controls, and ordered phase boundaries. Nanoseconds and periods remain integers throughout, including values beyond binary floating-point's exact range.

Startup and command windows are `[begin,end)`. Every sample belongs to one of five disjoint phases: before startup, startup, between phases, command, after command. Every sample also belongs to exactly one scope: target main thread, other thread in the target process, foreign PID. No samples from warmup, prompt typing, subprocesses or shutdown are silently folded into the command window or dropped.

`self.csv` contains every phase/scope/DSO/symbol row. `by-ip.csv.gz` preserves runtime IP, linked IP when available, original symbol offset, PID and TID. Integer sample and period sums reconcile across phases, scopes, symbols and distinct sampled IPs, and independently across each phase. Zero rows are explicit in phase/scope totals. Unknown symbols remain explicit. Full DSO paths are required for application identity; a basename alone receives no application/static join.

Runtime helpers with a nonempty source location in the bound helper audit receive `runtime_helper_source_bound`. Unlisted `js_` exports and `perry_fn_`/`perry_closure_`/`perry_method_` symbols are separately labeled naming families. These labels do not prove GC effects. Other application symbols and other DSOs remain in the self table. All values are **sampled self**, never callchain-derived inclusive time.

Internal reconciliation proves that this parser accounts for all lines it accepted. It cannot prove that an upstream export did not omit a whole well-formed sample. Root must bind the successful exporter, preserve perf stderr/loss evidence and independently reconcile sample/period totals against perf's self report. A capture with unusable startup or command evidence must remain unusable even if the syntax parses.

## Address and function binding

The raw `/proc/PID/maps` snapshot is taken at startup end by `profile_workload.py`. PGCM's section receipt supplies an exact file offset and linked VMA. For a unique readable mapping of the same application path, Linux device and inode:

```text
load_bias = map.start + (gcmap.file_offset - map.file_offset) - gcmap.linked_VMA
```

This uses the **same file byte** in both views. It does not assume ELF segment virtual addresses equal their file offsets. Ambiguous anchors, identity mismatches and missing mappings fail. Linux device decoding is explicit, because a Mac analyzer's native `os.major()` uses a different device-number layout. The retained ELF itself is not read or hashed here; root must bind its immutable SHA to the PGCM census.

Application sample IPs must lie in an executable mapping of that exact application. `linked_IP = runtime_IP - load_bias`; `function_start = linked_IP - perf_symbol_offset`. A PGCM function joins only when that exact start exists, its ELF symbol aliases contain the exact perf symbol, and a positive symbol size contains the sampled offset. Unknown symbols, zero sizes, conflicting names or absent records remain unbound. No nearest-address/name normalization is used. A missing PGCM entry does not mean a function has no statepoint overhead.

`self-with-static-metadata.jsonl.gz` adds the matched full per-function PGCM entries, including record counts, stack sizes and live-root-count distributions. Multiple PGCM entries and aliases remain explicit. Root locations count static metadata live sets; they are not spill instruction counts or dynamic executions.

## Leaf-hypothesis joins

The callsite join verifies the frozen census summary and hashes of:

- `definitions.csv`: the complete `post-opt` population, including functions with zero calls, keyed by exact symbol and capture attempt.
- `post-opt-hypothesis-targets.csv`: exact caller and callee identities, surviving statepoint count and live-operand count for each hypothesis.

An affected caller contributes its self samples **once per hypothesis**, regardless of its number of eligible sites. Several hypotheses can overlap; their period totals must not be added. If one symbol exists in multiple emission units, its coverage is marked ambiguous even when only one unit contains a candidate site. Without an exact PGCM start/symbol/size join, its samples remain unbound. Final accepted-emission-to-linked-application identity is a separate root-owned prerequisite; source-symbol equality alone cannot prove which object file was linked.

The summary's `hypothesis_caller_self_coverage` is an opportunity-coverage table. It is not an upper-bound CPU saving that can be added to helper self time. Callee work still executes after leaf classification; **no callee self cycles are subtracted or claimed to disappear**.

## Sound follow-on instruction attribution

1. Bind the exact ELF, executable mmap and complete PGCM to the same capture. Use the metadata return PC and exact machine instruction boundaries to identify a call whose following address is that return PC. A symbol near the PC is insufficient; indirect-call target identity needs its actual machine operand/IR correspondence.
2. Tie the call to the retained post-RS4GC/post-opt statepoint and its relocation uses. Follow machine CFG/dataflow and the allocator's stack-slot assignments. A store or load using a root slot is not automatically statepoint work: slot reuse, ordinary locals, dominance and exceptional paths must be resolved.
3. A paired compile that changes only the proved leaf classification can establish which stores/reloads, stack adjustments or root-reload machinery actually disappear. Preserve optimization and register-allocation changes explicitly. Map the changed instruction intervals separately in each exact binary.
4. Only then aggregate sampled IPs falling within those **proved instruction intervals**, or obtain a separate actual execution count for an exact callsite. Static instruction counts and function-wide self samples cannot supply call frequency. Sampling resolution/skid and ordinary A/B uncertainty still apply; report instruction-level sampled coverage rather than inventing latency.

There is no arbitrary `PC ± 50 bytes` window, no attribution from unreliable narrow callchains, and no assumption that every root record causes a distinct machine spill. The current script stops at per-function static joins; it performs no instruction-cost estimate.

## Local controls

`python3 -B -m unittest test_profile_samples -v` passes **13 tests**. The fixtures cover full integer precision, all boundary equalities, PID/thread partitions, malformed/truncated/loss rows, invalid run clocks/teardown, exact nontrivial bias, identity/hash failures, ambiguous mappings, unknown and out-of-symbol IPs, complete output accounting, preserved old output, and the zero-call duplicate-definition case.

The seven-sample accounting fixture has periods `[2,3,5,7,11,13,17]`, total **58**. Its five phase totals are `[2,8,7,24,17]`; command includes 11 target-main periods and 13 foreign-PID periods. The address fixture has GC-map VMA `0x8100`, file offset `0x6100`, and mapping start `0x408000`/offset `0x6000`: the correct bias is `0x400000`, while `map.start-map.offset` would incorrectly give `0x402000`.

Sabotage replaces phase classification with an unconditional startup result and requires the command assertion to fail. A separate wrong-bias sabotage prevents the required exact function join. No real installed-perf layout or full application result has yet been accepted.
