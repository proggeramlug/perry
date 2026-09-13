Implemented Option 2 in **699ae8f665**.

- **Flat primitive arrays:** compact at **1,024 value nodes or 64 KiB** of string content.
- **Other JSON-compatible literals, including records:** compact at **24,576 nodes or 1 MiB** of key/string content. Mid-size records keep ordinary lowering and static property layouts.

Cutoff calibration used the audit's exact `id/name/tags/w` record-array shape. Ordinary lowering took **475.17 s at 4,800 records** (33,601 nodes / 307,740 source bytes), and **timed out at 600 s at 6,400 records** (44,801 nodes / 412,540 bytes). At 6,400, emission finished in 4.5 s with about 85.1 MiB estimated IR; LLVM stalled on the remaining unit. The new rule compiles these in **0.35 s / 0.37 s**. It switches this shape at **3,511 records**, 27% below the eight-minute case and 45% below the timeout; the general node/text thresholds are 24× / 16× the primitive thresholds.

Five interleaved Linux A/B runs with the final compiler and matching archives:

| Hot loop | Ordinary/main control | Revised |
| --- | ---: | ---: |
| Separate 2,000-number array | 71 ms | 71 ms |
| Separate 400 typed records | 295 ms | 294 ms |
| Combined audit file: numbers | 290 ms | 291 ms |
| Combined audit file: records | 292 ms | 291 ms |

**Re-audit caveat: the requested combined-file numeric speedup is not retained.** The old broad rule measured 71 ms / 938 ms in that file. The revision fixes the record-read regression, but ordinary record initialization pushes the same unit over LLVM's existing 100k-instruction O0 machine-code limit (~622k instructions), slowing the numeric loop too. HIR confirms that its numeric array still uses `JsonParse`. Separate number-only entrypoints show no intrinsic runtime gain on this host. I kept this revision focused on the two-tier rule and documented this limitation rather than claiming both old A/B wins; initialization/unit splitting would be additional codegen work.

The preserved **4,623,800-byte / 213-provider** OpenCode define compiles and links in **1.52 s**, printing **213**. The installed snapshot has refreshed to **4,637,074 bytes**, still 213 providers; it takes **1.54 s** and also prints **213**. The actual `packages/core/src/models-dev.ts` regenerated in **10.6 s** with the installed `perry.json`. The surrounding Effect graph hit the 600 s diagnostic limit; resuming the cache completed **621/621 native modules**, exit 0, in **60.42 s**.

All via `./remote.sh`: **411 HIR tests passed, 1 ignored; 4 compile/run regressions passed; the 6,000-level deep-literal test passed; cargo fmt, file-size policy, test registration and Node-version consistency passed.** Tests, CLI docs and changelog now describe both tiers. The PR description contains the commands and results; `benchmarks/large_json_literals/` contains the reproducible generator and measurement notes. No versions or CHANGELOG.md changed.
