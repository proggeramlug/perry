### Performance

- **Constructing a regex literal no longer copies or hashes its pattern.**
  `js_regexp_new` derived everything from the pattern TEXT on every
  evaluation: `lazy::pattern_already_validated` built
  `(pattern.to_string(), flags.to_string())` and SipHashed the pair to ask a
  question whose answer is a pure function of that pair; `owned_pattern` took
  a third copy; and the `REGEX_SOURCE_TABLE` entry (#637 — `.source`/`.flags`
  must survive GC of a temporary input string) took a fourth, *per header*, so
  N live regexes over one literal retained N copies of its text. `emoji-regex`
  is a 12,807-character literal that `string-width` evaluates once per measured
  text segment, and ink's layout pass measures every segment of every line on
  every keystroke: ~50 KB copied and ~12 KB SipHashed per construction,
  thousands of times per rendered reply.

  `regex/site_cache.rs` (new) is a 512-slot direct-mapped table keyed by the
  pattern `StringHeader` ADDRESS. A regex literal lowers to `js_regexp_new`
  with an interned handle, so that address is stable per site and free to
  compute — but it is never trusted alone: a hit is confirmed by comparing the
  stored pattern and flag bytes, so a GC that recycles the address can only
  cost a refill, never produce a wrong answer. `memcmp` of an equal 12 KB
  pattern is ~20x cheaper than SipHashing it, and the hit path allocates
  nothing.

  A hit also yields the SHARED `Arc<str>` pattern and canonical flags, and
  `REGEX_SOURCE_TABLE` now stores that pair, so a literal's text is stored once
  however many live regexes were built from it. Nothing about what is validated
  changes — a miss runs the unchanged validation; the cache only records that a
  byte-identical pair has already passed it.
  (`site_cache::tests::address_reuse_with_different_bytes_misses`,
  `repeat_construction_shares_the_pattern_allocation`)
