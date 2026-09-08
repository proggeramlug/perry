`PERRY_GC_POISON_SWEPT=1` now turns each old-generation cell retired by a full
or budgeted mark-sweep into recognisable dead storage until exact-size reuse.
The sweep stamps the existing `0xDE` dead-object marker, preserves the cell's
size word for the out-of-line old free list, records the original object type,
and fills the payload with `0xDEAD_BEEF_DEAD_BEEF`. Reuse removes the provenance
and clears the payload before a constructor can observe the cell.

Property reads, inline-cache misses, and primitive method dispatch now fail
closed when the diagnostic table identifies their receiver as one of these
dead cells. The first read emits a line shaped like:

```text
[gc-poison-swept] STALE READ user_ptr=0x... obj_type_was=1 swept_by=42 sweep_site=old_reclaim_alloc_point reader_site=js_object_get_field_by_name
```

With `PERRY_GC_DIAG=1`, each full sweep also prints
`[gc-poison-swept] cells=N bytes=N blocks_protected=0`. The knob accepts
`panic` to panic after attribution; unset, `0`, unknown, and empty values are
strictly inert. The focused `gc::tests::poison_swept` module exercises both
ON and OFF arms, verifies the marker/payload, captures the stale-reader line,
and proves exact-size reuse clears the quarantine state.

Whole-block `mprotect` is intentionally not included. Old blocks flow through
reset, pool, selected-page defragmentation, and OS-deallocation paths, so safe
protection needs the same bounded ownership plus release-before-reuse protocol
as the nursery quarantine. That exceeds the optional sub-200-line extension;
cell poisoning provides the requested mark-sweep capture without changing
block lifecycle policy.

The knob is default-off and must cost nothing when off. The old-gen exact-fit
reuse path, the block-reset hole filter and the three mutator read entry
points therefore test `poison_swept_maybe_active()` — one relaxed load of a
flag written once, inside the mode's own resolution — before entering any
thread-local map. `poison_swept_mode` itself (a `OnceLock` read plus, in test
builds, a thread-local check) stays on the per-collection paths.

Two instrument corrections from the first cc rows: the non-fatal mark probe
now reports, on a minor, only children that minor could sweep — an old child
of a marked parent is unmarked by construction, which on a real bundle is up
to 1.8M spurious edges per minor — and every line names its `scope=`. The
conservative-scan rejection samples are re-read at the marks-final boundary
and report `at_boundary=marked|unmarked|no_header`, which is what separates a
dead stack word pointing at a retired cell from a live object the
valid-pointer set refused.
