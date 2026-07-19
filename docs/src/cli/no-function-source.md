# Function source & `toString` (`--no-function-source`)

Perry embeds each function's original source into the binary so
`Function.prototype.toString()` can return it. That source is roughly **1× the
bundle size** (more with nested functions, since an enclosing function's slice
already contains its inner functions' text). For an app that never inspects
function bodies — nearly every CLI and TUI — it is dead weight in the binary and,
once touched, in RSS.

Perry handles this in two layers.

## 1. Source is never copied to the heap (always on)

Even when source is kept, Perry does **not** copy it onto the GC heap. The source
stays in read-only rodata and is materialized to a `String` lazily, only on the
first `toString()` call for that function. So unused function source costs
essentially **zero resident memory** — the pages stay cold. This is automatic and
has no behavior change.

## 2. Source can be dropped from the binary entirely (auto by default)

Dropping the source removes the rodata *and* the per-function registration from
the binary — a smaller binary on top of the RSS win. When a function's source has
been dropped, `Function.prototype.toString()` returns a valid, spec-permitted
placeholder:

```js
function myFunction() { /* source unavailable */ }
```

Function `name` and arity behave as before. The `/* source unavailable */` body
is deliberate: it is **not** `{ [native code] }`, so it does not false-positive
the common native-detection sniff (`fn.toString().includes('[native code]')`,
e.g. lodash's `isNative`). This is sanctioned by the ES2019
`Function.prototype.toString` revision via `HostHasSourceTextAvailable` — a host
may report that it did not retain source, and the result only needs to parse as a
function. Genuine built-ins still report `[native code]`.

### Modes

| Mode | Behavior |
| --- | --- |
| **default (auto)** | Elide source **unless** the entry bundle looks like it reads function bodies via `toString`. |
| `--keep-function-source` | Always keep full source (exact `toString`). |
| `--no-function-source` | Always elide (also `PERRY_NO_FUNCTION_SOURCE=1`). |

**Auto-detection** scans the entry bundle for signals that it reads function
bodies — `new Function(`, `Function.prototype.toString`, `.toString.call`,
`.toString.apply` — and keeps source if any are present. This is the same kind of
compile-time inference Perry already does for the runtime feature set. It scans
the **entry file**, which for a bundled app (Perry's typical deployment) is the
whole program; a multi-module project whose *non-entry* modules parse function
bodies should pass `--keep-function-source`.

Auto is conservative — false positives merely keep source (safe). The residual
risk is a false negative: a program that dynamically parses a function body with
none of the tell-tale markers. If your app does that, use
`--keep-function-source`.

### When NOT to elide

Keep source (`--keep-function-source`, or rely on auto detecting it) if your app
or any dependency:

- extracts parameter names by parsing `fn.toString()` (Angular-style DI),
- reserializes functions — `new Function(fn.toString())`, or posts a function's
  source to a worker,
- otherwise reads a function's **body** text.

Name-, arity-, and native-detection-based logic are all unaffected by elision.

### Examples

```bash
perry compile app.js -o app                          # auto (recommended)
perry compile app.js -o app --no-function-source     # force elide
perry compile app.js -o app --keep-function-source   # force keep
PERRY_NO_FUNCTION_SOURCE=1 perry compile app.js -o app
```

Toggling the mode is part of the object-cache key, so switching cleanly
re-compiles the affected modules.
