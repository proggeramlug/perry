use super::*;

/// Size of each arena block (1 MB — issue #179 tier 1 #1).
///
/// Formerly 8 MB. The recent-5-blocks safety window (where LLVM caller-
/// saved registers might still hold uncaptured handles; see
/// `BLOCK_PERSIST_WINDOW` in gc.rs and `keep_low` in
/// `arena_reset_empty_blocks`) now reserves 5 × 1 MB = 5 MB of
/// non-reclaimable headroom instead of 5 × 8 MB = 40 MB. Combined with
/// the age-restricted block-persist from v0.5.193 this closes the
/// remaining `bench_json_roundtrip` RSS gap to within 5% of Node's
/// numbers without a speed regression.
///
/// Measured on `bench_json_roundtrip` (best-of-5, macOS ARM64):
///   8 MB blocks (v0.5.193): 384 ms / 213 MB
///   2 MB blocks:            325 ms / 208 MB
///   1 MB blocks:            320 ms / 199 MB
///   512 KB blocks:          318 ms / 200 MB  (diminishing returns)
///
/// Picked 1 MB: RSS essentially tied with 512 KB, block-count overhead
/// 2× smaller, `bench_gc_pressure` / `object_create` unchanged.
///
/// Trade-offs:
/// - More blocks in the arena for the same total bytes → walker loops
///   pay more per-block overhead. Measured: negligible — the walker is
///   O(objects), not O(blocks), once inside a block.
/// - More frequent "block full, advance to next" transitions in the
///   inline bump allocator's slow path. The slow path is a function
///   call; on `object_create` the cost is amortized across hundreds of
///   thousands of allocs per block before GC resets it. Measured:
///   `07_object_create` 0-1 ms unchanged.
/// - Large single allocations (Buffer.alloc(3 MB), big arena strings)
///   get a custom-sized block via `alloc_block(min_size)` that rounds
///   up to a BLOCK_SIZE multiple — unchanged mechanics, just rounds to
///   1 MB granularity now.
/// - The GC's adaptive step (gc.rs `GC_THRESHOLD_INITIAL_BYTES = 128
///   MB`) is unchanged; the workload still needs 128 MB of total arena
///   to trigger the first GC. With 1 MB blocks that's 128 blocks, and
///   `bench_json_roundtrip` hits that point at roughly the same
///   iteration as it did with 16 × 8 MB blocks — the adaptive step
///   shrinks appropriately on the first productive collection.
pub(crate) const BLOCK_SIZE: usize = 1024 * 1024;
pub(crate) const FRESH_GENERAL_BLOCK_MIN_USED_BYTES: usize = 256 * 1024;

/// Create a block of at least the given size (for oversized allocations)
/// Dedicated mimalloc heap for the arena's 1 MB blocks (PERRY_GC_ARENA_DEDICATED_HEAP,
/// default off = std::alloc as before). Isolating the blocks into their own heap
/// means freed blocks occupy their own 32 MB mimalloc segments, so
/// `arena_block_heap_collect()` (called at idle from gc_return_freed_to_os) can
/// return whole emptied segments to the OS — a block freed to the shared global
/// heap shares segments with the small-object non-arena churn and never purges.
pub(crate) mod arena_block_heap {
    use std::cell::Cell;
    use std::sync::OnceLock;

    thread_local! {
        static HEAP: Cell<*mut libmimalloc_sys::mi_heap_t> =
            const { Cell::new(std::ptr::null_mut()) };
    }

    pub(crate) fn enabled() -> bool {
        static CACHED: OnceLock<bool> = OnceLock::new();
        *CACHED.get_or_init(|| {
            matches!(
                std::env::var("PERRY_GC_ARENA_DEDICATED_HEAP").as_deref(),
                Ok("1") | Ok("on") | Ok("true")
            )
        })
    }

    fn heap() -> *mut libmimalloc_sys::mi_heap_t {
        HEAP.with(|h| {
            let mut p = h.get();
            if p.is_null() {
                p = unsafe { libmimalloc_sys::mi_heap_new() };
                h.set(p);
            }
            p
        })
    }

    /// Allocate `size` bytes (16-aligned) from the dedicated arena-block heap.
    pub(super) fn alloc(size: usize) -> *mut u8 {
        unsafe { libmimalloc_sys::mi_heap_malloc_aligned(heap(), size, 16) as *mut u8 }
    }

