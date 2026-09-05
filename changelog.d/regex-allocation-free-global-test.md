### Performance

- **`RegExp.prototype.test` on a global or sticky receiver no longer builds a
  match object.** `test` is stateful for `/g` and `/y` — it consults and
  advances `lastIndex` and anchors at it — so it was implemented by calling
  `js_regexp_exec` and discarding the result. That materialized an
  `ArrayHeader`, one `StringHeader` per capture group (every capture is copied
  out of the subject), the `groups` object for named groups and, under `/d`,
  the `indices` array — all immediate garbage, to answer a boolean. On the
  claude-code TUI a layout pass runs `/…/g` literals from `emoji-regex` and
  `ansi-regex` over every text segment on every keystroke.

  `regexp_test_advancing` is `exec`'s engine phase with `captures_at` replaced
  by `find_at`: the same engine order (repeat matcher, then fancy, then
  standard), the same sticky anchoring, the same `lastIndex > length` early
  out, and the same throwing `Set(R, "lastIndex")` on advance and on reset.
  Dropping the capture query is not only the allocation: the `regex` crate's
  meta engine can answer "does it match" with a DFA where a capture query
  forces the slower capture-tracking engine.
  (`global_and_sticky_test_track_last_index_like_exec` pins every `lastIndex`
  branch on all three engines.)
