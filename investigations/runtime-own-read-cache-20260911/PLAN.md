# Runtime own-data cache experiment

The prior census observes 396,025 short-key own-data reads across three cc
commands: 31.26% of ordinary tail lookups. Most are descriptor-marked and miss
the existing early read stub. The experiment tests whether remembering a fully
resolved own slot can remove enough repeated work to move CPU time.

The private branch `perf/runtime-own-read-cache-20260911` starts from retained
runtime source `b6545b491ee0dc4b6fb36db7b47903431686b313`. It adds a separate
bounded two-way cache with the existing read stub's bucket/way counts. Entries
hold exact class+ShapeId identity, short ASCII key content, and a tagged slot.
They retain no pointers or values. The cache occupies 96 KiB per initialized
thread on this 64-bit build; measure actual RSS rather than infer its delta.

Only the three ordinary own-data tail return sites prime it, after own-accessor
checks. The consumer remains after private-member, elements, process.env and
Proxy handling. The write-side producer and direct SSO consumer keep the old
cache and cannot consume these new proofs. Admission excludes native modules,
typed-array prototypes, boxed String objects, TTY `rows`, registered arguments
objects, and heap class objects. Exact class identity prevents cross-brand
sharing; semantic ShapeId transitions revoke descriptor/kind/prototype proofs.
Stable holes still miss and the current value is loaded on every hit.

The two independent Astra audits found the class-object exclusion necessary:
the outer getter can continue static dispatch after a tail result of undefined.
Caching that intermediate result would alter later reads. Descriptor table
installation paths use the semantic-generation transition; raw removals do not
create an accessor that falsifies a learned absence proof. See [AUDIT.md](AUDIT.md)
for the supported scope and remaining measurement limits.

Validation is focused: nine real-runtime tests, including actual cache hits,
accessor invalidation with a deliberately relabeled stale proof, exact class
identity, SSO isolation, elements attachment, class-kind rejection, long keys,
overflow values and stable deletion/re-add. A compiled fixture then compares
control and candidate byte-for-byte with Node, including getters, inheritance,
Proxy, array elements, boxed strings, freezing and delete/re-add churn.

All Cargo and workload execution is on perrymaster under `/root/rig9831/lock`.
The build reconstructs the retained source from sealed inputs, applies the six
changed files, uses an independent target, builds the retained shipping package
and feature graph, and relinks with the original compiler and generated-object
cache. The already verified control binary is reused by exact SHA; no historical
timing is substituted for new control rows. Compiler SHA:
`d4d3f4678374fb3d452b5d5e55dad6b0c27e242d2037395dd3081e601d1929c5`.
Control SHA:
`5560e04fe7016923d098ea70d254cb8edd3252c9973282aca40ff62d3415bf97`.

The comparison is five interleaved Perry pairs and three Node rows on the same
startup/actual-two-Read/stream workload. Timed arms contain no runtime census,
BPF probes or perf sampling. Preserve every row, including adverse RSS pairs.
The script/phase recorder is retained from the preceding comparison; only
labels, ports and stage bindings change. Weak results park the candidate; do
not repeat rows merely to obtain a favorable minimum.

No GC effect summary, statepoint, write barrier, compiler optimization or regex
implementation is changed. GC-point/barrier elision remains measurement-only.
No main commit, push, PR or broad CI is part of this experiment.
