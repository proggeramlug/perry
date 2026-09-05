### Performance

- **`PERRY_GC_DIAG=1` now reports why a young-log entry stayed relevant.** The
  `[gc-young-log]` counters added with the side-table young logs showed two of
  the five tables skipping nothing at all on the compiled claude-code TUI —
  `object.shape_cache` 0.0 % of 18,009 entries on every cycle,
  `closure.dynamic_props` under 10 % — while `object.descriptors` skipped 87 %
  and `object.transition_cache` 79 %. Those counters cannot distinguish an
  honest report of a genuinely young table from a predicate that is too coarse.

  `addr_is_minor_relevant` answers `true` for three different reasons that
  carry different duties: a nursery address is one a minor really moves, a
  `Longlived` address is only traced through (never moved, never swept), and a
  malloc-GC address is only swept. `[gc-young-gen]` now prints that split per
  collection, so the next filter is chosen against a measurement rather than a
  guess. Diag-only, behind the same cached `gc_diag_enabled()` flag as the rest
  of the `[gc-*]` reporting.
