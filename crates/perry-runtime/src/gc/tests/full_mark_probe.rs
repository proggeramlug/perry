//! Full-cycle mark diagnostics and the S=1 in-place-promotion/alloc-point-full
//! regression shape.

use super::super::*;
use super::support::*;

struct RestoredConservativeOverride {
    previous: Option<ConservativeStackScanMode>,
}

impl RestoredConservativeOverride {
    fn clear_for_forced_scan() -> Self {
        Self {
            previous: set_conservative_stack_scan_override(None),
        }
    }
}

impl Drop for RestoredConservativeOverride {
    fn drop(&mut self) {
        set_conservative_stack_scan_override(self.previous);
    }
}

fn arm_old_reclaim() {
    GC_OLD_RECLAIM_PENDING.with(|pending| pending.set(true));
}

fn clear_old_reclaim_state() {
    GC_OLD_RECLAIM_PENDING.with(|pending| pending.set(false));
    crate::gc::set_safepoint_pending(false);
    let old_in_use = crate::arena::old_gen_in_use_bytes();
    GC_LAST_OLD_RECLAIM_IN_USE_BYTES.with(|bytes| bytes.set(old_in_use));
}

#[test]
fn full_mark_probe_reports_marked_to_unmarked_edge() {
    std::thread::spawn(|| {
        let _isolation = GcTestIsolationGuard::new();
        let _verify = crate::gc::telemetry::GcVerifyMarkTestGuard::force_on();
        let _ = crate::gc::telemetry::test_take_full_verify_lines();

        let child = young_leaf();
        let (parent, fields) = unsafe { alloc_old_test_object(1) };
        unsafe {
            *fields = string_bits(child);
            let parent_header = header_from_user_ptr(parent as *const u8);
            // A pre-marked parent is deliberately not re-seeded by the full
            // trace, so its planted raw-store child stays white until the
            // marks-final verifier observes the broken invariant.
            (*parent_header).gc_flags |= GC_FLAG_MARKED;
        }

        gc_collect_full_mark_sweep_with_trigger(GcTriggerSnapshot::capture(GcTriggerKind::Manual));

        let lines = crate::gc::telemetry::test_take_full_verify_lines();
        assert!(
            lines.contains("[gc-mark-verify:full] marked->UNMARKED"),
            "the full marks-final boundary must emit the planted edge; lines={lines}"
        );

        // Do not leave a surviving old fixture pointing into the reclaimed
        // young cell for a later test's heap walk.
        unsafe { *fields = 0 };
    })
    .join()
    .expect("full mark probe worker");
}

#[derive(Clone, Copy)]
struct HeaderRecord {
    user: usize,
    obj_type: u8,
    size: u32,
}

#[derive(Clone, Copy)]
struct ParentRecord {
    header: HeaderRecord,
    slot: *mut u64,
}

fn header_record(user: usize) -> HeaderRecord {
    let header = unsafe { header_from_user_ptr(user as *const u8) };
    HeaderRecord {
        user,
        obj_type: unsafe { (*header).obj_type },
        size: unsafe { (*header).size },
    }
}

fn assert_header_intact(record: HeaderRecord, tenured: bool, label: &str) {
    let header = unsafe { header_from_user_ptr(record.user as *const u8) };
    assert_ne!(
        unsafe { (*header).obj_type },
        0,
        "{label} entered old free list"
    );
    assert_eq!(
        unsafe { (*header).obj_type },
        record.obj_type,
        "{label} type"
    );
    assert_eq!(unsafe { (*header).size }, record.size, "{label} size");
    if tenured {
        assert_ne!(
            unsafe { (*header).gc_flags } & GC_FLAG_TENURED,
            0,
            "{label} lost GC_FLAG_TENURED"
        );
    }
}

