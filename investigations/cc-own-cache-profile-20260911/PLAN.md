# Profile the measured own-read-cache candidate

The preceding comparison retained a modest runtime candidate: command CPU minima
1.22 → 1.19 s, with a 2.83× remaining Node gap. This study locates the remaining
cost before choosing another implementation. It changes no compiler or runtime
behavior, and does not reopen regex or GC-point/barrier elision.

Take three startup/actual-two-Read/stream profiles of binary SHA
`42bfb149007b5c79d11b11d6acb7ad16008932945a78efe700c19bec9d3e513a`,
using the unchanged validated `profile_workload_v4.py`. Bind each capture to its
own PID/start time, exact executable and maps. Preserve `cycles:u` at 999 Hz,
monotonic phase boundaries, fixed CPU set, sandbox HOME/configuration, mock
evidence and independently reconciled integer self totals. The campaign lock
covers sampling and subsequent analysis. No build, BPF entry probes or runtime
counters run with the profile.

Rank exact symbols and sampled instructions separately for startup and command.
Resolve sampled application addresses against this candidate's ELF rather than
reuse an earlier binary's addresses. Report all three rows and sampled-period
denominators; self shares are not execution counts or predicted savings. The
previous ordinary CPU comparison remains the performance result. New profiles
are attribution evidence, not another speedup comparison.

Choose the next mechanism only after inspecting the dominant remaining source
and machine regions. If no sufficiently large opportunity is demonstrated, say
so. Preserve all failed attempts; do not retry a completed row for a nicer result.
