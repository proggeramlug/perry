//! Inline unit tests extracted from `timer.rs` (#8354 follow-up to #8328).
//!
//! `timer.rs` crossed the 2000-line cap enforced by
//! `scripts/check_file_size.sh` at 2001 lines. These are the same tests,
//! moved verbatim; the `#[path]` + `mod` declaration at the end of
//! `timer.rs` keeps them in the `crate::timer` module so every `super::`
//! and private-item reference still resolves.

use super::*;

#[cfg(test)]
const TEST_CALLBACK_TIMER_ID: i64 = i64::MIN + 101;
#[cfg(test)]
const TEST_INTERVAL_TIMER_ID: i64 = i64::MIN + 102;

#[cfg(test)]
#[derive(Debug, Default)]
pub(crate) struct TestTimerScannerSnapshot {
    pub timeout_promise_ptr: usize,
    pub timeout_value_bits: u64,
    pub callback_ptr: usize,
    pub callback_arg_bits: u64,
    pub callback_context_store_bits: u64,
    pub interval_callback_ptr: usize,
    pub interval_context_store_bits: u64,
}

#[cfg(test)]
pub(crate) fn test_seed_timer_scanner_roots(
    promise: *mut Promise,
    value: f64,
    callback: i64,
    arg: f64,
    context_store: f64,
) {
    let context = crate::async_context::test_snapshot_with_store(context_store);
    let deadline = Instant::now() + Duration::from_secs(86_400);
    TIMER_QUEUE.lock().unwrap().push(Timer {
        // #6185: test scaffolding runs on the primary agent.
        owner: crate::agent::current_agent(),
        deadline,
        promise,
        value,
        has_ref: true,
    });
    CALLBACK_TIMERS.lock().unwrap().push(CallbackTimer {
        // #6185: test scaffolding runs on the primary agent.
        owner: crate::agent::current_agent(),
        id: TEST_CALLBACK_TIMER_ID,
        kind: CallbackTimerKind::Timeout,
        deadline,
        delay_ms: 86_400_000,
        callback,
        args: vec![arg],
        context: context.clone(),
        async_id: 0,
        trigger_async_id: 0,
        cleared: false,
    });
    INTERVAL_TIMERS.lock().unwrap().push(IntervalTimer {
        // #6185: test scaffolding runs on the primary agent.
        owner: crate::agent::current_agent(),
        id: TEST_INTERVAL_TIMER_ID,
        callback,
        interval_ms: 86_400_000,
        next_deadline: deadline,
        args: Vec::new(),
        context,
        async_id: 0,
        trigger_async_id: 0,
        cleared: false,
    });
}

#[cfg(test)]
pub(crate) fn test_seed_many_timeout_roots(values: &[f64]) {
    let deadline = Instant::now() + Duration::from_secs(86_400);
    let mut q = TIMER_QUEUE.lock().unwrap();
    q.clear();
    for &value in values {
        q.push(Timer {
            // #6185: test scaffolding runs on the primary agent.
            owner: crate::agent::current_agent(),
            deadline,
            promise: std::ptr::null_mut(),
            value,
            has_ref: true,
        });
    }
}

#[cfg(test)]
pub(crate) fn test_clear_all_timer_scanner_roots() {
    TIMER_QUEUE.lock().unwrap().clear();
    CALLBACK_TIMERS.lock().unwrap().clear();
    INTERVAL_TIMERS.lock().unwrap().clear();
}

#[cfg(test)]
pub(crate) fn test_timer_scanner_snapshot() -> TestTimerScannerSnapshot {
    let mut snapshot = TestTimerScannerSnapshot::default();
    if let Some(timer) = TIMER_QUEUE.lock().unwrap().last() {
        snapshot.timeout_promise_ptr = timer.promise as usize;
        snapshot.timeout_value_bits = timer.value.to_bits();
    }
    if let Some(timer) = CALLBACK_TIMERS
        .lock()
        .unwrap()
        .iter()
        .find(|timer| timer.id == TEST_CALLBACK_TIMER_ID)
    {
        snapshot.callback_ptr = timer.callback as usize;
        snapshot.callback_arg_bits = timer.args.first().copied().map(f64::to_bits).unwrap_or(0);
        snapshot.callback_context_store_bits =
            crate::async_context::test_snapshot_first_store(&timer.context)
                .map(f64::to_bits)
                .unwrap_or(0);
    }
    if let Some(timer) = INTERVAL_TIMERS
        .lock()
        .unwrap()
        .iter()
        .find(|timer| timer.id == TEST_INTERVAL_TIMER_ID)
    {
        snapshot.interval_callback_ptr = timer.callback as usize;
        snapshot.interval_context_store_bits =
            crate::async_context::test_snapshot_first_store(&timer.context)
                .map(f64::to_bits)
                .unwrap_or(0);
    }
    snapshot
}

