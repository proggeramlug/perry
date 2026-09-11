# Final source refinement

The [final CSV](helper-audit.csv) refines three existing `CannotCollect` contracts from the [frozen v2 audit](../audit-v2/runtime-audit.md). It does not add candidate helpers, change source behavior, or rerun compilation. The [source receipt](source-receipt.json) binds both CSV hashes and reviewed source files; existing `CannotCollect` membership and the 48 newly reviewed candidate names are unchanged.

`js_closure_get_capture_bits` uses null/bounds checks, a mask, pointer arithmetic and a raw u64 load. The supporting paths are `closure/alloc.rs:362–369,749–758` and `closure/registry.rs:1335`. It never allocates for admitted ABI inputs and has no route to Perry collection or JS reentry.

`js_implicit_this_get` and `js_implicit_this_set` read/replace a TLS Cell. Cold HotTls initialization can allocate native backing storage through the v2-audited `alloc_block_no_gc` route, so their allocation class remains **may allocate**, while Perry collection and JS reentry are **no**. A native allocation is not itself a Perry statepoint.

The final emitted-helper subset has 895 rows, with 72 independently reviewed and 823 explicitly unresolved. Its classifications are 15 never allocating, 51 potentially allocating and 829 unclear. The separate review-status column prevents an existing compiler contract from masquerading as a new complete body audit.