    /// Return this thread's dedicated-heap freed segments to the OS. No-op if the
    /// heap was never created (feature off / no arena blocks on this thread).
    pub(crate) fn collect() {
        HEAP.with(|h| {
            let p = h.get();
            if !p.is_null() {
                unsafe { libmimalloc_sys::mi_heap_collect(p, true) };
            }
        });
    }
}

/// Back the arena's 1 MB blocks with direct `mmap`/`munmap`
/// (PERRY_GC_ARENA_MMAP, default off = the allocator paths below).
///
/// Blocks are large (≥ BLOCK_SIZE = 1 MB) and reclaimed in bulk by the GC, so a
/// dedicated mapping per block gives per-block OS-return with **zero
/// fragmentation**: `munmap` returns exactly that block's pages regardless of
/// any other block's liveness. The mimalloc paths (global heap or the dedicated
/// arena heap) pack several 1 MB blocks into one multi-MB segment, so a single
/// surviving block — e.g. a copying-GC to-space survivor allocated from a
/// just-freed page — pins the whole segment against `mi_heap_collect`'s purge.
/// Measured at idle on the claude-code bundle: after the settle mark-compact
/// freed 188 blocks (188 MB) to the dedicated heap, `mi_heap_collect(force)`
/// returned ~1 MB (footprint 301→300); with `mmap` the same 188 blocks'
/// `munmap` returns all 188 MB to the OS.
#[derive(Clone, Copy, PartialEq, Eq)]
enum BlockBacking {
    /// Default: the allocator paths (global heap, or the dedicated arena heap).
    Alloc,
    /// mmap per block; `munmap` on free (returns pages AND unmaps the VA, so a
    /// stale read into a freed block faults — surfaces GC bugs loudly).
    Munmap,
    /// mmap per block; `madvise(MADV_FREE)` on free (returns physical pages but
    /// keeps the VA mapped, so a stale read reads zero/old bytes instead of
    /// faulting — same safety as the allocator paths, still drops footprint).
    MadvFree,
}

/// Backing mode for the arena's 1 MB blocks (PERRY_GC_ARENA_MMAP; default
/// `Alloc` = unchanged). `1`/`on`/`true`/`munmap` → Munmap; `free`/`madvfree` →
/// MadvFree.
fn block_backing() -> BlockBacking {
    use std::sync::OnceLock;
    static CACHED: OnceLock<u8> = OnceLock::new();
    let v = *CACHED.get_or_init(|| match std::env::var("PERRY_GC_ARENA_MMAP").as_deref() {
        Ok("1") | Ok("on") | Ok("true") | Ok("munmap") => 1,
        Ok("free") | Ok("madvfree") => 2,
        _ => 0,
    });
    match v {
        1 => BlockBacking::Munmap,
        2 => BlockBacking::MadvFree,
        _ => BlockBacking::Alloc,
    }
}

/// Reserve backing memory for one arena block of `layout.size()` bytes in
/// `space`. Returns null on failure (caller retries after an emergency GC).
///
/// Routing:
/// - `PERRY_GC_ARENA_MMAP` (experimental, default off): mmap per block for all
///   spaces. `MAP_ANON` pages are kernel-zeroed, matching the arena's
///   zeroed-block expectation. NOTE: this exposes latent stale-pointer reads
///   into freed blocks (the allocator paths mask them by keeping bytes intact),
///   so it currently breaks even trivial programs — kept for diagnostics only.
/// - Dedicated arena heap (`PERRY_GC_ARENA_DEDICATED_HEAP`): only the transient
///   `NurseryEden` arena routes here. Eden is wholesale-freed at every
///   compaction, so a heap holding ONLY Eden blocks has pure-Eden mimalloc
///   segments that fully empty on collection and can be returned to the OS
///   (`arena_block_heap_collect` → `mi_heap_collect`). Survivor/Old/Longlived
///   blocks survive, so isolating them buys nothing and would just fragment
///   their own heap — they stay on the global heap. Sharing one dedicated heap
///   across all spaces (the previous behavior) let surviving Survivor/Old blocks
///   pin the segments the freed Eden blocks lived in, so nothing returned
///   (measured: 188 MB freed, ~1 MB returned).
/// - Default: the global (mimalloc) heap.
pub(super) fn alloc_block_memory(layout: Layout, space: HeapSpace) -> *mut u8 {
    mem_trace::note_alloc(layout.size());
    if block_backing() != BlockBacking::Alloc {
        let p = unsafe {
            libc::mmap(
                std::ptr::null_mut(),
                layout.size(),
                libc::PROT_READ | libc::PROT_WRITE,
                libc::MAP_PRIVATE | libc::MAP_ANONYMOUS,
                -1,
                0,
            )
        };
        return if p == libc::MAP_FAILED {
            std::ptr::null_mut()
        } else {
            p as *mut u8
        };
    }
    if space == HeapSpace::NurseryEden && arena_block_heap::enabled() {
        return arena_block_heap::alloc(layout.size());
    }
    unsafe { alloc(layout) }
}

