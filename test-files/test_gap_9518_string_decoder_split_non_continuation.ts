// `node:string_decoder` — a held partial followed by a NON-continuation byte.
//
// The generated node:string_decoder parity test only ever splits at a VALID
// continuation ([E2,82] then [AC]), so it passes whether or not the stitch
// path is correct. This file covers the other half: what happens when the
// bytes arriving to complete a held sequence are NOT continuations.
//
// Node abandons the held sequence, emits replacement(s) for the bytes it was
// holding, and then decodes the offending byte as fresh input. Perry used to
// emit ONE U+FFFD and DISCARD the rest of the chunk, so `write([0xE2])`
// followed by `write("AB")` lost "AB" entirely (#9518, found by CodeRabbit on
// PR #9518; the same core backs process.stdin and Readable.setEncoding).
//
// The replacement COUNT is the subtle part: Node renders the held bytes with
// the ordinary lossy conversion, so WHATWG's maximal-subpart rule applies. A
// held [E2] is one replacement, but a held [F7,BC] is TWO — 0xF7 is not a
// legal lead at all, so the trailing 0xBC is a second, separate subpart.
import { StringDecoder } from "node:string_decoder";

// Compact, diffable rendering: a bare U+FFFD is invisible in a terminal diff.
function units(s: string): string {
  const out: string[] = [];
  for (let i = 0; i < s.length; i++) out.push(s.charCodeAt(i).toString(16));
  return out.join(" ");
}

const CASES: Array<[string, number[][]]> = [
  // Held 3-byte lead, then ASCII: the ASCII must survive.
  ["E2 | AB", [[0xe2], [0x41, 0x42]]],
  // Held 4-byte lead, then a single ASCII byte SHORTER than lastNeed — the
  // short-chunk branch used to buffer the non-continuation byte and drop it.
  ["F0 | A", [[0xf0], [0x41]]],
  ["F0 | A | 80 80", [[0xf0], [0x41], [0x80, 0x80]]],
  // First continuation valid, second not: one replacement, resume at the bad
  // byte (NOT at the byte after it).
  ["E2 | 82 41", [[0xe2], [0x82, 0x41]]],
  ["F0 | 9F 41", [[0xf0], [0x9f, 0x41]]],
  ["F0 | 9F 98 41", [[0xf0], [0x9f, 0x98, 0x41]]],
  ["F0 9F 98 | 41", [[0xf0, 0x9f, 0x98], [0x41]]],
  // Maximal subpart: held [F7,BC] is TWO replacements, not one.
  ["F7 BC | E7 41", [[0xf7, 0xbc], [0xe7, 0x41]]],
  ["F7 BC | (end)", [[0xf7, 0xbc]]],
  ["F5 | A", [[0xf5], [0x41]]],
  // A surrogate completed across a boundary is still rejected.
  ["ED A0 | 80", [[0xed, 0xa0], [0x80]]],
  // Controls: genuine splits still reassemble, and a still-incomplete tail is
  // held until end() flushes it.
  ["F0 9F | 98 80", [[0xf0, 0x9f], [0x98, 0x80]]],
  ["E2 | 82 (held)", [[0xe2], [0x82]]],
];

for (const [name, chunks] of CASES) {
  const dec = new StringDecoder("utf8");
  const perWrite: string[] = [];
  let all = "";
  for (const c of chunks) {
    const w = dec.write(Buffer.from(c));
    perWrite.push(units(w));
    all += w;
  }
  const fin = dec.end();
  all += fin;
  console.log(
    name + " -> writes=[" + perWrite.join(" | ") + "] end=[" + units(fin) +
      "] total=[" + units(all) + "] len=" + all.length,
  );
}
console.log("done");
