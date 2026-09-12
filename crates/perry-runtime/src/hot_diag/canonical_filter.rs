//! Canonical-handle classification census.
//!
//! `is_canonical_handle_addr` is not reached only from code that asks about
//! native wrappers: `value::addr_class::is_above_handle_band`,
//! `is_handle_band` and `is_small_handle` all embed it, so every ordinary heap
//! address whose numeric arm cannot decide the answer consults the
//! `CANONICAL_HANDLE_ADDR_FILTER` Bloom filter, and a filter pass continues
//! into `canonical_handle_parts_from_addr → handle_from_addr →
//! gc_malloc_header_is_tracked`. The caller census measured that registry
//! helper at 49,565,811 command calls, 99.844% negative; the filter's occupancy
//! grows from 169–181 of 1,024 bits after startup to 878–931 after one command.
//! This instrument measures the join between those two facts directly: how many
//! classifications happen, how many the filter admits, and how many of the
//! admitted ones are real canonical wrappers.
//!
//! Diagnostics only. Nothing branches on these counters, and when
//! `PERRY_CANONICAL_DIAG` is unset every probe is one relaxed load.

use super::{sink_from_env, write_sink, Sink};
use std::fmt::Write as _;
use std::sync::atomic::{AtomicBool, AtomicI64, AtomicU64, Ordering};
use std::sync::{Mutex, OnceLock};
use std::time::{Duration, Instant};

const SNAPSHOT_EVERY: u64 = 65536;

/// Entries to `is_canonical_handle_addr` — one per address the hot predicates
/// could not decide numerically.
static CALLS: AtomicU64 = AtomicU64::new(0);
/// Entries whose three filter bits were all set, so the registry path ran.
static FILTER_PASS: AtomicU64 = AtomicU64::new(0);
/// Filter passes that resolved to a live canonical wrapper.
static RESOLVED: AtomicU64 = AtomicU64::new(0);
static EVENTS: AtomicU64 = AtomicU64::new(0);
static CANONICAL_SINK: OnceLock<Option<Sink>> = OnceLock::new();
static CANONICAL_ON: AtomicBool = AtomicBool::new(false);
static LAST_DUMP: Mutex<Option<Instant>> = Mutex::new(None);

/// Admissions and retirements of canonical wrapper addresses, and the live
/// table population. These sit on wrapper creation/retirement, not on the
/// classification path, so they are maintained unconditionally: a dump is
/// worthless if the live population it reports only started counting when the
/// instrument armed.
static ADMITS: AtomicU64 = AtomicU64::new(0);
static RETIRES: AtomicU64 = AtomicU64::new(0);
static LIVE: AtomicI64 = AtomicI64::new(0);

fn canonical_sink() -> &'static Option<Sink> {
    CANONICAL_SINK.get_or_init(|| {
        let sink = sink_from_env("PERRY_CANONICAL_DIAG");
        CANONICAL_ON.store(sink.is_some(), Ordering::Relaxed);
        sink
    })
}

/// One relaxed load after the environment has been parsed once.
#[inline]
pub fn canonical_census_on() -> bool {
    if CANONICAL_SINK.get().is_none() {
        canonical_sink();
    }
    CANONICAL_ON.load(Ordering::Relaxed)
}

/// One classification entry. The caller has already tested
/// [`canonical_census_on`].
#[inline]
pub fn canonical_census_note_call() {
    CALLS.fetch_add(1, Ordering::Relaxed);
}

/// One filter pass, and whether it resolved to a real canonical wrapper.
/// A pass that does not resolve is a registry query with no answer in it.
#[inline]
pub fn canonical_census_note_pass(resolved: bool) {
    FILTER_PASS.fetch_add(1, Ordering::Relaxed);
    if resolved {
        RESOLVED.fetch_add(1, Ordering::Relaxed);
    }
    maybe_dump();
}

/// A wrapper address entered the filter and the identity table.
pub fn canonical_census_note_admit(replaced: bool) {
    ADMITS.fetch_add(1, Ordering::Relaxed);
    if !replaced {
        LIVE.fetch_add(1, Ordering::Relaxed);
    }
}

/// A wrapper identity left the table. The filter keeps its bits — that
/// asymmetry is the subject of this census.
pub fn canonical_census_note_retire() {
    RETIRES.fetch_add(1, Ordering::Relaxed);
    LIVE.fetch_sub(1, Ordering::Relaxed);
}

#[inline]
fn maybe_dump() {
    let event = EVENTS.fetch_add(1, Ordering::Relaxed);
    if event != 0 && event % SNAPSHOT_EVERY != 0 {
        return;
    }
    let Ok(mut last) = LAST_DUMP.lock() else {
        return;
    };
    if last.is_some_and(|instant| instant.elapsed() < Duration::from_secs(1)) {
        return;
    }
    *last = Some(Instant::now());
    if let Some(sink) = canonical_sink() {
        write_sink(sink, &render());
    }
}

fn render() -> String {
    let (bits_set, capacity_bits) = crate::native_handle::canonical_filter_occupancy();
    let calls = CALLS.load(Ordering::Relaxed);
    let passes = FILTER_PASS.load(Ordering::Relaxed);
    let resolved = RESOLVED.load(Ordering::Relaxed);
    let mut out = String::with_capacity(384);
    let _ = writeln!(
        out,
        "[canonical-diag] calls={calls} filter_pass={passes} resolved={resolved} \
         pass_unresolved={} admits={} retires={} live={} bits_set={bits_set} \
         capacity_bits={capacity_bits}",
        passes.saturating_sub(resolved),
        ADMITS.load(Ordering::Relaxed),
        RETIRES.load(Ordering::Relaxed),
        LIVE.load(Ordering::Relaxed),
    );
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The counters must be able to separate "the filter rejected" from "the
    /// filter admitted and the registry found nothing" — a census that cannot
    /// tell those apart cannot price the fix.
    #[test]
    fn pass_and_unresolved_are_distinguishable() {
        CALLS.store(0, Ordering::Relaxed);
        FILTER_PASS.store(0, Ordering::Relaxed);
        RESOLVED.store(0, Ordering::Relaxed);
        canonical_census_note_call();
        canonical_census_note_call();
        canonical_census_note_call();
        canonical_census_note_pass(false);
        canonical_census_note_pass(true);
        assert_eq!(CALLS.load(Ordering::Relaxed), 3);
        assert_eq!(FILTER_PASS.load(Ordering::Relaxed), 2);
        assert_eq!(RESOLVED.load(Ordering::Relaxed), 1);
        let text = render();
        assert!(text.contains("calls=3"), "{text}");
        assert!(text.contains("filter_pass=2"), "{text}");
        assert!(text.contains("pass_unresolved=1"), "{text}");
    }

    /// A replaced identity must not inflate the live population, and a
    /// retirement must lower it. Getting this wrong would make a saturated
    /// filter look justified by its own live set.
    #[test]
    fn live_population_tracks_new_identities_only() {
        LIVE.store(0, Ordering::Relaxed);
        canonical_census_note_admit(false);
        canonical_census_note_admit(false);
        canonical_census_note_admit(true);
        assert_eq!(LIVE.load(Ordering::Relaxed), 2);
        canonical_census_note_retire();
        assert_eq!(LIVE.load(Ordering::Relaxed), 1);
    }
}