/// Cross-thread committed-block accounting + a background trace thread
/// (PERRY_MEM_TRACE). `GLOBAL_ARENA_COMMITTED` sums live arena block bytes across
/// ALL threads (thread-local `ARENA_TOTAL_BYTES` can't be read off-thread), so the
/// trace thread can print committed-arena vs process phys_footprint every 2s —
/// definitively separating arena growth from non-arena (churn-leak) footprint
/// over startup AND true idle, independent of any pty measurement harness.
pub(crate) mod mem_trace {
    use std::sync::atomic::{AtomicBool, AtomicI64, Ordering};
    pub(crate) static GLOBAL_ARENA_COMMITTED: AtomicI64 = AtomicI64::new(0);
    /// Last main-thread arena_in_use snapshot (bytes). Written from a safepoint
    /// (the EventLoop drain), read by the bg trace thread — so the LIVE-vs-retained
    /// number rides the clean [mem] channel instead of a main-thread eprintln that
    /// interleaves with the TUI's pty render output.
    pub(crate) static GLOBAL_ARENA_IN_USE: AtomicI64 = AtomicI64::new(-1);
    static STARTED: AtomicBool = AtomicBool::new(false);

    /// Record the main thread's current arena in-use (live/bumped) bytes.
    pub(crate) fn note_in_use(v: usize) {
        GLOBAL_ARENA_IN_USE.store(v as i64, Ordering::Relaxed);
    }

    fn enabled() -> bool {
        use std::sync::OnceLock;
        static CACHED: OnceLock<bool> = OnceLock::new();
        *CACHED.get_or_init(|| std::env::var_os("PERRY_MEM_TRACE").is_some())
    }

    fn phys_footprint_mb() -> i64 {
        #[repr(C)]
        struct RUsageInfoV2 {
            _uuid: [u8; 16],
            _a: [u64; 7],
            ri_phys_footprint: u64,
            _rest: [u64; 10],
        }
        unsafe extern "C" {
            fn proc_pid_rusage(pid: i32, flavor: i32, buffer: *mut core::ffi::c_void) -> i32;
        }
        let mut buf = [0u8; 512];
        let pid = unsafe { libc::getpid() };
        let rc = unsafe { proc_pid_rusage(pid, 2, buf.as_mut_ptr() as *mut _) };
        if rc != 0 {
            return -1;
        }
        // ri_phys_footprint @ byte offset 72
        let fp = u64::from_ne_bytes(buf[72..80].try_into().unwrap());
        (fp / 1_048_576) as i64
    }

    pub(crate) fn note_alloc(_size: usize) {
        GLOBAL_ARENA_COMMITTED.fetch_add(_size as i64, Ordering::Relaxed);
        if enabled() && !STARTED.swap(true, Ordering::Relaxed) {
            std::thread::spawn(|| {
                let t0 = std::time::Instant::now();
                loop {
                    std::thread::sleep(std::time::Duration::from_secs(2));
                    let arena_mb = GLOBAL_ARENA_COMMITTED.load(Ordering::Relaxed) / 1_048_576;
                    let in_use = GLOBAL_ARENA_IN_USE.load(Ordering::Relaxed);
                    let in_use_mb = if in_use < 0 { -1 } else { in_use / 1_048_576 };
                    eprintln!(
                        "[mem] t={}s arena_committed={}MB arena_in_use={}MB footprint={}MB nonarena≈{}MB",
                        t0.elapsed().as_secs(),
                        arena_mb,
                        in_use_mb,
                        phys_footprint_mb(),
                        phys_footprint_mb() - arena_mb,
                    );
                }
            });
        }
    }

    pub(crate) fn note_free(size: usize) {
        GLOBAL_ARENA_COMMITTED.fetch_sub(size as i64, Ordering::Relaxed);
    }
}

