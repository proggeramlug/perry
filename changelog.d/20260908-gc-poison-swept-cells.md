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
