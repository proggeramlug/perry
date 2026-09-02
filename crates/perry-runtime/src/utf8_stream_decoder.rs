//! Node's `string_decoder` UTF-8 core: an INCREMENTAL decoder that replaces
//! invalid sequences with U+FFFD and, crucially, holds an incomplete
//! multi-byte sequence across a chunk boundary instead of mangling it.
//!
//! # Why this lives in perry-runtime (#9490)
//!
//! The logic below is not new — it was written for `node:string_decoder` and
//! has always lived in `perry-stdlib/src/string_decoder.rs`. But every stream
//! that honours `setEncoding("utf8")` lives one crate DOWN, in perry-runtime,
//! and perry-stdlib depends on perry-runtime rather than the other way round.
//! So the stream paths could not reach it, and each grew its own one-shot
//! decode instead:
//!
//!   * `process.stdin` passed the raw bytes to `js_string_from_bytes`, which
//!     does no validation at all — high bytes survived into the JS string and
//!     the WTF-8 length walk swallowed continuation bytes, so bytes 0..255
//!     came out as 158 code units with zero U+FFFD (Node: 256 and 128).
//!   * the generic `Readable` decoded each chunk independently, so a
//!     codepoint straddling two chunks became replacement characters.
//!
//! Moving the core down here — rather than copying it — keeps ONE
//! implementation: `perry-stdlib`'s `StringDecoderHandle` now embeds this
//! struct for its utf8 mode, so `node:string_decoder` and the stream decoders
//! cannot drift apart.

/// Incremental UTF-8 decode state: at most one partially-seen code point.
///
/// The fields are public because `node:string_decoder` exposes them verbatim
/// as its `lastNeed` / `lastTotal` / `lastChar` properties.
#[derive(Debug, Clone, Default)]
pub struct Utf8StreamDecoder {
    /// Number of bytes still needed to complete the current code point
    /// (0 when no partial point is buffered).
    pub last_need: u8,
    /// Total byte length of the in-progress code point (2, 3, or 4).
    pub last_total: u8,
    /// Up to 4 bytes of partial code point captured from prior writes.
    pub last_char: [u8; 4],
    /// How many bytes of `last_char` are valid; never larger than 4.
    pub last_char_len: u8,
}

impl Utf8StreamDecoder {
    /// `const` so a decoder can live in a `static Mutex<_>` — `process.stdin`
    /// is a process-global stream and needs exactly one decode state.
    pub const fn new() -> Self {
        Utf8StreamDecoder {
            last_need: 0,
            last_total: 0,
            last_char: [0; 4],
            last_char_len: 0,
        }
    }

    /// The incomplete sequence currently being held, if any. Callers that
    /// cannot keep a decoder alive between chunks (the generic `Readable`
    /// stores its state in a per-stream hidden field) round-trip these bytes
    /// and re-prefix them onto the next chunk, which is equivalent.
    pub fn pending_bytes(&self) -> &[u8] {
        &self.last_char[..self.last_char_len as usize]
    }

    /// True while an incomplete multi-byte sequence is being held.
    pub fn has_pending(&self) -> bool {
        self.last_need > 0
    }

    /// Forget any held partial without emitting a replacement. Used when a
    /// stream is destroyed or re-opened rather than ended.
    pub fn reset(&mut self) {
        self.last_need = 0;
        self.last_total = 0;
        self.last_char_len = 0;
        self.last_char = [0; 4];
    }

    /// Decode `bytes`, holding back any trailing incomplete sequence.
    /// Returns "" when the whole input was consumed into the held partial —
    /// callers must NOT emit a `'data'` event for an empty result, matching
    /// Node.
    pub fn write(&mut self, bytes: &[u8]) -> String {
        write_utf8(self, bytes)
    }

    /// Flush at end-of-stream: any held partial becomes a single U+FFFD,
    /// exactly as `StringDecoder.prototype.end` does. Node emits this as its
    /// own final `'data'` event, before `'end'`.
    pub fn end(&mut self, bytes: Option<&[u8]>) -> String {
        end_utf8(self, bytes)
    }
}