/// Release an arena block's backing memory to the OS. Mirrors
/// `alloc_block_memory`'s mode. `munmap` returns the block's pages immediately;
/// the dedicated/global mimalloc paths free via the global allocator (which is
/// mimalloc, so `dealloc` routes to `mi_free` back to the owning heap).
/// Caller is responsible for the `cfg!(test)` keep-mapped guard (unit tests hold
/// raw GC pointers across collections and must read stale bytes, not fault).
pub(crate) fn free_block_memory(data: *mut u8, layout: Layout) {
    if data.is_null() {
        return;
    }
    mem_trace::note_free(layout.size());
    match block_backing() {
        BlockBacking::Munmap => unsafe {
            libc::munmap(data as *mut libc::c_void, layout.size());
        },
        BlockBacking::MadvFree => unsafe {
            // Return the physical pages; leave the VA mapped (caller tombstones
            // the block pointer, so the mapping is intentionally not reused).
            libc::madvise(data as *mut libc::c_void, layout.size(), libc::MADV_FREE);
        },
        BlockBacking::Alloc => unsafe { std::alloc::dealloc(data, layout) },
    }
}

fn alloc_block(min_size: usize, space: HeapSpace) -> ArenaBlock {
    let size = if min_size <= BLOCK_SIZE {
        BLOCK_SIZE
    } else {
        // Round up to next multiple of BLOCK_SIZE
        min_size.div_ceil(BLOCK_SIZE) * BLOCK_SIZE
    };
    let layout = Layout::from_size_align(size, 16).unwrap();
    let mut data = alloc_block_memory(layout, space);
    if data.is_null() {
        // The OS refused memory. Try one emergency full collection —
        // idle-block dealloc and malloc sweep can return real pages —
        // then retry once before giving up.
        if crate::gc::gc_try_emergency_reclaim() {
            data = alloc_block_memory(layout, space);
        }
    }
    if data.is_null() {
        panic!(
            "Failed to allocate arena block of {} bytes (heap exhausted after emergency GC)",
            size
        );
    }
    ArenaBlock {
        data,
        size,
        offset: 0,
        dead_cycles: 0,
    }
}

/// A single arena block
pub(crate) struct ArenaBlock {
    pub(crate) data: *mut u8,
    pub(crate) size: usize,
    pub(crate) offset: usize,
    /// Issue #73: number of consecutive GC cycles this block has been
    /// observed with zero live objects. Reset requires TWO consecutive
    /// dead observations so a block can't be reclaimed on the same
    /// cycle its last live pointer slipped off the conservative scan
    /// (e.g. LLVM dropped a `samples` handle from a caller-saved FP
    /// reg after the IndexSet store). On the next cycle either the
    /// scan finds the pointer (counter resets to 0) or the block is
    /// truly dead and resets.
    pub(crate) dead_cycles: u32,
}

impl ArenaBlock {
    fn new(space: HeapSpace) -> Self {
        alloc_block(BLOCK_SIZE, space)
    }

    /// Try to allocate within this block, respecting alignment
    #[inline]
    pub(crate) fn alloc(&mut self, size: usize, align: usize) -> Option<*mut u8> {
        // Always preserve at least 8-byte alignment between calls so
        // the codegen inline bump-allocator fast path
        // (`crates/perry-codegen/src/lower_call.rs`'s inline-keys
        // allocator) can safely advance `offset += total_size`
        // without re-aligning. Pre-fix, an odd-sized string
        // allocation (`StringHeader=20` + N-byte payload via
        // `arena_alloc_gc`) left `offset` misaligned; the next
        // inline `new ClassName()` inherited the misalignment, the
        // returned user_ptr had low bits set, `arena_walk_objects`
        // (which iterates at 8-aligned positions) skipped it,
        // `build_valid_pointer_set` never inserted it, and the GC
        // mark phase rejected it as "not in valid_ptrs". The
        // archetype's `componentData` Map went unmarked and got
        // swept; the freed entries buffer was reused for a new alloc;
        // the first f64 key drifted to a denormal (~1.086e-311).
        let pad = align.max(8);
        // Check arithmetic on the bump path explicitly. `allocation_start`
        // already uses checked_add for the excluded-pages slow path; this
        // mirrors that on the fast path so a hostile `size`/`align` pair
        // can never wrap and hand back an in-bounds pointer for an
        // out-of-bounds region.
        let aligned_offset = self.offset.checked_add(pad - 1)? & !(pad - 1);
        let bumped = aligned_offset.checked_add(size)?;
        if bumped > self.size {
            return None;
        }

        let ptr = unsafe { self.data.add(aligned_offset) };
        let next = bumped.checked_add(pad - 1)? & !(pad - 1);
        self.offset = next;
        Some(ptr)
    }

