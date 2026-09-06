### Fixed

- **gc:** a keys-array family's descriptor list no longer memmoves its whole
  tail on every removal, and no longer scans linearly to find an id.

  `IdList::remove` was `Vec::remove(pos)`, which shifts everything past the
  removed position. Measured on the compiled claude-code TUI, one 3300-char
  reply, six draws: the removals sit at position **~0.31** of the list — i.e.
  essentially always the front — and the longest list reaches **512,691**
  entries, so the same 3.70 M removals memmove **525.7 GB** in the slow mode
  against **5.6 GB** in the fast one. That 520 GB difference is ~13 s at
  40 GB/s, against a measured 12.5–13.2 s turn-CPU difference between the two
  modes: the memmove is the mode.

  A spilled list now carries an `id -> index` map, built once it passes 32
  entries, and `families` removes through a swap-remove that moves one element
  regardless of position. `by_facts` keeps the order-preserving removal it
  needs (its first entry is the canonical answer for exact-facts interning) and
  is unaffected — measured at max length **1**, so it never builds an index.

  The same index also removes the linear membership scan in
  `family_push_back`, previously **6.2 %** of main-thread leaf samples.

  This does not address why one family reaches half a million descriptors,
  which is a separate defect and a separate change.
