# Runtime validation cost after the GC-leaf study

**The next measurement should attribute repeated runtime validation to its callers.** The completed cc command profiles put **8.33% of sampled cycles** in four exact pointer/Buffer/closure classification symbols. This is larger than the generated-caller coverage of the leaf-elision candidates. It is not yet evidence that those checks are redundant or that 8.33% is removable. No runtime optimization or new workload run was performed.

## Observed self cost

These are the three successful `Explain this project.` runs from the [GC-leaf study](../cc-gc-leaf-20260911/REPORT.md), including two actual file Reads and a streamed response. All figures below are command-phase **self** samples, weighted by integer hardware periods. Startup and typing are separate. This is not a comparison with the older no-tool prompt or a fresh Node arm.

| Runtime work | Command sampled cycles |
|---|---:|
| `gc_malloc_header_is_tracked` | **4.90%** |
| `js_native_call_method` | 3.14% |
| Buffer classification: `is_registered_buffer` + `_slow` | **2.25%** |
| `js_object_get_field_by_name` | 1.60% |
| `is_closure_ptr` | **1.18%** |

The four bold classification symbols total 1,576,569,576 periods / 18,920,915,610. Self samples belong to one instruction at a time; the table is not an inclusive call tree. The malloc validator alone has 178 samples and ranges from **3.57% to 5.80%** across the three rows. At startup it has only two samples (0.11% aggregate); that is too sparse for a useful instruction breakdown. [Every symbol and exact count](results/self-ranked.csv), [per-row totals](results/summary.json).

## Where the largest helper's samples land

Exact ELF symbol bounds and disassembly identify its 367-byte body. All sampled IPs join to actual instruction boundaries. Four manually reviewed, nonoverlapping instruction regions partition the body:

| Region | Samples | Share of helper self | Share of command |
|---|---:|---:|---:|
| Hash-set lookup, including empty-set check | 68 | 38.20% | 1.87% |
| Function entry/return and null-argument handling | 41 | 22.86% | 1.12% |
| RefCell borrow checks and `ensure_set_built` call dispatch | 40 | 22.65% | 1.11% |
| Thread-local state resolution | 29 | 16.30% | 0.80% |

The source's warm path still resolves the per-runtime TLS slot, takes a mutable borrow, calls the lazy-registry guard, checks membership and releases the borrow. The emitted binary retains the `ensure_set_built` call. Its **callee body is outside** the region above; this is not evidence that the registry is rebuilt on each invocation. The implementation maintains an exact set after its first activation.

Roughly 62% of this helper's self samples therefore land outside the hash-lookup region. That supports measuring whether callers can reuse a valid classification, before replacing the hash table. Sampling skid and small row counts prevent interpreting individual instructions as exact latency bills; entry samples do not count calls. [Instruction-level rows](results/selected-instructions.csv), [exact disassembly](disassembly/function-0.disasm).

## What must be resolved before a change

The same helper serves different obligations. `native_handle.rs:221` validates candidate native handles; `value/addr_class.rs:334` uses it as the exact malloc fallback; dynamic indexing and JSON have their own fallback paths. GC tracing and barriers also consult it. This finite source inventory establishes possible routes, **not their executed shares**. The current profile does not provide trustworthy caller chains, so it cannot assign the 4.90% to native method dispatch, GC work, JSON, or another consumer.

One particularly important constraint is explicit in `gc/trace.rs:35–48`: its membership predicate is a **union** of exact malloc membership and admitted arena objects. Malloc allocations can overlap ranges attributed to arena metadata. Replacing that union with an exclusive arena-vs-malloc choice would change the predicate. Other runtime boundaries also accept values whose ownership has not yet been established; their first validation is necessary. No validation check was removed or reordered here.

The next diagnostic should count entries by exact caller boundary, distinguish positive/negative registry answers, and count repeated validation of an unchanged value within one operation. Keep startup, command and collector phases separate; do not report instrumented timing as ordinary CPU. A reused verdict must retain its allocation/thread identity and end when collection, reallocation, publication changes or relevant callbacks can invalidate it. Only then choose between carrying an already-established type/ownership fact, reducing duplicate dispatch probes, or leaving the checks intact. No general “trust pointer-shaped bits” route is proposed.

## Identity and validation

The measured binary remains SHA256 `b907d616caf8eea350543185de24fc2af1426090fc58161ee49952e6980314f7`. Source is the unchanged retained overlay plus compiler observer, parent study commit `c16614181`. This follow-up branch is `diag/cc-runtime-helper-profile-20260911`; main is untouched. [Reviewed source hashes](source-receipt.json).

Six selected functions are disassembled on perrymaster under `/root/rig9831/lock`, with the whole binary hash verified before and after. No application is executed during that pass. [Execution receipt](disassembly/execution.json), [exact request](disassembly-request.json), [capture script](capture_disassembly.py).

The lightweight aggregation reuses the existing complete profiles. It reconciles every phase/scope/DSO/symbol by both sample count and integer period against the separately saved self tables, then against the final study phase totals. A one-period deletion is rejected in each of the three real rows; ambiguous instruction-region membership is also rejected. All selected samples have exact symbol starts and instruction boundaries. Full prior perf reconciliation and workload controls remain in the linked study.

`python3 -B analyze.py` reproduces the derived CSVs and JSON from the sibling study files. It does not compile or run cc. All original evidence and the new disassembly remain preserved; no existing result was overwritten or relabeled as a new profile. The broad optimization goal remains open, while the user's measurement-only constraint on GC elision remains in force.