/// Detect a multi-byte UTF-8 lead in the final 0–3 bytes of `buf`.
/// Returns the number of bytes that should be buffered for the next
/// write (so they aren't returned as garbled output). Mirrors the
/// `utf8CheckIncomplete` function in Node's `lib/string_decoder.js`.
fn utf8_check_incomplete(state: &mut Utf8StreamDecoder, buf: &[u8]) -> usize {
    let mut i = buf.len();
    // Walk back from the end of the buffer up to 3 bytes — the longest
    // UTF-8 lead sequence the trailing bytes could need to wait for.
    let walk = if buf.len() >= 3 { 3 } else { buf.len() };
    let mut steps = 0usize;
    while steps < walk {
        i -= 1;
        steps += 1;
        let b = buf[i];
        // Continuation byte 10xxxxxx — keep walking.
        if (b & 0xC0) == 0x80 {
            continue;
        }
        // 4-byte lead 11110xxx.
        if (b & 0xF8) == 0xF0 {
            // We've already walked `steps - 1` continuation bytes plus
            // this lead; we need 4 total, so we still need
            // `4 - steps` bytes.
            if steps < 4 {
                state.last_need = (4 - steps) as u8;
                state.last_total = 4;
                let start = buf.len() - steps;
                state.last_char_len = steps as u8;
                state.last_char[..steps].copy_from_slice(&buf[start..]);
                return steps;
            }
            return 0;
        }
        // 3-byte lead 1110xxxx.
        if (b & 0xF0) == 0xE0 {
            if steps < 3 {
                state.last_need = (3 - steps) as u8;
                state.last_total = 3;
                let start = buf.len() - steps;
                state.last_char_len = steps as u8;
                state.last_char[..steps].copy_from_slice(&buf[start..]);
                return steps;
            }
            return 0;
        }
        // 2-byte lead 110xxxxx.
        if (b & 0xE0) == 0xC0 {
            if steps < 2 {
                state.last_need = (2 - steps) as u8;
                state.last_total = 2;
                let start = buf.len() - steps;
                state.last_char_len = steps as u8;
                state.last_char[..steps].copy_from_slice(&buf[start..]);
                return steps;
            }
            return 0;
        }
        // ASCII byte 0xxxxxxx — nothing to buffer.
        return 0;
    }
    0
}

/// Emit the held (now abandoned) partial sequence the way Node does.
///
/// NOT a single blanket U+FFFD: Node 26's decoder is native, and it renders the
/// held bytes with the ordinary lossy UTF-8 conversion, so WHATWG's
/// maximal-subpart rule applies. `[E2]` and `[F0,9F,98]` each yield one
/// replacement, but `[F7,BC]` yields TWO — 0xF7 is not a legal lead at all, so
/// the trailing 0xBC is a second, separate invalid subpart. Collapsing that to
/// one character is what made the differential fuzz disagree with Node.
fn flush_held(state: &Utf8StreamDecoder, held: usize) -> String {
    String::from_utf8_lossy(&state.last_char[..held]).into_owned()
}

/// Validate that the bytes arriving to complete a held sequence really are
/// continuation bytes.
///
/// On failure it does NOT consume the offending byte. It sets `last_need` to
/// the number of leading bytes that WERE valid continuations — which
/// `write_utf8` reads back as the resume offset — and returns the abandoned
/// sequence's replacement text.
fn utf8_check_extra_bytes(state: &mut Utf8StreamDecoder, buf: &[u8]) -> Option<String> {
    // Bytes of the code point already held; equals Node's `lastTotal - lastNeed`.
    let p = (state.last_total - state.last_need) as usize;
    if (buf[0] & 0xC0) != 0x80 {
        let out = flush_held(state, p);
        state.last_need = 0;
        return Some(out);
    }
    if state.last_need > 1 && buf.len() > 1 {
        if (buf[1] & 0xC0) != 0x80 {
            // buf[0] was a valid continuation, so it joins the held sequence.
            state.last_char[p] = buf[0];
            let out = flush_held(state, p + 1);
            state.last_need = 1;
            return Some(out);
        }
        if state.last_need > 2 && buf.len() > 2 && (buf[2] & 0xC0) != 0x80 {
            state.last_char[p] = buf[0];
            state.last_char[p + 1] = buf[1];
            let out = flush_held(state, p + 2);
            state.last_need = 2;
            return Some(out);
        }
    }
    None
}

/// Complete the held sequence from the head of `buf`.
///
/// Returns `None` when `buf` was absorbed whole and the sequence is still
/// incomplete. Otherwise returns the decoded text, leaving `last_need` set to
/// the number of bytes of `buf` that were consumed.
fn utf8_fill_last(state: &mut Utf8StreamDecoder, buf: &[u8]) -> Option<String> {
    let p = (state.last_total - state.last_need) as usize;
    if let Some(replacement) = utf8_check_extra_bytes(state, buf) {
        return Some(replacement);
    }
    let need = state.last_need as usize;
    if buf.len() >= need {
        state.last_char[p..p + need].copy_from_slice(&buf[..need]);
        let total = state.last_total as usize;
        // Lossy, not all-or-nothing: every byte is a continuation, but the
        // sequence can still be an invalid lead (0xF5..0xFF), an overlong form
        // or a surrogate, and Node renders those per maximal subpart too.
        return Some(String::from_utf8_lossy(&state.last_char[..total]).into_owned());
    }
    // Still short. Every byte of `buf` is a validated continuation byte, so
    // buffering them cannot strand a non-continuation byte.
    state.last_char[p..p + buf.len()].copy_from_slice(buf);
    state.last_char_len = (p + buf.len()) as u8;
    state.last_need -= buf.len() as u8;
    None
}

