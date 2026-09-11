# Completed-unit barrier census preparation

The frozen `fresh_barrier_census.py` is preserved. `fresh_barrier_census_v2.py` adds a separately selected observation of the exact root roundtrip emitted by `function/precise_roots.rs:72` and scalar local slots. It changes no generated/runtime behavior and proves no generational-barrier elision.

`fresh_barrier_batch.py` uses the frozen callsite census's completed-attempt validation and lossless LLVM text reader. It streams one function at a time, preserving full-text hashes and original line offsets, instead of loading an entire large module into Python. Root's successful full-compile marker and emission-to-application identity remain prerequisites outside the static parser.

Run only under the campaign lock, after profiles have completed and the callsite owner has released its conversion window:

```sh
python3 -B fresh_barrier_batch.py --captures compile-v2/cc-bitcode \
  --helper-audit helper-audit.csv --text-root cc-ir-text-v1 \
  --output new-fresh-barrier-census
```

The current bound helper audit yields 80 explicit `CannotCollect` names and exactly 44 reviewed `Unknown` helpers with no collection or JavaScript reentry. The runner refuses a different extra-summary population, and writes both exact name lists and their hashes. These are finite supplied summaries; missing names remain conservative, including LLVM intrinsics not in the explicit set. `AllocNoReentry` is not treated as no collection.

Both narrow and extended observations use only 64-bit identity casts: i64/double bitcasts, pointer-to-i64 and i64-to-pointer. V1 accepted arbitrary cast widths; V2 explicitly declines truncating pointer conversions. The extra observation admits only this exact one-operand tied asm, with an optional ordinary attribute-group reference:

```llvm
%same = call i64 asm "", "=r,0"(i64 %bits) #0
```

Any different template, constraints, side-effect marker, operand count or type remains an unknown call. A scalar alloca qualifies only if every textual use of its address is its own declaration or a direct, nonvolatile, same-type load/store. Address copies, address stores/passing, GEP, lifetime intrinsics, atomic/volatile accesses and other uses decline that slot. Alloca-use analysis is linear in textual operands; it does not rescan every instruction for every slot.

A known value stored into a qualifying slot can be recovered by a subsequent direct load. Overwrites clear that fact. Every possibly collecting call clears **both** SSA and saved-slot facts; every CFG join also clears both. Merely rooting a value does not keep it fresh across a collection. Exact tied asm preserves an existing identity and establishes none when its operand is unknown.

`functions.jsonl.gz` retains each admitted/excluded function, its barrier rows, narrow counts, extended counts, additional sites under the 44-helper hypothesis, the exact asm/alloca ledger, and original IR lines. The summary includes the complete encountered/admitted/excluded function denominator, complete/incomplete attempt identities, unresolved-parent count, and the immediate defining opcode of unresolved parent values. An opcode describes where the operand came from; it does not identify a runtime cause by itself.

Exit 2 and `partial-static-barrier-census` preserve usable admitted rows while keeping excluded functions/failed units unavailable. Partial unit observations are never reported as a complete denominator. The denominator contains only reachable, explicit calls to the three recognized heap barrier ABIs in admitted functions. Hidden runtime setters, inlined generation tests, already-omitted barriers and unsupported parent representations are outside it.

Fresh returns can be old or already published. Reference-layout notes, incremental marking, physical spill owners and string sharing remain separate. The constructor source at `lower_call/ctor_prologue_stores.rs:83` expressly retains barriers for fresh unpublished fields because generation/incremental conditions still matter. A zero observed lower bound says nothing about all allocation/barrier work.

Nine focused local controls pass: three streaming/line-offset/exclusion controls and six exact-alias controls. The alias controls require a positive slot→load→tied-asm path, then reject collection, slot escape, volatile/GEP uses, overwrite, pointer truncation, other asm and CFG joins. Removing the tied-asm identity rule breaks the positive assertion; incorrectly treating a collecting call as noncollecting breaks the negative assertion. These are synthetic observer tests. **A real emitted positive construction path is still required and pending the locked fixture/full-module inspection.**
