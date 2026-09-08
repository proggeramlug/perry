//! Default-off poisoning and stale-reader attribution for swept old cells.

use super::*;
use crate::arena::QUARANTINE_POISON_OBJ_TYPE;
use std::collections::HashMap;
use std::sync::OnceLock;

pub(crate) const POISON_SWEPT_OBJ_TYPE: u8 = QUARANTINE_POISON_OBJ_TYPE;
const POISON_SWEPT_PAYLOAD_WORD: u64 = 0xDEAD_BEEF_DEAD_BEEF;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum PoisonSweptMode {
    Off,
    Poison,
    Panic,
}

fn parse_poison_swept_mode(value: Option<&str>) -> PoisonSweptMode {
    match value.map(str::trim).map(str::to_ascii_lowercase).as_deref() {
        Some("1" | "on" | "true") => PoisonSweptMode::Poison,
        Some("panic") => PoisonSweptMode::Panic,
        _ => PoisonSweptMode::Off,
    }
}

static POISON_SWEPT_MODE: OnceLock<PoisonSweptMode> = OnceLock::new();

/// Mirror of "the resolved mode is not `Off`", for the paths a default-off
/// diagnostic must not slow down: the old-gen reuse allocator, the block
/// reset walk and the mutator read entry points. `poison_swept_mode` is a
/// `OnceLock` read plus (in test builds) a thread-local check — fine per
/// collection, too much per property read and per allocation. This is one
/// relaxed load of a never-written-again flag, and it is set inside the
/// resolution below, which every poisoning path passes through before any
/// cell can carry poison.
static POISON_SWEPT_ACTIVE: std::sync::atomic::AtomicBool =
    std::sync::atomic::AtomicBool::new(false);

/// Cheap "could a poisoned cell exist?" test for hot paths. Never a false
/// negative once a cell has been poisoned; a false positive only costs the
/// slow path's own early return. Test builds always take the slow path so a
/// per-thread test mode is honoured.
#[inline(always)]
pub(crate) fn poison_swept_maybe_active() -> bool {
    #[cfg(test)]
    {
        true
    }
    #[cfg(not(test))]
    {
        POISON_SWEPT_ACTIVE.load(std::sync::atomic::Ordering::Relaxed)
    }
}

#[cfg(test)]
crate::perry_thread_local! {
    static TEST_POISON_SWEPT_MODE: Cell<Option<PoisonSweptMode>> = const { Cell::new(None) };
    static TEST_POISON_SWEPT_WORK: Cell<usize> = const { Cell::new(0) };
}

pub(crate) fn poison_swept_mode() -> PoisonSweptMode {
    #[cfg(test)]
    if let Some(mode) = TEST_POISON_SWEPT_MODE.with(Cell::get) {
        return mode;
    }
    *POISON_SWEPT_MODE.get_or_init(|| {
        let mode = parse_poison_swept_mode(std::env::var("PERRY_GC_POISON_SWEPT").ok().as_deref());
        if mode != PoisonSweptMode::Off {
            POISON_SWEPT_ACTIVE.store(true, std::sync::atomic::Ordering::Relaxed);
        }
        mode
    })
}

pub(crate) fn poison_swept_enabled() -> bool {
    poison_swept_mode() != PoisonSweptMode::Off
}

#[derive(Clone, Copy)]
pub(crate) struct PoisonSweepContext {
    pub(crate) cycle_ordinal: usize,
    pub(crate) scan_site: &'static str,
}

#[derive(Clone, Copy)]
struct SweptCellRecord {
    obj_type_was: u8,
    total_size: usize,
    cycle_ordinal: usize,
    scan_site: &'static str,
    reported: bool,
}

// Dead addresses only: this provenance table is never traced as a root. Entries
// leave at exact-size reuse or when their containing old block leaves the arena.
crate::perry_thread_local! {
    static SWEPT_CELLS: RefCell<HashMap<usize, SweptCellRecord>> = RefCell::new(HashMap::new());
    static POISONED_CELLS_SINCE_REPORT: Cell<usize> = const { Cell::new(0) };
    static POISONED_BYTES_SINCE_REPORT: Cell<usize> = const { Cell::new(0) };
}

/// Retire one dead old-arena cell while preserving the allocator's size word.
/// The old free list is out-of-line, so the complete payload is diagnostic data.
pub(crate) unsafe fn poison_dead_old_cell(
    header: *mut GcHeader,
    context: PoisonSweepContext,
) -> usize {
    let obj_type_was = (*header).obj_type;
    let total_size = (*header).size as usize;
    let user_ptr = header.add(1) as usize;

    crate::arena::unregister_old_object_pages(header as usize, total_size);

    let payload_len = total_size.saturating_sub(GC_HEADER_SIZE);
    let mut offset = 0usize;
    while offset + std::mem::size_of::<u64>() <= payload_len {
        ((user_ptr + offset) as *mut u64).write_unaligned(POISON_SWEPT_PAYLOAD_WORD);
        offset += std::mem::size_of::<u64>();
    }
    if offset < payload_len {
        std::ptr::write_bytes((user_ptr + offset) as *mut u8, 0xDE, payload_len - offset);
    }

    (*header).obj_type = POISON_SWEPT_OBJ_TYPE;
    (*header).gc_flags = 0;
    // Preserve the former type in-cell as a debugger breadcrumb. The full
    // provenance below remains authoritative across all reader diagnostics.
    (*header)._reserved = obj_type_was as u16;
    SWEPT_CELLS.with(|cells| {
        cells.borrow_mut().insert(
            user_ptr,
            SweptCellRecord {
                obj_type_was,
                total_size,
                cycle_ordinal: context.cycle_ordinal,
                scan_site: context.scan_site,
                reported: false,
            },
        );
    });
    POISONED_CELLS_SINCE_REPORT.with(|count| count.set(count.get().saturating_add(1)));
    POISONED_BYTES_SINCE_REPORT.with(|bytes| bytes.set(bytes.get().saturating_add(total_size)));
    #[cfg(test)]
    TEST_POISON_SWEPT_WORK.with(|count| count.set(count.get() + 1));
    total_size
}

