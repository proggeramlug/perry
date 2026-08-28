### Changed

- An inline `Array.prototype.push` of an untyped value that turns out to be a plain number no longer pays the three GC-bookkeeping calls and the write barrier. The append tests the live bits and the receiver's live layout flags once and branches over all four, the same shape the statically numeric push has used since #7839.
