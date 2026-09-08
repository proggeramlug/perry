use super::super::*;
use super::support::*;

struct ActiveSiteGuard;

impl ActiveSiteGuard {
    fn old_reclaim_alloc_point() -> Self {
        set_active_scan_fallback_site(Some(ConservativeScanSite::OldReclaimAllocPoint));
        Self
    }
}

impl Drop for ActiveSiteGuard {
    fn drop(&mut self) {
        set_active_scan_fallback_site(None);
    }
}

unsafe fn dead_target_beside_rooted_peer(
) -> (*mut crate::object::ObjectHeader, u8, u32, u64, Box<u64>) {
    let (target, _) = alloc_old_test_object(37);
    let target_header = header_from_user_ptr(target as *const u8);
    let obj_type = (*target_header).obj_type;
    let total_size = (*target_header).size;

    let (peer, _) = alloc_old_test_object(1);
    let mut peer_root = Box::new(ptr_bits(peer as usize));
    js_gc_register_global_root((&mut *peer_root as *mut u64) as i64);
    let cycle_ordinal = gc_total_collection_count() + 1;
    let _site = ActiveSiteGuard::old_reclaim_alloc_point();
    gc_collect_full_mark_sweep_with_trigger(GcTriggerSnapshot::capture(GcTriggerKind::Direct));
    std::hint::black_box(*peer_root);
    (target, obj_type, total_size, cycle_ordinal, peer_root)
}

#[test]
fn poison_swept_marks_a_freed_old_cell_dead_until_reuse() {
    std::thread::spawn(|| {
        let _isolation = GcTestIsolationGuard::new();
        old_free_reset_for_test();
        let _mode = PoisonSweptModeGuard::set(PoisonSweptMode::Poison);

        let (target, obj_type, total_size, _, _peer_root) =
            unsafe { dead_target_beside_rooted_peer() };
        let header = unsafe { header_from_user_ptr(target as *const u8) };
        assert_eq!(unsafe { (*header).obj_type }, POISON_SWEPT_OBJ_TYPE);
        assert_eq!(unsafe { (*header)._reserved }, obj_type as u16);
        assert_eq!(unsafe { (*header).size }, total_size);
        assert_eq!(
            unsafe { (target as *const u64).read_unaligned() },
            0xDEAD_BEEF_DEAD_BEEF
        );
        assert!(poison_swept_work_for_test() >= 1);
        assert!(
            unsafe { crate::value::addr_class::try_read_tracked_gc_header(target as usize) }
                .is_none()
        );

        let payload = std::mem::size_of::<crate::object::ObjectHeader>() + 37 * 8;
        let reused = crate::arena::arena_alloc_gc_old(payload, 8, GC_TYPE_OBJECT)
            as *mut crate::object::ObjectHeader;
        assert_eq!(
            reused, target,
            "exact-size allocation must consume the poisoned hole"
        );
        let reused_header = unsafe { header_from_user_ptr(reused as *const u8) };
        assert_eq!(unsafe { (*reused_header).obj_type }, obj_type);
        assert_eq!(unsafe { (*reused_header)._reserved }, 0);
        assert_eq!(unsafe { (reused as *const u64).read_unaligned() }, 0);
        assert!(!report_stale_swept_read(
            reused as usize,
            "test_after_reuse"
        ));
    })
    .join()
    .expect("poison-swept reuse worker");
}

#[test]
fn poison_swept_stale_read_reports_the_cell() {
    std::thread::spawn(|| {
        let _isolation = GcTestIsolationGuard::new();
        old_free_reset_for_test();
        let _mode = PoisonSweptModeGuard::set(PoisonSweptMode::Poison);
        let _ = crate::gc::telemetry::test_take_full_verify_lines();

        let (target, obj_type, _, cycle_ordinal, _peer_root) =
            unsafe { dead_target_beside_rooted_peer() };
        let key_bytes = b"poison_probe";
        let key = crate::string::js_string_from_bytes(key_bytes.as_ptr(), key_bytes.len() as u32);
        assert_eq!(
            crate::object::js_object_get_field_by_name(target, key).bits(),
            crate::value::TAG_UNDEFINED
        );
        // A repeated read fails closed but does not flood the capture.
        assert_eq!(
            crate::object::js_object_get_field_by_name(target, key).bits(),
            crate::value::TAG_UNDEFINED
        );

        let lines = crate::gc::telemetry::test_take_full_verify_lines();
        let needle = format!(
            "[gc-poison-swept] STALE READ user_ptr=0x{:x} obj_type_was={} swept_by={} sweep_site=old_reclaim_alloc_point reader_site=js_object_get_field_by_name",
            target as usize, obj_type, cycle_ordinal
        );
        assert!(lines.contains(&needle), "missing stale-read attribution: {lines}");
        assert_eq!(lines.matches("[gc-poison-swept] STALE READ").count(), 1);
    })
    .join()
    .expect("poison-swept stale-read worker");
}

#[test]
fn poison_swept_is_inert_when_off() {
    assert_eq!(parse_poison_swept_mode_for_test(None), PoisonSweptMode::Off);
    assert_eq!(
        parse_poison_swept_mode_for_test(Some("0")),
        PoisonSweptMode::Off
    );
    assert_eq!(
        parse_poison_swept_mode_for_test(Some("1")),
        PoisonSweptMode::Poison
    );
    assert_eq!(
        parse_poison_swept_mode_for_test(Some("panic")),
        PoisonSweptMode::Panic
    );

    std::thread::spawn(|| {
        let _isolation = GcTestIsolationGuard::new();
        old_free_reset_for_test();
        let _mode = PoisonSweptModeGuard::set(PoisonSweptMode::Off);
        let (target, _, _, _, _peer_root) = unsafe { dead_target_beside_rooted_peer() };
        let header = unsafe { header_from_user_ptr(target as *const u8) };
        assert_eq!(unsafe { (*header).obj_type }, 0);
        assert_eq!(poison_swept_work_for_test(), 0);
        assert!(!report_stale_swept_read(target as usize, "off_test"));
    })
    .join()
    .expect("poison-swept off worker");
}
