Route ordinary builtin RegExp.test calls with heap-string inputs directly to
the existing matcher before generic method-call argument and collector-handle
vectors are constructed. Keep generic dispatch for overridden methods,
accessors, changed prototypes, and inputs requiring conversion. Preserve the
existing matching, lastIndex, and recursion behavior.

Validate the canonical prototype method against its actual property key after
an object-shape change, so moving a different key into the recorded slot cannot
retain the earlier proof.