#[cfg(test)]
pub(crate) fn test_callback_timer_snapshot(timer_id: i64) -> Option<(usize, u64)> {
    CALLBACK_TIMERS
        .lock()
        .unwrap()
        .iter()
        .find(|timer| timer.id == timer_id)
        .map(|timer| {
            (
                timer.callback as usize,
                timer.args.first().copied().map(f64::to_bits).unwrap_or(0),
            )
        })
}

#[cfg(test)]
pub(crate) fn test_clear_timer_scanner_roots(promise_before: usize, promise_after: usize) {
    TIMER_QUEUE.lock().unwrap().retain(|timer| {
        let promise = timer.promise as usize;
        promise != promise_before && promise != promise_after
    });
    CALLBACK_TIMERS
        .lock()
        .unwrap()
        .retain(|timer| timer.id != TEST_CALLBACK_TIMER_ID);
    INTERVAL_TIMERS
        .lock()
        .unwrap()
        .retain(|timer| timer.id != TEST_INTERVAL_TIMER_ID);
}

#[cfg(test)]
mod drain_expired_tests;

#[cfg(test)]
mod expired_batch_order_tests {
    use super::{order_expired_callback_batch, CallbackTimer, CallbackTimerKind};
    use std::time::{Duration, Instant};

    fn timer(id: i64, kind: CallbackTimerKind, base: Instant, delay_ms: u64) -> CallbackTimer {
        CallbackTimer {
            // #6185: test scaffolding runs on the primary agent.
            owner: crate::agent::current_agent(),
            id,
            kind,
            deadline: base + Duration::from_millis(delay_ms),
            delay_ms,
            callback: 0,
            args: Vec::new(),
            context: crate::async_context::AsyncContextSnapshot::default(),
            async_id: 0,
            trigger_async_id: 0,
            cleared: false,
        }
    }

    /// #6287 case 1: the batch fires in DEADLINE order, not creation order —
    /// a 5 ms timer created after a 10 ms one still fires first. Ground truth
    /// from node: `setTimeout(f,10); setTimeout(g,5)` runs g then f.
    #[test]
    fn expired_timeouts_fire_in_deadline_order() {
        let base = Instant::now();
        let mut batch = vec![
            timer(1, CallbackTimerKind::Timeout, base, 10),
            timer(2, CallbackTimerKind::Timeout, base, 5),
            timer(3, CallbackTimerKind::Timeout, base, 1),
        ];
        order_expired_callback_batch(&mut batch);
        let ids: Vec<i64> = batch.iter().map(|t| t.id).collect();
        assert_eq!(ids, vec![3, 2, 1], "earliest deadline first");
    }

    /// Same-deadline timers must STILL fire in creation order — the ordering
    /// Perry already got right, preserved by the sort being stable.
    #[test]
    fn same_deadline_timeouts_keep_creation_order() {
        let base = Instant::now();
        let mut batch = vec![
            timer(1, CallbackTimerKind::Timeout, base, 3),
            timer(2, CallbackTimerKind::Timeout, base, 3),
            timer(3, CallbackTimerKind::Timeout, base, 3),
        ];
        order_expired_callback_batch(&mut batch);
        let ids: Vec<i64> = batch.iter().map(|t| t.id).collect();
        assert_eq!(ids, vec![1, 2, 3], "stable sort keeps creation order");
    }

    /// #6287 case 2: setImmediate runs in the CHECK phase, so an expired
    /// setTimeout fires ahead of an immediate scheduled earlier — and this is
    /// exactly why a naive sort by deadline alone is wrong (an immediate's
    /// deadline is ~now, so it would sort ahead of the timeout). Immediates
    /// keep FIFO order among themselves.
    #[test]
    fn expired_timeouts_precede_immediates_which_stay_fifo() {
        let base = Instant::now();
        let mut batch = vec![
            timer(1, CallbackTimerKind::Immediate, base, 0),
            timer(2, CallbackTimerKind::Timeout, base, 5),
            timer(3, CallbackTimerKind::Immediate, base, 0),
            timer(4, CallbackTimerKind::Timeout, base, 1),
        ];
        order_expired_callback_batch(&mut batch);
        let ids: Vec<i64> = batch.iter().map(|t| t.id).collect();
        assert_eq!(
            ids,
            vec![4, 2, 1, 3],
            "timeouts by deadline (4 then 2), then immediates FIFO (1 then 3)"
        );
    }
}

