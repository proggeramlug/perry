use super::*;

#[derive(Clone, Copy)]
struct RejectedStackWord {
    word: u64,
    block: crate::arena::ArenaBlockDiagnostic,
    header_type: Option<u8>,
    nanboxed: bool,
}

pub(super) struct RejectedStackWordsReport {
    enabled: bool,
    count: usize,
    /// Rejected words that carry a pointer NaN-box tag AND sit at a
    /// plausible object header: the shape of a dropped root. Raw words equal
    /// to a block base or a header address are Rust bookkeeping pointers
    /// (`*mut GcHeader`, block bases) and are counted only in `count`.
    nanboxed_plausible: usize,
    first: [Option<RejectedStackWord>; 3],
}

impl RejectedStackWordsReport {
    pub(super) fn new(enabled: bool) -> Self {
        Self {
            enabled,
            count: 0,
            nanboxed_plausible: 0,
            first: [None; 3],
        }
    }

    #[inline]
    pub(super) fn record_if_rejected(&mut self, word: u64, valid_ptrs: &ValidPointerSet) {
        // The accepted path never calls this method. With the knob off, the
        // rejected path pays this one cached bool test and returns.
        if !self.enabled {
            return;
        }
        let tag = word & TAG_MASK;
        let nanboxed = tag == POINTER_TAG || tag == STRING_TAG || tag == BIGINT_TAG;
        let candidate = if nanboxed {
            let ptr = (word & POINTER_MASK) as usize;
            if ptr == 0 || valid_ptrs.contains(&ptr) {
                return;
            }
            ptr
        } else {
            if !(0x1000..=0x0000_FFFF_FFFF_FFFF).contains(&word) {
                return;
            }
            let ptr = word as usize;
            if valid_ptrs.contains(&ptr) || valid_ptrs.enclosing_object(ptr).is_some() {
                return;
            }
            ptr
        };
        let Some(block) = crate::arena::arena_block_diagnostic_for_addr(candidate) else {
            return;
        };
        self.count = self.count.saturating_add(1);
        let header_type = plausible_header_type(candidate, block);
        if nanboxed && header_type.is_some() {
            self.nanboxed_plausible = self.nanboxed_plausible.saturating_add(1);
        }
        if let Some(slot) = self.first.iter_mut().find(|slot| slot.is_none()) {
            *slot = Some(RejectedStackWord {
                word,
                block,
                header_type,
                nanboxed,
            });
        }
    }

    fn print_sample(prefix: &str, sample: RejectedStackWord) {
        let (plausible, type_name) = sample
            .header_type
            .map(|obj_type| ("yes", gc_type_info(obj_type).map_or("?", |info| info.name)))
            .unwrap_or(("no", "none"));
        let report = format!(
            "{}0x{:x} block=0x{:x} space={} header_plausible={} type={} nanboxed={}",
            prefix,
            sample.word,
            sample.block.base,
            sample.block.space.as_str(),
            plausible,
            type_name,
            if sample.nanboxed { "yes" } else { "no" },
        );
        #[cfg(test)]
        super::super::telemetry::test_record_full_verify_line(&report);
        eprintln!("{report}");
    }
}

impl Drop for RejectedStackWordsReport {
    fn drop(&mut self) {
        if !self.enabled {
            return;
        }
        match self.first[0] {
            Some(first) => Self::print_sample(
                &format!(
                    "[gc-full-verify] stack_words_rejected_in_blocks={} nanboxed_plausible={} first=",
                    self.count, self.nanboxed_plausible
                ),
                first,
            ),
            None => {
                let report = "[gc-full-verify] stack_words_rejected_in_blocks=0 nanboxed_plausible=0 first=0x0 block=0x0 space=none header_plausible=no type=none nanboxed=no";
                #[cfg(test)]
                super::super::telemetry::test_record_full_verify_line(report);
                eprintln!("{report}");
            }
        }
        for (index, sample) in self.first.iter().copied().enumerate().skip(1) {
            if let Some(sample) = sample {
                Self::print_sample(
                    &format!(
                        "[gc-full-verify] stack_word_rejected_sample={} word=",
                        index + 1
                    ),
                    sample,
                );
            }
        }
    }
}

fn plausible_header_type(
    candidate: usize,
    block: crate::arena::ArenaBlockDiagnostic,
) -> Option<u8> {
    let plausible_at = |addr: usize| {
        if addr < block.base || addr.checked_add(GC_HEADER_SIZE)? > block.used_end {
            return None;
        }
        let header = addr as *const GcHeader;
        let (size, obj_type) = unsafe { ((*header).size as usize, (*header).obj_type) };
        if size < GC_HEADER_SIZE
            || addr.checked_add(size)? > block.used_end
            || !gc_type_is_arena_walkable(obj_type)
        {
            return None;
        }
        Some(obj_type)
    };
    plausible_at(candidate).or_else(|| candidate.checked_sub(GC_HEADER_SIZE).and_then(plausible_at))
}
