**The hot shape-table consumers read descriptor FIELDS instead of lifting the
whole ~56-byte record.**

`shape_descriptor_by_id` returns `ShapeDescriptor` by value, and an
exact-count uprobe attribution of `cc --help` measured 3,095,503 such lifts
per run — 1.90% of the symbolized profile plus a share of `__memmove` — the
majority from callers that consume one or two fields of the copy. The no-copy
closure accessor (`shape_descriptor_field_by_id`, "same lookup, same
validation, four bytes instead of forty-eight") already existed with exactly
one caller (`object_live_slot_count`), wired in and then missed everywhere
else.

Converted by measured caller share: `object_keys_array` (~45% of all lifts,
across its 153 call sites — the by-name get/set tails, the own-key family,
the URLSearchParams screen), `is_class_object_ptr` (14.6% with its inlined
copy in the class-static write mirror; `typeof`/`new`/`instanceof` route
through it), the typed-feedback class-field guard contracts (6.5%, each of
which paid TWO lifts — an existence probe via `object_shape_id` and a second
for the fields — now ONE field probe), the get-IC prime path (4.8%),
`object_key_matches_field` (2.9%), the own-data overwrite fast path (2.1%,
also two lifts merged into one), and the GC store-barrier's
`layout_note_slot` (1.3%, now the existing `object_live_slot_count`).

Left copying, deliberately: the shape publication/mutation paths (~15% of
lifts) consume most of the record — lineage carries `semantic_generation`,
`object_kind`, `hole_count`, `keys` and both counts — and every remaining
caller is below 1%. `object_shape_id`'s outlined form measured zero calls on
`cc --help` and keeps the copying spelling.

The conversion closures are pure field projections (a field or a small tuple)
— no re-entry into the shape table, no allocation — so the way-cache hit
arm's read through the boxed record stays sound.