pub(crate) unsafe fn retire_dead_old_header(
    header: *mut GcHeader,
    total_size: usize,
    context: Option<PoisonSweepContext>,
) {
    if let Some(context) = context {
        poison_dead_old_cell(header, context);
    } else {
        super::oldgen::invalidate_dead_old_arena_header(header, total_size);
    }
}

pub(crate) fn report_poisoned_sweep_summary_if_diag() {
    let cells = POISONED_CELLS_SINCE_REPORT.with(|count| count.replace(0));
    let bytes = POISONED_BYTES_SINCE_REPORT.with(|count| count.replace(0));
    if gc_diag_enabled() {
        eprintln!("[gc-poison-swept] cells={cells} bytes={bytes} blocks_protected=0");
    }
}

/// Clear poison before the allocator publishes a reused cell to constructors.
pub(crate) unsafe fn prepare_swept_cell_reuse(user_ptr: usize) {
    let record = SWEPT_CELLS.with(|cells| cells.borrow_mut().remove(&user_ptr));
    let Some(record) = record else {
        return;
    };
    let payload_len = record.total_size.saturating_sub(GC_HEADER_SIZE);
    std::ptr::write_bytes(user_ptr as *mut u8, 0, payload_len);
}

pub(crate) fn forget_swept_cell(user_ptr: usize) {
    SWEPT_CELLS.with(|cells| {
        cells.borrow_mut().remove(&user_ptr);
    });
}

pub(crate) fn forget_swept_cells_in_range(start: usize, end: usize) {
    SWEPT_CELLS.with(|cells| {
        cells
            .borrow_mut()
            .retain(|user_ptr, _| *user_ptr < start || *user_ptr >= end);
    });
}

/// Mutator read barrier for entry points that dereference object payloads.
/// Returns true after naming a poisoned stale read so callers can fail closed.
pub(crate) fn report_stale_swept_read(user_ptr: usize, reader_site: &'static str) -> bool {
    if !poison_swept_enabled() {
        return false;
    }
    let record = SWEPT_CELLS.with(|cells| {
        let mut cells = cells.borrow_mut();
        let record = cells.get_mut(&user_ptr)?;
        if record.reported {
            return Some((*record, false));
        }
        record.reported = true;
        Some((*record, true))
    });
    let Some((record, first_report)) = record else {
        return false;
    };

    if first_report {
        let line = format!(
            "[gc-poison-swept] STALE READ user_ptr=0x{user_ptr:x} obj_type_was={} swept_by={} sweep_site={} reader_site={reader_site}",
            record.obj_type_was, record.cycle_ordinal, record.scan_site
        );
        eprintln!("{line}");
        #[cfg(test)]
        super::telemetry::test_record_full_verify_line(&line);
    }
    if poison_swept_mode() == PoisonSweptMode::Panic {
        panic!(
            "stale read of swept old cell 0x{user_ptr:x} (original type {})",
            record.obj_type_was
        );
    }
    true
}

#[cfg(test)]
pub(crate) struct PoisonSweptModeGuard(Option<PoisonSweptMode>);

#[cfg(test)]
impl PoisonSweptModeGuard {
    pub(crate) fn set(mode: PoisonSweptMode) -> Self {
        let previous = TEST_POISON_SWEPT_MODE.with(|slot| slot.replace(Some(mode)));
        Self(previous)
    }
}

#[cfg(test)]
impl Drop for PoisonSweptModeGuard {
    fn drop(&mut self) {
        TEST_POISON_SWEPT_MODE.with(|slot| slot.set(self.0));
    }
}

#[cfg(test)]
pub(crate) fn poison_swept_work_for_test() -> usize {
    TEST_POISON_SWEPT_WORK.with(Cell::get)
}

#[cfg(test)]
pub(crate) fn reset_poison_swept_for_test() {
    SWEPT_CELLS.with(|cells| cells.borrow_mut().clear());
    POISONED_CELLS_SINCE_REPORT.with(|count| count.set(0));
    POISONED_BYTES_SINCE_REPORT.with(|count| count.set(0));
    TEST_POISON_SWEPT_WORK.with(|count| count.set(0));
}

#[cfg(test)]
pub(crate) fn parse_poison_swept_mode_for_test(value: Option<&str>) -> PoisonSweptMode {
    parse_poison_swept_mode(value)
}