#[cfg(test)]
mod managed_wrapper_tests {
    use super::*;

    fn wrapper_addr(value: f64) -> usize {
        crate::value::js_nanbox_get_pointer(value) as usize
    }

    fn call_timer_method(value: f64, method: &[u8]) -> f64 {
        unsafe {
            crate::object::js_native_call_method(
                value,
                method.as_ptr().cast(),
                method.len(),
                std::ptr::null(),
                0,
            )
        }
    }

    #[test]
    fn timer_values_are_managed_wrappers_with_headers() {
        crate::hot_diag::receiver_repr_test_reset();
        crate::hot_diag::receiver_repr_test_arm(true);

        let id = js_set_timeout_callback(0, 60_000.0);
        let value = js_timer_wrap_id(id);
        let addr = wrapper_addr(value);
        let header = unsafe { crate::value::addr_class::try_read_tracked_gc_header(addr) }
            .expect("timer wrapper must have a tracked GcHeader");
        assert_eq!(unsafe { header.as_ref().obj_type }, crate::gc::GC_TYPE_NATIVE_HANDLE);

        let key = crate::string::js_string_from_bytes(b"hasRef".as_ptr(), 6);
        let property = crate::object::js_object_get_field_by_name_f64(addr as *const _, key);
        assert_ne!(property.to_bits(), crate::value::TAG_UNDEFINED);
        assert_ne!(
            call_timer_method(value, b"hasRef").to_bits(),
            crate::value::TAG_UNDEFINED
        );

        let (constructed, observed_old, observed_wrapped) =
            crate::hot_diag::receiver_repr_test_snapshot(
                crate::hot_diag::ReceiverReprFamily::Timer,
            );
        assert!(constructed > 0);
        assert_eq!(observed_old, 0);
        assert!(observed_wrapped > 0);

        clearTimeout(id);
        crate::hot_diag::receiver_repr_test_arm(false);
    }

    #[test]
    fn timer_identity_survives_a_copying_minor() {
        let _isolation = crate::gc::CopyingNurseryTestGuard::new(0);
        let scope = crate::gc::RuntimeHandleScope::new();
        let id = js_set_timeout_callback(0, 60_000.0);
        let first = scope.root_nanbox_f64(js_timer_wrap_id(id));

        // Ensure the nursery is nonempty so the asserted cycle cannot be a
        // vacuous collection around the nonmoving malloc wrapper.
        let young = crate::object::js_object_alloc(0, 0);
        let _young = scope.root_raw_mut_ptr(young);
        let before = crate::gc::copying_minor_cycles();
        let _ = crate::gc::gc_collect_minor();
        assert!(crate::gc::copying_minor_cycles() > before);

        let after = first.get_nanbox_f64();
        assert_eq!(after.to_bits(), js_timer_wrap_id(id).to_bits());
        assert_eq!(canonical_timer_id(wrapper_addr(after) as i64), id);
        assert_eq!(
            call_timer_method(after, b"hasRef").to_bits(),
            crate::value::TAG_TRUE
        );
        clearTimeout(id);
    }

    #[inline(never)]
    fn schedule_and_drop_wrapper() -> (i64, usize) {
        let id = js_set_timeout_callback(0, 60_000.0);
        let addr = wrapper_addr(js_timer_wrap_id(id));
        (id, addr)
    }

    #[test]
    fn timer_wrapper_finalization_or_immortality() {
        let _isolation = crate::gc::global_side_table_test_lock();
        let provider = crate::native_handle::NATIVE_HANDLE_PROVIDER_TIMER;
        crate::gc::js_gc_collect();
        let before = crate::native_handle::canonical_handle_entry_count_for_tests(provider);
        let (id, old_addr) = schedule_and_drop_wrapper();
        assert_eq!(
            crate::native_handle::canonical_handle_entry_count_for_tests(provider),
            before + 1
        );

        crate::gc::js_gc_collect();
        assert_eq!(
            crate::native_handle::canonical_handle_entry_count_for_tests(provider),
            before,
            "the full-cycle finalizer must remove the weak interner entry"
        );
        assert!(
            is_known_timer_id(id),
            "timer wrappers are borrowed views: finalization must not close the timer"
        );
        assert!(
            crate::native_handle::canonical_handle_parts_from_addr(old_addr).is_none(),
            "the finalized allocation must no longer be allocator-owned"
        );
        let _replacement = js_timer_wrap_id(id);
        assert_eq!(
            crate::native_handle::canonical_handle_entry_count_for_tests(provider),
            before + 1,
            "re-publication must install a new live canonical entry"
        );
        clearTimeout(id);
    }
}