    #[inline]
    fn allocation_start(&self, size: usize, align: usize) -> Option<usize> {
        if self.data.is_null() {
            return None;
        }
        let pad = align.max(8);
        let aligned_offset = (self.offset + pad - 1) & !(pad - 1);
        let bumped = aligned_offset.checked_add(size)?;
        if bumped > self.size {
            return None;
        }
        (self.data as usize).checked_add(aligned_offset)
    }

    #[inline]
    pub(crate) fn alloc_excluding_pages(
        &mut self,
        size: usize,
        align: usize,
        excluded_pages: &crate::fast_hash::PtrHashSet<usize>,
    ) -> Option<*mut u8> {
        let start = self.allocation_start(size, align)?;
        if address_span_overlaps_pages(start, size, excluded_pages) {
            return None;
        }
        self.alloc(size, align)
    }
}

/// Thread-local arena allocator
///
/// When a thread exits (e.g., worker threads from `perry/thread`), the Drop
/// impl frees all arena blocks so memory isn't leaked.
pub(crate) struct Arena {
    pub(crate) blocks: Vec<ArenaBlock>,
    pub(crate) current: usize,
    pub(crate) generation: HeapGeneration,
    pub(crate) space: HeapSpace,
}

impl Drop for Arena {
    fn drop(&mut self) {
        for block in &self.blocks {
            // Skip tombstoned slots (gen-GC Phase C4b-δ): C4b-δ
            // deallocates fully-idle nursery blocks back to the OS
            // and leaves a `data = null, size = 0` tombstone in the
            // Vec to keep block-index semantics stable across GC
            // cycles. `dealloc(null, …)` is UB.
            if block.data.is_null() {
                continue;
            }
            let layout = std::alloc::Layout::from_size_align(block.size, 16).unwrap();
            // #4665: in test builds keep freed blocks mapped (no munmap/dealloc) so
            // unit tests holding raw GC pointers across a collection read stale
            // bytes instead of SIGSEGV-ing on an unmapped page.
            if !cfg!(test) {
                free_block_memory(block.data, layout);
            }
        }
    }
}

impl Arena {
    fn new(generation: HeapGeneration, space: HeapSpace) -> Self {
        let initial = ArenaBlock::new(space);
        register_block_space(initial.data as usize, initial.size, generation, space);
        ARENA_TOTAL_BYTES.with(|t| t.set(t.get() + initial.size));
        Arena {
            blocks: vec![initial],
            current: 0,
            generation,
            space,
        }
    }

    /// Lazy variant of `new`: starts with a single tombstone block
    /// (`data = null, size = 0`) instead of an eagerly-mapped 1 MB
    /// block, so JS-touching threads that never allocate in this
    /// region (spawn workers, tokio callers) don't pay the block.
    /// The tombstone shape is exactly the one C4b-δ dealloc leaves
    /// behind, so every walker/reset/alloc path already handles it:
    /// the first `alloc` misses the tombstone, and the slow path's
    /// `install_fresh_block` replaces the tombstone slot in place.
    /// Only used for the non-Eden regions — Eden must stay eager
    /// because `js_inline_arena_state` hands its current block to
    /// codegen's inline bump allocator at thread start.
    fn new_lazy(generation: HeapGeneration, space: HeapSpace) -> Self {
        Arena {
            blocks: vec![ArenaBlock {
                data: std::ptr::null_mut(),
                size: 0,
                offset: 0,
                dead_cycles: 0,
            }],
            current: 0,
            generation,
            space,
        }
    }

    /// Bump-allocate in `blocks[idx]`, delta-maintaining the cached
    /// old-gen in-use counter (see `OLD_GEN_IN_USE_BYTES`). Every
    /// successful offset advance of an old-arena block MUST go through
    /// here — a bypassed site silently skews the OldReclaim trigger.
    #[inline]
    fn try_block_alloc(&mut self, idx: usize, size: usize, align: usize) -> Option<*mut u8> {
        let before = self.blocks[idx].offset;
        let ptr = self.blocks[idx].alloc(size, align)?;
        if self.generation == HeapGeneration::Old {
            old_gen_in_use_bytes_add(self.blocks[idx].offset - before);
        }
        Some(ptr)
    }

