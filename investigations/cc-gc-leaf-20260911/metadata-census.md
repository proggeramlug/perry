# Complete PGCM v5 metadata census

`metadata_census.py` reads the linked ELF's entire `.perry_gcmap` and emits every function entry, statepoint return PC and live-set location. It reads metadata sections only. It neither executes the binary nor estimates CPU savings.

Run under the campaign lock, with an already identity-bound application and a new output directory:

```sh
python3 -B investigations/cc-gc-leaf-20260911/metadata_census.py --elf /path/to/exact-app --output /path/to/new-owned-output
```

Root supplied retained section offset `0x15359760`, size `0x16e5b90`; those values are context, not parser constants. The parser derives both from that ELF's section table. No real campaign ELF has been parsed by this agent. Local verification used only small synthetic byte fixtures.

## Source contract

The authoritative source files and hashes are bound in `metadata-census-receipt.json`:

- `crates/perry-codegen/src/gc_map.rs:721`: `encode_slots` emits register tags and signed wrapping deltas; `:758` emits per-function repeat chains and derived-base indices; `:1007` describes the header; `:1063` derives table widths/total length and emits alignment and arrays.
- `crates/perry-runtime/src/gc/roots/stack_maps_decode.rs:30`: concatenated-blob walk, pointer width, checked table layout, stream-offset reconciliation and return-PC addition.
- `crates/perry-runtime/src/gc/roots/stack_maps_lazy.rs:98`: shared `RecordWalk`; `:203`: shared `SlotIter`.
- `state-map.md`: integration context and independent source map.

The exact little-endian layout is:

| Bytes | Meaning |
| --- | --- |
| 0–15 | `PGCM`, version `5`, reserved `0`, u16 flags, u32 function count, u32 total length |
| Next | One address/u32 stack-size/u32 record-count entry per function; flags bit0 selects address width 8 versus 4 |
| Next | One u32 stream offset per function |
| Next | One u32 instruction offset per record, ordered by function |
| Remaining | Varint record stream |

Each new blob begins at an eight-byte boundary. Padding must be zero. ELF integration accepts linked ELF64 little-endian x86_64/AArch64; the isolated PGCM decoder also has a tested four-byte address mode. The ELF wrapper does not accept ELF32 or relocatable object files.

A full record starts with `(root_count << 2) | (has_derived << 1)`. Word `1` repeats the previous full payload within the same function. Each slot encodes `(zigzag_i32_delta << 2) | tag`; tags 0 and 1 mean literal DWARF registers **29 and 31**, including on x86_64. Tag 2 is followed by an explicit u16 register varint. Offsets accumulate with signed i32 wrapping. A derived list follows its count and all base indices, then starts a new offset-delta chain. Every base index must refer to that record's root list.

The parser validates every read against the current blob, stream offsets against its sequential walk, and exact final stream consumption. It refuses unknown flags/versions, noncanonical varints, noncanonical repeat words, zero-length derived lists marked present, nonzero padding, width truncation and trailing unparsed bytes. These are stricter checks for the current emitter's canonical output; the runtime decoder's more permissive resynchronization is not an invitation to silently skip bytes in a census.

## Outputs and count interpretation

- `summary.json`: emitted only on complete success; section bytes reconcile exactly to blob bytes plus padding. It includes blob/function/record counts, root/derived count distributions, ELF identity before/after, bounded-read receipts and compressed-output hashes.
- `functions.jsonl.gz`: one row per function-table entry, its stack size, record count, distributions, PC range and all `STT_FUNC` symbols whose addresses match exactly. Missing exact symbols are counted; no nearest-symbol guess is substituted.
- `records.tsv.gz`: one row per static record with linked return PC, instruction offset, function ID, root/derived counts, repeat flag and payload ID. Duplicate function addresses and duplicate return PCs are preserved.
- `payloads.jsonl.gz`: one row per encoded full payload. Roots are `[DWARF register, signed frame offset]`; derived locations are `[base-root index, DWARF register, signed frame offset]`. Repeat rows refer to the same payload ID.

`root_location_occurrences` and `derived_location_occurrences` sum the live locations for **every record**, including repeats. `encoded_root_locations` and `encoded_derived_locations` count the locations physically encoded in full payloads once. Neither is the number of dynamically executed spills, loads or collections. Zero-root records and zero-record function entries remain explicit. `unique_function_addresses` is separate from table-entry count.

The record PC is exactly `function_address + instruction_offset`, with overflow rejected. Coordinates are linked ELF virtual addresses. For perf comparisons, root must use the recorded executable mmap to establish the process load bias. This script never guesses ASLR bias, translates a callchain address into a sampled IP, or counts callee CPU as caller spill cost.

## ELF reads and relocations

The reader opens only the ELF header, section headers/names, full symbol tables and their string tables, `.perry_gcmap`, and supported relocation tables. Executable section ranges come from headers; executable bytes are never read. Each read has an offset/length/SHA256 receipt. The whole binary is not hashed. Device, inode, file size, mtime and ctime are checked across the read; inode and nanosecond identities are strings.

The allowed relocation-section names are `.rela.dyn`, `.rel.dyn`, `.rela.perry_gcmap` and `.rel.perry_gcmap`. For words touching the GC-map section, only symbol-free `R_X86_64_RELATIVE` (8) or `R_AARCH64_RELATIVE` (1027) is accepted. RELA supplies the explicit signed addend, interpreted modulo u64; REL supplies the raw word as implicit addend. Both yield the linked VMA with load bias zero. Every affected word must be an exact function-address field. Partial, overlapping, duplicate and other-field writes fail.

Other relocation sections are skipped only when their nonzero `sh_info` explicitly targets a different section. An unknown dynamic relocation section with no distinct target fails. Packed RELR fails explicitly. Unsupported relocation types into this section fail instead of producing guessed PCs. Raw and resolved GC-map hashes and the applied-relative count are retained. Function addresses must lie in executable sections and return PCs must stay in the same section (the section's end is permitted as a return address).

An existing output directory is never overwritten. On failure, partial streams remain with `failure.json` and no complete `summary.json`. Consumers must require the complete marker before aggregating any rows.

## Executed local witnesses

```sh
python3 -B -W error::ResourceWarning -m unittest test_metadata_census -v
```

All **13** tests pass. They cover exact concatenated layout, 32/64-bit widths, duplicate symbol aliases/PCs, repeat reset at function boundaries, derived bases, signed-delta/register decoding, header/table/stream corruption, truncation, ELF header/symbol bounds, supported and rejected relocations, bounded reads excluding `.text`, output preservation and sabotage controls.

The independently constructed golden section has a 107-byte first blob, five padding bytes and a 42-byte second blob: **154 bytes**, two blobs, four function entries, three with records, three distinct function addresses and five records. The root counts are `[3,3,0,1,1]`: eight logical occurrences and five encoded locations. Derived counts are `[1,1,0,0,0]`: two logical occurrences and one encoded location. Four full payloads and one repeat account for all five records. Return PCs are `0x1010,0x1020,0x1030,0x1010,0x3008`.

One sabotage changes the expected version and is rejected. Another changes a valid repeat byte into an empty full payload: parsing still succeeds, but logical root occurrences fall from eight to five, so the original required count assertion fails. This separates format rejection from a counter that must detect changed content. No native build, campaign ELF parse, timing or box work was performed.
