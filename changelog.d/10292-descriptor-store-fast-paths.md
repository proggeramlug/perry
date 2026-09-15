A receiver that carries a property descriptor keeps the object-store fast paths
for its other keys, and a class-less receiver whose prototype was set explicitly
(`new F()`, `Object.create`, `setPrototypeOf`) is vetted per key instead of
being rejected wholesale. `Object.defineProperty` adding a new key now reuses
the learned shape transition.

Descriptor transitions also share their successor shape. The generation that
gives a descriptor install or removal its identity is now a pure function of
the transition — predecessor shape, key and attributes — so every receiver
that repeats the same install lands on the same successor instead of minting a
private one. The per-key descriptor summary is consulted exactly: a set Bloom
bit is confirmed against the descriptor tables rather than surrendering the
fast path, because a store that falls back appends to a private keys array and
takes the receiver off the shared transition chain permanently, costing every
later store on that object as well.

The store-plan cache is vetted the same way. It exists to stop every store
re-running the interception vet, but it refused any receiver carrying a
descriptor at all — so no zod schema object ever held a plan, and each of its
stores re-walked the prototype chain, the class registry and
`Object.prototype`. It is now denied only for the keys a descriptor can
actually cover.

Constructing 300 real zod v4 `z.object` schemas drops from 21.9 to 11.8
billion instructions (-46%). A fixture building 2,000 receivers that define one
non-enumerable property and then assign 40 properties drops from 3.9 to 0.8
billion (-79%), and at 80 properties from 7.7 to 1.8 billion (-76%). The same
fixtures without a descriptor are unchanged.
