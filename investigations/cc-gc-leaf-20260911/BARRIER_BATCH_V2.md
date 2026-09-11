# Barrier batch with the final 48-summary audit

Use `fresh_barrier_batch_v2.py` with `--helper-audit audit-v2/helper-audit.csv`. This preserves the 44-summary batch and its preparation receipt. The only batch delta is the required population count and corresponding output filename (`extra-48.json`). All alias rules and limitations in BARRIER_BATCH.md remain unchanged.

The final audit contains 80 explicit CannotCollect names and 48 reviewed Unknown/no-Perry-GC/no-JavaScript summaries. Cold native allocation is still possible and is not claimed removed. Source receipt: audit-v2/source-receipt.json.

No actual profile/barrier analysis has yet run. Profiles and independent perf-self reconciliation remain ahead of this longer static pass. A real emitted positive remains required.