/// Decode `bytes` against the existing partial-codepoint state, mutating
/// `state` to reflect any new trailing partial. Returns the decoded
/// string. UTF-8 invalid sequences are replaced with U+FFFD, matching
/// Node's `lossy` UTF-8 decoder behavior.
fn write_utf8(state: &mut Utf8StreamDecoder, bytes: &[u8]) -> String {
    if bytes.is_empty() {
        return String::new();
    }
    let mut out = String::new();
    // Offset into `bytes` at which ordinary decoding resumes.
    let mut resume = 0usize;

    if state.last_need > 0 {
        match utf8_fill_last(state, bytes) {
            // Absorbed whole; the sequence is still incomplete.
            None => return out,
            Some(text) => {
                out.push_str(&text);
                // Node reads `lastNeed` back AFTER fillLast, where it means
                // "bytes of the new chunk consumed" — the completed-sequence
                // path leaves it at the count it took, and the invalid path
                // rewinds it to the valid-continuation count. Either way the
                // remaining bytes must still be decoded, not dropped.
                resume = state.last_need as usize;
                state.last_need = 0;
                state.last_total = 0;
                state.last_char_len = 0;
            }
        }
    }

    if resume < bytes.len() {
        out.push_str(&write_utf8_tail(state, &bytes[resume..]));
    }
    out
}

/// Tail half of `write_utf8`: assumes `state.last_need == 0` on entry.
/// Splits a trailing incomplete code point off into `state`.
fn write_utf8_tail(state: &mut Utf8StreamDecoder, bytes: &[u8]) -> String {
    if bytes.is_empty() {
        return String::new();
    }
    let trail = utf8_check_incomplete(state, bytes);
    let head = &bytes[..bytes.len() - trail];
    String::from_utf8_lossy(head).into_owned()
}

