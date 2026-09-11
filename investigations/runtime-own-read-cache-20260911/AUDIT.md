# Source review decisions

Two Astra agents independently reviewed the retained source at `1647916a6`
and then the candidate diff against `b6545b491`. Their work was read-only;
they performed no builds or execution probes. Runtime source is identical
between those bases apart from the preceding diagnostic-only hooks.

Descriptor review found all production string descriptor insert/upsert funnels
in `object/descriptor_state.rs` call `note_descriptor_target` first. That marks
a shaped receiver and advances its semantic generation, which participates in
shape identity. Bulk defineProperties/freeze/seal use those setters. Direct raw
removals are handles, closures, arrays, or ordinary accessor-to-data conversion;
removal cannot introduce an accessor that defeats an earlier absence proof.
GC owner rekeying preserves identity. Non-GC descriptor-owner transfer is used
for real array-header growth, outside the candidate receiver type.

The tail probes the owner's accessor table independently of global accessor
activation before these data-return hooks. Global activation alone is not an
identified counterexample. This proof covers current setter/clear funnels;
future changes that transfer descriptor state between distinct live object
identities must preserve or revoke the semantic-generation contract.

Receiver review found that shape equality distinguishes Ordinary/Class but
does not include the exact class ID. The candidate therefore includes class ID
in its cache identity. It also separates the new table from the existing
write-side producer and direct SSO consumer, because they do not establish the
same full-read proof. Elements backing can attach without a shape transition;
the by-name prelude handles it before the new lookup, exercised by a focused
test with an old cache entry still present.

Mapped arguments own reads normally return before these hooks. Final
construction descriptors provide a semantic fence before arguments registration;
the candidate additionally rejects registered arguments at admission. Boxed
String objects and the externally varying TTY `rows` property are excluded.
Native modules and typed-array prototypes retain their exclusions.

The candidate review found and corrected a class-object case: the outer getter
can call the tail as an intermediate lookup, then continue to static-method or
accessor dispatch after undefined. A cached slot that later becomes undefined
could suppress that continuation. Class-kind receivers are now rejected at
priming. Conversion to class kind already changes ShapeId. No class-kind
intermediate result is treated as a final own-data proof.

Slot admission uses `index < live`, matching `object_field_at_with_live`; the
allocation-capacity floor is not the live bound. The existing tagged slot reader
loads current data and rejects holes. A private stable deletion can retain its
token while writing a hole into the old value slot; re-add appends at the current
logical key count and squeeze mints a new ShapeId. The added test exercises a
real stable-token hole, cache miss, and re-add. The compiled fixture additionally
exercises repeated deletion/re-add churn.

The accessor sabotage relabels an old learned proof with the current
post-descriptor identity and calls the actual by-name getter. It requires the
wrong old data result and a counted hit. This demonstrates the consequence of a
missing fence; it does not literally disable the production invalidator.

No reviewed source invariant predicts cc cache hit rates, conflict behavior or
speedup. Actual paired rows decide whether the added storage, probes and priming
work pay for themselves. This is a bounded candidate review, not an audit of
every runtime subsystem or a new GC-leaf proof.
