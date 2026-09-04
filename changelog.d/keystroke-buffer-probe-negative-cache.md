### Performance

- **`is_registered_buffer` remembers negative answers.** The address window
  in front of the buffer registries stops discriminating in any long-running
  process (the claude-code TUI has buffers across the whole old arena), so
  every "is this pointer a buffer?" question — asked per element by
  `js_array_get_f64`, by the descriptor probes, the vtable guards and
  `js_dyn_index_set_strict` — reached `is_registered_buffer_slow`, 2.2 % of
  the keystroke profile, all of it answering "no".

  - `crates/perry-runtime/src/buffer/header.rs` — a 4096-slot, thread-local,
    direct-mapped negative cache keyed by address and stamped with a
    process-wide registration epoch. Every route that can make an address
    findable (`register_buffer`, and the SAB registry through
    `note_buffer_like_published`) bumps the epoch AFTER publishing, and a
    probe loads the epoch before it runs the slow path, so a cached negative
    can never outlive the moment its address becomes a buffer on any thread.
    The test-only registry probe counter keeps its meaning (it counts probes
    that got past the window).

  Test: `buffer_negative_cache_is_invalidated_by_registration` (probe twice,
  register the same address, probe again — a stale negative would be a type
  confusion).