/// `decoder.end([buf?])` — flush any incomplete state as U+FFFD, matching
/// Node's behavior.
fn end_utf8(state: &mut Utf8StreamDecoder, bytes: Option<&[u8]>) -> String {
    let mut out = match bytes {
        Some(b) => write_utf8(state, b),
        None => String::new(),
    };
    if state.last_need > 0 {
        // Same maximal-subpart rule as a failed stitch: Node renders the held
        // bytes lossily, so a held `[F7,BC]` ends as TWO replacements, not one.
        let held = (state.last_total - state.last_need) as usize;
        out.push_str(&flush_held(state, held));
        state.last_need = 0;
        state.last_total = 0;
        state.last_char_len = 0;
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn split_euro_sign() {
        // U+20AC EURO SIGN = E2 82 AC in UTF-8.
        let mut d = Utf8StreamDecoder::new();
        assert_eq!(d.write(&[0xE2, 0x82]), "");
        assert_eq!(d.last_need, 1);
        assert_eq!(d.last_total, 3);
        assert!(d.has_pending());
        assert_eq!(d.write(&[0xAC]), "\u{20AC}");
        assert_eq!(d.last_need, 0);
        assert!(!d.has_pending());
    }

    #[test]
    fn emoji_split_at_every_boundary() {
        // U+1F600 = F0 9F 98 80. #9490's fixture splits it 1/3, 2/2 and 3/1;
        // all three must reassemble to the same single code point.
        let emoji = [0xF0u8, 0x9F, 0x98, 0x80];
        for cut in 1..4usize {
            let mut d = Utf8StreamDecoder::new();
            let a = d.write(&emoji[..cut]);
            let b = d.write(&emoji[cut..]);
            assert_eq!(a, "", "cut {cut} must emit nothing yet");
            assert_eq!(b, "\u{1F600}", "cut {cut}");
            assert!(!d.has_pending());
        }
    }

    #[test]
    fn end_flushes_partial_as_one_replacement() {
        let mut d = Utf8StreamDecoder::new();
        assert_eq!(d.write(&[0x41, 0xE2, 0x82]), "A");
        assert_eq!(d.end(None), "\u{FFFD}");
        assert!(!d.has_pending());
    }

    #[test]
    fn all_256_bytes_match_node() {
        // Node: 256 code units, 128 of them U+FFFD.
        let bytes: Vec<u8> = (0..=255u8).collect();
        let mut d = Utf8StreamDecoder::new();
        let mut out = d.write(&bytes);
        out.push_str(&d.end(None));
        assert_eq!(out.encode_utf16().count(), 256);
        assert_eq!(out.chars().filter(|c| *c == '\u{FFFD}').count(), 128);
    }

    #[test]
    fn invalid_sequences_replace_per_whatwg() {
        let mut d = Utf8StreamDecoder::new();
        // lone continuation, 2-byte overlong, 3-byte overlong, surrogate.
        assert_eq!(d.write(&[0x80]), "\u{FFFD}");
        assert_eq!(d.write(&[0xC0, 0x80]), "\u{FFFD}\u{FFFD}");
        assert_eq!(d.write(&[0xE0, 0x80, 0xAF]), "\u{FFFD}\u{FFFD}\u{FFFD}");
        assert_eq!(d.write(&[0xED, 0xA0, 0x80]), "\u{FFFD}\u{FFFD}\u{FFFD}");
    }

    #[test]
    fn reset_drops_the_partial_without_emitting() {
        let mut d = Utf8StreamDecoder::new();
        assert_eq!(d.write(&[0xF0, 0x9F]), "");
        d.reset();
        assert!(!d.has_pending());
        assert_eq!(d.end(None), "");
    }

    #[test]
    fn ascii_round_trips() {
        let mut d = Utf8StreamDecoder::new();
        assert_eq!(d.write(b"hello"), "hello");
        assert_eq!(d.last_need, 0);
    }

    /// A held partial followed by a NON-continuation byte. Node emits one
    /// U+FFFD for the abandoned sequence and then decodes the offending byte
    /// as fresh input — it does not swallow it. Every expectation below was
    /// read off node 26.5.1's own `string_decoder`.
    #[test]
    fn held_partial_then_non_continuation_matches_node() {
        // (chunks, expected concatenation of writes, expected end())
        let cases: &[(&[&[u8]], &str, &str)] = &[
            (&[&[0xE2], b"AB"], "\u{FFFD}AB", ""),
            (&[&[0xF0], &[0x41]], "\u{FFFD}A", ""),
            (&[&[0xF0], &[0x41], &[0x80, 0x80]], "\u{FFFD}A\u{FFFD}\u{FFFD}", ""),
            // First continuation is valid, second is not: node consumes the
            // good one, emits ONE replacement, resumes at the bad byte.
            (&[&[0xE2], &[0x82, 0x41]], "\u{FFFD}A", ""),
            (&[&[0xF0], &[0x9F, 0x41]], "\u{FFFD}A", ""),
            (&[&[0xF0], &[0x9F, 0x98, 0x41]], "\u{FFFD}A", ""),
            (&[&[0xF0, 0x9F, 0x98], &[0x41]], "\u{FFFD}A", ""),
            // Single non-continuation byte, shorter than `last_need`: the
            // short-chunk branch must not buffer it and lose it.
            (&[&[0xE2], &[0x41]], "\u{FFFD}A", ""),
            // Control: a genuine split still reassembles.
            (&[&[0xF0, 0x9F], &[0x98, 0x80]], "\u{1F600}", ""),
            // Control: a still-incomplete tail is held, then flushed by end().
            (&[&[0xE2], &[0x82]], "", "\u{FFFD}"),
            // Maximal subpart: 0xF7 is not a legal lead at all, so a held
            // [F7,BC] is TWO invalid subparts, not one abandoned sequence.
            (&[&[0xF7, 0xBC], &[0xE7, 0x41]], "\u{FFFD}\u{FFFD}\u{FFFD}A", ""),
            (&[&[0xF7, 0xBC]], "", "\u{FFFD}\u{FFFD}"),
            (&[&[0xF5], &[0x41]], "\u{FFFD}A", ""),
            (&[&[0xF0, 0x9F, 0x98]], "", "\u{FFFD}"),
            // Surrogate completed across a boundary is still rejected.
            (&[&[0xED, 0xA0], &[0x80]], "\u{FFFD}\u{FFFD}\u{FFFD}", ""),
        ];
        for (chunks, want_writes, want_end) in cases {
            let mut d = Utf8StreamDecoder::new();
            let got: String = chunks.iter().map(|c| d.write(c)).collect();
            let got_end = d.end(None);
            assert_eq!(
                got, *want_writes,
                "writes for {chunks:02X?}: got {got:?} want {want_writes:?}"
            );
            assert_eq!(got_end, *want_end, "end() for {chunks:02X?}");
        }
    }
}
