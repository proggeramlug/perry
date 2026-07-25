//! Checked unboxing of dynamic-call callees.
//!
//! Split out of `dispatch.rs` to keep that module under the 2000-line cap.

use super::dispatch::throw_not_callable;

/// Unbox a dynamic-call callee to its closure pointer, throwing
/// `TypeError: value is not a function` when the value is not a heap
/// pointer.
///
/// Issue #5504: the call-emission path used to mask the callee's low 48
/// bits unconditionally and hand them to `js_closure_callN` as a
/// `*const ClosureHeader`. For a non-callable NUMBER whose mantissa's low
/// 48 bits happen to form an in-range address (e.g. `1e-8` →
/// `0x798E_E230_8C3A`), `get_valid_func_ptr`'s range check passed and the
/// subsequent `read_volatile(closure + 12)` dereferenced a wild pointer →
/// SIGSEGV. A range check alone cannot distinguish a real closure pointer
/// from a mantissa-derived address; only a tag check on the full
/// NaN-boxed value can, and it must happen BEFORE the low-48 mask. This
/// runs at the codegen unbox site where the original `f64` is still
/// available. A callable value (closure, bound method/function, native
/// handle) is always `POINTER_TAG`; numbers, strings, bigints, booleans,
/// null and undefined are not, and throw here.
#[no_mangle]
pub extern "C" fn js_closure_unbox_callee_checked(callee: f64) -> i64 {
    let bits = callee.to_bits();
    if bits & crate::value::TAG_MASK != crate::value::POINTER_TAG {
        stale_callee_diag(bits);
        throw_not_callable();
    }
    (bits & crate::value::POINTER_MASK) as i64
}

/// PERRY_GC_STALE_DIAG: when a non-callable callee's raw bits look like a bare
/// heap ADDRESS (top-16 zero, plausible range), it is almost certainly
/// forwarding-pointer bytes read through a STALE object reference — the reader
/// holds a from-space pointer to a moved object whose first field was
/// overwritten by the forwarding pointer. Print the pointed-to (to-space)
/// object's identity so the un-enumerated root holding the stale reference can
/// be identified by what it targets. Zero cost unless the env is set.
#[cold]
#[inline(never)]
fn stale_callee_diag(bits: u64) {
    if std::env::var_os("PERRY_GC_STALE_DIAG").is_none() {
        return;
    }
    // Bare address: not NaN-boxed (top bits zero), inside the plausible heap VA.
    if bits >> 48 != 0 || bits < 0x0010_0000 {
        eprintln!("[stale-diag] non-callable callee bits=0x{bits:x} (not a bare address)");
        return;
    }
    let addr = bits as usize;
    let generation = crate::arena::classify_heap_generation(addr);
    let space = crate::arena::classify_heap_space(addr);
    let mut obj_type = -1i32;
    let mut class_id = -1i64;
    // Only dereference when the page classifier knows the region (registered
    // arena page ⇒ mapped).
    if !matches!(generation, crate::arena::HeapGeneration::Unknown) {
        unsafe {
            let header =
                (addr as *const u8).sub(crate::gc::GC_HEADER_SIZE) as *const crate::gc::GcHeader;
            obj_type = (*header).obj_type as i32;
            // First payload word often carries identity info; print raw for
            // offline decoding.
            class_id = *(addr as *const i64);
        }
    }
    eprintln!(
        "[stale-diag] non-callable callee is a BARE ADDRESS 0x{addr:x} gen={generation:?} space={space:?} target_obj_type={obj_type} first_word=0x{class_id:x} — forwarding bytes read through a stale (unrooted) reference"
    );
}

/// #6475: receiver-aware variant of [`js_closure_unbox_callee_checked`] for
/// the fused member-call lowering (`o.m(args)` compiled as property-get +
/// `js_closure_callN`). An object-literal method carries its `this` baked
/// into a reserved capture slot at construction time, and that slot WINS over
/// the `IMPLICIT_THIS` cell codegen sets around the call — so a method
/// inherited through `Object.setPrototypeOf(obj, proto)` ran with `this`
/// bound to the PROTO literal instead of the receiver. `js_native_call_method`
/// (the by-name dispatcher) already rebinds via `clone_closure_rebind_this`;
/// this brings the fused path to parity. effect's Pipeable
/// (`TagClass.pipe(...)` in `HttpRouter.Tag`) resolved `pipe` off the Tag
/// prototype chain and composed against the wrong `this`, so
/// `HttpApiBuilder.group(...)` returned a curried function instead of a
/// Layer ("Not a valid effect: undefined" at web.ts startup).
///
/// `clone_closure_rebind_this` is a no-op for closures that don't capture
/// `this` (plain functions, arrows), so receiverless shapes and the common
/// own-method call (baked `this` == receiver) keep their exact behavior.
#[no_mangle]
pub extern "C" fn js_closure_unbox_callee_checked_rebind(callee: f64, receiver: f64) -> i64 {
    let bits = callee.to_bits();
    if bits & crate::value::TAG_MASK != crate::value::POINTER_TAG {
        throw_not_callable();
    }
    let rebound = crate::closure::clone_closure_rebind_this(bits, receiver);
    (rebound & crate::value::POINTER_MASK) as i64
}

/// Keepalive: generated code is the only caller (#6475).
#[used]
static KEEP_JS_CLOSURE_UNBOX_CALLEE_CHECKED_REBIND: extern "C" fn(f64, f64) -> i64 =
    js_closure_unbox_callee_checked_rebind;
