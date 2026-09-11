Enable guarded Segmenter record projection by default for eligible loops that
consume only each record's `segment` field. Preserve the original loop body,
evaluation order and real iterator; observable iterator changes and cleanup
use the existing materialization fallback. `PERRY_SEGMENTS_PROJECT=0` retains
the comparison and bisection control, independently of the older SEGVIEW pass.

The full cc workload measured 15.4% lower median paired CPU against the same
compiler with projection disabled, and 13.3% lower against the retained build
(12 alternating pairs each). Against the retained build, median peak RSS rose
0.48%; the maximum paired increase was 7.11%. A separate native census confirms
that projection removes ordinary segment-record construction; instrumented
timings are excluded from these performance results.