    /// `try_block_alloc` twin for the page-excluding path.
    #[inline]
    fn try_block_alloc_excluding_pages(
        &mut self,
        idx: usize,
        size: usize,
        align: usize,
        excluded_pages: &crate::fast_hash::PtrHashSet<usize>,
    ) -> Option<*mut u8> {
        let before = self.blocks[idx].offset;
        let ptr = self.blocks[idx].alloc_excluding_pages(size, align, excluded_pages)?;
        if self.generation == HeapGeneration::Old {
            old_gen_in_use_bytes_add(self.blocks[idx].offset - before);
        }
        Some(ptr)
    }

    #[inline]
    fn resync_inline_to_current(&self) {
        // `INLINE_STATE` mirrors ONLY the general nursery-Eden arena — the
        // one the codegen inline bump-allocator (`js_inline_arena_state`)
        // targets. The old-gen, survivor, and longlived arenas reuse this
        // same `Arena::alloc` body, whose block-reuse forward-scan
        // (`self.current = i`) calls back here. Without this guard, an
        // old-gen/survivor allocation that forward-scans to reuse a block
        // would repoint `INLINE_STATE` at a non-Eden block; the next Eden
        // `arena_alloc` then writes that foreign block's offset into the
        // real current Eden block, rewinding it and allocating fresh objects
        // over still-live ones (#1824: a large-JSON `await` allocation that
        // landed in old-gen clobbered a suspended async-step closure, whose
        // bytes were then read as a garbage function pointer → SIGSEGV on
        // resume; reproduced with `full_gc=0`, so no collection involved).
        if self.space != HeapSpace::NurseryEden {
            return;
        }
        INLINE_STATE.with(|s| unsafe {
            let inline = &mut *s.get();
            if !inline.data.is_null() {
                let block = &self.blocks[self.current];
                inline.data = block.data;
                inline.offset = block.offset;
                inline.size = block.size;
            }
        });
    }

    pub(crate) fn install_fresh_block(&mut self, size: usize) {
        let fresh = alloc_block(size, self.space);
        let fresh_size = fresh.size;
        let fresh_base = fresh.data as usize;
        register_block_space(fresh_base, fresh_size, self.generation, self.space);
        let mut tomb_idx: Option<usize> = None;
        for i in 0..self.blocks.len() {
            if self.blocks[i].data.is_null() {
                tomb_idx = Some(i);
                break;
            }
        }
        let new_idx = match tomb_idx {
            Some(i) => {
                self.blocks[i] = fresh;
                i
            }
            None => {
                self.blocks.push(fresh);
                self.blocks.len() - 1
            }
        };
        self.current = new_idx;
        ARENA_TOTAL_BYTES.with(|t| t.set(t.get() + fresh_size));
    }

    fn alloc_fresh_block(&mut self, size: usize, align: usize) -> *mut u8 {
        self.install_fresh_block(size);
        self.try_block_alloc(self.current, size, align)
            .expect("Fresh block should have space")
    }

    fn alloc_fresh_block_excluding_pages(
        &mut self,
        size: usize,
        align: usize,
        excluded_pages: &crate::fast_hash::PtrHashSet<usize>,
    ) -> *mut u8 {
        loop {
            self.install_fresh_block(size);
            if let Some(ptr) =
                self.try_block_alloc_excluding_pages(self.current, size, align, excluded_pages)
            {
                return ptr;
            }
        }
    }

