//! Early entry for the existing builtin RegExp test implementation.
//! Admission does not run JS or allocate managed cells. The nonstateful
//! engine path uses only native program storage; the stateful path establishes
//! its own receiver/subject handles before lastIndex coercion can run JS.

use crate::value::JSValue;

pub(super) unsafe fn try_dispatch(receiver: f64, subject: f64) -> Option<f64> {
    #[cfg(test)]
    if FORCE_DECLINE.with(|flag| flag.get()) {
        return None;
    }
    let regexp = JSValue::from_bits(receiver.to_bits()).as_pointer::<crate::regex::RegExpHeader>();
    if !crate::regex::regex_header_has_magic(regexp)
        || crate::object::exotic_expando::exotic_has_own_property(
            crate::object::exotic_expando::ExoticKind::RegExp,
            regexp as usize,
            "test",
        )
        || !crate::object::regex_proto_thunks::regexp_prototype_test_is_canonical(receiver)
    {
        return None;
    }
    // Preserve the original recursion accounting, including reentrant
    // lastIndex coercion. At its limit, decline to the unchanged generic
    // guard and its existing reporting/null-object return.
    let _depth = super::CallMethodDepthGuard::enter("test")?;
    let string = JSValue::from_bits(subject.to_bits()).as_string_ptr();
    let answer = crate::regex::js_regexp_test(regexp, string) != 0;
    #[cfg(test)]
    FAST_RETURNS.with(|count| count.set(count.get() + 1));
    Some(f64::from_bits(JSValue::bool(answer).bits()))
}

#[cfg(test)]
thread_local! {
    pub(super) static FORCE_DECLINE: std::cell::Cell<bool> = const { std::cell::Cell::new(false) };
    pub(super) static FAST_RETURNS: std::cell::Cell<u64> = const { std::cell::Cell::new(0) };
    pub(super) static GENERIC_VECTORS: std::cell::Cell<u64> = const { std::cell::Cell::new(0) };
}

#[cfg(test)]
pub(super) fn note_generic_vectors() {
    GENERIC_VECTORS.with(|count| count.set(count.get() + 1));
}
