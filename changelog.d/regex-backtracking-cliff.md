### Performance

- **A capture group no longer turns a pattern into a ReDoS.**
  `repeat_matcher::capture_layout` takes a pattern off the linear `regex`
  engine when ECMA-262's RepeatMatcher capture semantics are observable — a
  capture group directly under a quantifier, or a capture inside a negative
  lookaround. That routing is a correctness requirement (the linear engine
  keeps the last value of a capture nested in a quantified group; the spec
  clears it on every iteration), but the engine it routes to, `regress`, is a
  classical backtracker with no step budget. So adding parentheses was enough
  to fall off a linear-time path onto an exponential one:

  | pattern | node | perry (before) | perry (after) |
  |---|---|---|---|
  | `/^(a+)+$/.test("a"×28 + "!")` | 2,627 ms | **8,139 ms** | see below |
  | `/^(?:a+)+$/.test(…)` (same language, no capture) | 2,301 ms | 0 ms | 0 ms |

  7.2 % of the 2,803 distinct regex literals in the claude-code bundle take
  that route, including shapes like `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`.

  The two engines accept exactly the same LANGUAGE for a pattern they both
  compile; they disagree only about which capture assignment to report. So the
  linear program is asked first (`linear_rules_out_match`), and when it proves
  there is no match at or after the search offset — which is what every ReDoS
  input is, a subject that ALMOST matches and then fails — the backtracker is
  never entered. Every `&str`-subject entry point goes through
  `lookup_repeat_matcher_for`: `test`, `exec`, `match`, `matchAll`, `search`,
  `split` and `replace` with a string replacement. The gate disables itself
  where the linear engine has no opinion (a pattern it could not compile holds
  the never-match placeholder), which is exactly the lookaround shapes.

  This removes the reachable exponential case; it does not BOUND the worst
  case. A real step budget has to be counted by the backtracker, and `regress`
  has none today (`fancy-regex`, by contrast, ships `backtrack_limit:
  1_000_000`). That remains open and is tracked with the engine evaluation.
  (`quantified_capture_pattern_does_not_backtrack_on_a_non_matching_subject`)