#[test]
fn alloc_point_full_after_in_place_promotion_keeps_stack_held_objects() {
    std::thread::spawn(|| {
        const ROOTS: usize = 2_000;
        let _isolation = GcTestIsolationGuard::new();
        let _pacing = crate::gc::policy::force_moving_gc_pacing();
        let _triggers = GcTriggerThresholdTestGuard::suppress_automatic_triggers();
        let _barriers = GeneratedWriteBarrierTestGuard::active();
        let _promote = InPlacePromotionTestGuard::enabled(1000);
        let _verify = crate::gc::telemetry::GcVerifyMarkTestGuard::force_on();

        let frame = js_shadow_frame_push(ROOTS as u32);
        let mut stack_roots = [0u64; ROOTS];
        let mut all_headers = Vec::with_capacity(ROOTS);
        let mut parents = Vec::with_capacity(ROOTS * 2 / 3);

        for (index, root) in stack_roots.iter_mut().enumerate() {
            let (user, bits) = match index % 3 {
                0 => {
                    let (parent, fields) = unsafe { alloc_nursery_test_object(1) };
                    let child = young_leaf();
                    unsafe { *fields = string_bits(child) };
                    parents.push(ParentRecord {
                        header: header_record(parent as usize),
                        slot: fields,
                    });
                    (parent as usize, ptr_bits(parent as usize))
                }
                1 => {
                    let payload = std::mem::size_of::<crate::array::ArrayHeader>() + 8;
                    let array = crate::arena::arena_alloc_gc(payload, 8, GC_TYPE_ARRAY)
                        as *mut crate::array::ArrayHeader;
                    let elements = unsafe {
                        (*array).length = 1;
                        (*array).capacity = 1;
                        (array as *mut u8).add(std::mem::size_of::<crate::array::ArrayHeader>())
                            as *mut u64
                    };
                    let child = young_leaf();
                    unsafe {
                        *elements = string_bits(child);
                        layout_note_slot(array as usize, 0, *elements);
                    }
                    parents.push(ParentRecord {
                        header: header_record(array as usize),
                        slot: elements,
                    });
                    (array as usize, ptr_bits(array as usize))
                }
                _ => {
                    let string = young_leaf();
                    (string, string_bits(string))
                }
            };
            *root = bits;
            all_headers.push(header_record(user));
            js_shadow_slot_set(index as u32, bits);
        }

        let trace = collect_minor_trace(GcTriggerKind::Direct);
        assert_copied_minor_trace(&trace, true, CopiedMinorFallbackReason::None, false);
        assert!(trace.copying_nursery.in_place_promotion);
        assert!(trace.copying_nursery.in_place_promoted_blocks > 0);
        assert!(trace.copying_nursery.in_place_promoted_objects >= ROOTS);
        js_shadow_frame_pop(frame);

        for parent in &parents {
            let child = young_leaf();
            let bits = string_bits(child);
            unsafe {
                *parent.slot = bits;
                layout_note_slot(parent.header.user, 0, bits);
                runtime_write_barrier_slot(parent.header.user, parent.slot as usize, bits);
            }
        }
        let children: Vec<HeaderRecord> = parents
            .iter()
            .map(|parent| unsafe { header_record((*parent.slot & POINTER_MASK) as usize) })
            .collect();

        // The collection must find the promoted roots through this native
        // stack array alone. The Vec records above live in Rust heap storage,
        // which the conservative scanner does not traverse.
        std::hint::black_box(&mut stack_roots);
        let _ = crate::gc::telemetry::test_take_full_verify_lines();
        clear_old_reclaim_state();
        reset_scan_fallback_counters();
        let _scan_override = RestoredConservativeOverride::clear_for_forced_scan();
        arm_old_reclaim();
        gc_check_trigger();
        std::hint::black_box(&mut stack_roots);

        assert_eq!(
            scan_fallback_count(ConservativeScanSite::OldReclaimAllocPoint),
            1
        );
        let lines = crate::gc::telemetry::test_take_full_verify_lines();
        assert!(
            lines.contains("[gc-full-verify] site=old_reclaim_alloc_point"),
            "missing alloc-point census line: {lines}"
        );
        assert!(
            lines.contains("tenured_flag_missing=0 page_index_missing=0"),
            "promotion metadata census found damage: {lines}"
        );
        assert!(
            lines.contains(" unmarked=0 tenured_flag_missing=0"),
            "a stack-held promoted object was left unmarked: {lines}"
        );
        assert!(
            lines.contains("[gc-mark-verify:full] OK (no marked->unmarked)"),
            "the full mark verifier found a live-to-white edge: {lines}"
        );
        assert!(
            lines.contains("[gc-full-verify] stack_words_rejected_in_blocks=0"),
            "the conservative scanner rejected an in-block candidate: {lines}"
        );

        for record in all_headers {
            assert_header_intact(record, true, "stack-held promoted object");
        }
        for (parent, child) in parents.iter().zip(children) {
            assert_header_intact(parent.header, true, "promoted parent");
            assert_header_intact(child, false, "young child");
            assert_eq!(
                unsafe { *parent.slot & POINTER_MASK } as usize,
                child.user,
                "promoted parent lost its young child"
            );
        }
        clear_old_reclaim_state();
    })
    .join()
    .expect("in-place promotion/full-scan worker");
}