    #[inline]
    pub(crate) fn alloc(&mut self, size: usize, align: usize) -> *mut u8 {
        // Try current block first
        if let Some(ptr) = self.try_block_alloc(self.current, size, align) {
            return ptr;
        }

        // Current block is full. Check GC trigger first — if it fires
        // and reclaims at least one fully-empty block (via
        // `arena_reset_empty_blocks`), we may be able to reuse that
        // block instead of pushing a new one.
        //
        // Threshold pressure is paid through bounded mutator-assist work.
        // A completed assist cycle may reset blocks before we retry; an
        // incomplete cycle leaves the debt active for later host or allocator
        // steps.
        crate::gc::gc_check_trigger();

        // Retry the (possibly newly-reset) current block. arena.current
        // may have been changed by arena_reset_empty_blocks to point
        // at the lowest reset block.
        if let Some(ptr) = self.try_block_alloc(self.current, size, align) {
            return ptr;
        }

        // Scan forward for any other block with space — the GC may
        // have reset blocks we haven't tried yet. Without this scan,
        // we'd push a fresh block on the very first overflow even
        // though blocks `current+1..n_blocks` are all empty.
        for i in 0..self.blocks.len() {
            if i == self.current {
                continue;
            }
            if let Some(ptr) = self.try_block_alloc(i, size, align) {
                self.current = i;
                // Resync inline state to the new current block.
                self.resync_inline_to_current();
                return ptr;
            }
        }

        // Still no room anywhere — need a fresh block. C4b-δ:
        // prefer reusing a tombstoned slot (a block deallocated by
        // `arena_reset_empty_blocks` after staying idle past the
        // dealloc threshold) over growing the Vec, so block_idx
        // semantics stay bounded even on workloads that churn
        // through nursery blocks.
        self.alloc_fresh_block(size, align)
    }

    pub(crate) fn alloc_excluding_pages(
        &mut self,
        size: usize,
        align: usize,
        excluded_pages: &crate::fast_hash::PtrHashSet<usize>,
    ) -> *mut u8 {
        if excluded_pages.is_empty() {
            return self.alloc(size, align);
        }
        if let Some(ptr) =
            self.try_block_alloc_excluding_pages(self.current, size, align, excluded_pages)
        {
            return ptr;
        }
        for i in 0..self.blocks.len() {
            if i == self.current {
                continue;
            }
            if let Some(ptr) = self.try_block_alloc_excluding_pages(i, size, align, excluded_pages)
            {
                self.current = i;
                self.resync_inline_to_current();
                return ptr;
            }
        }
        self.alloc_fresh_block_excluding_pages(size, align, excluded_pages)
    }
}

