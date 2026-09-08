Add an inactive managed native-wrapper substrate using the shared registration
core. Publication consumes an exact Wrapper lease, canonicalizes weakly per JS
thread, and retains immutable identity after native retirement. Exact operations
hold independent leases through their closure. GC cleanup and JS-thread teardown
release native metadata independently of explicit resource disposal.

Runtime-linked fixtures cover domain/type rejection, ownership balance, worker
retirement, disposal, publication ordering, matching weak removal, teardown, and
an acyclic owner's moving child slot. A source/sabotage runner checks exact
assertions and rejects failed compilation as mutation evidence. Production timer
publication, scheduling, dispatch, and other receiver families remain unchanged.
