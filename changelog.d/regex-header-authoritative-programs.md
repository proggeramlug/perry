### Performance

- **`exec`/`test` no longer copy and hash the pattern text on every call.**
  `lookup_fancy_regex` and `lookup_repeat_matcher` build the header's programs
  and then, when the header's `fancy_ptr` / `repeat_matcher_ptr` slot was null,
  fell through to a `(pattern, flags)` probe of the thread-local caches — a
  full `String` copy of the pattern AND of the flags, plus a SipHash over the
  whole pattern text, per lookup, twice per lookup, and both lookups run on
  every `exec`/`test`/`replace`/`match`. For a pattern with neither fallback —
  the overwhelmingly common case — that is four copies and four hashes of the
  pattern per call, purely to re-derive "no, there is no fallback". On the
  claude-code TUI, whose layout pass runs `emoji-regex`'s 12,807-character
  `/…/g` literal over every text segment, that was ~51 KB copied and hashed per
  `test()`, and SipHash over pattern text was 31 % of the main thread in the
  20 s after a reply rendered.

  A BUILT header already knows. `lazy::build_and_install_programs` writes
  `fancy_ptr` and `repeat_matcher_ptr` and only then publishes `regex_ptr` (it
  is the built/not-built flag), and it runs only for a header that passed
  `is_valid_regex_ptr` — so a non-null `regex_ptr` means all three slots are
  current and a null `fancy_ptr` beside it means "this pattern has no fancy
  fallback". The cache probe now runs only when the build declined (the
  pointer is not a live RegExp allocation), where the header's slots really do
  say nothing.

  That made one latent incoherence load-bearing, so it is fixed here too: the
  three compiled-program caches are capped independently and each `clear()`s
  wholesale on overflow, so `FANCY_CACHE` can be empty while `REGEX_CACHE`
  still holds the never-match placeholder installed for a lookaround pattern.
  `get_or_compile_regex` then answers from that placeholder without re-running
  the fancy build, and the header was published as "compiled" carrying a
  program that matches nothing and no fallback — a lookbehind regex that
  silently stops matching. `build_and_install_programs` now recognises the
  placeholder and rebuilds the fallback beside it, so a built header always
  carries every program its pattern needs.
  (`built_header_keeps_its_fancy_fallback_after_a_fancy_cache_clear`)