thread_local! {
    /// Cached running sum of `block.size` across every arena (general,
    /// longlived, old-gen). `arena_total_bytes()` previously walked
    /// every block of every arena summing this on every call — and
    /// `gc_check_trigger()` calls it on every `gc_malloc`, so for an
    /// 80-block working set the per-allocation overhead was ~250 ns
    /// just to recompute a total that almost never changes (only on
    /// fresh-block alloc and tombstone dealloc). Maintained via deltas
    /// at the four mutation sites (Arena::new initial block, fresh
    /// alloc into a tombstone slot or the end, and dealloc inside
    /// `arena_reset_empty_blocks`).
    pub(crate) static ARENA_TOTAL_BYTES: std::cell::Cell<usize> = const { std::cell::Cell::new(0) };

    /// Cached running sum of `block.offset` across the old-gen arena —
    /// the delta-maintained twin of `ARENA_TOTAL_BYTES` above, same
    /// rationale: `gc_budgeted_due_trigger()` reads the old-gen in-use
    /// total on every `gc_check_trigger` (i.e. every `gc_malloc` and
    /// every nursery block fill), and recomputing it walked every
    /// old-arena block each time — a linear-in-old-gen tax on every
    /// malloc-class allocation once the old gen holds real data.
    /// Mutation sites (each MUST maintain the delta):
    ///   - `Arena::try_block_alloc` / `try_block_alloc_excluding_pages`
    ///     (the only offset-advance funnel for `Arena::alloc`,
    ///     `alloc_excluding_pages`, and the fresh-block paths),
    ///   - `reset_region_to_zero` (generation-aware, reset.rs),
    ///   - the old-arena reclaim family in reset.rs
    ///     (`old_arena_reclaim_dead_blocks`,
    ///     `old_arena_reclaim_selected_dead_blocks`,
    ///     `OldArenaReclaimDeadBlocksState::process_block`) which zero
    ///     old block offsets on sweep/defrag.
    /// Block install/dealloc paths don't touch it: fresh blocks start
    /// at offset 0 and blocks are only deallocated after their offset
    /// was already zeroed. `old_gen_in_use_bytes()` (stats.rs)
    /// debug-asserts this cache against the O(blocks) recompute so a
    /// missed mutation site fails tests instead of silently skewing
    /// the OldReclaim trigger.
    pub(crate) static OLD_GEN_IN_USE_BYTES: std::cell::Cell<usize> = const { std::cell::Cell::new(0) };

    pub(crate) static ARENA: UnsafeCell<Arena> =
        UnsafeCell::new(Arena::new(HeapGeneration::Nursery, HeapSpace::NurseryEden));

    /// Segregated long-lived arena (issue #179). Holds objects that are
    /// intentionally pinned for the lifetime of the program by explicit
    /// root scanners — `PARSE_KEY_CACHE` interned strings, class/object
    /// shape-cache `keys_array`s + their string element pointers. Keeping
    /// these out of the general arena prevents block-persistence
    /// cascades: without segregation, those long-lived allocations
    /// co-locate with the first few iterations' fresh parse output in
    /// general-arena block 0, block-persist marks every adjacent dead
    /// iter-0 object live, those dead objects' field values anchor
    /// fresh-block objects, and the "live set" snowballs.
    ///
    /// Longlived blocks are never reset by `arena_reset_empty_blocks` /
    /// `arena_reset_all_blocks_to_zero`, and are never fed into the
    /// inline bump allocator (no `INLINE_STATE` entanglement). Walkers
    /// still traverse them so mark/trace reach cached objects; root
    /// scanners (`scan_parse_roots`, `scan_shape_cache_roots`,
    /// `scan_transition_cache_roots`) keep them marked.
    pub(crate) static LONGLIVED_ARENA: UnsafeCell<Arena> =
        UnsafeCell::new(Arena::new_lazy(HeapGeneration::Longlived, HeapSpace::Longlived));

    /// Copying nursery survivor semispaces. At most one is the active
    /// from-space at the start of a copying minor GC; the other is reset
    /// and used as to-space for fresh Eden survivors.
    pub(crate) static SURVIVOR_ARENA_0: UnsafeCell<Arena> =
        UnsafeCell::new(Arena::new_lazy(HeapGeneration::Nursery, HeapSpace::Survivor0));
    pub(crate) static SURVIVOR_ARENA_1: UnsafeCell<Arena> =
        UnsafeCell::new(Arena::new_lazy(HeapGeneration::Nursery, HeapSpace::Survivor1));
    pub(crate) static ACTIVE_SURVIVOR: Cell<usize> = const { Cell::new(0) };

    /// Generational-GC old-generation arena (gen-GC Phase B per
    /// `docs/generational-gc-plan.md`). Holds objects PROMOTED from
    /// the nursery (= the existing `ARENA`, treated as nursery in
    /// the gen-GC model). Empty in Phase B — Phase C's minor GC
    /// will populate it via the evacuation path. Same `Arena`
    /// shape as the others; same walker / tracer integration so
    /// every existing pass already covers it once `arena_walk_*`
    /// extends to a third region.
    ///
    /// Old-arena blocks are never reset by `arena_reset_empty_blocks`
    /// (same lifetime contract as longlived blocks from the nursery
    /// reset path), and never feed the inline bump allocator. Full
    /// mark-sweep can reclaim completely dead old blocks through the
    /// dedicated old-arena reset/deallocation path.
    pub(crate) static OLD_ARENA: UnsafeCell<Arena> =
        UnsafeCell::new(Arena::new_lazy(HeapGeneration::Old, HeapSpace::Old));

    /// Inline allocator state — a cache of the current arena block's
    /// `(data, offset, size)` triple, exposed via a stable pointer so
    /// codegen can emit inline bump-allocate IR without going through
    /// any function call or `LocalKey::with` wrapper.
    ///
    /// `#[repr(C)]` on `InlineArenaState` keeps the field offsets stable
    /// (data=0, offset=8, size=16). The codegen reads/writes these fields
    /// directly via fixed GEPs, so changing the struct layout would
    /// silently break every emitted `new ClassName()`.
    pub(crate) static INLINE_STATE: UnsafeCell<InlineArenaState> = const { UnsafeCell::new(InlineArenaState {
        data: std::ptr::null_mut(),
        offset: 0,
        size: 0,
    }) };
}

/// Delta-maintenance for `OLD_GEN_IN_USE_BYTES` — see the thread-local's
/// doc comment for the full mutation-site inventory.
#[inline]
pub(crate) fn old_gen_in_use_bytes_add(delta: usize) {
    if delta == 0 {
        return;
    }
    OLD_GEN_IN_USE_BYTES.with(|c| c.set(c.get().saturating_add(delta)));
}

#[inline]
pub(crate) fn old_gen_in_use_bytes_sub(delta: usize) {
    if delta == 0 {
        return;
    }
    OLD_GEN_IN_USE_BYTES.with(|c| c.set(c.get().saturating_sub(delta)));
}
