### Fixed

- Start `fs.promises.watch()` when it is created so filesystem events that
  occur before the first async-iterator pull are queued like Node.js.
