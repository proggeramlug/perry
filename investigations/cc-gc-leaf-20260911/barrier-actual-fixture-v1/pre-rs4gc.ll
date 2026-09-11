; ModuleID = '/root/cc-perf-native-recv-0909/gc-leaf-census-20260911/compile-v2/fixture-on-bitcode/pid-3681148-attempt-0/pre-rs4gc.bc'
source_filename = "perry_module"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@diagnostic_fixture_ts_.str.0 = private unnamed_addr constant [77 x i8] c"/root/cc-perf-native-recv-0909/gc-leaf-census-20260911/diagnostic_fixture.ts\00"
@diagnostic_fixture_ts_.str.0.bytes = private unnamed_addr constant [2 x i8] c"!\00"
@diagnostic_fixture_ts_.str.1.bytes = private unnamed_addr constant [5 x i8] c"seed\00"
@diagnostic_fixture_ts_.str.2.bytes = private unnamed_addr constant [5 x i8] c"kept\00"
@diagnostic_fixture_ts_.str.3.bytes = private unnamed_addr constant [5 x i8] c"text\00"
@diagnostic_fixture_ts_.str.4.bytes = private unnamed_addr constant [6 x i8] c"value\00"
@diagnostic_fixture_ts_.str.5.bytes = private unnamed_addr constant [2 x i8] c":\00"
@diagnostic_fixture_ts_.str.6.bytes = private unnamed_addr constant [6 x i8] c"slice\00"
@perry_class_keys_packed_diagnostic_fixture_ts__0 = private unnamed_addr constant [12 x i8] c"text\00value\00\00"
@diagnostic_fixture_ts_.str.1 = private unnamed_addr constant [11 x i8] c"allocating\00"
@diagnostic_fixture_ts_.str.2 = private unnamed_addr constant [12 x i8] c"dynamicCall\00"
@diagnostic_fixture_ts_.str.3 = private unnamed_addr constant [9 x i8] c"exercise\00"
@diagnostic_fixture_ts_.str.4 = private unnamed_addr constant [33 x i8] c"new __AnonShape_2a938cab61a60894\00"
@diagnostic_fixture_ts_.str.5 = private unnamed_addr constant [10 x i8] c"increment\00"
@diagnostic_fixture_ts_.str.6 = private unnamed_addr constant [78 x i8] c"function allocating(text: string): string {\0A    return text.slice(1) + \22!\22;\0A}\00"
@diagnostic_fixture_ts_.str.7 = private unnamed_addr constant [73 x i8] c"function dynamicCall(fn: any, value: any): any {\0A    return fn(value);\0A}\00"
@diagnostic_fixture_ts_.str.8 = private unnamed_addr constant [308 x i8] c"function exercise(seed: number): string {\0A    const fresh: any = { text: \22seed\22, value: seed };\0A    fresh.text = \22kept\22;\0A    fresh.value = Number.isSafeInteger(seed) ? seed : 0;\0A    const increment: any = (n: number) => n + 1;\0A    return allocating(fresh.text) + \22:\22 + dynamicCall(increment, fresh.value);\0A}\00"
@diagnostic_fixture_ts_.str.9 = private unnamed_addr constant [21 x i8] c"(n: number) => n + 1\00"
@PERRY_SYMBOL_PROPERTY_IC_EPOCH = external global i64
@PERRY_GC_POLL_ARMED = external global i32
@PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED = external global i8
@PERRY_CLASS_PROTOTYPE_FAST_GUARDS_INVALIDATED = external global i8
@PERRY_CLASS_PROTOTYPE_FAST_GUARDS_INVALIDATED_BY_METHOD = external global [65536 x i8]
@PERRY_PER_OBJECT_LAYOUTS_ANY = external global i32
@PERRY_LAYOUT_ADDR_FILTER = external global [64 x i64]
@PERRY_YOUNG_LAYOUT_RECORDS = external global i32
@PERRY_ARRAY_INDEX_FAST_PATH_INVALIDATED = external global i8
@PERRY_ARRAY_PROTO_ITERATOR_PATCHED = external global i8
@PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT = external global i32
@PERRY_HOT_TSD_KEY = external global i64
@PERRY_TA_KIND_CACHE = external global [64 x i64]
@PERRY_U8_INLINE_CACHE = external global [64 x i64]
@PERRY_TA_VIEW_GUARD = external global i64
@perry_null_guard_zero_diagnostic_fixture_ts = internal global i32 0
@perry_class_keys_diagnostic_fixture_ts____AnonShape_2a938cab61a60894 = internal global i64 0
@perry_class_shape_id_diagnostic_fixture_ts____AnonShape_2a938cab61a60894 = global i32 0
@perry_class_header_image_diagnostic_fixture_ts____AnonShape_2a938cab61a60894 = internal global <2 x i64> zeroinitializer
@diagnostic_fixture_ts_.str.0.handle = internal global double 0.000000e+00
@diagnostic_fixture_ts_.str.1.handle = internal global double 0.000000e+00
@diagnostic_fixture_ts_.str.2.handle = internal global double 0.000000e+00
@diagnostic_fixture_ts_.str.3.handle = internal global double 0.000000e+00
@diagnostic_fixture_ts_.str.4.handle = internal global double 0.000000e+00
@diagnostic_fixture_ts_.str.5.handle = internal global double 0.000000e+00
@diagnostic_fixture_ts_.str.6.dispatch = private unnamed_addr constant { i32, i32, i64, ptr } { i32 5, i32 0, i64 -3123560339533080399, ptr @diagnostic_fixture_ts_.str.6.bytes }
@diagnostic_fixture_ts_.str.6.handle = internal global double 0.000000e+00
@perry_typed_shape_raw_f64_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894 = private unnamed_addr constant [1 x i64] [i64 2]
@perry_typed_shape_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894 = private unnamed_addr constant [1 x i64] [i64 1]

declare void @js_gc_init()

declare void @js_typed_feedback_maybe_dump_trace()

declare void @js_set_process_entry_path(ptr, i32)

declare void @js_stdlib_init_dispatch()

declare void @perry_app_group_init(ptr, i32)

declare void @perry_update_notify_startup(ptr, i32)

declare void @perry_macos_bundle_chdir()

declare i32 @perry_i18n_locale_index_for(i64, i32)

declare void @perry_i18n_init(ptr, ptr, i32, i32)

declare void @perry_i18n_set_currencies(ptr, i32)

declare i32 @perry_i18n_plural_category(i32, double)

declare void @js_register_function_name_static(ptr, ptr, i32)

declare void @js_register_function_name(ptr, ptr, i32)

declare void @js_register_function_source_static(ptr, ptr, i32, i32)

declare void @js_register_function_source(ptr, ptr, i32, i32)

declare void @js_console_log_dynamic(double)

declare void @js_console_log_number(double)

declare void @js_console_error_dynamic(double)

declare void @js_console_error_number(double)

declare void @js_console_warn_dynamic(double)

declare void @js_console_warn_number(double)

declare void @js_console_dir_with_options(double, double)

declare double @js_console_method_by_value(double)

declare double @js_nanbox_string(i64)

; Function Attrs: nounwind willreturn memory(none)
declare double @js_nanbox_pointer(i64) #0

; Function Attrs: nounwind willreturn memory(none)
declare i64 @js_nanbox_get_pointer(double) #0

declare double @js_native_handle_new_owned(i64, i64, i32, i32, ptr, ptr, i64)

declare double @js_native_handle_new_borrowed(i64, i64, i32, i32, ptr, i64)

declare i64 @js_native_handle_unwrap(double, i64, i32, i32, i32)

declare i64 @js_canonical_handle_id(double)

declare i64 @js_canonical_handle_id_from_addr(i64)

declare double @js_canonical_common_handle_value(i64)

declare i64 @js_string_from_bytes(ptr, i32)

declare i64 @js_string_from_wtf8_bytes(ptr, i32)

; Function Attrs: nounwind willreturn memory(read)
declare i32 @js_is_truthy(double) #1

declare double @js_native_abi_check_f64(double)

; Function Attrs: nounwind willreturn memory(none)
declare i32 @js_typed_f64_arg_guard(double) #0

declare double @js_typed_f64_arg_to_raw(double)

; Function Attrs: nounwind willreturn memory(none)
declare i32 @js_typed_i32_arg_guard(double) #0

; Function Attrs: nounwind willreturn memory(none)
declare i32 @js_typed_i32_arg_to_raw(double) #0

; Function Attrs: nounwind willreturn memory(none)
declare i32 @js_typed_i1_arg_guard(double) #0

; Function Attrs: nounwind willreturn memory(none)
declare i32 @js_typed_i1_arg_to_raw(double) #0

; Function Attrs: nounwind willreturn memory(none)
declare i32 @js_typed_string_arg_guard(double) #0

declare i64 @js_typed_string_arg_to_raw(double)

declare i32 @js_param_type_guard(double, ptr, i32)

declare float @js_native_abi_check_f32(double)

declare i8 @js_native_abi_check_i8(double)

declare i16 @js_native_abi_check_i16(double)

declare i32 @js_native_abi_check_i32(double)

declare i64 @js_native_abi_check_i64(double)

declare i8 @js_native_abi_check_u8(double)

declare i16 @js_native_abi_check_u16(double)

declare i32 @js_native_abi_check_u32(double)

declare i64 @js_native_abi_check_u64(double)

declare i64 @js_native_abi_check_usize(double)

declare i64 @js_native_abi_check_isize(double)

declare double @js_native_abi_materialize_i64(i64)

declare double @js_native_abi_materialize_u64(i64)

declare i64 @js_native_abi_check_string_ptr(double)

declare i64 @js_native_abi_check_ptr(double)

declare ptr @js_native_abi_check_buffer_data_ptr(double)

declare i64 @js_native_abi_check_buffer_byte_len(double)

declare i64 @js_native_abi_check_promise(double)

declare i64 @js_native_abi_check_pod_object(double)

declare double @js_date_now()

declare void @js_gc_register_global_root(i64)

declare i64 @js_string_concat(i64, i64)

declare double @js_string_concat_box(double, double)

declare i64 @js_jsvalue_to_string(double)

declare i64 @js_jsvalue_to_string_method(double)

declare i64 @js_jsvalue_to_string_coerce(double)

declare i64 @js_string_concat_value(i64, double)

declare double @js_string_concat_site_value(i64, i64, double)

declare i64 @js_value_concat_string(double, i64)

declare double @js_string_concat_value_box(i64, double)

declare double @js_string_add_value(double, double)

declare double @js_value_add_string(double, double)

declare i64 @js_string_concat_chain(i64, i32)

declare i64 @js_string_append_chain(i64, i32)

declare i64 @js_string_append(i64, i64)

declare i64 @js_string_append_known_heap(i64, i64)

declare i32 @js_string_index_of(i64, i64)

declare i32 @js_string_index_of_from(i64, i64, i32)

declare i32 @js_string_position_to_index(double)

declare i64 @js_string_slice(i64, i32, i32)

declare i64 @js_string_substring(i64, i32, i32)

declare i64 @js_string_substr(i64, double, double)

declare i64 @js_string_split(i64, i64)

declare i64 @js_string_split_n(i64, i64, i32)

declare double @js_string_split_part_value(i64, i64, i32)

declare double @js_string_split_part_utf16_length(i64, i64, i32)

declare double @js_string_to_upper_case_split_part_utf16_length(i64, i64, i32)

declare i32 @js_string_to_upper_case_index_of(i64, i64)

declare i64 @js_string_split_value(i64, double, double)

declare double @js_math_trunc(double)

declare double @js_math_round(double)

declare double @js_math_sign(double)

declare double @js_math_imul(double, double)

declare double @js_math_pow(double, double)

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.sqrt.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.floor.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.ceil.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fabs.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.copysign.f64(double, double) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #3

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i16 @llvm.bswap.i16(i16) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.bswap.i32(i32) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.bswap.i64(i64) #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #4

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr writeonly captures(none), ptr readonly captures(none), i64, i1 immarg) #5

declare i64 @js_json_stringify(double, i32)

declare i64 @js_map_alloc(i32)

declare i64 @js_text_encoder_encode_into_llvm(double, double)

declare i64 @js_value_typeof(double)

declare i32 @js_value_typeof_tag(double)

declare i32 @js_string_starts_with(i64, i64)

declare i32 @js_string_ends_with(i64, i64)

declare i64 @js_string_search_value_to_string(double, i32)

declare i32 @js_string_starts_with_at(i64, i64, i32)

declare i32 @js_string_ends_with_at(i64, i64, i32)

declare i64 @js_closure_alloc(ptr, i32)

declare i64 @js_closure_alloc_init(ptr, i32, ptr)

declare i64 @js_closure_alloc_singleton(ptr)

declare i64 @js_closure_alloc_with_captures_singleton(ptr, i32, ptr)

declare void @js_closure_set_capture_bits(i64, i32, i64)

declare void @js_closure_set_box_capture_ptr(i64, i32, i64)

declare i64 @js_closure_get_capture_bits(i64, i32)

declare void @js_closure_set_capture_f64(i64, i32, double)

declare double @js_closure_get_capture_f64(i64, i32)

declare void @js_register_closure_rest(ptr, i32)

declare void @js_register_closure_synthetic_arguments(ptr, i32)

declare void @js_register_closure_rest_and_arguments(ptr, i32)

declare void @js_register_closure_arity(ptr, i32)

declare void @js_register_closure_length(ptr, i32)

declare void @js_register_closure_arrow_function(ptr)

declare void @js_register_closure_trusted_direct(ptr, ptr, i32, i64)

declare void @js_register_closure_versioned_loop_direct(ptr, ptr, i32, i64)

declare ptr @js_closure_resolve_versioned_loop_direct_call(i64, i32)

declare void @js_register_closure_strict_function(ptr)

declare void @js_register_closure_async_function(ptr)

declare void @js_register_closure_generator_function(ptr)

declare void @js_register_closure_async_generator_function(ptr)

declare i64 @js_closure_unbox_callee_checked(double)

declare i64 @js_closure_unbox_callee_checked_rebind(double, double)

declare double @js_closure_call0(i64)

declare double @js_closure_call1(i64, double)

declare double @js_closure_call1_receiverless(i64, double)

declare double @js_closure_call2(i64, double, double)

declare double @js_closure_call3(i64, double, double, double)

declare ptr @js_closure_resolve_arrow_direct_call(i64, i32)

declare double @js_closure_call4(i64, double, double, double, double)

declare double @js_closure_call5(i64, double, double, double, double, double)

declare double @js_closure_call6(i64, double, double, double, double, double, double)

declare double @js_closure_call7(i64, double, double, double, double, double, double, double)

declare double @js_closure_call8(i64, double, double, double, double, double, double, double, double)

declare double @js_closure_call9(i64, double, double, double, double, double, double, double, double, double)

declare double @js_closure_call10(i64, double, double, double, double, double, double, double, double, double, double)

declare double @js_closure_call11(i64, double, double, double, double, double, double, double, double, double, double, double)

declare double @js_closure_call12(i64, double, double, double, double, double, double, double, double, double, double, double, double)

declare double @js_closure_call13(i64, double, double, double, double, double, double, double, double, double, double, double, double, double)

declare double @js_closure_call14(i64, double, double, double, double, double, double, double, double, double, double, double, double, double, double)

declare double @js_closure_call15(i64, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double)

declare double @js_closure_call16(i64, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double)

declare i64 @js_array_map(i64, i64)

declare void @js_array_map_discard(i64, i64)

declare i64 @js_array_filter(i64, i64)

declare i64 @js_array_concat(i64, i64)

declare i64 @js_array_concat_new(i64, i64)

declare i64 @js_error_new()

declare i64 @js_error_new_with_message(i64)

declare i64 @js_error_new_from_value(double)

declare i64 @js_error_new_kind_from_value(i32, double)

declare i64 @js_error_new_with_cause_from_value(double, double)

declare i64 @js_error_new_kind_with_options_from_value(i32, double, double)

declare double @js_assert_assertion_error_ctor(double)

declare double @js_assert_assert_ctor(double)

declare void @js_throw_type_error_property_access(i32, ptr, i64)

declare void @js_throw_type_error_not_a_function(ptr, i64, ptr, i64)

declare void @js_throw_error_with_code(ptr, i64, ptr, i64, i32)

declare i64 @js_map_set(i64, double, double)

declare i64 @js_map_set_string_number(i64, i64, double)

declare i64 @js_map_set_string_key(i64, i64, double)

declare i64 @js_map_set_string_i32(i64, i64, i32)

declare i64 @js_map_set_string_u32(i64, i64, i32)

declare i64 @js_map_set_string_f32(i64, i64, float)

declare i64 @js_map_set_string_bool(i64, i64, i32)

declare i64 @js_map_set_string_string(i64, i64, i64)

declare i64 @js_map_set_number_key(i64, double, double)

declare double @js_map_get(i64, double)

declare double @js_declared_map_get(double, double)

declare double @js_map_get_string_key(i64, i64)

declare double @js_map_get_number_key(i64, double)

declare i32 @js_map_has(i64, double)

declare i32 @js_map_has_string_key(i64, i64)

declare i32 @js_map_has_number_key(i64, double)

declare i32 @js_map_delete(i64, double)

declare i32 @js_map_delete_string_key(i64, i64)

declare i32 @js_map_delete_number_key(i64, double)

declare i64 @js_object_keys(i64)

declare i64 @js_object_keys_value(double)

declare i64 @js_for_in_keys_value(double)

declare i64 @js_for_in_keys_stable_value(double)

declare double @js_is_finite(double)

declare i32 @js_is_undefined_or_bare_nan(double)

declare double @js_math_min_array(i64)

declare double @js_math_max_array(i64)

declare double @js_math_min2(double, double)

declare double @js_math_max2(double, double)

declare i64 @js_string_coerce(double)

declare i64 @js_string_coerce_method_this(double, ptr, i64)

declare i64 @js_array_slice(i64, i32, i32)

declare i64 @js_array_slice_values(i64, double, double)

declare double @js_array_shift_f64(i64)

declare i64 @js_set_alloc(i32)

declare i64 @js_set_from_array(i64)

declare i64 @js_set_from_iterable(double)

declare i64 @js_map_from_array(i64)

declare i64 @js_map_from_iterable(double)

declare double @js_object_has_property(double, double)

declare double @js_in_operator(double, double)

declare double @js_private_brand_check(double, double, i32, ptr, i32, i32, i32)

declare double @js_private_guard(double, double, i32, ptr, i32, i32, i32)

declare double @js_private_brand_add(double, i32)

declare double @js_private_field_add(double, i32, double, double)

declare double @js_class_field_add(double, double, double)

declare double @js_class_computed_field_key(double, i32, ptr, i64)

declare double @js_fs_to_unix_timestamp(double)

declare i32 @js_fs_write_file_sync(double, double)

declare i32 @js_fs_write_file_sync_options(double, double, double)

declare i32 @js_fs_append_file_sync(double, double)

declare i32 @js_fs_append_file_sync_options(double, double, double)

declare i32 @js_fs_exists_sync(double)

declare i64 @js_fs_read_file_sync(double)

declare double @js_fs_read_file_dispatch(double, double)

declare double @js_fs_open_as_blob(double, double)

declare double @js_fs_promises_read_file(double, double)

declare double @js_fs_promises_write_file(double, double, double)

declare double @js_fs_promises_append_file(double, double, double)

declare double @js_fs_promises_mkdir(double, double)

declare double @js_fs_promises_rmdir(double, double)

declare i32 @js_fs_mkdir_sync(double)

declare i32 @js_fs_mkdir_sync_options(double, double)

declare i32 @js_fs_unlink_sync(double)

declare double @js_fs_readdir_sync(double, double)

declare double @js_fs_stat_sync(double)

declare double @js_fs_stat_sync_options(double, double)

declare double @js_fs_lstat_sync(double)

declare double @js_fs_lstat_sync_options(double, double)

declare i32 @js_fs_rename_sync(double, double)

declare i32 @js_fs_copy_file_sync(double, double)

declare i32 @js_fs_copy_file_sync_flags(double, double, double)

declare i32 @js_fs_cp_sync(double, double)

declare i32 @js_fs_cp_sync_options(double, double, double)

declare i32 @js_fs_chmod_sync(double, double)

declare i32 @js_fs_chown_sync(double, double, double)

declare i32 @js_fs_lchown_sync(double, double, double)

declare i32 @js_fs_lchmod_sync(double, double)

declare i32 @js_fs_truncate_sync(double, double)

declare i32 @js_fs_ftruncate_sync(double, double)

declare i32 @js_fs_fsync_sync(double)

declare i32 @js_fs_fdatasync_sync(double)

declare i32 @js_fs_fchmod_sync(double, double)

declare i32 @js_fs_fchown_sync(double, double, double)

declare double @js_fs_fstat_sync(double)

declare double @js_fs_fstat_sync_options(double, double)

declare i32 @js_fs_utimes_sync(double, double, double)

declare i32 @js_fs_lutimes_sync(double, double, double)

declare i32 @js_fs_futimes_sync(double, double, double)

declare double @js_fs_readv_sync(double, double, double)

declare double @js_fs_writev_sync(double, double, double)

declare double @js_fs_statfs_sync(double)

declare double @js_fs_statfs_sync_options(double, double)

declare double @js_fs_opendir_sync(double)

declare double @js_fs_glob_sync(double)

declare double @js_fs_glob_sync_options(double, double)

declare i32 @js_fs_link_sync(double, double)

declare i32 @js_fs_symlink_sync(double, double)

declare double @js_fs_symlink_callback(double, double, double, double)

declare i64 @js_fs_readlink_sync(double)

declare i64 @js_fs_readlink_sync_options(double, double)

declare double @js_fs_readlink_dispatch(double, double)

declare double @js_fs_open_sync(double, double)

declare i32 @js_fs_close_sync(double)

declare double @js_fs_read_sync(double, double, double, double, double)

declare double @js_fs_read_sync_options(double, double, double)

declare double @js_fs_write_sync(double, double)

declare double @js_fs_write_string_sync_options(double, double, double)

declare double @js_fs_write_buffer_sync(double, double, double, double, double)

declare double @js_fs_write_sync_options_dispatch(double, double, double)

declare i32 @js_fs_access_sync(double)

declare i32 @js_fs_access_sync_mode(double, double)

declare double @js_fs_access_sync_throw(double)

declare double @js_fs_access_sync_throw_mode(double, double)

declare i64 @js_fs_realpath_sync(double)

declare double @js_fs_realpath_dispatch(double, double)

declare i64 @js_fs_mkdtemp_sync(double)

declare i64 @js_fs_mkdtemp_sync_options(double, double)

declare double @js_fs_mkdtemp_dispatch(double, double)

declare double @js_fs_mkdtemp_disposable_sync(double, double)

declare i32 @js_fs_rmdir_sync(double)

declare i32 @js_fs_rmdir_sync_options(double, double)

declare i32 @js_fs_rm_recursive(double)

declare i32 @js_fs_rm_recursive_options(double, double)

declare double @js_fs_create_write_stream(double, double)

declare double @js_fs_create_read_stream(double, double)

declare double @js_fs_utf8_stream_new(double)

declare double @js_fs_utf8_stream_call_without_new(double)

declare double @js_fs_utf8_stream_write(double, double)

declare double @js_fs_utf8_stream_flush(double, double)

declare double @js_fs_utf8_stream_flush_sync(double)

declare double @js_fs_utf8_stream_end(double, double)

declare double @js_fs_utf8_stream_destroy(double)

declare double @js_fs_utf8_stream_reopen(double, double)

declare double @js_fs_utf8_stream_on(double, double, double)

declare double @js_fs_utf8_stream_once(double, double, double)

declare double @js_fs_utf8_stream_off(double, double, double)

declare double @js_fs_utf8_stream_remove_all(double, double)

declare double @js_fs_utf8_stream_listener_count(double, double)

declare double @js_fs_utf8_stream_emit(double, double, double)

declare double @js_fs_read_file_callback(double, double, double)

declare double @js_fs_stats_is_file(double)

declare double @js_fs_stats_is_directory(double)

declare i64 @js_fs_read_file_binary(double)

declare double @js_number_coerce(double)

declare double @js_math_to_number(double)

declare i64 @js_set_add(i64, double)

declare i64 @js_set_add_string(i64, i64)

declare i64 @js_set_add_number(i64, double)

declare i64 @js_set_add_i32(i64, i32)

declare i64 @js_set_add_u32(i64, i32)

declare i64 @js_set_add_f32(i64, float)

declare i64 @js_set_add_bool(i64, i32)

declare i32 @js_set_has(i64, double)

declare double @js_readonly_set_has(double, double)

declare i32 @js_set_has_string(i64, i64)

declare i32 @js_set_has_number(i64, double)

declare i32 @js_set_has_i32(i64, i32)

declare i32 @js_set_has_u32(i64, i32)

declare i32 @js_set_has_f32(i64, float)

declare i32 @js_set_has_bool(i64, i32)

declare i32 @js_set_delete(i64, double)

declare i32 @js_set_delete_string(i64, i64)

declare i32 @js_set_delete_number(i64, double)

declare i32 @js_set_delete_i32(i64, i32)

declare i32 @js_set_delete_u32(i64, i32)

declare i32 @js_set_delete_f32(i64, float)

declare i32 @js_set_delete_bool(i64, i32)

declare i32 @js_set_size(i64)

declare i64 @js_set_union(i64, double)

declare i64 @js_set_intersection(i64, double)

declare i64 @js_set_difference(i64, double)

declare i64 @js_set_symmetric_difference(i64, double)

declare i32 @js_set_is_subset_of(i64, double)

declare i32 @js_set_is_superset_of(i64, double)

declare i32 @js_set_is_disjoint_from(i64, double)

declare i64 @js_string_to_lower_case(i64)

declare i64 @js_string_to_upper_case(i64)

declare i64 @js_string_to_locale_lower_case(i64, double)

declare i64 @js_string_to_locale_upper_case(i64, double)

declare void @js_string_validate_collator_args(double, double)

declare i64 @js_string_trim(i64)

declare i64 @js_string_trim_start(i64)

declare i64 @js_string_trim_end(i64)

declare i64 @js_string_big(i64)

declare i64 @js_string_blink(i64)

declare i64 @js_string_bold(i64)

declare i64 @js_string_fixed(i64)

declare i64 @js_string_italics(i64)

declare i64 @js_string_small(i64)

declare i64 @js_string_strike(i64)

declare i64 @js_string_sub(i64)

declare i64 @js_string_sup(i64)

declare i64 @js_string_anchor(i64, i64)

declare i64 @js_string_link(i64, i64)

declare i64 @js_string_fontcolor(i64, i64)

declare i64 @js_string_fontsize(i64, i64)

declare i64 @js_string_char_at(i64, i32)

declare double @js_string_index_get(i64, double)

declare double @js_string_index_get_boxed(double, double)

declare i32 @js_string_index_to_i32(double)

declare i32 @js_string_end_index_to_i32(double, i32)

declare double @js_typed_feedback_object_get_field_by_value_f64(i64, i64, double)

declare double @js_dyn_index_get(double, double)

declare double @js_packed_arraylike_index_get(double, double, ptr)

declare i32 @js_packed_arraylike_loop_guard(double, double, i32, ptr)

declare i64 @js_packed_arraylike_loop_guard_live(double, double, i32, ptr)

declare i64 @js_packed_arraylike_loop_revalidate_live(double, double, i32, ptr)

declare double @js_dyn_index_set(double, double, double)

declare double @js_dyn_index_set_strict(double, double, double, i32)

declare i64 @js_string_to_char_array(i64)

declare i64 @js_string_repeat(i64, double)

declare i64 @js_string_replace_string(i64, i64, i64)

declare i64 @js_string_replace_all_string(i64, i64, i64)

declare i32 @js_string_equals(i64, i64)

declare i32 @js_string_compare(i64, i64)

declare i32 @js_jsvalue_equals(double, double)

declare i32 @js_string_compare_value(double, double)

declare i64 @js_jsvalue_to_string_radix(double, double)

declare double @js_math_random()

declare double @js_webassembly_validate(double)

declare double @js_webassembly_compile(double)

declare double @js_webassembly_module_new(double)

declare double @js_webassembly_module_exports(double)

declare double @js_webassembly_module_imports(double)

declare double @js_webassembly_module_custom_sections(double, double)

declare double @js_webassembly_instantiate(double, double)

declare double @js_wasi_emit_warning()

declare double @js_webassembly_call_export_0(double, double)

declare double @js_webassembly_call_export_1(double, double, double)

declare double @js_webassembly_call_export_2(double, double, double, double)

declare double @js_webassembly_call_export_3(double, double, double, double, double)

declare double @js_webassembly_call_export_4(double, double, double, double, double, double)

declare void @js_console_log_spread(i64)

declare void @js_console_info_spread(i64)

declare void @js_console_debug_spread(i64)

declare void @js_console_error_spread(i64)

declare void @js_console_warn_spread(i64)

declare double @js_util_format(i64)

declare double @js_util_format_with_options(double, i64)

declare double @js_util_inspect(double, double)

declare double @js_util_debuglog(double, double)

declare double @js_util_diff(double, double)

declare double @js_util_inherits(double, double)

declare double @js_util_is_deep_strict_equal(double, double)

declare double @js_util_strip_vt_control_characters(double)

declare double @js_util_style_text(double, double, double)

declare double @js_util_get_call_sites(double, double)

declare double @js_util_promisify(double)

declare double @js_util_callbackify(double)

declare double @js_util_deprecate(double, double, double)

declare double @js_util_aborted(double, double)

declare double @js_util_transferable_abort_controller()

declare double @js_util_transferable_abort_signal(double)

declare double @js_util_parse_args(double)

declare double @js_boxed_number_new(double)

declare double @js_boxed_string_new(double, i32)

declare double @js_boxed_boolean_new(double)

declare double @js_util_types_is_arguments_object(double)

declare double @js_util_types_is_promise(double)

declare double @js_util_types_is_big_int_object(double)

declare double @js_util_types_is_symbol_object(double)

declare double @js_util_types_is_array_buffer(double)

declare double @js_util_types_is_shared_array_buffer(double)

declare double @js_util_types_is_any_array_buffer(double)

declare double @js_util_types_is_array_buffer_view(double)

declare double @js_util_types_is_data_view(double)

declare double @js_util_types_is_typed_array(double)

declare double @js_util_types_is_uint8_array(double)

declare double @js_util_types_is_int8_array(double)

declare double @js_util_types_is_int16_array(double)

declare double @js_util_types_is_uint16_array(double)

declare double @js_util_types_is_int32_array(double)

declare double @js_util_types_is_uint32_array(double)

declare double @js_util_types_is_float16_array(double)

declare double @js_util_types_is_float32_array(double)

declare double @js_util_types_is_float64_array(double)

declare double @js_util_types_is_uint8_clamped_array(double)

declare double @js_util_types_is_big_int64_array(double)

declare double @js_util_types_is_big_uint64_array(double)

declare double @js_util_types_is_map(double)

declare double @js_util_types_is_weak_map(double)

declare double @js_util_types_is_set(double)

declare double @js_util_types_is_weak_set(double)

declare double @js_util_types_is_date(double)

declare double @js_util_types_is_reg_exp(double)

declare double @js_util_types_is_async_function(double)

declare double @js_util_types_is_generator_function(double)

declare double @js_util_types_is_generator_object(double)

declare double @js_util_types_is_native_error(double)

declare double @js_util_types_is_number_object(double)

declare double @js_util_types_is_string_object(double)

declare double @js_util_types_is_boolean_object(double)

declare double @js_util_types_is_boxed_primitive(double)

declare double @js_util_types_is_external(double)

declare double @js_util_types_is_module_namespace_object(double)

declare double @js_util_types_is_key_object(double)

declare double @js_util_types_is_crypto_key(double)

declare double @js_util_types_is_proxy(double)

declare double @js_util_types_is_map_iterator(double)

declare double @js_util_types_is_set_iterator(double)

declare double @js_data_view_new(double, double, double)

declare double @js_data_view_get_direct(double, double, double, i32, i32)

declare double @js_data_view_set_direct(double, double, double, double, i32, i32)

declare i64 @js_getenv(i64)

declare double @js_getenv_value(i64)

declare void @js_setenv(i64, double)

declare void @js_removeenv(i64)

declare double @js_process_exit_code_get()

declare double @js_process_exit_code_set(double)

declare void @js_console_table(double)

declare void @js_console_table_with_properties(double, double)

declare void @js_console_trace(double)

declare void @js_console_trace_spread(i64)

declare i64 @js_process_cwd()

declare i64 @js_process_argv()

declare double @js_process_pid()

declare double @js_process_ppid()

declare double @js_process_uptime()

declare i64 @js_process_version()

declare double @js_process_versions()

declare double @js_process_memory_usage()

declare double @js_bigint_as_int_n_call(double, double)

declare double @js_bigint_as_uint_n_call(double, double)

declare double @js_v8_serialize(double)

declare double @js_v8_deserialize(double)

declare double @js_v8_get_heap_statistics()

declare double @js_v8_get_heap_code_statistics()

declare double @js_v8_get_heap_space_statistics()

declare double @js_v8_cached_data_version_tag()

declare double @js_v8_get_heap_snapshot(double)

declare double @js_v8_write_heap_snapshot(double, double)

declare double @js_v8_gc_profiler_new()

declare double @js_v8_gc_profiler_start(double)

declare double @js_v8_gc_profiler_stop(double)

declare double @js_v8_gc_profiler_report()

declare double @js_v8_serializer_new(double)

declare double @js_v8_deserializer_new(double)

declare double @js_v8_noop_undefined()

declare double @js_v8_is_building_snapshot()

declare double @js_v8_namespace(ptr, i64)

declare double @js_v8_throw_not_building_snapshot()

declare double @js_v8_promise_hook_register()

declare double @js_v8_promise_hooks_on_init(double)

declare double @js_v8_promise_hooks_on_before(double)

declare double @js_v8_promise_hooks_on_after(double)

declare double @js_v8_promise_hooks_on_settled(double)

declare double @js_v8_promise_hooks_create_hook(double)

declare double @js_process_thread_cpu_usage(double)

declare double @js_process_available_memory()

declare double @js_process_constrained_memory()

declare double @js_process_source_maps_enabled()

declare double @js_process_set_source_maps_enabled(double)

declare double @js_process_has_uncaught_exception_capture_callback()

declare double @js_process_set_uncaught_exception_capture_callback(double)

declare double @js_process_add_uncaught_exception_capture_callback(double)

declare double @js_process_getuid()

declare double @js_process_geteuid()

declare double @js_process_getgid()

declare double @js_process_getegid()

declare void @js_process_emit_warning(double, double, double)

declare double @js_process_cpu_usage(double)

declare double @js_process_resource_usage()

declare double @js_process_active_resources_info()

declare double @js_process_env()

declare double @js_process_hrtime_bigint()

declare double @js_process_hrtime(double)

declare double @js_process_title()

declare void @js_process_set_title(double)

declare void @js_process_chdir(i64)

declare void @js_process_chdir_jsv(double)

declare double @js_process_kill(double, double)

declare void @js_process_exit(double)

declare void @js_process_abort()

declare double @js_process_umask()

declare double @js_process_umask_set(double)

declare double @js_process_on(i64, i64)

declare double @js_process_add_listener(i64, i64)

declare double @js_process_once(i64, i64)

declare double @js_process_prepend_listener(i64, i64)

declare double @js_process_prepend_once_listener(i64, i64)

declare double @js_process_emit(i64, i64)

declare void @js_process_emit_before_exit(double)

declare void @js_process_emit_before_exit_pending()

declare void @js_process_run_exit_sequence()

declare void @js_process_run_finalization_exit()

declare void @js_trace_events_flush_output()

declare void @js_promise_report_unhandled_rejections()

declare i32 @js_process_pending_exit_code()

declare void @js_gc_release_current_thread_collection_side_allocations()

declare double @js_process_remove_listener(i64, i64)

declare double @js_process_off(i64, i64)

declare double @js_process_remove_all_listeners(i64)

declare double @js_process_listener_count(i64, i64)

declare i64 @js_process_listeners(i64)

declare i64 @js_process_raw_listeners(i64)

declare i64 @js_process_event_names()

declare double @js_process_set_max_listeners(double)

declare double @js_process_get_max_listeners()

declare double @js_process_get_builtin_module(double)

declare double @js_process_get_builtin_module_devirt(double)

declare double @js_process_execve(double, double, double)

declare double @js_module_is_builtin(double)

declare double @js_module_find_package_json(double, double, double)

declare double @js_module_find_source_map(double)

declare double @js_module_source_map_new(double, double)

declare double @js_module_register(double, double, double)

declare double @js_module_register_hooks(double)

declare void @js_process_next_tick(i64, i64)

declare double @js_process_stdin()

declare double @js_process_stdout()

declare double @js_process_stderr()

declare double @js_readline_set_raw_mode(double)

declare void @js_readline_stdin_on(i64, i64)

declare double @js_readline_stdin_remove_listener(i64, i64)

declare double @js_readline_stdin_pause()

declare double @js_readline_stdin_resume()

declare double @js_readline_stdin_unref()

declare double @js_readline_stdin_ref()

declare double @js_readline_stdin_destroy()

declare double @js_tty_isatty(double)

declare double @js_tty_read_stream_new(double)

declare double @js_tty_write_stream_new(double)

declare double @js_wasi_constructor_call(double)

declare double @js_process_stdin_isatty()

declare double @js_process_stdout_isatty()

declare double @js_process_stderr_isatty()

declare double @js_process_stdout_columns()

declare double @js_process_stdout_rows()

declare double @js_process_stdout_on(i64, i64)

declare i64 @js_os_platform()

declare i64 @js_os_arch()

declare i64 @js_os_type()

declare i64 @js_os_release()

declare i64 @js_os_hostname()

declare i64 @js_os_eol()

declare double @js_os_available_parallelism()

declare i64 @js_os_endianness()

declare i64 @js_os_dev_null()

declare i64 @js_os_machine()

declare i64 @js_os_loadavg()

declare i64 @js_os_version()

declare i64 @js_box_alloc_bits(i64)

declare i64 @js_box_get_bits(i64)

declare i64 @js_box_get_bits_named(i64, double)

declare void @js_box_set_bits(i64, i64)

declare i64 @js_box_get_bits_trusted(i64)

declare i64 @js_box_get_bits_trusted_named(i64, double)

declare void @js_box_set_bits_trusted_no_barrier(i64, i64)

declare i64 @js_box_alloc(double)

declare double @js_box_get(i64)

declare void @js_box_set(i64, double)

declare i64 @js_i32_box_alloc(i32)

declare i32 @js_i32_box_get(i64)

declare void @js_i32_box_set(i64, i32)

declare void @js_box_release(i64)

declare void @js_i32_box_release(i64)

declare void @js_bool_box_release(i64)

declare i64 @js_bool_box_alloc(i32)

declare i32 @js_bool_box_get(i64)

declare void @js_bool_box_set(i64, i32)

declare i64 @js_arguments_object_alloc(double, double, i32)

declare void @js_arguments_object_map_index(i64, i32, i64)

declare i64 @js_array_like_to_array(double)

declare i32 @js_object_get_class_id(i64)

declare i64 @js_object_alloc_with_parent(i32, i32, i32)

declare i64 @js_object_alloc_class_with_keys(i32, i32, i32, ptr, i32)

declare i64 @js_object_alloc_class_dynamic_parent(i32, i32, ptr, i32)

declare i64 @js_object_alloc_class_inline_keys(i32, i32, i32, i64)

declare i64 @js_object_alloc_class_inline_keys_stamped(i32, i32, i32, i64, i32)

declare i64 @js_build_class_keys_array(i32, i32, ptr, i32)

declare i32 @js_object_shape_id_for_keys(i64, i32)

declare i32 @js_gc_typed_shape_id_for_keys(i32, i64, i32, ptr, i32, ptr, i32)

declare ptr @js_inline_arena_state()

declare ptr @js_inline_arena_slow_alloc(ptr, i64, i64)

declare i32 @js_object_delete_field(i64, i64)

declare i32 @js_object_delete_field_value(double, i64)

declare i32 @js_object_delete_dynamic_value(double, double)

declare double @js_delete_result(i32, i32)

declare i64 @js_eq(i64, i64)

declare i64 @js_loose_eq(i64, i64)

declare i64 @js_number_to_fixed(double, double)

declare i64 @js_string_replace_regex(i64, i64, i64)

declare i64 @js_string_replace_all_regex(i64, i64, i64)

declare double @js_array_at(i64, double)

declare double @js_date_get_time(double)

declare double @js_date_get_full_year(double)

declare double @js_date_get_month(double)

declare double @js_date_get_date(double)

declare double @js_date_get_day(double)

declare double @js_date_get_hours(double)

declare double @js_date_get_minutes(double)

declare double @js_date_get_seconds(double)

declare double @js_date_get_milliseconds(double)

declare double @js_date_get_utc_day(double)

declare double @js_date_get_utc_full_year(double)

declare double @js_date_get_utc_month(double)

declare double @js_date_get_utc_date(double)

declare double @js_date_get_utc_hours(double)

declare double @js_date_get_utc_minutes(double)

declare double @js_date_get_utc_seconds(double)

declare double @js_date_get_utc_milliseconds(double)

declare double @js_date_value_of(double)

declare double @js_date_get_timezone_offset(double)

declare double @js_date_coerce_number(double)

declare double @js_rel_lt(double, double)

declare double @js_rel_le(double, double)

declare double @js_rel_gt(double, double)

declare double @js_rel_ge(double, double)

declare i64 @js_date_to_string(double)

declare i64 @js_date_to_iso_string(double)

declare i64 @js_date_to_iso_string_or_throw(double)

declare double @js_date_new_from_timestamp(double)

declare double @js_date_new_from_value(double)

declare i32 @js_array_indexOf_f64(i64, double)

declare i64 @js_array_indexOf_jsvalue(i64, double, double, i32)

declare i64 @js_array_last_index_of_jsvalue(i64, double, double, i32)

declare i32 @js_array_includes_f64(i64, double)

declare i32 @js_array_includes_jsvalue(i64, double, double, i32)

declare i32 @js_map_size(i64)

declare void @js_map_clear(i64)

declare void @js_set_clear(i64)

declare i64 @js_map_entries(i64)

declare i64 @js_map_keys(i64)

declare i64 @js_map_values(i64)

declare double @js_map_entry_key_at(i64, i32)

declare double @js_map_entry_value_at(i64, i32)

declare double @js_map_entry_key_raw_at(i64, i32)

declare double @js_map_entry_value_raw_at(i64, i32)

declare double @js_set_value_raw_at(i64, i32)

declare double @js_map_find_key_index(double, double)

declare double @js_set_find_value_index(double, double)

declare double @js_map_cursor_next(double, double, double)

declare double @js_map_compaction_epoch(double)

declare double @js_set_cursor_next(double, double, double)

declare double @js_set_compaction_epoch(double)

declare void @js_map_foreach(i64, double, double)

declare void @js_set_foreach(i64, double, double)

declare i64 @js_map_entries_iter_obj(i64)

declare i64 @js_map_keys_iter_obj(i64)

declare i64 @js_map_values_iter_obj(i64)

declare i64 @js_set_values_iter_obj(i64)

declare i64 @js_set_keys_iter_obj(i64)

declare i64 @js_set_entries_iter_obj(i64)

declare i64 @js_set_to_array(i64)

declare double @js_set_value_at(i64, i32)

declare i64 @js_array_splice(i64, i32, i32, ptr, i32, ptr)

declare i32 @js_array_splice_delete_count(double)

declare double @js_parse_int(i64, double)

declare double @js_parse_float(i64)

declare double @js_array_reduce(i64, i64, i32, double)

declare double @js_array_reduce_right(i64, i64, i32, double)

declare i64 @js_array_sort_default(i64)

declare i64 @js_array_reverse(i64)

declare double @js_array_reverse_value(double)

declare i64 @js_array_flat(i64)

declare i64 @js_array_flat_depth(i64, double)

declare i64 @js_array_flatMap(i64, i64)

declare i64 @js_array_sort_with_comparator(i64, i64)

declare i64 @js_validate_array_comparator(double)

declare i64 @js_validate_array_callback(double)

declare i64 @js_validate_array_map_callback(i64, double)

declare i64 @js_array_to_reversed(i64)

declare i64 @js_array_to_sorted_default(i64)

declare i64 @js_array_to_sorted_with_comparator(i64, i64)

declare i64 @js_array_to_spliced(i64, double, double, ptr, i32)

declare i64 @js_array_with(i64, double, double)

declare i64 @js_array_copy_within(i64, double, double, i32, double)

declare double @js_array_copy_within_value(double, double, double, i32, double)

declare i64 @js_regexp_new(i64, i64)

declare i64 @js_regexp_new_site(i64, i64, i64)

declare i64 @js_regexp_construct(double, double)

declare i64 @js_regexp_construct_call(double, double)

declare i32 @js_regexp_test(i64, i64)

declare double @js_regexp_escape(double)

declare i64 @js_get_string_pointer_unified(double)

declare i32 @js_switch_strict_equals(double, double)

declare i64 @js_value_to_str_ptr_for_ffi(double)

declare void @js_string_addref(i64)

declare void @js_string_addref_if_heap_string(double)

declare i64 @js_bigint_from_string(ptr, i32)

declare i64 @js_bigint_from_f64(double)

declare i64 @js_bigint_from_i128_parts(i64, i64)

declare i32 @js_bigint_cmp(i64, i64)

declare double @js_dynamic_add(double, double)

declare double @js_to_numeric(double)

declare double @js_numeric_step(double, i32)

declare i64 @js_box_capture_cell_ptr(i64)

declare double @js_dynamic_string_or_number_add(double, double)

declare double @js_dynamic_sub(double, double)

declare double @js_dynamic_mul(double, double)

declare double @js_dynamic_div(double, double)

declare double @js_dynamic_mod(double, double)

declare double @js_dynamic_bitand(double, double)

declare double @js_dynamic_bitor(double, double)

declare double @js_dynamic_bitxor(double, double)

declare double @js_dynamic_shl(double, double)

declare double @js_dynamic_shr(double, double)

declare double @js_dynamic_bitnot(double)

declare double @js_dynamic_pow(double, double)

declare double @js_dynamic_ushr(double, double)

declare double @js_instanceof(double, i32)

declare double @js_instanceof_dynamic(double, double)

declare double @js_instanceof_noncallable_rhs()

declare void @js_register_class_extends_error(i32)

declare void @js_register_class_extends_data_view(i32)

declare void @js_register_class_extends_typed_array(i32)

declare void @js_register_class_id(i32)

declare void @js_register_class_name(i32, ptr, i32)

declare void @js_register_class_source(i32, ptr, i32)

declare void @js_register_class_length(i32, i32)

declare void @js_register_anon_shape_class_id(i32)

declare double @js_get_global_this_builtin_value(ptr, i64)

declare double @js_promise_static_function_value(ptr, i64)

declare double @js_builtin_prototype_method_value(ptr, i64, ptr, i64)

declare void @js_register_class_parent(i32, i32)

declare void @js_register_class_generic_origin(i32, i32)

declare void @js_register_class_parent_dynamic(i32, double)

declare double @js_get_dynamic_parent_value(i32)

declare void @js_class_register_capture_values(i32, ptr, i64)

declare void @js_class_object_refresh_capture_values(double, i64, double)

declare void @js_tdz_suppress_begin()

declare void @js_tdz_suppress_end()

declare double @js_class_capture_value(i32, i32)

declare double @js_class_capture_value_for_receiver(double, i32, i32)

declare double @js_class_capture_value_or(i32, i32, double)

declare double @js_param_or_class_capture_value(double, i32, i32)

declare void @js_super_construct_apply(i32, double, double)

declare double @js_super_method_call_dynamic(i32, ptr, i64, double, ptr, i64)

declare double @js_super_method_call_dynamic_apply(i32, ptr, i64, double, double)

declare i64 @js_array_push_spread_any(i64, double)

declare i32 @js_set_function_prototype(double, double)

declare double @js_set_prototype_property(double, double, i32)

declare void @js_register_prototype_method(i32, ptr, i64, double)

declare i32 @js_register_function_prototype_method(double, ptr, i64, double)

declare double @js_new_function_construct(double, ptr, i64)

declare double @js_function_ctor_from_strings(ptr, i64)

declare double @js_new_function_construct_apply(double, double)

declare double @js_throw_not_a_constructor()

declare double @js_new_target_value()

declare double @js_get_function_prototype_method(double, ptr, i64)

declare double @js_function_prototype_value_for_read(double)

declare i64 @js_typeerror_new(i64)

declare i64 @js_rangeerror_new(i64)

declare i64 @js_syntaxerror_new(i64)

declare i64 @js_referenceerror_new(i64)

declare double @js_throw_symbol_constructor_type_error()

declare double @js_throw_bigint_constructor_type_error()

declare double @js_throw_strict_eval_arguments_syntax_error()

declare double @js_throw_eval_syntax_error(double)

declare double @js_throw_restricted_function_property_assignment()

declare double @js_throw_math_constructor_type_error()

declare double @js_throw_json_constructor_type_error()

declare double @js_webcrypto_illegal_constructor()

declare double @js_throw_type_error_const_assignment(double)

declare double @js_throw_reference_error_unresolvable_assignment(double)

declare double @js_throw_reference_error_unresolved_get()

declare double @js_with_implicit_unset()

declare double @js_with_implicit_read(double, double)

declare double @js_iterator_result_validate(double)

declare double @js_for_of_next(double)

declare double @js_segments_view_open(double, double)

declare double @js_segments_view_next(double)

declare double @js_segments_view_code_point_at(double, double)

declare double @js_segments_view_segment(double)

declare double @js_segments_view_regexp_test(double, double)

declare double @js_segments_project_can_open(double)

declare double @js_segments_project_open(double, double)

declare double @js_segments_project_iterator(double)

declare double @js_segments_project_next(double)

declare double @js_segments_project_segment(double)

declare double @js_segments_project_observe_iterator(double)

declare double @js_global_get_or_throw_unresolved(double)

declare double @js_module_ambient_require()

declare double @js_module_ambient_require_apply(double)

declare double @js_module_dynamic_import_fallback(double)

declare double @js_module_dynamic_import_deferred(double, double)

declare double @js_module_create_require_devirt(double)

declare double @js_global_get_optional(double)

declare double @js_global_update(double, double, double)

declare double @js_global_assign_existing_or_throw(double, double)

declare double @js_throw_reference_error_this_before_super()

declare double @js_throw_reference_error_super_delete()

declare double @js_throw_reference_error_unresolved_assignment()

declare i64 @js_evalerror_new(i64)

declare i64 @js_urierror_new(i64)

declare i64 @js_weakmap_new()

declare i64 @js_weakset_new()

declare double @js_weakmap_init_iterable(double, double)

declare double @js_weakset_init_iterable(double, double)

declare double @js_weakmap_set(double, double, double)

declare double @js_weakmap_get(double, double)

declare double @js_weakmap_has(double, double)

declare double @js_weakmap_delete(double, double)

declare double @js_weakset_add(double, double)

declare double @js_weakset_has(double, double)

declare double @js_weakset_delete(double, double)

declare double @js_weak_throw_primitive()

declare i64 @js_buffer_from_string(i64, i32)

declare i32 @js_encoding_tag_from_value(double)

declare i64 @js_value_to_string_with_encoding(double, i32)

declare i64 @js_value_to_string_with_encoding_or_radix(double, i32, double)

declare i64 @js_object_values(i64)

declare i64 @js_object_values_value(double)

declare i64 @js_object_entries(i64)

declare i64 @js_object_entries_value(double)

declare i64 @js_path_join(i64, i64)

declare i64 @js_path_win32_join(i64, i64)

declare i64 @js_path_win32_dirname(i64)

declare i64 @js_path_win32_basename(i64)

declare i64 @js_path_win32_basename_ext(i64, i64)

declare i64 @js_path_win32_extname(i64)

declare i32 @js_path_win32_is_absolute(i64)

declare i64 @js_path_win32_normalize(i64)

declare i64 @js_path_win32_parse(i64)

declare i64 @js_path_win32_format(double)

declare i64 @js_path_win32_relative(i64, i64)

declare i64 @js_path_win32_relative_checked(double, double)

declare i64 @js_path_win32_resolve(i64)

declare i64 @js_path_win32_resolve_join(i64, i64)

declare i64 @js_path_win32_to_namespaced_path(i64)

declare double @js_path_win32_to_namespaced_path_value(double)

declare i32 @js_path_win32_matches_glob(i64, i64)

declare i64 @js_path_win32_sep_get()

declare i64 @js_path_win32_delimiter_get()

declare i64 @js_path_dirname(i64)

declare i64 @js_path_resolve(i64)

declare i64 @js_path_relative(i64, i64)

declare i64 @js_path_relative_checked(double, double)

declare i64 @js_path_to_namespaced_path(i64)

declare double @js_path_to_namespaced_path_value(double)

declare i32 @js_path_matches_glob(i64, i64)

declare i64 @js_path_resolve_join(i64, i64)

declare i64 @js_path_arg_header(double)

declare i64 @js_path_join_value(double, double)

declare i64 @js_path_win32_join_value(double, double)

declare i64 @js_path_resolve_join_value(double, double)

declare i64 @js_path_win32_resolve_join_value(double, double)

declare i64 @js_path_basename_ext_value(double, double)

declare i64 @js_path_win32_basename_ext_value(double, double)

declare i32 @js_path_matches_glob_value(double, double)

declare i32 @js_path_win32_matches_glob_value(double, double)

declare double @js_object_from_entries(double)

declare i64 @js_string_match(i64, i64)

declare i64 @js_string_match_all(i64, i64)

declare i64 @js_string_match_all_value(i64, double)

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.log.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.log2.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.log10.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.exp.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.sin.f64(double) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.cos.f64(double) #2

declare i64 @js_path_basename(i64)

declare i64 @js_path_basename_ext(i64, i64)

declare i64 @js_path_extname(i64)

declare i64 @js_path_sep_get()

declare i64 @js_path_delimiter_get()

declare i64 @js_path_parse(i64)

declare i64 @js_json_parse(i64)

declare i64 @js_json_text_to_string(double)

declare double @js_json_raw_json(double)

declare double @js_json_is_raw_json(double)

declare i64 @js_json_parse_or_null(i64)

declare i64 @js_json_parse_typed_array(i64, i64, i32, i32)

declare i64 @js_date_to_date_string(double)

declare i64 @js_date_to_time_string(double)

declare i64 @js_date_to_utc_string(double)

declare i64 @js_date_to_locale_date_string(double)

declare i64 @js_date_to_locale_time_string(double)

declare i64 @js_date_to_json(double)

declare i64 @js_regexp_exec(i64, i64)

declare i64 @js_number_to_precision(double, double)

declare i64 @js_number_to_exponential(double, double)

declare double @js_date_new()

declare double @js_number_is_integer(double)

declare double @js_number_is_nan(double)

declare double @js_number_is_safe_integer(double)

declare double @js_date_parse(i64)

declare double @js_date_utc(ptr, i32)

declare double @js_date_new_local_components(double, double, double, double, double, double, double)

declare double @js_date_apply_setter(double, i32, i32, ptr, i32)

declare double @js_math_clz32(double)

declare double @js_math_cbrt(double)

declare double @js_math_fround(double)

declare double @js_math_f16round(double)

declare double @js_math_sinh(double)

declare double @js_math_cosh(double)

declare double @js_math_tanh(double)

declare double @js_math_asinh(double)

declare double @js_math_acosh(double)

declare double @js_math_atanh(double)

declare double @js_math_hypot(double, double)

declare double @js_object_is(double, double)

declare i64 @js_path_normalize(i64)

declare i64 @js_path_format(double)

declare i32 @js_path_is_absolute(i64)

declare i64 @js_encode_uri(double)

declare i64 @js_decode_uri(double)

declare i64 @js_encode_uri_component(double)

declare i64 @js_decode_uri_component(double)

declare i64 @js_text_encoder_new()

declare i64 @js_text_decoder_new(double, double, double)

declare i64 @js_text_encoder_encode_llvm(double)

declare i64 @js_text_decoder_decode_llvm(double, double)

declare i64 @js_text_decoder_encoding(double)

declare double @js_text_decoder_fatal(double)

declare double @js_text_decoder_ignore_bom(double)

declare void @js_queue_microtask(i64)

declare void @js_queue_next_tick(i64)

declare void @js_queue_next_tick_args(i64, ptr, i32)

declare void @js_drain_queued_microtasks()

declare i64 @js_uint8array_from_array(i64)

declare i64 @js_uint8array_alloc(i32)

declare i64 @js_uint8array_new(double)

declare i64 @js_uint8array_view(double, double, double)

declare i64 @js_typed_array_new_empty(i32, i32)

declare i64 @js_typed_array_new_from_array(i32, i64)

declare i64 @js_typed_array_new(i32, double)

declare i64 @js_typed_array_view(i32, double, double, double)

declare i32 @js_typed_array_length(i64)

declare double @js_typed_array_get(i64, i32)

declare i32 @js_typed_array_read_int32(i64, i32)

declare double @js_typed_array_read_f64(i64, i32)

declare double @js_u8_buffer_read_f64(i64, i32)

declare double @js_typed_array_index_get_dynamic(i64, double)

declare double @js_typed_array_at(i64, double)

declare void @js_typed_array_set(i64, i32, double)

declare double @js_typed_array_index_set_dynamic(i64, double, double)

declare i32 @js_uint8array_get(i64, i32)

declare double @js_uint8array_index_get_value(i64, i32)

declare void @js_uint8array_set(i64, i32, i32)

declare i64 @js_native_arena_alloc(i64)

declare i64 @js_native_arena_view(i64, i32, i64, i64)

declare i64 @js_native_pod_view(i64, i64, i64, i64, i64, i64)

declare double @js_native_pod_view_length(double)

declare ptr @js_native_abi_check_pod_view_data_ptr(double, i64)

declare i64 @js_native_abi_check_pod_view_record_count(double, i64)

declare void @js_native_arena_dispose(i64)

declare void @js_native_memory_fill_u32(i64, double)

declare void @js_native_memory_copy(i64, i64)

declare i64 @js_typed_array_to_reversed(i64)

declare i64 @js_typed_array_to_sorted_default(i64)

declare i64 @js_typed_array_to_sorted_with_comparator(i64, i64)

declare i64 @js_typed_array_with(i64, double, double)

declare double @js_typed_array_find_last(i64, i64)

declare double @js_typed_array_find_last_index(i64, i64)

declare double @js_typed_array_set_from(i64, double, double)

declare i64 @js_typed_array_subarray(i64, i32, double, i32, double)

declare double @js_object_has_own(double, double)

declare double @js_object_property_is_enumerable(double, double)

declare double @js_object_define_getter(double, double, double)

declare double @js_object_define_setter(double, double, double)

declare double @js_object_lookup_getter(double, double)

declare double @js_object_lookup_setter(double, double)

declare double @js_object_get_own_field_or_undef(double, ptr, i64)

declare double @js_unresolved_namespace_stub()

declare double @js_node_submodule_export_as_function(ptr, i32, ptr, i32)

declare double @js_node_submodule_namespace_member(ptr, i32, ptr, i32)

declare double @js_node_submodule_namespace(ptr, i32)

declare void @js_node_submod_install_vm()

declare void @js_node_submod_install_timers()

declare void @js_node_submod_install_timers_promises()

declare void @js_node_submod_install_fs_promises()

declare void @js_node_submod_install_readline_promises()

declare void @js_node_submod_install_stream_promises()

declare void @js_node_submod_install_stream_consumers()

declare void @js_node_submod_install_stream_web()

declare void @js_node_submod_install_hono_jsx_server()

declare void @js_node_submod_install_hono_jsx_streaming()

declare void @js_node_submod_install_sys()

declare void @js_node_submod_install_diagnostics_channel()

declare void @js_node_submod_install_trace_events()

declare void @js_node_submod_install_test()

declare void @js_node_submod_install_test_reporters()

declare void @js_node_submod_install_all()

declare void @js_node_submod_enable_install_all()

declare double @js_unresolved_default_call()

declare double @js_get_global_this()

declare double @js_module_top_this()

declare double @js_global_or_console_property_by_name(i64)

declare void @js_class_register_static_symbol(i32, double, double)

declare void @js_register_class_computed_method(i64, double, i64, i64, i64, i64, i64)

declare void @js_register_class_computed_accessor(i64, double, i64, i64, i64, i64)

declare void @js_class_register_static_field(i32, ptr, i64, double, ptr)

declare double @js_object_define_property(double, double, double)

declare double @js_object_define_get_accessor(double, double, double)

declare double @js_object_get_own_property_descriptor(double, double)

declare double @js_object_get_own_property_descriptors(double)

declare double @js_object_get_own_property_names(double)

declare double @js_symbol_new(double)

declare double @js_symbol_new_empty()

declare double @js_symbol_for(double)

declare double @js_symbol_computed_member(double, double)

declare double @js_symbol_key_for(double)

declare double @js_symbol_description(double)

declare i64 @js_symbol_to_string(double)

declare i32 @js_symbol_equals(double, double)

declare i32 @js_is_symbol(double)

declare i64 @js_object_get_own_property_symbols(double)

declare double @js_object_set_symbol_property(double, double, double)

declare double @js_to_property_key(double)

declare double @js_object_set_property_key(double, double, double)

declare double @js_object_get_property_key(double, double)

declare double @js_object_set_property_key_method(double, double, double)

declare double @js_object_super_get(double, double, double)

declare double @js_object_super_put_value_set(double, double, double, double, i32)

declare double @js_object_super_call(double, double, double, ptr, i64)

declare double @js_object_literal_infer_computed_function_name(double, double)

declare double @js_object_get_symbol_property(double, double)

declare double @js_object_get_symbol_property_ic_miss(double, double, ptr)

declare double @js_object_get_symbol_then_field_ic_miss(double, double, ptr, i64, ptr, ptr)

declare double @js_object_create(double)

declare double @js_object_create_with_props(double, double)

declare double @js_object_freeze(double)

declare double @js_object_seal(double)

declare double @js_object_prevent_extensions(double)

declare void @js_object_copy_own_fields(i64, double)

declare double @js_object_assign_validate_target(double)

declare double @js_object_assign_one(double, double)

declare double @js_string_at(i64, i32)

declare double @js_string_code_point_at(i64, i32)

declare i64 @js_string_from_code_point(double)

declare i64 @js_string_raw(double, double)

declare i64 @js_string_from_char_code(double)

declare i64 @js_string_from_char_code_array(double)

declare double @js_string_char_code_at(i64, i32)

declare i32 @js_string_last_index_of(i64, i64)

declare i32 @js_string_last_index_of_from(i64, i64, double, i32)

declare double @js_string_locale_compare(i64, i64)

declare double @js_string_locale_compare_opts(i64, i64, double)

declare i64 @js_string_normalize(i64, double)

declare i64 @js_string_pad_start(i64, double, i64)

declare i64 @js_string_pad_end(i64, double, i64)

declare i64 @js_string_pad_fill(double)

declare double @js_string_is_well_formed(i64)

declare i64 @js_string_to_well_formed(i64)

declare i32 @js_string_search_regex(i64, i64)

declare i32 @js_string_search_value(i64, double)

declare i64 @js_string_match_value(i64, double)

declare double @js_regexp_exec_get_index()

declare i64 @js_regexp_exec_get_groups()

declare double @js_regexp_get_last_index(i64)

declare void @js_regexp_set_last_index(i64, double)

declare i64 @js_regexp_get_source(i64)

declare i64 @js_regexp_get_flags(i64)

declare i64 @js_string_replace_regex_named(i64, i64, i64)

declare i64 @js_string_replace_all_regex_named(i64, i64, i64)

declare i64 @js_string_replace_string_fn(i64, i64, double)

declare i64 @js_string_replace_string_dyn(i64, i64, double)

declare i64 @js_string_replace_all_string_dyn(i64, i64, double)

declare i64 @js_string_replace_regex_dyn(i64, i64, double)

declare i64 @js_string_replace_all_regex_dyn(i64, i64, double)

declare i64 @js_string_replace_search_dyn(i64, double, double)

declare i64 @js_string_replace_all_search_dyn(i64, double, double)

declare i64 @js_string_replace_all_string_fn(i64, i64, double)

declare i64 @js_string_replace_regex_fn(i64, i64, double)

declare i64 @js_string_replace_all_regex_fn(i64, i64, double)

declare double @js_structured_clone(double)

declare double @js_structured_clone_with_options(double, double)

declare double @js_generator_attach_prototype(double, i32)

declare double @js_generator_attach_closure_prototype(double, i64)

declare i64 @js_weakref_new(double)

declare double @js_weakref_deref(double)

declare i64 @js_finreg_new(double)

declare double @js_finreg_register(double, double, double, double)

declare double @js_finreg_unregister(double, double)

declare i64 @js_atob(double)

declare i64 @js_btoa(double)

declare double @js_object_is_frozen(double)

declare double @js_object_is_sealed(double)

declare double @js_object_is_extensible(double)

declare i64 @js_aggregateerror_new(i64, i64)

declare i64 @js_error_new_with_cause(i64, double)

declare i64 @js_aggregateerror_new_full(double, i64, double)

declare i64 @js_error_new_kind_with_options(i32, i64, double)

declare double @js_error_is_error(double)

declare i64 @js_error_get_errors(i64)

declare i64 @js_crypto_sha256(i64)

declare i64 @js_crypto_sha256_bytes(i64)

declare i64 @js_crypto_md5(i64)

declare i64 @js_crypto_hmac_sha256(i64, i64)

declare i64 @js_crypto_hmac_sha256_bytes(i64, i64)

declare void @js_runtime_validate_string_arg(double, ptr, i32)

declare void @js_set_call_location(ptr, i64, i32)

declare void @js_runtime_validate_crypto_key_arg(double, ptr, i32)

declare void @js_runtime_validate_integer_arg(double, ptr, i32, double, double)

declare i64 @js_crypto_pbkdf2_bytes(i64, i64, double, double, i64)

declare double @js_crypto_pbkdf2_async_alg(i64, i64, double, double, i64, double)

declare i64 @js_crypto_argon2_sync(i64, double)

declare double @js_crypto_argon2_async(i64, double, double)

declare i64 @js_crypto_encapsulate(double)

declare double @js_crypto_encapsulate_async(double, double)

declare i64 @js_crypto_decapsulate(double, double)

declare double @js_crypto_decapsulate_async(double, double, double)

declare i64 @js_crypto_hkdf_bytes_alg(i64, i64, i64, i64, double)

declare double @js_crypto_hkdf_async_alg(i64, i64, i64, i64, double, double)

declare i64 @js_crypto_scrypt_bytes(i64, i64, double, double)

declare double @js_crypto_scrypt_async(i64, i64, double, double, double)

declare i64 @js_crypto_sign_rsa_sha256(i64, i64, double)

declare double @js_crypto_sign_async(i64, i64, double, double)

declare double @js_crypto_verify_rsa_sha256(i64, i64, double, i64)

declare double @js_crypto_verify_async(i64, i64, double, i64, double)

declare i64 @js_crypto_public_encrypt(i64, i64)

declare i64 @js_crypto_private_decrypt(i64, i64)

declare i64 @js_crypto_private_encrypt(i64, i64)

declare i64 @js_crypto_public_decrypt(i64, i64)

declare i64 @js_crypto_create_public_key(i64)

declare i64 @js_crypto_create_private_key_value(double)

declare i64 @js_crypto_create_public_key_value(double)

declare i64 @js_crypto_generate_key_pair_sync_rsa(double)

declare i64 @js_crypto_generate_key_pair_sync_ec_p256(double)

declare i64 @js_crypto_generate_key_pair_sync_ed25519(double)

declare i64 @js_crypto_generate_key_pair_sync_x25519(double)

declare double @js_crypto_generate_key_pair_async(i64, double, double)

declare i64 @js_crypto_diffie_hellman(double)

declare double @js_crypto_get_cipher_info(double, double)

declare i64 @js_crypto_get_curves()

declare i64 @js_crypto_secure_heap_used()

declare i64 @js_crypto_random_bytes_buffer(double)

declare double @js_crypto_random_bytes_async(double, double)

declare i64 @js_crypto_random_uuid(double)

declare i64 @js_crypto_random_uuidv7()

declare double @js_crypto_random_int(double, double)

declare double @js_crypto_random_int_async(double, double, double)

declare double @js_crypto_timing_safe_equal(double, double)

declare i64 @js_crypto_get_hashes()

declare i64 @js_crypto_get_ciphers()

declare double @js_crypto_generate_prime_sync(double, double)

declare double @js_crypto_generate_prime_async(double, double, double)

declare double @js_crypto_check_prime_sync(double, double)

declare double @js_crypto_check_prime_async(double, double, double)

declare i64 @js_crypto_create_secret_key(i64, i64)

declare i64 @js_crypto_generate_key_sync(i64, double)

declare double @js_crypto_generate_key_async(i64, double, double)

declare i64 @js_webcrypto_digest(double, double)

declare i64 @js_webcrypto_import_key(double, double, double, double, double)

declare i64 @js_webcrypto_export_key(double, double)

declare i64 @js_webcrypto_sign(double, double, double)

declare i64 @js_webcrypto_verify(double, double, double, double)

declare i64 @js_webcrypto_derive_bits(double, double, double)

declare i64 @js_webcrypto_derive_key(double, double, double, double, double)

declare i64 @js_webcrypto_encrypt(double, double, double)

declare i64 @js_webcrypto_decrypt(double, double, double)

declare i64 @js_webcrypto_generate_key(double, double, double)

declare i64 @js_webcrypto_wrap_key(double, double, double, double)

declare i64 @js_webcrypto_unwrap_key(double, double, double, double, double, double, double)

declare i64 @js_zlib_create_brotli_decompress(double)

declare double @js_crypto_random_fill_sync(double, double, double)

declare double @js_crypto_random_fill_async(double, double, double, double)

declare double @js_crypto_create_hash(i64)

declare double @js_crypto_create_hash_options(i64, double)

declare double @js_crypto_x509_new(i64)

declare double @js_crypto_certificate_verify_spkac(double)

declare double @js_crypto_certificate_export_public_key(double)

declare double @js_crypto_certificate_export_challenge(double)

declare double @js_crypto_create_sign(i64)

declare double @js_crypto_create_verify(i64)

declare double @js_crypto_create_ecdh(i64)

declare double @js_crypto_create_diffie_hellman(double, double, double)

declare double @js_crypto_get_diffie_hellman(double)

declare double @js_crypto_ecdh_convert_key(double, double, double, double, double)

declare double @js_crypto_create_hmac(i64, i64)

declare i64 @js_buffer_alloc(i32, i32)

declare i64 @js_buffer_alloc_fill_value(i32, double, i32)

declare i64 @js_array_buffer_new(i32)

declare i64 @js_shared_array_buffer_new(i32)

declare i64 @js_array_buffer_new_value(double)

declare i64 @js_shared_array_buffer_new_value(double)

declare i64 @js_json_stringify_full(double, double, double)

declare i64 @js_json_parse_with_reviver(i64, i64)

declare double @js_array_find(i64, i64)

declare i32 @js_array_findIndex(i64, i64)

declare double @js_array_find_last(i64, i64)

declare i32 @js_array_find_last_index(i64, i64)

declare double @js_array_some(i64, i64)

declare double @js_array_some_captureless(i64, ptr)

declare double @js_array_every(i64, i64)

declare i32 @js_promise_state(i64)

declare double @js_promise_value(i64)

declare double @js_promise_reason(i64)

declare i32 @js_value_is_promise(double)

declare double @js_assimilate_thenable(double)

declare i32 @js_promise_run_microtasks()

declare i32 @js_promise_run_microtasks_event_loop()

declare i32 @js_promise_run_microtasks_await_loop()

declare i32 @js_await_loop_tick_timers()

declare void @js_mark_entry_module_esm()

declare i32 @js_promise_run_promise_jobs()

declare void @js_run_stdlib_pump()

declare void @js_sleep_ms(double)

declare void @js_wait_for_event()

declare i32 @js_event_loop_host_driven()

declare void @js_unsettled_top_level_await_exit()

declare void @js_throw(double)

declare void @js_eh_try_push()

declare i32 @perry_eh_personality(...)

declare void @js_try_end()

declare double @js_get_exception()

declare void @js_clear_exception()

declare i32 @js_has_exception()

declare void @js_enter_finally()

declare void @js_leave_finally()

declare double @js_await_any_promise(double)

declare i64 @js_promise_new()

declare i64 @js_promise_new_with_executor(i64)

declare i32 @js_timer_tick()

declare i32 @js_timer_tick_if_refed()

declare i32 @js_callback_timer_tick()

declare i32 @js_interval_timer_tick()

declare i32 @js_timer_has_pending()

declare i32 @js_callback_timer_has_pending()

declare i32 @js_interval_timer_has_pending()

declare i32 @js_stdlib_has_active_handles()

declare i32 @js_bun_ffi_has_active_threadsafe_callbacks()

declare i32 @js_microtasks_pending()

declare i64 @js_timer_validate_callback(double, i32)

declare double @js_timer_wrap_id(i64)

declare i64 @js_set_timeout_callback(i64, double)

declare i64 @js_set_timeout_callback_args(i64, double, ptr, i32)

declare i64 @js_set_immediate_callback(i64)

declare i64 @js_set_immediate_callback_args(i64, ptr, i32)

declare i64 @setInterval(i64, double)

declare i64 @js_set_interval_callback_args(i64, double, ptr, i32)

declare void @clearTimeout(i64)

declare void @clearInterval(i64)

declare void @clearImmediate(i64)

declare void @js_clear_timeout_value(double)

declare void @js_clear_interval_value(double)

declare void @js_clear_immediate_value(double)

declare i64 @js_buffer_from_array(i64)

declare i64 @js_buffer_from_arraybuffer_slice(i64, i32, i32)

declare i32 @js_buffer_length(i64)

declare i32 @js_buffer_get(i64, i32)

declare double @js_buffer_index_get_value(i64, i32)

declare ptr @js_native_buffer_data_ptr(double)

declare i64 @js_native_buffer_byte_len(double)

declare void @js_console_time(i64)

declare void @js_console_time_end(i64)

declare void @js_console_time_log(i64)

declare void @js_console_time_value(double)

declare void @js_console_time_end_value(double)

declare void @js_console_time_log_value(double)

declare void @js_console_time_log_spread(double, i64)

declare void @js_console_count(i64)

declare void @js_console_count_reset(i64)

declare void @js_console_count_value(double)

declare void @js_console_count_reset_value(double)

declare double @js_console_new(double)

declare double @js_console_new2(double, double)

declare void @js_console_group_begin()

declare void @js_console_group_end()

declare void @js_console_clear()

declare void @js_console_noop()

declare double @js_native_call_method(double, ptr, i64, ptr, i64)

declare double @js_native_call_method_by_id(double, i64, ptr, i64)

declare double @js_native_call_method_apply(double, ptr, i64, i64)

declare double @js_native_call_method_apply_by_id(double, i64, i64)

declare double @js_native_call_method_str_key(double, i64, ptr, i64)

declare double @js_native_call_method_value(double, double, ptr, i64)

declare double @js_native_call_method_value_apply(double, double, i64)

declare void @js_promise_resolve(i64, double)

declare void @js_promise_reject(i64, double)

declare void @js_promise_mark_internally_handled(i64)

declare i64 @js_promise_resolved(double)

declare i64 @js_async_fn_result(double)

declare i64 @js_promise_rejected(double)

declare double @js_create_namespace(i32, ptr, ptr, ptr, ptr)

declare double @js_finalize_namespace(double)

declare i64 @js_promise_then(i64, i64, i64)

declare i64 @js_promise_resolved_then(double, i64, i64)

declare i64 @js_promise_finally(i64, i64)

declare double @js_promise_then_checked(double, double, double)

declare double @js_promise_catch_checked(double, double)

declare double @js_promise_finally_checked(double, double)

declare i64 @js_promise_closure_arg(double)

declare i64 @js_promise_all(i64)

declare i64 @js_promise_race(i64)

declare i64 @js_promise_any(i64)

declare i64 @js_promise_all_settled(i64)

declare i64 @js_promise_all_iterable(double)

declare i64 @js_promise_race_iterable(double)

declare i64 @js_promise_any_iterable(double)

declare i64 @js_promise_all_settled_iterable(double)

declare i64 @js_promise_with_resolvers()

declare i64 @js_promise_try(double, i64)

declare i64 @js_array_unshift_f64(i64, double)

declare i64 @js_array_unshift_variadic(i64, ptr, i32)

declare i64 @js_array_entries(i64)

declare i64 @js_array_keys(i64)

declare i64 @js_array_values(i64)

declare i64 @js_array_entries_iter_obj(i64)

declare i64 @js_array_keys_iter_obj(i64)

declare i64 @js_array_values_iter_obj(i64)

declare double @js_response_new(i64, double, i64, double)

declare double @js_fetch_unwrap_handle(double)

declare double @js_response_body_init_reset()

declare i64 @js_response_body_init_ptr(double)

declare double @js_headers_new()

declare double @js_headers_set(double, i64, i64)

declare double @js_headers_append(double, i64, i64)

declare i64 @js_headers_get(double, i64)

declare double @js_headers_get_set_cookie(double)

declare double @js_headers_has(double, i64)

declare double @js_headers_delete(double, i64)

declare double @js_headers_for_each(double, double)

declare double @js_headers_keys(double)

declare double @js_headers_values(double)

declare double @js_headers_entries(double)

declare double @js_headers_init_from_value(double, double)

declare double @js_headers_method_value(double, i64, i64)

declare double @js_request_new(i64, i64, i64, double, i64, i64, i64, i64, i64, i64, i64, double, i64, double)

declare double @js_request_new_from_init(i64, double)

declare i64 @js_request_get_url(double)

declare i64 @js_request_input_to_url(double)

declare i64 @js_request_get_method(double)

declare double @js_request_get_body(double)

declare double @js_request_body_used(double)

declare i64 @js_request_get_destination(double)

declare i64 @js_request_get_referrer(double)

declare i64 @js_request_get_referrer_policy(double)

declare i64 @js_request_get_mode(double)

declare i64 @js_request_get_credentials(double)

declare i64 @js_request_get_cache(double)

declare i64 @js_request_get_redirect(double)

declare i64 @js_request_get_integrity(double)

declare double @js_request_get_keepalive(double)

declare i64 @js_request_get_duplex(double)

declare double @js_request_get_signal(double)

declare double @js_request_get_headers(double)

declare i64 @js_request_text(double)

declare i64 @js_request_json(double)

declare i64 @js_request_array_buffer(double)

declare i64 @js_request_blob(double)

declare i64 @js_request_bytes(double)

declare i64 @js_request_form_data(double)

declare double @js_request_clone(double)

declare double @js_fetch_response_status(double)

declare i64 @js_fetch_response_status_text(double)

declare double @js_fetch_response_ok(double)

declare i64 @js_fetch_response_type(double)

declare i64 @js_fetch_response_url(double)

declare double @js_fetch_response_redirected(double)

declare double @js_response_body_used(double)

declare i64 @js_fetch_response_text(double)

declare i64 @js_fetch_response_json(double)

declare double @js_response_get_headers(double)

declare double @js_response_clone(double)

declare i64 @js_response_array_buffer(double)

declare i64 @js_response_blob(double)

declare i64 @js_response_bytes(double)

declare i64 @js_response_form_data(double)

declare double @js_form_data_new()

declare double @js_form_data_append(double, double, double, double)

declare double @js_form_data_set(double, double, double, double)

declare double @js_form_data_delete(double, i64)

declare double @js_form_data_get(double, i64)

declare double @js_form_data_get_all(double, i64)

declare double @js_form_data_has(double, i64)

declare double @js_form_data_entries(double)

declare double @js_form_data_keys(double)

declare double @js_form_data_values(double)

declare double @js_form_data_for_each(double, double)

declare double @js_blob_size(double)

declare i64 @js_blob_type(double)

declare i64 @js_blob_array_buffer(double)

declare i64 @js_blob_bytes(double)

declare i64 @js_blob_text(double)

declare double @js_blob_slice(double, double, double, i64)

declare double @js_blob_new(double, double)

declare double @js_file_new(double, double, double, double)

declare i64 @js_file_name(double)

declare double @js_file_last_modified(double)

declare i64 @js_url_create_object_url(double)

declare void @js_url_revoke_object_url(double)

declare double @js_buffer_resolve_object_url(double)

declare double @js_response_static_json(double, double, i64, double)

declare double @js_response_static_redirect(i64, double)

declare double @js_response_static_error()

declare double @js_blob_stream(double)

declare double @js_response_body(double)

declare double @js_readable_stream_new(double, double, double, double)

declare double @js_readable_stream_new_with_source_type(double, double, double, double, double)

declare double @js_readable_stream_new_with_strategy_and_source_type(double, double, double, double, double)

declare double @js_readable_stream_new_from_source_object(double, double)

declare double @js_readable_stream_get_reader(double)

declare double @js_readable_stream_get_reader_with_options(double, double)

declare double @js_readable_stream_get_byob_reader(double)

declare double @js_readable_stream_controller_byob_request(double)

declare double @js_readable_stream_from_iterable(double)

declare double @js_readable_stream_locked(double)

declare i64 @js_readable_stream_cancel(double, double)

declare double @js_readable_stream_tee(double)

declare i64 @js_readable_stream_pipe_to(double, double, double)

declare double @js_readable_stream_pipe_through(double, double, double)

declare double @js_readable_stream_pipe_through_validate(double, double, double, double)

declare double @js_readable_stream_controller_enqueue(double, double)

declare double @js_readable_stream_controller_close(double)

declare double @js_readable_stream_controller_error(double, double)

declare double @js_readable_stream_controller_desired_size(double)

declare i64 @js_reader_read(double)

declare i64 @js_reader_read_with_view(double, double)

declare double @js_reader_release_lock(double)

declare i64 @js_reader_closed(double)

declare i64 @js_reader_cancel(double, double)

declare double @js_writable_stream_new(double, double, double, double, double)

declare double @js_writable_stream_new_with_sink_type(double, double, double, double, double, double)

declare double @js_writable_stream_new_from_sink_object(double, double)

declare double @js_writable_stream_throw_invalid_sink()

declare double @js_writable_stream_get_writer(double)

declare double @js_writable_stream_locked(double)

declare i64 @js_writable_stream_close(double)

declare i64 @js_writable_stream_abort(double, double)

declare i64 @js_writer_write(double, double)

declare i64 @js_writer_close(double)

declare i64 @js_writer_abort(double, double)

declare double @js_writer_release_lock(double)

declare i64 @js_writer_closed(double)

declare i64 @js_writer_ready(double)

declare double @js_writer_desired_size(double)

declare double @js_transform_stream_new(double, double, double, double, double)

declare double @js_transform_stream_new_from_transformer_object(double, double, double)

declare double @js_transform_stream_readable(double)

declare double @js_transform_stream_writable(double)

declare double @js_text_encoding_stream_new()

declare double @js_text_encoder_stream_new()

declare double @js_text_decoder_stream_new()

declare double @js_stream_web_text_encoder_stream_new()

declare double @js_stream_web_text_decoder_stream_new(double, double)

declare double @js_stream_web_compression_stream_new(double)

declare double @js_stream_web_decompression_stream_new(double)

declare double @js_streams_strategy_high_water_mark(double)

declare double @js_count_queuing_strategy_new(double)

declare double @js_byte_length_queuing_strategy_new(double)

declare double @js_stream_unwrap_handle(double)

declare double @js_readable_stream_subclass_init(double, double, double, double, double)

declare double @js_writable_stream_subclass_init(double, double, double, double, double)

declare double @js_transform_stream_subclass_init(double, double, double, double)

declare double @js_request_subclass_init(double, double, double)

declare double @js_response_subclass_init(double, double, double)

declare double @js_fetch_or_value_super(double, double, ptr, i64)

declare double @js_builtin_subclass_construct(i32, ptr, i64, ptr, i64)

declare i64 @js_abort_controller_new()

declare i64 @js_abort_controller_signal(i64)

declare void @js_abort_controller_abort(i64)

declare void @js_abort_controller_abort_reason(i64, double)

declare void @js_abort_signal_add_listener(i64, double, double)

declare i64 @js_abort_signal_timeout(double)

declare i64 @js_abort_signal_abort(double)

declare i64 @js_abort_signal_any(i64)

declare double @js_abort_signal_throw_if_aborted(i64)

declare i64 @js_event_target_new()

declare i64 @js_event_new(double, double, i32)

declare double @js_event_subclass_init(double, double, double, i32, i32)

declare i64 @js_custom_event_new(double, double, i32)

declare i64 @js_dom_exception_new(double, double)

declare double @js_dom_exception_subclass_init(double, double, double)

declare void @js_event_target_add_event_listener(i64, i64, i64)

declare void @js_event_target_add_event_listener_with_options(i64, i64, i64, double)

declare void @js_event_target_remove_event_listener(i64, i64, i64)

declare void @js_event_target_remove_event_listener_with_options(i64, i64, i64, double)

declare double @js_event_target_dispatch_event(i64, double)

declare i32 @js_event_target_is_event_target(i64)

declare i64 @js_event_target_get_event_listeners(i64, i64)

declare double @js_event_target_get_max_listeners(i64)

declare i32 @js_event_target_set_max_listeners(i64, double)

declare double @js_message_channel_new()

declare double @js_message_port_constructor_error()

declare double @js_broadcast_channel_new(double)

declare i64 @js_array_alloc(i32)

declare i64 @js_tagged_template_register_raw(i64, i64)

declare i64 @js_tagged_template_get_or_init(i64, i64, i64)

declare i64 @js_template_raw(i64)

declare i64 @js_array_create()

declare i64 @js_array_constructor_single(double)

declare i64 @js_array_alloc_literal(i32)

declare i64 @js_array_from_values(ptr, i32)

declare double @js_value_from_const_descriptor(ptr, i32)

declare i64 @js_array_push_f64(i64, double)

declare i64 @js_array_push_u31_with_length(i64, i32, ptr)

declare i64 @js_array_push_f64_spec(i64, double)

declare void @js_array_push_guard(i64)

declare i64 @js_array_push_hole(i64)

declare i64 @js_array_numeric_push_f64_unboxed(i64, double)

declare i64 @js_array_push_spread_f64(i64, i64)

declare double @js_array_get_f64(i64, i32)

declare i32 @js_array_ensure_element_shape(i64)

declare double @js_array_get_index_or_string(i64, double)

declare double @js_array_numeric_get_f64_unboxed(i64, i32)

declare void @js_array_set_f64(i64, i32, double)

declare i32 @js_array_numeric_set_f64_unboxed(i64, i32, double)

declare i64 @js_array_set_f64_extend(i64, i32, double)

declare i64 @js_array_set_f64_extend_strict(i64, i32, double)

declare i64 @js_array_fill_f64_const_extend(i64, i32, double)

declare i64 @js_array_fill_f64_iota_extend(i64, i32)

declare i64 @js_array_fill_f64_const_len_extend(i64, double)

declare i64 @js_array_fill_f64_iota_len_extend(i64)

declare i64 @js_array_numeric_range_add(double, double, double, double)

declare i64 @js_array_numeric_range_add_len(double, double, double)

declare i64 @js_array_fill_range_strided_tagged(double, double, double, double, i64)

declare i64 @js_array_set_string_key(i64, i64, double)

declare i64 @js_array_set_index_or_string(i64, double, double)

declare i64 @js_array_mark_arguments_object(i64)

declare i32 @js_array_mark_numeric_f64_layout(i64)

declare i32 @js_array_is_numeric_f64_layout(i64)

declare void @js_array_clear_numeric_layout(i64)

; Function Attrs: nounwind willreturn
declare double @js_array_numeric_value_to_raw_f64(double) #6

declare double @js_array_refresh_local_head(double)

declare void @js_array_note_numeric_write(i64, i64)

declare void @js_array_declare_all_pointer_elements(i64)

declare i32 @js_array_length(i64)

declare double @js_array_is_array(double)

declare double @js_value_length_f64(double)

declare double @js_value_length_property_f64(double)

declare double @js_value_length_property_ic_f64(double, ptr)

declare nonnull ptr @js_shadow_frame_enter(i32)

declare i64 @js_shadow_frame_push(i32)

declare void @js_shadow_frame_pop(i64)

declare void @js_shadow_slot_set(i32, i64)

declare void @js_shadow_slot_bind(i32, ptr)

declare void @js_gc_write_barriers_emitted(i32)

declare i32 @js_gc_temp_root_push(i64)

declare i64 @js_gc_temp_root_get(i32)

declare void @js_gc_temp_root_set(i32, i64)

declare void @js_gc_temp_root_truncate(i32)

declare void @js_array_push_f64_temp_rooted(i32, double)

declare void @js_gc_loop_safepoint()

declare void @js_write_barrier(i64, i64)

declare void @js_write_barrier_slot(i64, i64, i64)

declare i64 @js_array_live_head(i64)

declare void @js_write_barrier_slot_validated_parent(i64, i64, i64)

declare void @js_write_barrier_root_nanbox(i64)

declare void @js_write_barrier_root_heap_word(i64)

declare void @js_gc_note_slot_layout(i64, i32, i64)

declare void @js_gc_note_slot_layout_aware(i64, i32, i64, i64)

declare void @js_gc_init_typed_shape_layout(i64, i32, ptr, i32, ptr, i32)

declare void @js_gc_declare_typed_shape_layout(i64, i32, ptr, i32, ptr, i32)

declare void @js_gc_forget_object_layout(i64)

declare double @js_array_pop_f64(i64)

declare i64 @js_array_join(i64, i64)

declare i64 @js_array_join_value(i64, double)

declare void @js_array_forEach(i64, i64)

declare i64 @js_array_fill(i64, double)

declare i64 @js_array_fill_range(i64, double, double, double)

declare double @js_array_fill_generic(double, double, i32, double, i32, double)

declare i32 @js_array_delete(i64, i32)

declare void @js_array_set_length(i64, double)

declare void @js_array_set_length_strict(i64, double)

declare i64 @js_array_clone(i64)

declare i32 @js_short_packed_spread_values(double, ptr)

declare i64 @js_spread_tail_fallback_args(ptr, i64, double)

declare i64 @js_array_from_value(double)

declare i64 @js_array_from_arraylike_holey_value(double)

declare double @js_iterator_from(double)

declare i64 @js_array_from_mapped(double, double, double)

declare i64 @js_array_concat_variadic(i64, ptr, i32)

declare double @js_arraylike_forEach(double, double, double)

declare double @js_arraylike_map(double, double, double)

declare double @js_arraylike_filter(double, double, double)

declare double @js_arraylike_some(double, double, double)

declare double @js_arraylike_every(double, double, double)

declare double @js_arraylike_find(double, double, double)

declare double @js_arraylike_findIndex(double, double, double)

declare double @js_arraylike_findLast(double, double, double)

declare double @js_arraylike_findLastIndex(double, double, double)

declare double @js_arraylike_reduce(double, double, i32, double)

declare double @js_arraylike_reduceRight(double, double, i32, double)

declare double @js_arraylike_indexOf(double, double, double, i32)

declare double @js_arraylike_lastIndexOf(double, double, double, i32)

declare double @js_arraylike_includes(double, double, double, i32)

declare double @js_arraylike_at(double, double)

declare double @js_arraylike_join(double, double)

declare double @js_arraylike_flat(double, double)

declare double @js_arraylike_slice(double, double, i32, double, i32)

declare double @js_arraylike_sort(double, double)

declare double @js_arraylike_splice(double, ptr, i32)

declare double @js_arraylike_concat(double, ptr, i32)

declare double @js_arraylike_pop(double)

declare double @js_arraylike_shift(double)

declare double @js_arraylike_push(double, ptr, i32)

declare double @js_arraylike_unshift(double, ptr, i32)

declare i64 @js_array_clone_for_spread(double)

declare i64 @js_array_spread_append(i64, double)

declare i64 @js_iterator_to_array(double)

declare double @js_iterator_next_result(double)

declare double @js_iterator_close_if_not_done(double, double)

declare double @js_iterator_rest_to_array(double, double)

declare double @js_get_iterator(double)

declare double @js_get_async_iterator(double)

declare double @js_for_of_to_array(double)

declare i64 @js_object_alloc(i32, i32)

declare double @js_object_coerce(double)

declare void @js_object_mark_class(i64)

declare void @js_class_object_pin_parent(i64, i32)

declare i64 @js_object_alloc_with_shape(i32, i32, ptr, i32)

declare void @js_object_set_field(i64, i32, i64)

declare i64 @js_object_get_field(i64, i32)

declare void @js_object_set_field_by_name(i64, i64, double)

declare void @js_object_set_field_by_property_id(i64, i64, double)

declare void @js_object_set_field_by_name_nonenum(i64, i64, double)

declare void @js_error_subclass_default_init(double, double)

declare void @js_object_set_field_by_name_nonconfigurable(i64, i64, double)

declare void @js_error_apply_cause_to_object(i64, double)

declare void @js_error_subclass_capture_stack(double)

declare i32 @js_with_has_binding(double, i64)

declare double @js_with_get_binding(double, i64)

declare double @js_with_set_binding(double, i64, double, i32)

declare i32 @js_with_delete_binding(double, i64)

declare i32 @js_pod_scalar_write_compatible(double, i32)

declare void @js_typed_feedback_register_site(i64, i32, ptr, i64, ptr, i64, ptr, i64, ptr, i64, ptr, i64, ptr, i64)

declare void @js_typed_feedback_record_guard_pass(i64)

declare void @js_typed_feedback_record_guard_fail(i64)

declare void @js_typed_feedback_record_fallback_call(i64)

declare void @js_typed_feedback_observe_property_get(i64, i64, i64)

declare void @js_typed_feedback_observe_property_set(i64, i64, i64)

declare double @js_typed_feedback_object_get_field_by_name_f64(i64, i64, i64)

declare void @js_typed_feedback_object_set_field_by_name(i64, i64, i64, double)

declare void @js_typed_feedback_object_set_field_by_name_fast(i64, i64, i64, double)

declare i32 @js_typed_feedback_class_field_set_guard(i64, double, i32, i32, i64, i32, double, i32)

declare void @js_class_field_set_fallback(i64, i64, i64, double)

declare void @js_class_field_set_ic(i64, double, i32, i32, i64, i32, double, i32)

declare i32 @js_typed_feedback_class_field_get_guard(i64, double, i32, i32, i64, i32, i32)

declare double @js_class_field_get_ic(i64, double, i32, i32, i64, i32, i32)

declare double @js_typed_feedback_native_call_method(i64, double, ptr, i64, ptr, i64)

declare double @js_typed_feedback_native_call_method_by_id(i64, double, i64, ptr, i64)

declare double @js_typed_feedback_native_call_method_apply(i64, double, ptr, i64, i64)

declare double @js_typed_feedback_native_call_method_apply_by_id(i64, double, i64, i64)

declare i32 @js_typed_feedback_method_direct_call_guard(i64, double, i32, i32, ptr, i64, ptr)

declare i32 @js_method_direct_shape_guard(double, i32, i32, i32)

declare i32 @js_method_direct_shape_class(double, ptr, i32)

declare i32 @js_typed_feedback_closure_direct_call_guard(i64, double, ptr, i32, i32)

declare i64 @js_closure_exact_func_guard(double, ptr)

declare i64 @js_object_own_method_cache_miss(double, i32, i32, ptr, i64, ptr, ptr)

declare void @js_typed_feedback_object_set_unboxed_f64_field(i64, i64, i32, i64, double)

declare double @js_typed_feedback_observe_helper_return(i64, double)

declare void @js_object_set_index_polymorphic(i64, double, double)

declare double @js_object_get_index_polymorphic(i64, double)

declare double @js_object_get_field_by_name_f64(i64, i64)

declare double @js_object_get_field_by_name_boxed(double, i64)

declare double @js_object_get_field_by_property_id_f64(i64, i64)

declare double @js_native_module_property_by_name(ptr, i64, ptr, i64)

declare double @js_native_module_esm_export_value(double, double)

declare double @js_native_module_named_esm_export_value(double, double)

declare double @js_create_native_module_namespace(ptr, i64)

declare void @js_nm_install_assert()

declare void @js_nm_install_async_hooks()

declare void @js_nm_install_bigint()

declare void @js_nm_install_buffer()

declare void @js_bun_tcp_nm_install()

declare void @js_nm_install_bun()

declare void @js_nm_install_bun_ffi()

declare void @js_nm_install_child_process()

declare void @js_nm_install_cluster()

declare void @js_nm_install_console()

declare void @js_nm_install_crypto()

declare void @js_nm_install_dgram()

declare void @js_nm_install_dns()

declare void @js_nm_install_domain()

declare void @js_nm_install_events()

declare void @js_nm_install_fs()

declare void @js_nm_install_http()

declare void @js_nm_install_inspector()

declare void @js_nm_install_module()

declare void @js_nm_install_net()

declare void @js_nm_install_node_pty()

declare void @js_nm_install_os()

declare void @js_nm_install_path()

declare void @js_nm_install_perf()

declare void @js_nm_install_process()

declare void @js_nm_install_punycode()

declare void @js_nm_install_querystring()

declare void @js_nm_install_readline()

declare void @js_nm_install_repl()

declare void @js_nm_install_sea()

declare void @js_nm_install_sqlite()

declare void @js_nm_install_stream()

declare void @js_nm_install_timers()

declare void @js_nm_install_tls()

declare void @js_nm_install_tty()

declare void @js_nm_install_url()

declare void @js_nm_install_util()

declare void @js_nm_install_v8()

declare void @js_nm_install_vm()

declare void @js_nm_install_wasi()

declare void @js_nm_install_zlib()

declare void @js_nm_install_all()

declare double @js_object_get_field_ic_miss(i64, i64, ptr)

declare double @js_object_get_field_ic(i64, i64, i64, ptr)

declare i64 @js_object_rest(i64, i64)

declare double @js_require_object_coercible(double)

declare double @js_require_json_disk(double)

declare double @js_require_resolve_node_modules(double, double)

declare void @js_globalthis_seed_async_local_storage()

declare void @js_register_path_module_partial(double, double)

declare void @js_register_path_module(double, double)

declare void @js_link_path_module_parent(double)

declare void @js_run_module_init_catching(i64)

declare double @js_require_path_module(double)

declare double @js_has_path_module(double)

declare void @js_register_path_init(ptr, i64, i64)

declare i64 @js_array_alloc_with_length(i32)

declare void @js_array_set_f64_unchecked(i64, i32, double)

declare double @js_typed_feedback_array_get_f64(i64, i64, i32)

; Function Attrs: nounwind willreturn
declare i32 @js_typed_feedback_plain_array_index_get_guard(i64, double, i32, i32) #6

; Function Attrs: nounwind willreturn
declare i32 @js_typed_feedback_numeric_array_index_get_guard(i64, double, i32, i32) #6

declare i32 @js_typed_feedback_packed_f64_array_loop_guard(i64, double)

declare i32 @js_string_array_range_loop_guard(double, i32, i32)

declare i32 @js_typed_feedback_packed_f64_range_loop_guard(i64, double, i32, i32)

declare i32 @js_typed_feedback_packed_f64_range_loop_guard_dense(i64, double, i32, i32)

declare i32 @js_typed_feedback_packed_f64_range_loop_guard_dense_i32(i64, double, i32, i32)

declare i32 @js_typed_feedback_masked_window_ta_kind(i64, double, i32, i32)

declare i64 @js_typed_array_masked_window_data_ptr(double)

declare i64 @js_packed_ecs_u32_loop_guard(double, double, double, double, double, double, i32, ptr)

declare i32 @js_typed_feedback_packed_u32_array_loop_guard(i64, double)

declare double @js_typed_feedback_array_index_get_fallback_boxed(i64, double, double)

declare void @js_typed_feedback_array_set_f64(i64, i64, i32, double)

declare i64 @js_typed_feedback_array_set_f64_extend(i64, i64, i32, double)

; Function Attrs: nounwind willreturn
declare i32 @js_typed_feedback_plain_array_index_set_guard(i64, double, i32, double, i32) #6

; Function Attrs: nounwind willreturn
declare i32 @js_typed_feedback_numeric_array_index_set_guard(i64, double, i32, double, i32) #6

; Function Attrs: nounwind willreturn
declare i32 @js_typed_feedback_numeric_array_push_guard(i64, double, double) #6

declare double @js_typed_feedback_array_index_set_fallback_boxed(i64, double, double, double, i32)

declare void @js_typed_feedback_observe_array_element(i64, i64, i32)

declare i64 @js_typed_feedback_array_set_string_key(i64, i64, i64, double)

declare i64 @js_typed_feedback_array_set_index_or_string(i64, i64, double, double, i32)

declare void @js_typed_feedback_object_set_index_polymorphic(i64, i64, double, double)

declare double @js_proxy_new(double, double)

declare double @js_proxy_revocable(double, double)

declare void @js_proxy_revoke(double)

declare i32 @js_proxy_is_revoked(double)

declare i32 @js_proxy_is_proxy(double)

declare double @js_proxy_target(double)

declare double @js_proxy_get(double, double)

declare double @js_proxy_set(double, double, double)

declare double @js_proxy_has(double, double)

declare double @js_proxy_delete(double, double)

declare double @js_proxy_apply(double, double, double)

declare double @js_proxy_construct(double, double, double)

declare double @js_reflect_construct(double, double, double)

declare double @js_reflect_get(double, double, double)

declare double @js_reflect_set(double, double, double, double)

declare double @js_put_value_set(double, double, double, double, i32)

declare i32 @js_transition_ic_spill_append(double, i64, i32, double)

declare ptr @perry_transition_cache_base()

declare void @js_transition_ic_note_hit()

declare double @js_put_value_set_dyn_ic(ptr, double, double, double, i32)

declare double @js_put_value_set_ic_miss(double, i64, double, i32, ptr, i32)

declare i32 @js_put_value_set_ic_overflow_store(double, i64, i32, double)

declare double @js_object_get_field_ic_overflow_load(i64, i64, i32, ptr)

declare double @js_put_value_set_ic_poly_tail(ptr, double, i64, double, i32)

declare i64 @js_object_array_numeric_write_guard(double, double, double, double, double, i32, i32)

declare i64 @js_object_array_numeric_write_range_guard(double, double, double, double, double, i32, i32, i32)

declare double @js_super_put_value_set(i32, double, double, double, i32)

declare double @js_super_accessor_get(i32, double, double)

declare double @js_reflect_has(double, double)

declare double @js_reflect_delete(double, double)

declare double @js_reflect_own_keys(double)

declare double @js_reflect_apply(double, double, double)

declare double @js_reflect_define_property(double, double, double)

declare double @js_reflect_get_own_property_descriptor(double, double)

declare double @js_reflect_get_prototype_of(double)

declare double @js_reflect_set_prototype_of(double, double)

declare double @js_reflect_is_extensible(double)

declare double @js_reflect_prevent_extensions(double)

declare double @js_reflect_define_metadata(double, double, double, double)

declare double @js_reflect_get_metadata(double, double, double)

declare double @js_reflect_get_own_metadata(double, double, double)

declare double @js_reflect_has_metadata(double, double, double)

declare double @js_reflect_has_own_metadata(double, double, double)

declare double @js_reflect_get_metadata_keys(double, double)

declare double @js_reflect_get_own_metadata_keys(double, double)

declare double @js_reflect_delete_metadata(double, double, double)

declare double @js_http_server_construct_with_this(double, double, double)

declare double @js_https_server_construct_with_this(double, double, double)

declare i64 @js_net_socket_set_encoding(i64, i64)

declare double @js_vm_create_context(double, double)

declare double @js_vm_create_script_branded(double, double)

declare double @js_vm_module_call()

declare double @js_vm_module_constructor_error()

declare double @js_repl_start(double)

declare double @js_repl_repl_server_new(double)

declare double @js_repl_recoverable_new(double)

declare double @js_worker_threads_worker_new(i64, double)

declare double @js_worker_threads_worker_post_message(i64, double)

declare double @js_worker_threads_worker_on(i64, double, i64)

declare double @js_worker_threads_worker_once(i64, double, i64)

declare double @js_worker_threads_worker_off(i64, double, i64)

declare double @js_worker_threads_worker_add_event_listener(i64, double, i64)

declare double @js_worker_threads_worker_remove_event_listener(i64, double, i64)

declare double @js_worker_threads_worker_terminate(i64)

declare double @js_worker_threads_worker_ref(i64)

declare double @js_worker_threads_worker_unref(i64)

declare double @js_worker_threads_worker_get_heap_statistics(i64)

declare double @js_worker_threads_worker_cpu_usage(i64, double)

declare double @js_worker_threads_worker_get_heap_snapshot(i64, double)

declare double @js_worker_threads_worker_start_cpu_profile(i64)

declare double @js_worker_threads_worker_start_heap_profile(i64)

declare i64 @js_http_client_request_end(i64, double)

declare i64 @js_http_client_request_write(i64, double)

declare i64 @js_http_client_request_end_full(i64, double, i64, i64)

declare double @js_http_client_request_write_full(i64, double, i64, i64)

declare i64 @js_http_set_timeout_full(i64, double, i64)

declare i64 @js_http_client_request_method(i64)

declare i64 @js_http_client_request_protocol(i64)

declare i64 @js_http_client_request_host(i64)

declare i64 @js_http_client_request_path(i64)

declare double @js_http_client_request_listener_count(i64, i64)

declare double @js_http_client_request_get_header(i64, i64)

declare double @js_http_client_request_has_header(i64, i64)

declare double @js_http_client_request_remove_header(i64, i64)

declare double @js_http_client_request_get_header_names(i64)

declare double @js_http_client_request_get_headers(i64)

declare double @js_http_client_request_get_raw_header_names(i64)

declare double @js_http_client_request_abort(i64)

declare i64 @js_http_client_request_destroy(i64, double)

declare double @js_http_client_request_noop_undefined(i64, double, double)

declare double @js_http_client_request_aborted(i64)

declare double @js_http_client_request_destroyed(i64)

declare double @js_http_client_request_finished(i64)

declare double @js_http_client_request_reused_socket(i64)

declare double @js_http_client_request_max_headers_count(i64)

declare double @js_http_client_request_writable_ended(i64)

declare double @js_http_client_request_writable_finished(i64)

declare double @js_http_client_request_socket(i64)

declare i64 @js_http_get(double, i64)

declare i64 @js_http_get_overload(i64)

declare i64 @js_http_request_overload(i64)

declare i64 @js_https_get_overload(i64)

declare i64 @js_https_request_overload(i64)

declare i64 @js_http_on(i64, i64, i64)

declare i64 @js_http_once(i64, i64, i64)

declare i64 @js_http_request(double, i64)

declare i64 @js_http_request_body(i64)

declare double @js_http_request_body_length(i64)

declare i64 @js_http_request_content_type(i64)

declare double @js_http_request_has_header(i64, i64)

declare i64 @js_http_request_header(i64, i64)

declare i64 @js_http_request_headers_all(i64)

declare double @js_http_request_id(i64)

declare double @js_http_request_is_method(i64, i64)

declare i64 @js_http_request_method(i64)

declare i64 @js_http_request_path(i64)

declare i64 @js_http_request_query(i64)

declare i64 @js_http_request_query_all(i64)

declare i64 @js_http_request_query_param(i64, i64)

declare double @js_http_respond_error(i64, double, i64)

declare double @js_http_respond_html(i64, double, i64)

declare double @js_http_respond_json(i64, double, i64)

declare double @js_http_respond_not_found(i64)

declare double @js_http_respond_redirect(i64, i64, double)

declare i64 @js_http_respond_status_text(double)

declare double @js_http_respond_text(i64, double, i64)

declare double @js_http_respond_with_headers(i64, double, i64, i64)

declare double @js_http_response_headers(i64)

declare double @js_http_response_trailers(i64)

declare double @js_http_incoming_message_socket(i64)

declare double @js_http_incoming_message_req(i64)

declare i64 @js_http_incoming_message_set_encoding(i64, i64)

declare i64 @js_http_server_accept_v2(i64)

declare double @js_http_server_close(i64)

declare i64 @js_http_server_create(double)

declare i64 @js_http_set_header(i64, i64, i64)

declare i64 @js_http_set_timeout(i64, double)

declare double @js_http_status_code(i64)

declare i64 @js_http_status_message(i64)

declare i64 @js_http_agent_new(double)

declare i64 @js_https_agent_new(double)

declare i64 @js_http_agent_get_name(i64, double)

declare i64 @js_http_agent_noop_self(i64)

declare double @js_http_agent_max_sockets(i64)

declare double @js_http_agent_max_free_sockets(i64)

declare double @js_http_agent_max_total_sockets(i64)

declare double @js_http_agent_keep_alive_msecs(i64)

declare double @js_http_agent_keep_alive(i64)

declare i64 @js_http_agent_protocol(i64)

declare double @js_http_agent_default_port(i64)

declare void @js_http_agent_set_protocol(i64, i64)

declare i64 @js_http_agent_destroy(i64)

declare double @js_http_agent_destroyed(i64)

declare double @js_http_agent_sockets(i64)

declare double @js_http_agent_free_sockets(i64)

declare double @js_http_agent_requests(i64)

declare void @js_http_agent_set_max_sockets(i64, double)

declare void @js_http_agent_set_max_free_sockets(i64, double)

declare void @js_http_agent_set_max_total_sockets(i64, double)

declare void @js_http_agent_set_keep_alive(i64, double)

declare void @js_http_agent_set_keep_alive_msecs(i64, double)

declare void @js_http_agent_set_create_connection(i64, i64)

declare void @js_http_agent_set_create_socket(i64, i64)

declare i64 @js_http_agent_create_connection(i64)

declare i64 @js_http_agent_create_socket(i64)

declare i64 @js_https_get(double, i64)

declare i64 @js_https_request(double, i64)

declare i64 @js_node_http_create_server(i64)

declare i64 @js_node_http_server_listen(i64, i64)

declare void @js_node_http_server_close(i64, i64)

declare void @js_node_http_server_close_all_connections(i64)

declare void @js_node_http_server_close_idle_connections(i64)

declare i64 @js_node_http_server_address_json(i64)

declare i32 @js_node_http_server_listening(i64)

declare double @js_node_http_server_listening_value(i64)

declare double @js_node_http_server_on(i64, i64, i64)

declare i64 @js_node_http_im_method(i64)

declare i64 @js_node_http_im_url(i64)

declare i64 @js_node_http_im_http_version(i64)

declare i64 @js_node_http_im_headers_json(i64)

declare i64 @js_node_http_im_raw_headers_json(i64)

declare i64 @js_node_http_im_headers_distinct_json(i64)

declare i64 @js_node_http_im_trailers_json(i64)

declare i64 @js_node_http_im_raw_trailers_json(i64)

declare i64 @js_node_http_im_trailers_distinct_json(i64)

declare i32 @js_node_http_im_complete(i64)

declare i32 @js_node_http_im_aborted(i64)

declare i32 @js_node_http_im_destroyed(i64)

declare i64 @js_node_http_im_remote_address(i64)

declare double @js_node_http_im_remote_port(i64)

declare void @js_node_http_im_pause(i64)

declare void @js_node_http_im_resume(i64)

declare void @js_node_http_im_destroy(i64)

declare double @js_node_http_im_on(i64, i64, i64)

declare double @js_node_http_im_once(i64, i64, i64)

declare double @js_node_http_im_read(i64)

declare i64 @js_node_http_im_set_timeout(i64, double, i64)

declare void @js_node_http_res_set_status(i64, double)

declare double @js_node_http_res_get_status(i64)

declare void @js_node_http_res_set_status_message(i64, i64)

declare void @js_node_http_res_set_header(i64, i64, double)

declare i64 @js_node_http_res_set_header_self(i64, i64, double)

declare double @js_node_http_res_get_header(i64, i64)

declare void @js_node_http_res_remove_header(i64, i64)

declare i32 @js_node_http_res_has_header(i64, i64)

declare double @js_node_http_res_has_header_value(i64, i64)

declare i64 @js_node_http_res_get_headers_json(i64)

declare i64 @js_node_http_res_get_header_names_json(i64)

declare i64 @js_node_http_res_append_header(i64, i64, i64)

declare i64 @js_node_http_res_set_headers(i64, double)

declare double @js_node_http_res_get_status_message(i64)

declare i32 @js_node_http_res_headers_sent(i64)

declare i32 @js_node_http_res_writable_ended(i64)

declare i32 @js_node_http_res_writable_finished(i64)

declare i32 @js_node_http_res_finished(i64)

declare i32 @js_node_http_res_send_date(i64)

declare void @js_node_http_res_set_send_date(i64, double)

declare i32 @js_node_http_res_strict_content_length(i64)

declare void @js_node_http_res_set_strict_content_length(i64, double)

declare i64 @js_node_http_res_req_handle(i64)

declare void @js_node_http_res_write_head(i64, double, i64, i64)

declare i32 @js_node_http_res_write(i64, double)

declare double @js_node_http_res_write_full(i64, double, i64, i64)

declare void @js_node_http_res_add_trailers(i64, double)

declare void @js_node_http_res_end(i64, double)

declare void @js_node_http_res_end_full(i64, double, i64, i64)

declare void @js_node_http_res_flush_headers(i64)

declare void @js_node_http_res_cork(i64)

declare void @js_node_http_res_uncork(i64)

declare i64 @js_node_http_res_set_timeout(i64, double, i64)

declare void @js_node_http_res_write_early_hints(i64, double, i64)

declare void @js_node_http_res_write_continue(i64)

declare void @js_node_http_res_write_processing(i64)

declare double @js_node_http_res_on(i64, i64, i64)

declare i64 @js_node_https_create_server(double, i64)

declare i64 @js_node_https_server_listen(i64, i64)

declare void @js_node_https_server_close(i64, i64)

declare void @js_node_https_server_close_all_connections(i64)

declare void @js_node_https_server_close_idle_connections(i64)

declare i64 @js_node_https_server_address_json(i64)

declare double @js_node_https_server_on(i64, i64, i64)

declare double @js_node_https_server_listening_value(i64)

declare double @js_node_https_server_headers_timeout(i64)

declare double @js_node_https_server_set_headers_timeout(i64, double)

declare double @js_node_https_server_keep_alive_timeout(i64)

declare double @js_node_https_server_set_keep_alive_timeout(i64, double)

declare double @js_node_https_server_keep_alive_timeout_buffer(i64)

declare double @js_node_https_server_set_keep_alive_timeout_buffer(i64, double)

declare double @js_node_https_server_request_timeout(i64)

declare double @js_node_https_server_set_request_timeout(i64, double)

declare double @js_node_https_server_idle_timeout(i64)

declare double @js_node_https_server_set_idle_timeout(i64, double)

declare double @js_node_https_server_max_headers_count(i64)

declare double @js_node_https_server_set_max_headers_count(i64, double)

declare double @js_node_https_server_max_requests_per_socket(i64)

declare double @js_node_https_server_set_max_requests_per_socket(i64, double)

declare i64 @js_node_https_server_set_timeout_method(i64, double, i64)

declare i64 @js_node_http2_create_server(double, double)

declare i64 @js_node_http2_create_secure_server(double, i64)

declare i64 @js_node_http2_connect(double, double, i64)

declare i64 @js_node_http2_server_listen(i64, i64)

declare void @js_node_http2_server_close(i64, i64)

declare i64 @js_node_http2_server_address_json(i64)

declare double @js_node_http2_server_on(i64, i64, i64)

declare i64 @js_node_http2_get_default_settings()

declare i64 @js_node_http2_get_packed_settings(i64)

declare i64 @js_node_http2_get_unpacked_settings(i64)

declare i64 @js_pg_client_connect(i64)

declare i64 @js_pg_client_end(i64)

declare i64 @js_pg_client_new(i64)

declare i64 @js_pg_client_query(i64, i64)

declare i64 @js_pg_client_query_params(i64, i64, i64)

declare i64 @js_pg_connect(i64)

declare i64 @js_pg_create_pool(i64)

declare i64 @js_pg_pool_end(i64)

declare i64 @js_pg_pool_new(i64)

declare i64 @js_pg_pool_query(i64, i64)

declare i64 @js_ioredis_connect(i64)

declare i64 @js_ioredis_decr(i64, i64)

declare i64 @js_ioredis_del(i64, i64)

declare void @js_ioredis_disconnect(i64)

declare i64 @js_ioredis_exists(i64, i64)

declare i64 @js_ioredis_expire(i64, i64, double)

declare i64 @js_ioredis_get(i64, i64)

declare i64 @js_ioredis_hdel(i64, i64, i64)

declare i64 @js_ioredis_hget(i64, i64, i64)

declare i64 @js_ioredis_hgetall(i64, i64)

declare i64 @js_ioredis_hlen(i64, i64)

declare i64 @js_ioredis_hset(i64, i64, i64, i64)

declare i64 @js_ioredis_incr(i64, i64)

declare i64 @js_ioredis_new(i64)

declare i64 @js_ioredis_ping(i64)

declare i64 @js_ioredis_quit(i64)

declare i64 @js_ioredis_set(i64, i64, i64)

declare i64 @js_ioredis_setex(i64, i64, double, i64)

declare i64 @js_mongodb_client_close(i64)

declare i64 @js_mongodb_client_connect(i64)

declare i64 @js_mongodb_client_db(i64, i64)

declare i64 @js_mongodb_client_list_databases(i64)

declare i64 @js_mongodb_client_new(i64)

declare i64 @js_mongodb_collection_count_value(i64, double)

declare i64 @js_mongodb_collection_delete_many_value(i64, double)

declare i64 @js_mongodb_collection_delete_one_value(i64, double)

declare i64 @js_mongodb_collection_find_one_value(i64, double)

declare i64 @js_mongodb_collection_find_value(i64, double)

declare i64 @js_mongodb_collection_insert_many_value(i64, double)

declare i64 @js_mongodb_collection_insert_one_value(i64, double)

declare i64 @js_mongodb_collection_update_many_value(i64, double, double)

declare i64 @js_mongodb_collection_update_one_value(i64, double, double)

declare i64 @js_mongodb_collection_count(i64, i64)

declare i64 @js_mongodb_collection_delete_many(i64, i64)

declare i64 @js_mongodb_collection_delete_one(i64, i64)

declare i64 @js_mongodb_collection_find(i64, i64)

declare i64 @js_mongodb_collection_find_one(i64, i64)

declare i64 @js_mongodb_collection_insert_many(i64, i64)

declare i64 @js_mongodb_collection_insert_one(i64, i64)

declare i64 @js_mongodb_collection_update_many(i64, i64, i64)

declare i64 @js_mongodb_collection_update_one(i64, i64, i64)

declare i64 @js_mongodb_connect(i64)

declare i64 @js_mongodb_db_collection(i64, i64)

declare i64 @js_mongodb_db_list_collections(i64)

declare void @js_sqlite_close(i64)

declare void @js_sqlite_exec(i64, i64)

declare i64 @js_sqlite_open(i64)

declare i64 @js_sqlite_pragma(i64, i64, i64)

declare i64 @js_sqlite_prepare(i64, i64)

declare i64 @js_sqlite_stmt_all(i64, i64)

declare i64 @js_sqlite_stmt_columns(i64)

declare i64 @js_sqlite_stmt_get(i64, i64)

declare i64 @js_sqlite_stmt_run(i64, i64)

declare i64 @js_sqlite_transaction(i64, i64)

declare void @js_sqlite_transaction_commit(i64)

declare void @js_sqlite_transaction_rollback(i64)

declare i64 @js_bun_sqlite_database_call(double, double)

declare i64 @js_bun_sqlite_database_new(double, double)

declare i64 @js_bun_sqlite_database_query(i64, double)

declare i64 @js_bun_sqlite_database_run(i64, double, i64)

declare i64 @js_bun_sqlite_database_filename(i64)

declare i64 @js_bun_sqlite_database_transaction(i64, double)

declare i64 @js_bun_sqlite_statement_values(i64, i64)

declare double @js_bun_sqlite_statement_safe_integers(i64, double)

declare void @js_bun_sqlite_statement_finalize(i64)

declare i64 @js_node_sqlite_backup(double, double, double)

declare i64 @js_node_sqlite_database_sync_call(double, double)

declare i64 @js_node_sqlite_database_sync_new(double, double)

declare i32 @js_node_sqlite_database_sync_open(i64)

declare i32 @js_node_sqlite_database_sync_close(i64)

declare i32 @js_node_sqlite_database_sync_dispose(i64)

declare i32 @js_node_sqlite_database_sync_exec(i64, double)

declare i64 @js_node_sqlite_database_sync_prepare(i64, double, double)

declare i32 @js_node_sqlite_database_sync_function(i64, double, double, double)

declare i32 @js_node_sqlite_database_sync_aggregate(i64, double, double)

declare i32 @js_node_sqlite_database_sync_enable_defensive(i64, double)

declare i32 @js_node_sqlite_database_sync_set_authorizer(i64, double)

declare i64 @js_node_sqlite_database_sync_create_tag_store(i64, double)

declare i64 @js_node_sqlite_database_sync_create_session(i64, double)

declare double @js_node_sqlite_database_sync_apply_changeset(i64, double, double)

declare i32 @js_node_sqlite_database_sync_enable_load_extension(i64, double)

declare i32 @js_node_sqlite_database_sync_load_extension(i64, double)

declare double @js_node_sqlite_database_sync_location(i64, double)

declare double @js_node_sqlite_database_sync_is_open(i64)

declare double @js_node_sqlite_database_sync_is_transaction(i64)

declare i64 @js_node_sqlite_database_sync_limits(i64)

declare i64 @js_node_sqlite_statement_sync_call(double, double)

declare i64 @js_node_sqlite_statement_sync_new(double, double)

declare i64 @js_node_sqlite_statement_sync_run(i64, i64)

declare double @js_node_sqlite_statement_sync_get(i64, i64)

declare i64 @js_node_sqlite_statement_sync_all(i64, i64)

declare double @js_node_sqlite_statement_sync_iterate(i64, i64)

declare i64 @js_node_sqlite_statement_sync_columns(i64)

declare i32 @js_node_sqlite_statement_sync_set_read_bigints(i64, double)

declare i32 @js_node_sqlite_statement_sync_set_return_arrays(i64, double)

declare i32 @js_node_sqlite_statement_sync_set_allow_bare_named_parameters(i64, double)

declare i32 @js_node_sqlite_statement_sync_set_allow_unknown_named_parameters(i64, double)

declare i64 @js_node_sqlite_statement_sync_source_sql(i64)

declare i64 @js_node_sqlite_statement_sync_expanded_sql(i64)

declare i64 @js_node_sqlite_sql_tag_store_run(i64, i64)

declare double @js_node_sqlite_sql_tag_store_get(i64, i64)

declare i64 @js_node_sqlite_sql_tag_store_all(i64, i64)

declare double @js_node_sqlite_sql_tag_store_iterate(i64, i64)

declare i32 @js_node_sqlite_sql_tag_store_clear(i64)

declare double @js_node_sqlite_sql_tag_store_size(i64)

declare double @js_node_sqlite_sql_tag_store_capacity(i64)

declare i64 @js_node_sqlite_sql_tag_store_db(i64)

declare i64 @js_node_sqlite_session_call(double, double)

declare i64 @js_node_sqlite_session_new(double, double)

declare i64 @js_node_sqlite_session_changeset(i64)

declare i64 @js_node_sqlite_session_patchset(i64)

declare i32 @js_node_sqlite_session_close(i64)

declare i32 @js_node_sqlite_session_dispose(i64)

declare i64 @js_os_cpus()

declare double @js_os_freemem()

declare i64 @js_os_homedir()

declare i64 @js_os_network_interfaces()

declare i64 @js_os_tmpdir()

declare double @js_os_totalmem()

declare double @js_os_uptime()

declare i64 @js_os_user_info()

declare i64 @js_os_user_info_buffer()

declare i64 @js_os_user_info_options(i64)

declare i64 @js_crypto_aes256_decrypt(i64, i64, i64)

declare i64 @js_crypto_aes256_encrypt(i64, i64, i64)

declare i64 @js_crypto_aes256_gcm_decrypt(i64, i64, i64)

declare i64 @js_crypto_aes256_gcm_encrypt(i64, i64, i64)

declare double @js_crypto_create_cipheriv(i64, i64, i64, double)

declare double @js_crypto_create_decipheriv(i64, i64, i64, double)

declare i64 @js_crypto_hkdf_sha256(i64, i64, i64, double)

declare i64 @js_crypto_hkdf_sync(i64, i64, i64, i64, double)

declare i64 @js_crypto_pbkdf2(i64, i64, double, double)

declare i64 @js_crypto_random_bytes_hex(double)

declare i64 @js_crypto_random_nonce()

declare i64 @js_crypto_scrypt(i64, i64, double)

declare double @js_crypto_generate_key_pair_sync(i64, i64)

declare i64 @js_crypto_scrypt_custom(i64, i64, double, double, double, double)

declare i64 @js_crypto_x25519_keypair()

declare i64 @js_crypto_x25519_shared_secret(i64, i64)

declare i64 @js_keccak256_native(i64)

declare i64 @js_keccak256_native_bytes(i64)

declare i64 @js_nanoid(double)

declare i64 @js_nanoid_custom(i64, double)

declare i64 @js_argon2_hash(i64)

declare i64 @js_argon2_hash_options(i64, i64)

declare i64 @js_argon2_verify(i64, i64)

declare i64 @js_bcrypt_compare(i64, i64)

declare double @js_bcrypt_compare_sync(i64, i64)

declare i64 @js_bcrypt_gen_salt(double)

declare i64 @js_bcrypt_hash(i64, double)

declare i64 @js_bcrypt_hash_sync(i64, double)

declare i64 @js_ads_interstitial_load(i64)

declare i64 @js_ads_interstitial_show()

declare i64 @js_ads_rewarded_load(i64)

declare i64 @js_ads_rewarded_show()

declare double @js_ads_banner_create(i64, i64)

declare void @js_ads_banner_destroy(double)

declare i64 @js_ads_request_consent()

declare i64 @js_perry_read_embedded(double)

declare i64 @js_perry_embedded_files()

declare double @js_thread_parallel_map(double, double)

declare double @js_thread_parallel_filter(double, double)

declare double @js_thread_spawn(double)

declare double @js_perry_native_i8(double)

declare double @js_perry_native_i16(double)

declare double @js_perry_native_u8(double)

declare double @js_perry_native_u16(double)

declare double @js_perry_native_i32(double)

declare double @js_perry_native_i64(double)

declare double @js_perry_native_u32(double)

declare double @js_perry_native_u64(double)

declare double @js_perry_native_usize(double)

declare double @js_perry_native_isize(double)

declare double @js_perry_native_f32(double)

declare double @js_perry_native_f64(double)

declare i64 @js_jwt_decode(i64)

declare i64 @js_jwt_sign(i64, i64, double, i64)

declare i64 @js_jwt_sign_es256(i64, i64, double, i64)

declare i64 @js_jwt_sign_rs256(i64, i64, double, i64)

declare i64 @js_jwt_verify(i64, i64)

declare i64 @js_jwt_verify_es256(i64, i64)

declare i64 @js_jwt_verify_rs256(i64, i64)

declare i64 @js_jwt_sign_dyn(i64, i64, i64, double, i64)

declare i64 @js_jwt_verify_dyn(i64, i64, i64)

declare i64 @js_jwt_sign_dyn_opts(i64, i64, double)

declare i64 @js_jwt_verify_dyn_opts(i64, i64, double)

declare double @js_axios_create(i64)

declare i64 @js_axios_delete(i64)

declare i64 @js_axios_get(i64)

declare i64 @js_axios_head(i64)

declare i64 @js_axios_options(i64)

declare i64 @js_axios_post(i64, double)

declare i64 @js_axios_put(i64, double)

declare i64 @js_axios_patch(i64, double)

declare i64 @js_axios_request(i64)

declare double @js_axios_response_status(i64)

declare i64 @js_axios_response_status_text(i64)

declare i64 @js_axios_response_data(i64)

declare double @js_axios_response_data_parsed(i64)

declare i64 @js_sharp_auto_orient(i64)

declare i64 @js_sharp_avif(i64, double)

declare i64 @js_sharp_blur(i64, double)

declare i64 @js_sharp_composite(i64, double)

declare i64 @js_sharp_extend(i64, double)

declare i64 @js_sharp_extract(i64, double)

declare i64 @js_sharp_flip(i64)

declare i64 @js_sharp_flop(i64)

declare i64 @js_sharp_from_buffer(i64, double)

declare i64 @js_sharp_from_file(i64)

declare i64 @js_sharp_from_input(i64)

declare i64 @js_sharp_grayscale(i64)

declare i64 @js_sharp_metadata(i64)

declare i64 @js_sharp_sharpen(i64)

declare i64 @js_sharp_trim(i64)

declare i64 @js_sharp_negate(i64)

declare i64 @js_sharp_quality(i64, double)

declare i64 @js_sharp_resize(i64, double, double)

declare i64 @js_sharp_rotate(i64, double)

declare i64 @js_sharp_to_buffer(i64)

declare i64 @js_sharp_to_file(i64, i64)

declare i64 @js_sharp_to_format(i64, i64)

declare void @js_cron_clear_interval(i64)

declare void @js_cron_clear_timeout(i64)

declare i64 @js_cron_describe(i64)

declare double @js_cron_job_is_running(i64)

declare i64 @js_cron_job_new(i64, i64, double)

declare void @js_cron_job_start(i64)

declare void @js_cron_job_stop(i64)

declare i64 @js_cron_next_date(i64)

declare i64 @js_cron_next_dates(i64, double)

declare i64 @js_cron_schedule(i64, i64)

declare i64 @js_cron_set_interval(double, double)

declare i64 @js_cron_set_timeout(double, double)

declare i32 @js_cron_timer_has_pending()

declare i32 @js_cron_timer_tick()

declare double @js_cron_validate(i64)

declare i64 @js_async_hooks_create_hook(double)

declare double @js_async_hooks_execution_async_id()

declare double @js_async_hooks_trigger_async_id()

declare double @js_async_hooks_execution_async_resource()

declare i64 @js_async_hook_enable(i64)

declare i64 @js_async_hook_disable(i64)

declare i64 @js_async_resource_new(double, double)

declare double @js_async_resource_subclass_init(double, double, double)

declare double @js_async_resource_async_id(i64)

declare double @js_async_resource_trigger_async_id(i64)

declare i64 @js_async_resource_emit_destroy(i64)

declare double @js_async_resource_run_in_async_scope(i64, double, double, i64)

declare i64 @js_async_resource_bind(i64, double, double)

declare i64 @js_async_resource_static_bind(i64, double)

declare void @js_async_local_storage_disable(i64)

declare void @js_async_local_storage_enter_with(i64, double)

declare double @js_async_local_storage_exit(i64, double, i64)

declare double @js_async_local_storage_get_store(i64)

declare i64 @js_async_local_storage_new()

declare double @js_async_local_storage_subclass_init(double)

declare double @js_async_local_storage_run(i64, double, double, i64)

declare i64 @js_disposable_stack_new()

declare i64 @js_async_disposable_stack_new()

declare double @js_suppressed_error_new(double, double, double)

declare i64 @js_zlib_deflate_sync(i64, double)

declare void @js_zlib_deflate(double, double)

declare i64 @js_zlib_gunzip_sync(i64)

declare void @js_zlib_gunzip(double, double)

declare i64 @js_zlib_gzip_sync(i64, double)

declare void @js_zlib_gzip(double, double)

declare i64 @js_zlib_inflate_sync(i64)

declare void @js_zlib_inflate(double, double)

declare i64 @js_zlib_deflate_raw_sync(double, double)

declare void @js_zlib_deflate_raw(double, double)

declare i64 @js_zlib_inflate_raw_sync(double)

declare void @js_zlib_inflate_raw(double, double)

declare i64 @js_zlib_unzip_sync(double)

declare void @js_zlib_unzip(double, double)

declare double @js_zlib_crc32(double, double)

declare i64 @js_zlib_brotli_compress_sync(i64)

declare i64 @js_zlib_brotli_decompress_sync(i64)

declare void @js_zlib_brotli_compress(double, double)

declare void @js_zlib_brotli_decompress(double, double)

declare i64 @js_zlib_zstd_compress_sync(double, double)

declare i64 @js_zlib_zstd_decompress_sync(double, double)

declare void @js_zlib_zstd_compress(double, double)

declare void @js_zlib_zstd_decompress(double, double)

declare i64 @js_zlib_create_gzip(double)

declare i64 @js_zlib_create_gunzip(double)

declare i64 @js_zlib_create_deflate(double)

declare i64 @js_zlib_create_inflate(double)

declare i64 @js_zlib_create_deflate_raw(double)

declare i64 @js_zlib_create_inflate_raw(double)

declare i64 @js_zlib_create_unzip(double)

declare i64 @js_zlib_create_brotli_compress(double)

declare i64 @js_zlib_create_zstd_compress(double)

declare i64 @js_zlib_create_zstd_decompress(double)

declare i64 @js_buffer_alloc_unsafe(i32)

declare i32 @js_buffer_byte_length(i64)

declare i32 @js_buffer_byte_length_value(double, double)

declare i64 @js_buffer_concat(i64)

declare i64 @js_buffer_concat_with_length(i64, double)

declare i32 @js_buffer_validate_size(double)

declare i64 @js_buffer_validate_concat_list(double)

declare i32 @js_buffer_copy(i64, i64, i32, i32, i32)

declare i32 @js_buffer_equals(i64, i64)

declare i64 @js_buffer_fill(i64, i32)

declare i64 @js_buffer_from_value(i64, i32)

declare double @js_buffer_is_ascii(double)

declare i32 @js_buffer_is_buffer(i64)

declare i32 @js_buffer_is_node_buffer(i64)

declare i32 @js_buffer_is_encoding(double)

declare double @js_buffer_is_utf8(double)

declare void @js_buffer_print(i64)

declare void @js_buffer_set(i64, i32, i32)

declare void @js_buffer_set_from(i64, i64, i32)

declare i64 @js_buffer_slice(i64, i32, i32)

declare i64 @js_buffer_to_string(i64, i32)

declare i64 @js_buffer_transcode(double, double, double)

declare i32 @js_buffer_write(i64, i64, i32, i32)

declare double @js_child_process_exec_sync(i64, i64)

declare double @js_child_process_exec(i64, double, double)

declare i64 @js_child_process_get_process_status(double)

declare i32 @js_child_process_kill_process(double)

declare i64 @js_child_process_spawn_background(double, i64, double, double)

declare i64 @js_child_process_spawn_sync(i64, i64, i64)

declare double @js_child_process_spawn_streams(i64, i64, i64)

declare double @js_pty_spawn(i64, i64, i64)

declare double @js_child_process_fork(i64, i64, i64)

declare double @js_child_process_exec_file(i64, double, double, double)

declare double @js_child_process_exec_file_sync(i64, double, double)

declare double @js_child_process_validate_command(double, ptr, i32)

declare double @js_child_process_validate_args(double)

declare double @js_child_process_validate_options(double, i32, i32)

declare double @js_child_process_validate_fork_module(double)

declare double @js_child_process_validate_spawn_args(double, i32, i32)

declare double @js_child_process_new()

declare i64 @js_cheerio_load(i64)

declare i64 @js_cheerio_load_fragment(i64)

declare i64 @js_cheerio_select(i64, i64)

declare i64 @js_cheerio_selection_attr(i64, i64)

declare i64 @js_cheerio_selection_attrs(i64, i64)

declare i64 @js_cheerio_selection_children(i64, i64)

declare i64 @js_cheerio_selection_eq(i64, double)

declare i64 @js_cheerio_selection_find(i64, i64)

declare i64 @js_cheerio_selection_first(i64)

declare double @js_cheerio_selection_has_class(i64, i64)

declare i64 @js_cheerio_selection_html(i64)

declare double @js_cheerio_selection_is(i64, i64)

declare i64 @js_cheerio_selection_last(i64)

declare double @js_cheerio_selection_length(i64)

declare i64 @js_cheerio_selection_parent(i64)

declare i64 @js_cheerio_selection_text(i64)

declare i64 @js_cheerio_selection_texts(i64)

declare i64 @js_cheerio_selection_to_array(i64)

declare double @js_url_file_url_to_path(double, double)

declare double @js_url_file_url_to_path_buffer(double, double)

declare double @js_url_get_hash(i64)

declare double @js_url_get_host(i64)

declare double @js_url_get_hostname(i64)

declare double @js_url_get_href(i64)

declare double @js_url_get_origin(i64)

declare double @js_url_get_pathname(i64)

declare double @js_url_get_port(i64)

declare double @js_url_get_protocol(i64)

declare double @js_url_get_search(i64)

declare double @js_url_get_search_params(i64)

declare i64 @js_url_new(i64)

declare i64 @js_url_new_with_base(i64, i64)

declare i64 @js_url_pattern_new(double, double)

declare double @js_url_pattern_constructor_call(double, double)

declare i32 @js_url_can_parse(i64)

declare i32 @js_url_can_parse_with_base(i64, i64)

declare i64 @js_url_parse(i64)

declare i64 @js_url_parse_with_base(i64, i64)

declare void @js_url_set_pathname(i64, double)

declare void @js_url_set_search(i64, double)

declare void @js_url_set_hash(i64, double)

declare void @js_url_set_protocol(i64, double)

declare void @js_url_set_hostname(i64, double)

declare void @js_url_set_port(i64, double)

declare void @js_url_set_username(i64, double)

declare void @js_url_set_password(i64, double)

declare void @js_url_set_href(i64, double)

declare double @js_url_search_params_has2(i64, double, double)

declare void @js_url_search_params_delete2(i64, double, double)

declare double @js_url_search_params_throw_missing_args(i32)

declare void @js_url_search_params_append(i64, double, double)

declare void @js_url_search_params_delete(i64, double)

declare i64 @js_url_search_params_get(i64, double)

declare double @js_url_search_params_get_all(i64, double)

declare double @js_url_search_params_has(i64, double)

declare i64 @js_url_search_params_new(i64)

declare i64 @js_url_search_params_new_any(double)

declare i64 @js_url_search_params_new_empty()

declare double @js_url_search_params_subclass_init(double, double)

declare void @js_url_search_params_set(i64, double, double)

declare i64 @js_url_search_params_to_string(i64)

declare i32 @js_url_search_params_size(i64)

declare double @js_url_search_params_entries_arr(i64)

declare double @js_url_search_params_keys_arr(i64)

declare double @js_url_search_params_values_arr(i64)

declare void @js_url_search_params_sort(i64)

declare void @js_url_search_params_for_each(i64, double, double)

declare i64 @js_url_coerce_string(double)

declare double @js_url_path_to_file_url(double, double)

declare double @js_url_domain_to_ascii(double)

declare double @js_url_domain_to_unicode(double)

declare double @js_url_to_http_options(double)

declare double @js_url_legacy_url_new()

declare double @js_url_format(double, double)

declare double @js_url_legacy_parse(double, double, double)

declare double @js_url_legacy_resolve(double, double)

declare double @js_url_legacy_resolve_object(double, double)

declare void @js_ws_close(i64)

declare i64 @js_ws_connect(i64)

declare double @js_ws_connect_start(double)

declare i64 @js_ws_handle_to_i64(double)

declare double @js_ws_is_open(i64)

declare double @js_ws_message_count(i64)

declare double @js_ws_ready_state(i64)

declare i64 @js_ws_on(i64, i64, i64)

declare i64 @js_ws_receive(i64)

declare void @js_ws_send(i64, i64)

declare void @js_ws_send_to_client(double, i64)

declare void @js_ws_close_client(double)

declare void @js_ws_send_client_i64(i64, i64)

declare void @js_ws_close_client_i64(i64)

declare i64 @js_ws_on_client_i64(i64, i64, i64)

declare void @js_ws_server_close(i64)

declare double @js_ws_server_clients(i64)

declare double @js_ws_server_address(i64)

declare i32 @js_ws_server_emit(i64, i64, double, double)

declare i64 @js_ws_server_new(double)

declare void @js_ws_handle_upgrade(i64, double, double, double, i64)

declare i64 @js_ws_wait_for_message(i64, double)

declare i64 @js_pdf_create_pdf(double)

declare void @js_pdf_add_text(i64, i64, double, double, double)

declare void @js_pdf_add_line(i64, double, double, double, double)

declare void @js_pdf_new_page(i64)

declare void @js_pdf_save(i64)

declare i64 @js_commander_action(i64, i64)

declare i64 @js_commander_command(i64, i64)

declare i64 @js_commander_description(i64, i64)

declare i64 @js_commander_get_option(i64, i64)

declare double @js_commander_get_option_bool(i64, i64)

declare double @js_commander_get_option_number(i64, i64)

declare i64 @js_commander_name(i64, i64)

declare i64 @js_commander_new()

declare i64 @js_commander_option(i64, i64, i64, i64)

declare i64 @js_commander_opts(i64)

declare i64 @js_commander_parse(i64, double)

declare i64 @js_commander_required_option(i64, i64, i64, i64)

declare i64 @js_commander_version(i64, i64)

declare double @js_dotenv_config()

declare double @js_dotenv_config_path(i64)

declare i64 @js_dotenv_parse(i64)

declare double @js_datefns_add_days(double, double)

declare double @js_datefns_add_months(double, double)

declare double @js_datefns_add_years(double, double)

declare double @js_datefns_difference_in_days(double, double)

declare double @js_datefns_difference_in_hours(double, double)

declare double @js_datefns_difference_in_minutes(double, double)

declare double @js_datefns_end_of_day(double)

declare i64 @js_datefns_format(double, i64)

declare double @js_datefns_is_after(double, double)

declare double @js_datefns_is_before(double, double)

declare double @js_datefns_parse_iso(i64)

declare double @js_datefns_start_of_day(double)

declare double @js_dayjs_add(i64, double, i64)

declare double @js_dayjs_date(i64)

declare double @js_dayjs_day(i64)

declare double @js_dayjs_diff(i64, i64, i64)

declare double @js_dayjs_end_of(i64, i64)

declare double @js_dayjs_factory(i64)

declare i64 @js_dayjs_format(i64, i64)

declare double @js_dayjs_from_timestamp(double)

declare double @js_dayjs_hour(i64)

declare double @js_dayjs_is_after(i64, i64)

declare double @js_dayjs_is_before(i64, i64)

declare double @js_dayjs_is_same(i64, i64)

declare double @js_dayjs_is_valid(i64)

declare double @js_dayjs_millisecond(i64)

declare double @js_dayjs_minute(i64)

declare double @js_dayjs_month(i64)

declare double @js_dayjs_now()

declare double @js_dayjs_parse(i64)

declare double @js_dayjs_second(i64)

declare double @js_dayjs_start_of(i64, i64)

declare double @js_dayjs_subtract(i64, double, i64)

declare i64 @js_dayjs_to_iso_string(i64)

declare double @js_dayjs_unix(i64)

declare double @js_dayjs_value_of(i64)

declare double @js_dayjs_year(i64)

declare double @js_moment_add(i64, double, i64)

declare double @js_moment_clone(i64)

declare double @js_moment_date(i64)

declare double @js_moment_day(i64)

declare double @js_moment_diff(i64, i64, i64)

declare double @js_moment_end_of(i64, i64)

declare double @js_moment_factory(i64)

declare i64 @js_moment_format(i64, i64)

declare i64 @js_moment_from_now(i64)

declare double @js_moment_from_timestamp(double)

declare double @js_moment_hour(i64)

declare double @js_moment_is_after(i64, i64)

declare double @js_moment_is_before(i64, i64)

declare double @js_moment_is_between(i64, i64, i64)

declare double @js_moment_is_same(i64, i64, i64)

declare double @js_moment_is_valid(i64)

declare double @js_moment_millisecond(i64)

declare double @js_moment_minute(i64)

declare double @js_moment_month(i64)

declare double @js_moment_now()

declare double @js_moment_parse(i64)

declare double @js_moment_second(i64)

declare double @js_moment_start_of(i64, i64)

declare double @js_moment_subtract(i64, double, i64)

declare double @js_moment_to_date(i64)

declare i64 @js_moment_to_iso_string(i64)

declare double @js_moment_unix(i64)

declare double @js_moment_value_of(i64)

declare double @js_moment_year(i64)

declare i64 @js_decimal_abs(i64)

declare i64 @js_decimal_ceil(i64)

declare double @js_decimal_cmp(i64, i64)

declare double @js_decimal_cmp_value(i64, double)

declare i64 @js_decimal_coerce_to_handle(double)

declare i64 @js_decimal_div(i64, i64)

declare i64 @js_decimal_div_number(i64, double)

declare i64 @js_decimal_div_value(i64, double)

declare double @js_decimal_eq(i64, i64)

declare double @js_decimal_eq_value(i64, double)

declare i64 @js_decimal_floor(i64)

declare i64 @js_decimal_from_number(double)

declare i64 @js_decimal_from_string(i64)

declare double @js_decimal_gt(i64, i64)

declare double @js_decimal_gt_value(i64, double)

declare double @js_decimal_gte(i64, i64)

declare double @js_decimal_gte_value(i64, double)

declare double @js_decimal_is_negative(i64)

declare double @js_decimal_is_positive(i64)

declare double @js_decimal_is_zero(i64)

declare double @js_decimal_lt(i64, i64)

declare double @js_decimal_lt_value(i64, double)

declare double @js_decimal_lte(i64, i64)

declare double @js_decimal_lte_value(i64, double)

declare i64 @js_decimal_minus(i64, i64)

declare i64 @js_decimal_minus_number(i64, double)

declare i64 @js_decimal_minus_value(i64, double)

declare i64 @js_decimal_mod(i64, i64)

declare i64 @js_decimal_mod_value(i64, double)

declare i64 @js_decimal_neg(i64)

declare i64 @js_decimal_plus(i64, i64)

declare i64 @js_decimal_plus_number(i64, double)

declare i64 @js_decimal_plus_value(i64, double)

declare i64 @js_decimal_pow(i64, double)

declare i64 @js_decimal_round(i64)

declare i64 @js_decimal_sqrt(i64)

declare i64 @js_decimal_times(i64, i64)

declare i64 @js_decimal_times_number(i64, double)

declare i64 @js_decimal_times_value(i64, double)

declare i64 @js_decimal_to_fixed(i64, double)

declare double @js_decimal_to_number(i64)

declare i64 @js_decimal_to_string(i64)

declare i64 @js_ethers_format_ether(i64)

declare i64 @js_ethers_format_units(i64, double)

declare i64 @js_ethers_get_address(i64)

declare i64 @js_ethers_parse_ether(i64)

declare i64 @js_ethers_parse_units(i64, double)

declare i64 @js_lodash_camel_case(i64)

declare i64 @js_lodash_capitalize(i64)

declare i64 @js_lodash_chunk(i64, double)

declare double @js_lodash_clamp(double, double, double)

declare i64 @js_lodash_compact(i64)

declare i64 @js_lodash_concat(i64, i64)

declare i64 @js_lodash_difference(i64, i64)

declare i64 @js_lodash_drop(i64, double)

declare i64 @js_lodash_drop_right(i64, double)

declare double @js_lodash_ends_with(i64, i64)

declare i64 @js_lodash_escape(i64)

declare double @js_lodash_first(i64)

declare i64 @js_lodash_flatten(i64)

declare double @js_lodash_in_range(double, double, double)

declare double @js_lodash_includes(i64, i64)

declare i64 @js_lodash_initial(i64)

declare i64 @js_lodash_kebab_case(i64)

declare double @js_lodash_last(i64)

declare i64 @js_lodash_lower_case(i64)

declare i64 @js_lodash_lower_first(i64)

declare double @js_lodash_max(i64)

declare double @js_lodash_max_by(i64, double)

declare double @js_lodash_mean(i64)

declare double @js_lodash_mean_by(i64, double)

declare double @js_lodash_min(i64)

declare double @js_lodash_min_by(i64, double)

declare i64 @js_lodash_pad(i64, double)

declare i64 @js_lodash_pad_end(i64, double)

declare i64 @js_lodash_pad_start(i64, double)

declare double @js_lodash_random(double, double)

declare i64 @js_lodash_repeat(i64, double)

declare i64 @js_lodash_replace(i64, i64, i64)

declare i64 @js_lodash_reverse(i64)

declare double @js_lodash_size(i64)

declare i64 @js_lodash_snake_case(i64)

declare i64 @js_lodash_split(i64, i64)

declare i64 @js_lodash_start_case(i64)

declare double @js_lodash_starts_with(i64, i64)

declare double @js_lodash_sum(i64)

declare double @js_lodash_sum_by(i64, double)

declare i64 @js_lodash_tail(i64)

declare i64 @js_lodash_take(i64, double)

declare i64 @js_lodash_take_right(i64, double)

declare i64 @js_lodash_trim(i64)

declare i64 @js_lodash_trim_end(i64)

declare i64 @js_lodash_trim_start(i64)

declare i64 @js_lodash_truncate(i64, double)

declare i64 @js_lodash_unescape(i64)

declare i64 @js_lodash_uniq(i64)

declare i64 @js_lodash_upper_case(i64)

declare i64 @js_lodash_upper_first(i64)

declare void @js_lru_cache_clear(i64)

declare double @js_lru_cache_delete(i64, double)

declare double @js_lru_cache_get(i64, double)

declare double @js_lru_cache_has(i64, double)

declare i64 @js_lru_cache_new(double)

declare double @js_lru_cache_peek(i64, double)

declare i64 @js_lru_cache_set(i64, double, double)

declare double @js_lru_cache_size(i64)

declare double @js_event_emitter_subclass_init(double)

declare double @js_event_emitter_async_resource_subclass_init(double, double)

declare double @js_array_subclass_init(double, double)

declare double @js_array_subclass_init_args(double, ptr, i64)

declare double @js_map_set_subclass_init(double, i32, double)

declare double @js_weak_collection_subclass_init(double, i32, double)

declare double @js_promise_subclass_init(double, double)

declare double @js_node_stream_readable_new(double)

declare double @js_node_stream_readable_subclass_init(double, double)

declare double @js_node_stream_writable_new(double)

declare double @js_node_stream_writable_subclass_init(double, double)

declare double @js_node_stream_duplex_new(double)

declare double @js_node_stream_duplex_subclass_init(double, double)

declare double @js_node_stream_transform_new(double)

declare double @js_node_stream_transform_subclass_init(double, double)

declare double @js_node_stream_passthrough_new(double)

declare double @js_node_stream_readable_from(double)

declare double @js_node_stream_readable_from_options(double, double)

declare double @js_node_stream_duplex_from_options(double, double)

declare double @js_node_stream_is_disturbed(double)

declare double @js_node_stream_is_errored(double)

declare double @js_node_stream_is_readable(double)

declare double @js_node_stream_is_writable(double)

declare double @js_node_stream_is_array_buffer_view(double)

declare double @js_node_stream_is_uint8_array(double)

declare double @js_node_stream_is_destroyed(double)

declare double @js_node_stream_uint8_array_to_buffer(double)

declare double @js_node_stream_get_default_hwm(double)

declare double @js_node_stream_set_default_hwm(double, double)

declare double @js_node_stream_add_abort_signal(double, double)

declare double @js_node_stream_compose(i64)

declare double @js_node_stream_pipeline(i64)

declare double @js_node_stream_finished(i64)

declare double @js_node_stream_duplex_pair(double)

declare double @js_node_stream_readable_to_web(double)

declare double @js_node_stream_writable_to_web(double)

declare double @js_node_stream_duplex_to_web(double)

declare double @js_node_stream_readable_from_web(double, double)

declare double @js_node_stream_writable_from_web(double, double)

declare double @js_node_stream_duplex_from_web(double, double)

declare double @js_node_stream_to_web(double)

declare double @js_node_stream_from_web(double)

declare double @js_node_stream_method_readable_aborted(i64)

declare double @js_node_stream_method_closed(i64)

declare double @js_node_stream_method_errored(i64)

declare double @js_node_stream_method_readable_did_read(i64)

declare double @js_node_stream_method_destroyed(i64)

declare double @js_node_stream_method_destroy(i64, double)

declare double @js_node_stream_method_pause(i64)

declare double @js_node_stream_method_readable(i64)

declare double @js_node_stream_method_readable_length(i64)

declare double @js_node_stream_method_readable_flowing(i64)

declare double @js_node_stream_method_readable_ended(i64)

declare double @js_node_stream_method_readable_object_mode(i64)

declare double @js_node_stream_method_pipe(i64, double, double)

declare double @js_node_stream_method_unpipe(i64, double)

declare double @js_node_stream_method_is_paused(i64)

declare double @js_node_stream_method_resume(i64)

declare double @js_node_stream_method_readable_encoding(i64)

declare double @js_node_stream_method_cork(i64)

declare double @js_node_stream_method_uncork(i64)

declare double @js_node_stream_method_writable_corked(i64)

declare double @js_node_stream_method_writable_length(i64)

declare double @js_node_stream_method_writable_need_drain(i64)

declare double @js_node_stream_method_writable(i64)

declare double @js_node_stream_method_writable_ended(i64)

declare double @js_node_stream_method_writable_finished(i64)

declare double @js_node_stream_method_allow_half_open(i64)

declare double @js_node_stream_method_set_encoding(i64, double)

declare double @js_node_stream_method_writable_object_mode(i64)

declare double @js_event_emitter_emit(i64, i64, i64)

declare double @js_event_emitter_emit0(i64, i64)

declare double @js_event_emitter_listener_count(i64, i64, i64)

declare i64 @js_event_emitter_new()

declare i64 @js_event_emitter_new_with_options(double)

declare i64 @js_event_emitter_on(i64, i64, i64)

declare i64 @js_event_emitter_once(i64, i64, i64)

declare i64 @js_event_emitter_prepend_listener(i64, i64, i64)

declare i64 @js_event_emitter_prepend_once_listener(i64, i64, i64)

declare i64 @js_event_emitter_remove_all_listeners(i64, i64)

declare i64 @js_event_emitter_remove_listener(i64, i64, i64)

declare i64 @js_event_emitter_set_max_listeners(i64, double)

declare double @js_event_emitter_get_max_listeners(i64)

declare i64 @js_event_emitter_event_names(i64)

declare i64 @js_event_emitter_listeners(i64, i64)

declare i64 @js_event_emitter_raw_listeners(i64, i64)

declare double @js_event_emitter_domain_value(i64)

declare i64 @js_event_emitter_async_resource_new(double)

declare double @js_event_emitter_async_resource_call(double)

declare double @js_event_emitter_async_resource_async_id(i64)

declare double @js_event_emitter_async_resource_trigger_async_id(i64)

declare double @js_event_emitter_async_resource_async_resource(i64)

declare double @js_event_emitter_async_resource_emit_destroy(i64)

declare i64 @js_events_once(double, i64, double)

declare i64 @js_events_on(double, i64, double)

declare i64 @js_events_add_abort_listener(double, double)

declare i64 @js_events_get_event_listeners(double, i64)

declare double @js_events_listener_count(double, i64)

declare double @js_events_get_max_listeners(double)

declare double @js_events_set_max_listeners(double, i64)

declare double @js_events_init()

declare i64 @js_domain_create()

declare i64 @js_domain_on(i64, i64, i64)

declare double @js_domain_emit(i64, i64, i64)

declare double @js_domain_run(i64, double, i64)

declare double @js_domain_bind(i64, double)

declare double @js_domain_intercept(i64, double)

declare i64 @js_domain_add(i64, double)

declare i64 @js_domain_remove(i64, double)

declare double @js_domain_enter(i64)

declare double @js_domain_exit(i64)

declare i64 @js_string_decoder_new(i64)

declare double @js_string_decoder_write(i64, double)

declare double @js_string_decoder_end(i64, double)

declare double @js_querystring_escape(double)

declare double @js_querystring_unescape(double)

declare i64 @js_querystring_unescape_buffer(double, double)

declare i64 @js_querystring_parse(double, double, double, double)

declare double @js_querystring_stringify(double, double, double, double)

declare i32 @js_fastify_add_hook(i64, i64, i64)

declare i32 @js_fastify_all(i64, i64, i64)

declare i64 @js_fastify_create()

declare i64 @js_fastify_create_with_opts(double)

declare double @js_fastify_ctx_html(i64, i64, double)

declare double @js_fastify_ctx_json(i64, double, double)

declare double @js_fastify_ctx_redirect(i64, i64, double)

declare double @js_fastify_ctx_text(i64, i64, double)

declare i32 @js_fastify_delete(i64, i64, i64)

declare i32 @js_fastify_get(i64, i64, i64)

declare i32 @js_fastify_head(i64, i64, i64)

declare void @js_fastify_listen(i64, double, i64)

declare void @js_fastify_app_close(i64)

declare i64 @js_fastify_app_server(i64)

declare void @js_fastify_app_on(i64, i64, i64)

declare i32 @js_fastify_options(i64, i64, i64)

declare i32 @js_fastify_patch(i64, i64, i64)

declare i32 @js_fastify_post(i64, i64, i64)

declare i32 @js_fastify_put(i64, i64, i64)

declare i32 @js_fastify_register(i64, i64, double)

declare i64 @js_fastify_reply_header(i64, i64, i64)

declare i32 @js_fastify_reply_send(i64, double)

declare i64 @js_fastify_reply_status(i64, double)

declare i64 @js_fastify_reply_type(i64, i64)

declare i64 @js_fastify_req_body(i64)

declare double @js_fastify_req_get_user_data(i64)

declare i64 @js_fastify_req_header(i64, i64)

declare i64 @js_fastify_req_headers(i64)

declare double @js_fastify_req_json(i64)

declare i64 @js_fastify_req_method(i64)

declare i64 @js_fastify_req_param(i64, i64)

declare i64 @js_fastify_req_params(i64)

declare i64 @js_fastify_req_query(i64)

declare double @js_fastify_req_query_object(i64)

declare void @js_fastify_req_set_user_data(i64, double)

declare i64 @js_fastify_req_url(i64)

declare i32 @js_fastify_route(i64, i64, i64, i64)

declare i32 @js_fastify_set_error_handler(i64, i64)

declare double @js_nodemailer_create_transport(i64)

declare i64 @js_nodemailer_send_mail(i64, i64)

declare i64 @js_nodemailer_verify(i64)

declare i64 @js_ratelimit_block(i64, i64, double)

declare i64 @js_ratelimit_consume(i64, i64, double)

declare i64 @js_ratelimit_create(i64)

declare i64 @js_ratelimit_delete(i64, i64)

declare i64 @js_ratelimit_get(i64, i64)

declare i64 @js_ratelimit_new_from_options(i64)

declare i64 @js_ratelimit_penalty(i64, i64, double)

declare i64 @js_ratelimit_reward(i64, i64, double)

declare double @js_validator_contains(i64, i64)

declare double @js_validator_equals(i64, i64)

declare double @js_validator_is_alpha(i64)

declare double @js_validator_is_alphanumeric(i64)

declare double @js_validator_is_email(i64)

declare double @js_validator_is_empty(i64)

declare double @js_validator_is_float(i64)

declare double @js_validator_is_hexadecimal(i64)

declare double @js_validator_is_int(i64)

declare double @js_validator_is_json(i64)

declare double @js_validator_is_length(i64, double, double)

declare double @js_validator_is_lowercase(i64)

declare double @js_validator_is_numeric(i64)

declare double @js_validator_is_uppercase(i64)

declare double @js_validator_is_url(i64)

declare double @js_validator_is_uuid(i64)

declare i64 @js_date_to_locale_string(double)

declare i64 @js_number_to_locale_string(double)

declare double @js_value_to_locale_string(double)

declare i64 @js_string_split_regex(i64, i64)

declare i32 @js_object_delete_dynamic(i64, double)

declare double @js_object_get_prototype_of(double)

declare double @js_object_set_prototype_of(double, double)

declare double @js_object_define_properties(double, double)

declare double @js_math_acos(double)

declare double @js_math_asin(double)

declare double @js_math_atan(double)

declare double @js_math_atan2(double, double)

declare double @js_math_cos(double)

declare double @js_math_expm1(double)

declare double @js_math_log(double)

declare double @js_math_log10(double)

declare double @js_math_log1p(double)

declare double @js_math_log2(double)

declare double @js_math_sin(double)

declare double @js_math_tan(double)

declare double @js_atomics_load(ptr, double, double)

declare double @js_atomics_is_lock_free(ptr, double)

declare double @js_atomics_store(ptr, double, double, double)

declare double @js_atomics_add(ptr, double, double, double)

declare double @js_atomics_sub(ptr, double, double, double)

declare double @js_atomics_and(ptr, double, double, double)

declare double @js_atomics_or(ptr, double, double, double)

declare double @js_atomics_xor(ptr, double, double, double)

declare double @js_atomics_exchange(ptr, double, double, double)

declare double @js_atomics_compare_exchange(ptr, double, double, double, double)

declare double @js_atomics_notify(ptr, double, double, double)

declare double @js_atomics_wait(ptr, double, double, double, double)

declare double @js_atomics_wait_async(ptr, double, double, double, double)

declare double @js_number_is_finite(double)

declare double @js_json_get_bool(i64, i64)

declare double @js_json_get_number(i64, i64)

declare i64 @js_json_get_string(i64, i64)

declare double @js_json_is_valid(i64)

declare i64 @js_json_stringify_bool(double)

declare i64 @js_json_stringify_null()

declare i64 @js_json_stringify_number(double)

declare i64 @js_json_stringify_string(i64)

declare void @js_set_property(double, i64, i64, double)

declare i64 @js_error_get_message(i64)

declare double @js_await_js_promise(double)

declare i64 @js_text_decoder_decode(i64)

declare i64 @js_text_encoder_encode(double)

declare double @js_call_function(i64, i64, i64, i64, i64)

declare double @js_call_method(double, i64, i64, i64, i64)

declare double @js_call_value(double, i64, i64)

declare double @js_closure_call_array(i64, ptr, i64)

declare double @js_closure_call_apply_with_spread(double, ptr, i64, i64)

declare double @js_create_callback(i64, i64, i64)

declare double @js_dynamic_neg(double)

declare double @js_dynamic_pos(double)

declare i32 @js_dynamic_string_equals(double, double)

declare double @js_is_nan(double)

declare i32 @js_jsvalue_compare(double, double)

declare i32 @js_jsvalue_loose_equals(double, double)

declare void @js_gc_collect()

declare void @js_console_assert(double, i64)

declare void @js_console_assert_spread(double, i64)

declare void @js_console_group(i64)

declare double @js_console_context(double)

declare double @js_console_create_task(double)

declare i64 @js_fetch_input_ptr(double)

declare i64 @js_fetch_get(i64)

declare i64 @js_fetch_get_with_auth(i64, i64)

declare i64 @js_fetch_post(i64, i64, i64)

declare i64 @js_fetch_post_with_auth(i64, i64, i64)

declare double @js_fetch_stream_close(double)

declare i64 @js_fetch_stream_poll(double)

declare double @js_fetch_stream_start(i64, i64, i64, i64)

declare double @js_fetch_stream_status(double)

declare i64 @js_fetch_text(i64)

declare i64 @js_fetch_with_options(i64, i64, i64, i64)

declare void @js_fetch_set_pending_signal(double)

declare i64 @js_fetch_headers_to_json(double)

declare double @js_net_create_connection(i32, i64, i64)

declare i64 @js_net_create_server(i64, i64)

declare i64 @js_ext_net_create_server(i64, i64)

declare i64 @js_ext_net_socket_connect(double, double, double)

declare double @js_net_normalize_args(double)

declare double @js_net_create_server_handle_stub(double, double, double, double, double)

declare void @js_net_validate_create_server_options(double)

declare i64 @js_net_socket_set_timeout(i64, double, i64)

declare void @js_net_server_listen(i64, double, double, double)

declare void @js_net_server_close(i64, i64)

declare i64 @js_net_server_address(i64)

declare void @js_net_server_on(i64, i64, i64)

declare double @js_net_server_get_listening(i64)

declare double @js_net_server_get_connections(i64)

declare double @js_net_server_get_max_connections(i64)

declare double @js_net_server_set_max_connections(i64, double)

declare double @js_net_server_get_drop_max_connection(i64)

declare double @js_net_server_set_drop_max_connection(i64, double)

declare i64 @js_net_block_list_new()

declare double @js_net_block_list_is_block_list(double)

declare double @js_net_block_list_add_address(i64, i64, i64)

declare double @js_net_block_list_add_range(i64, i64, i64, i64)

declare double @js_net_block_list_add_subnet(i64, i64, double, i64)

declare double @js_net_block_list_check(i64, i64, i64)

declare double @js_net_block_list_to_json(i64)

declare i64 @js_net_block_list_rules(i64)

declare double @js_net_block_list_from_json(i64, double)

declare i64 @js_net_socket_address_new(double)

declare double @js_net_socket_address_parse(i64)

declare i64 @js_net_socket_address_get_address(i64)

declare i64 @js_net_socket_address_get_family(i64)

declare double @js_net_socket_address_get_port(i64)

declare double @js_net_socket_address_get_flowlabel(i64)

declare double @js_net_socket_get_type_of_service(i64)

declare i64 @js_net_socket_set_type_of_service(i64, double)

declare i64 @js_net_socket_address(i64)

declare i64 @js_net_socket_once(i64, i64, i64)

declare i64 @js_ext_net_socket_once(i64, i64, i64)

declare void @js_ext_net_socket_on(i64, i64, i64)

declare i64 @js_ext_tls_connect(double, double, double, double)

declare i64 @js_net_socket_remove_listener(i64, i64, i64)

declare i64 @js_net_socket_remove_all_listeners(i64, i64)

declare double @js_net_socket_listener_count(i64, i64)

declare i64 @js_net_socket_event_names(i64)

declare i64 @js_net_socket_reset_and_destroy(i64)

declare i64 @js_net_server_once(i64, i64, i64)

declare i64 @js_net_server_remove_listener(i64, i64, i64)

declare i64 @js_net_server_remove_all_listeners(i64, i64)

declare double @js_net_server_listener_count(i64, i64)

declare i64 @js_net_server_event_names(i64)

declare double @js_performance_now()

declare double @js_perf_mark(double, double)

declare double @js_perf_measure(double, double, double)

declare double @js_perf_get_entries()

declare double @js_perf_get_entries_by_type(double)

declare double @js_perf_get_entries_by_name(double, double)

declare double @js_perf_clear_marks(double)

declare double @js_perf_clear_measures(double)

declare double @js_perf_event_loop_utilization(double, double)

declare double @js_perf_to_json()

declare double @js_perf_clear_resource_timings()

declare double @js_perf_set_resource_timing_buffer_size(double)

declare double @js_perf_mark_resource_timing(double, double, double, double, double, double, double, double)

declare double @js_perf_timerify(double, double)

declare double @js_perf_observer_new(double)

declare double @js_perf_observer_observe(double, double)

declare double @js_perf_observer_disconnect(double)

declare double @js_perf_observer_take_records(double)

declare double @js_perf_monitor_event_loop_delay(double)

declare double @js_perf_create_histogram(double)

declare double @js_iter_result_set(double, i32)

declare double @js_iter_result_set_f64(double, i32)

declare double @js_iter_result_set_i32(i32, i32)

declare double @js_iter_result_set_i1(i32, i32)

declare double @js_iter_result_get_value()

declare double @js_iter_result_get_value_f64()

declare i32 @js_iter_result_get_value_i32()

declare i32 @js_iter_result_get_value_i1()

declare double @js_iter_result_get_done()

declare i64 @js_async_step_chain(double, i64)

declare i64 @js_async_step_done(double, i64)

declare i64 @js_get_current_step_closure()

declare double @js_async_first_call(double)

declare double @js_async_generator_resume(double, double, double)

declare void @js_register_class_getter(i64, i64, i64, i64)

declare void @js_register_class_setter(i64, i64, i64, i64)

declare void @js_register_class_string_member_order(i64, i64, i64, i64, i64)

declare void @js_register_class_method_bind_length(i64, i64, i64, i64)

declare void @js_register_class_static_method_bind_length(i64, i64, i64, i64)

declare void @js_register_class_static_getter(i64, i64, i64, i64)

declare void @js_register_class_static_setter(i64, i64, i64, i64)

declare void @js_register_class_method(i64, i64, i64, i64, i64, i64, i64)

declare void @js_register_class_constructor(i64, i64, i64, i64)

declare void @js_register_class_constructor_flags(i64, i64, i64)

declare void @js_register_class_static_method(i64, i64, i64, i64, i64, i64)

declare double @js_class_static_method_call(double, i64, i64, ptr, i64)

declare double @js_class_method_bind(double, i64, i64)

declare double @js_class_method_snapshot_bind(double, i64, i64)

declare double @js_class_method_bind_by_id(double, i64)

declare double @js_class_lexical_binding_get(double)

declare double @js_class_lexical_binding_set(double, double)

declare double @js_class_prototype_method_value(double, double)

declare double @js_implicit_this_get()

declare double @js_implicit_this_get_sloppy()

declare double @js_implicit_this_set(double)

declare double @js_static_this_resolve(double)

declare void @js_static_this_arm_classref(i32)

declare void @js_static_this_arm_value(double)

declare double @js_ctor_return_override(double, double, i32)

declare double @js_new_target_get()

declare double @js_new_target_set(double)

declare void @js_derived_super_scope_push(ptr)

declare void @js_derived_super_scope_pop()

declare double @js_derived_super_bind_current()

declare double @js_derived_this_check_current()

declare double @js_get_export(i64, i64, i64)

declare double @js_get_property(double, i64, i64)

declare i64 @js_load_module(i64, i64)

declare double @js_module_dynamic_import_apply_hooks(double)

declare double @js_native_call_method_nullsafe(double, i64, i64, i64, i64)

declare double @js_native_call_value(double, i64, i64)

declare double @js_new_from_handle(double, i64, i64)

declare double @js_new_instance(i64, i64, i64, i64, i64)

declare void @js_runtime_init()

declare double @js_object_set_symbol_method(double, double, double)

declare double @js_object_set_method_by_name(double, double, double)

declare double @js_object_define_accessor(double, double, double, double)

declare double @js_object_literal_set_computed(double, double, double)

declare double @js_object_literal_to_property_key(double)

declare double @js_object_literal_set_prototype(double, double)

declare double @js_to_primitive(double, i32)

declare void @js_register_class_has_instance(i32, i64)

declare void @js_register_class_to_string_tag(i32, i64)

declare double @js_object_to_string(double)

declare double @js_object_group_by(double, double)

declare double @js_map_group_by(double, double)

declare double @js_array_from_async(double, double, double)

declare double @js_jsx(double, double)

declare double @js_jsxs(double, double)

declare i64 @js_node_http_server_ref(i64)

declare i64 @js_node_http_server_unref(i64)

declare i64 @js_node_https_server_ref(i64)

declare i64 @js_node_https_server_unref(i64)

declare double @js_http_client_request_flush_headers(i64, double, double)

declare double @js_node_http_im_http_version_major(i64)

declare double @js_node_http_im_http_version_minor(i64)

declare i64 @js_node_http_im_pause_self(i64)

declare i64 @js_node_http_im_resume_self(i64)

declare i64 @js_commander_args_array(i64)

declare i64 @js_commander_argument(i64, i64)

declare token @llvm.experimental.gc.statepoint.p0(i64 immarg, i32 immarg, ptr, i32 immarg, i32 immarg, ...)

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token, i32 immarg, i32 immarg) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i1 @llvm.experimental.gc.result.i1(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i8 @llvm.experimental.gc.result.i8(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i16 @llvm.experimental.gc.result.i16(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i32 @llvm.experimental.gc.result.i32(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i64 @llvm.experimental.gc.result.i64(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i128 @llvm.experimental.gc.result.i128(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare float @llvm.experimental.gc.result.f32(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare double @llvm.experimental.gc.result.f64(token) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare ptr @llvm.experimental.gc.result.p0(token) #7

define internal double @"perry_fn_diagnostic_fixture_ts__allocating$spec_b"(double %arg0) #8 gc "statepoint-example" {
entry.0:
  %r1 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r1, align 8
  %rs4gc.b1 = bitcast double %arg0 to i64
  %rs4gc.s1 = inttoptr i64 %rs4gc.b1 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r1, align 8
  %r2.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r2.rs4i = ptrtoint ptr addrspace(1) %r2.rs4p to i64
  %r2.rs4o = call i64 asm "", "=r,0"(i64 %r2.rs4i) #11
  %r2 = bitcast i64 %r2.rs4o to double
  %r3 = call i64 @js_get_string_pointer_unified(double %r2)
  %r4 = inttoptr i64 %r3 to ptr
  %r5 = load i32, ptr %r4, align 4
  %r6 = call i32 @js_string_index_to_i32(double 1.000000e+00)
  %r7 = call i64 @js_string_slice(i64 %r3, i32 %r6, i32 %r5)
  %r8 = or i64 %r7, 9223090561878065152
  %r9 = bitcast i64 %r8 to double
  %r10 = load double, ptr @diagnostic_fixture_ts_.str.0.handle, align 8
  %r11 = call double @js_string_concat_box(double %r9, double %r10)
  ret double %r11
}

define internal double @"perry_fn_diagnostic_fixture_ts__exercise$spec_i32"(i32 %arg3) #8 gc "statepoint-example" {
entry.0:
  %r2 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r2, align 8
  %rs4gc.b1 = bitcast double 0x7FFC000000000001 to i64
  %rs4gc.s1 = inttoptr i64 %rs4gc.b1 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r2, align 8
  %r6 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r6, align 8
  %r7 = load i64, ptr @perry_class_keys_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 4
  %rs4gc.s2 = inttoptr i64 %r7 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s2, ptr %r6, align 8
  %r9 = alloca i32, align 4
  %r10 = load i32, ptr @perry_class_shape_id_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 4
  store i32 %r10, ptr %r9, align 4
  %r13 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r13, align 8
  store ptr addrspace(1) null, ptr %r13, align 8
  %r219 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r219, align 8
  %rs4gc.b3 = bitcast double 0x7FFC000000000001 to i64
  %rs4gc.s3 = inttoptr i64 %rs4gc.b3 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s3, ptr %r219, align 8
  %r242 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r242, align 8
  store ptr addrspace(1) null, ptr %r242, align 8
  %r1 = alloca i32, align 4
  store i32 %arg3, ptr %r1, align 4
  %r3 = load double, ptr @diagnostic_fixture_ts_.str.1.handle, align 8
  %r4 = load i32, ptr %r1, align 4
  %r5 = sitofp i32 %r4 to double
  %r8.rs4p = load ptr addrspace(1), ptr %r6, align 8
  %r8.rs4i = ptrtoint ptr addrspace(1) %r8.rs4p to i64
  %r8 = call i64 asm "", "=r,0"(i64 %r8.rs4i) #11
  %r11 = load i32, ptr %r9, align 4
  %r12 = call i64 @js_object_alloc_class_inline_keys_stamped(i32 1, i32 0, i32 2, i64 %r8, i32 %r11)
  call void @js_gc_declare_typed_shape_layout(i64 %r12, i32 2, ptr @perry_typed_shape_raw_f64_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, i32 1, ptr @perry_typed_shape_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, i32 1) #11
  %rs4gc.s4 = inttoptr i64 %r12 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s4, ptr %r13, align 8
  %r14.rs4p = load ptr addrspace(1), ptr %r13, align 8
  %r14.rs4i = ptrtoint ptr addrspace(1) %r14.rs4p to i64
  %r14 = call i64 asm "", "=r,0"(i64 %r14.rs4i) #11
  %r15 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r16 = icmp ne i32 %r15, 0
  br i1 %r16, label %shadow.root.barrier.1, label %shadow.root.barrier.done.2

shadow.root.barrier.1:                            ; preds = %entry.0
  call void @js_write_barrier_root_nanbox(i64 %r14) #11
  br label %shadow.root.barrier.done.2

shadow.root.barrier.done.2:                       ; preds = %shadow.root.barrier.1, %entry.0
  %r17 = or i64 %r12, 9222527611924643840
  %r18 = bitcast i64 %r17 to double
  %r19 = load double, ptr @diagnostic_fixture_ts_.str.1.handle, align 8
  %r20 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r21 = icmp eq i8 %r20, 0
  %r22 = inttoptr i64 %r12 to ptr
  %r23 = getelementptr i8, ptr %r22, i64 -6
  %r24 = load i16, ptr %r23, align 2
  %r25 = and i16 %r24, 4096
  %r26 = icmp ne i16 %r25, 0
  %r27 = and i1 %r21, %r26
  %r28 = bitcast double %r5 to i64
  %r29 = and i64 %r28, 9218868437227405312
  %r30 = icmp ne i64 %r29, 9218868437227405312
  %r31 = and i1 %r27, %r30
  br i1 %r31, label %ctor_prologue.fast.3, label %ctor_prologue.slow.4

ctor_prologue.fast.3:                             ; preds = %shadow.root.barrier.done.2
  %r32 = inttoptr i64 %r12 to ptr
  %r33 = getelementptr i8, ptr %r32, i64 16
  %r34 = bitcast double %r18 to i64
  %r35 = getelementptr double, ptr %r33, i64 0
  store double %r19, ptr %r35, align 8
  %r36 = ptrtoint ptr %r35 to i64
  %r37 = bitcast double %r19 to i64
  %r38 = lshr i64 %r37, 48
  %r39 = icmp eq i64 %r38, 0
  %r40 = icmp uge i64 %r37, 4096
  %r41 = and i1 %r39, %r40
  %r42 = icmp eq i64 %r38, 32765
  %r43 = icmp eq i64 %r38, 32767
  %r44 = icmp eq i64 %r38, 32762
  %r45 = or i1 %r42, %r43
  %r46 = or i1 %r45, %r44
  %r47 = or i1 %r46, %r41
  br i1 %r47, label %ctor_prologue.barrier.maybe.6, label %ctor_prologue.barrier.done.8

ctor_prologue.slow.4:                             ; preds = %shadow.root.barrier.done.2
  %r59 = call double @diagnostic_fixture_ts____AnonShape_2a938cab61a60894_constructor(double %r18, double %r19, double %r5)
  br label %ctor_prologue.merge.5

ctor_prologue.merge.5:                            ; preds = %ctor_prologue.barrier.done.8, %ctor_prologue.slow.4
  %r60 = phi double [ 0x7FFC000000000001, %ctor_prologue.barrier.done.8 ], [ %r59, %ctor_prologue.slow.4 ]
  %r61.rs4p = load ptr addrspace(1), ptr %r13, align 8
  %r61.rs4i = ptrtoint ptr addrspace(1) %r61.rs4p to i64
  %r61 = call i64 asm "", "=r,0"(i64 %r61.rs4i) #11
  %r62 = or i64 %r61, 9222527611924643840
  %r63 = bitcast i64 %r62 to double
  %r64 = bitcast double %r60 to i64
  %r65 = icmp eq i64 %r64, 9222246136947933185
  br i1 %r65, label %ctor_ret.merge.10, label %ctor_ret.override.9

ctor_prologue.barrier.maybe.6:                    ; preds = %ctor_prologue.fast.3
  %r48 = sub i64 %r12, 7
  %r49 = inttoptr i64 %r48 to ptr
  %r50 = load i8, ptr %r49, align 1
  %r51 = and i8 %r50, 32
  %r52 = icmp ne i8 %r51, 0
  %r53 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r54 = icmp ne i32 %r53, 0
  %r55 = or i1 %r52, %r54
  br i1 %r55, label %ctor_prologue.barrier.7, label %ctor_prologue.barrier.done.8

ctor_prologue.barrier.7:                          ; preds = %ctor_prologue.barrier.maybe.6
  call void @js_write_barrier_slot_validated_parent(i64 %r12, i64 %r36, i64 %r37) #11
  br label %ctor_prologue.barrier.done.8

ctor_prologue.barrier.done.8:                     ; preds = %ctor_prologue.barrier.7, %ctor_prologue.barrier.maybe.6, %ctor_prologue.fast.3
  %r56 = getelementptr double, ptr %r33, i64 1
  store double %r5, ptr %r56, align 8
  %r57 = ptrtoint ptr %r56 to i64
  %r58 = bitcast double %r5 to i64
  br label %ctor_prologue.merge.5

ctor_ret.override.9:                              ; preds = %ctor_prologue.merge.5
  %r66 = call double @js_ctor_return_override(double %r63, double %r60, i32 0)
  br label %ctor_ret.merge.10

ctor_ret.merge.10:                                ; preds = %ctor_ret.override.9, %ctor_prologue.merge.5
  %r67 = phi double [ %r63, %ctor_prologue.merge.5 ], [ %r66, %ctor_ret.override.9 ]
  store ptr addrspace(1) null, ptr %r13, align 8
  %rs4gc.b5 = bitcast double %r67 to i64
  %rs4gc.s5 = inttoptr i64 %rs4gc.b5 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s5, ptr %r2, align 8
  %r68.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r68.rs4i = ptrtoint ptr addrspace(1) %r68.rs4p to i64
  %r68 = call i64 asm "", "=r,0"(i64 %r68.rs4i) #11
  %r69 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r70 = icmp ne i32 %r69, 0
  br i1 %r70, label %shadow.root.barrier.11, label %shadow.root.barrier.done.12

shadow.root.barrier.11:                           ; preds = %ctor_ret.merge.10
  call void @js_write_barrier_root_nanbox(i64 %r68) #11
  br label %shadow.root.barrier.done.12

shadow.root.barrier.done.12:                      ; preds = %shadow.root.barrier.11, %ctor_ret.merge.10
  %r71.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r71.rs4i = ptrtoint ptr addrspace(1) %r71.rs4p to i64
  %r71.rs4o = call i64 asm "", "=r,0"(i64 %r71.rs4i) #11
  %r71 = bitcast i64 %r71.rs4o to double
  %r72 = load double, ptr @diagnostic_fixture_ts_.str.2.handle, align 8
  %r73 = load i32, ptr %r9, align 4
  %r74 = bitcast double %r71 to i64
  %r75 = and i64 %r74, 281474976710655
  %r76 = load double, ptr @diagnostic_fixture_ts_.str.3.handle, align 8
  %r77 = bitcast double %r72 to i64
  %r78 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r79 = icmp eq i8 %r78, 0
  %r80 = lshr i64 %r74, 48
  %r81 = icmp eq i64 %r80, 32765
  %r82 = icmp ugt i64 %r75, 1048575
  %r83 = and i1 %r81, %r82
  %r84 = and i1 %r83, %r79
  br i1 %r84, label %class_field_inline.deref.15, label %class_field_inline.guardcall.16

class_field_sloppy_set.boxed_fast.13:             ; preds = %class_field_inline.deref.15
  %r114 = inttoptr i64 %r75 to ptr
  %r115 = getelementptr i8, ptr %r114, i64 16
  %r116 = getelementptr double, ptr %r115, i64 0
  %r117 = ptrtoint ptr %r116 to i64
  store double %r72, ptr %r116, align 8
  %r118 = bitcast double %r72 to i64
  %r119 = lshr i64 %r118, 48
  %r120 = icmp eq i64 %r119, 0
  %r121 = icmp uge i64 %r118, 4096
  %r122 = and i1 %r120, %r121
  %r123 = icmp eq i64 %r119, 32765
  %r124 = icmp eq i64 %r119, 32767
  %r125 = icmp eq i64 %r119, 32762
  %r126 = or i1 %r123, %r124
  %r127 = or i1 %r126, %r125
  %r128 = or i1 %r127, %r122
  br i1 %r128, label %class_field_set.gc_bookkeeping.17, label %class_field_set.gc_bookkeeping.done.18

class_field_sloppy_set.boxed_merge.14:            ; preds = %class_field_set.gc_bookkeeping.done.18, %class_field_inline.guardcall.16
  %r142.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r142.rs4i = ptrtoint ptr addrspace(1) %r142.rs4p to i64
  %r142.rs4o = call i64 asm "", "=r,0"(i64 %r142.rs4i) #11
  %r142 = bitcast i64 %r142.rs4o to double
  %r143 = load i32, ptr %r1, align 4
  %r144 = sitofp i32 %r143 to double
  %r145 = call double @js_number_is_safe_integer(double %r144)
  %r146 = bitcast double %r145 to i64
  %r147 = and i64 %r146, 9221120237041090560
  %r148 = icmp ne i64 %r147, 9221120237041090560
  br i1 %r148, label %truthy.num.22, label %truthy.tag.23

class_field_inline.deref.15:                      ; preds = %shadow.root.barrier.done.12
  %r85 = inttoptr i64 %r75 to ptr
  %r86 = getelementptr i8, ptr %r85, i64 -8
  %r87 = load i8, ptr %r86, align 1
  %r88 = icmp eq i8 %r87, 2
  %r89 = getelementptr i8, ptr %r85, i64 -7
  %r90 = load i8, ptr %r89, align 1
  %r91 = and i8 %r90, -128
  %r92 = icmp eq i8 %r91, 0
  %r93 = getelementptr i8, ptr %r85, i64 -6
  %r94 = load i16, ptr %r93, align 2
  %r95 = getelementptr i8, ptr %r85, i64 0
  %r96 = load i32, ptr %r95, align 4
  %r97 = icmp eq i32 %r96, 1
  %r98 = getelementptr i8, ptr %r85, i64 4
  %r99 = load i32, ptr %r98, align 4
  %r100 = icmp eq i32 %r99, %r73
  %r101 = and i1 %r88, %r92
  %r102 = and i1 %r101, %r97
  %r103 = and i1 %r102, %r100
  %r104 = and i16 %r94, 3072
  %r105 = icmp eq i16 %r104, 0
  %r106 = and i1 %r103, %r105
  %r107 = and i16 %r94, 1
  %r108 = icmp eq i16 %r107, 0
  %r109 = and i1 %r106, %r108
  %r110 = and i16 %r94, 128
  %r111 = icmp eq i16 %r110, 0
  %r112 = and i1 %r109, %r111
  br i1 %r112, label %class_field_sloppy_set.boxed_fast.13, label %class_field_inline.guardcall.16

class_field_inline.guardcall.16:                  ; preds = %class_field_inline.deref.15, %shadow.root.barrier.done.12
  %r113 = call double @js_put_value_set(double %r71, double %r76, double %r72, double %r71, i32 0)
  br label %class_field_sloppy_set.boxed_merge.14

class_field_set.gc_bookkeeping.17:                ; preds = %class_field_sloppy_set.boxed_fast.13
  call void @js_string_addref_if_heap_string(double %r72) #11
  %r314.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r314.rs4i = ptrtoint ptr addrspace(1) %r314.rs4p to i64
  %r314.rs4o = call i64 asm "", "=r,0"(i64 %r314.rs4i) #11
  %r314 = bitcast i64 %r314.rs4o to double
  %r315 = bitcast double %r314 to i64
  %r316 = and i64 %r315, 281474976710655
  %r129 = inttoptr i64 %r316 to ptr
  %r310.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r310.rs4i = ptrtoint ptr addrspace(1) %r310.rs4p to i64
  %r310.rs4o = call i64 asm "", "=r,0"(i64 %r310.rs4i) #11
  %r310 = bitcast i64 %r310.rs4o to double
  %r311 = bitcast double %r310 to i64
  %r312 = and i64 %r311, 281474976710655
  %r313 = inttoptr i64 %r312 to ptr
  %r130 = getelementptr i8, ptr %r313, i64 -6
  %r131 = load i16, ptr %r130, align 2
  %r132 = and i16 %r131, -12288
  %r133 = icmp eq i16 %r132, -28672
  br i1 %r133, label %class_field_set.layout_note.done.20, label %class_field_set.layout_note.19

class_field_set.gc_bookkeeping.done.18:           ; preds = %class_field_set.barrier.21, %class_field_set.layout_note.done.20, %class_field_sloppy_set.boxed_fast.13
  br label %class_field_sloppy_set.boxed_merge.14

class_field_set.layout_note.19:                   ; preds = %class_field_set.gc_bookkeeping.17
  %r305.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r305.rs4i = ptrtoint ptr addrspace(1) %r305.rs4p to i64
  %r305.rs4o = call i64 asm "", "=r,0"(i64 %r305.rs4i) #11
  %r305 = bitcast i64 %r305.rs4o to double
  %r306 = bitcast double %r305 to i64
  %r307 = and i64 %r306, 281474976710655
  %r308 = load double, ptr @diagnostic_fixture_ts_.str.2.handle, align 8
  %r309 = bitcast double %r308 to i64
  call void @js_gc_note_slot_layout(i64 %r307, i32 0, i64 %r309) #11
  br label %class_field_set.layout_note.done.20

class_field_set.layout_note.done.20:              ; preds = %class_field_set.layout_note.19, %class_field_set.gc_bookkeeping.17
  %r302.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r302.rs4i = ptrtoint ptr addrspace(1) %r302.rs4p to i64
  %r302.rs4o = call i64 asm "", "=r,0"(i64 %r302.rs4i) #11
  %r302 = bitcast i64 %r302.rs4o to double
  %r303 = bitcast double %r302 to i64
  %r304 = and i64 %r303, 281474976710655
  %r134 = sub i64 %r304, 7
  %r135 = inttoptr i64 %r134 to ptr
  %r136 = load i8, ptr %r135, align 1
  %r137 = and i8 %r136, 32
  %r138 = icmp ne i8 %r137, 0
  %r139 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r140 = icmp ne i32 %r139, 0
  %r141 = or i1 %r138, %r140
  br i1 %r141, label %class_field_set.barrier.21, label %class_field_set.gc_bookkeeping.done.18

class_field_set.barrier.21:                       ; preds = %class_field_set.layout_note.done.20
  %r298.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r298.rs4i = ptrtoint ptr addrspace(1) %r298.rs4p to i64
  %r298.rs4o = call i64 asm "", "=r,0"(i64 %r298.rs4i) #11
  %r298 = bitcast i64 %r298.rs4o to double
  %r299 = bitcast double %r298 to i64
  %r300 = load double, ptr @diagnostic_fixture_ts_.str.2.handle, align 8
  %r301 = bitcast double %r300 to i64
  call void @js_write_barrier_slot(i64 %r299, i64 %r117, i64 %r301) #11
  br label %class_field_set.gc_bookkeeping.done.18

truthy.num.22:                                    ; preds = %class_field_sloppy_set.boxed_merge.14
  %r149 = fcmp one double %r145, 0.000000e+00
  br label %truthy.merge.25

truthy.tag.23:                                    ; preds = %class_field_sloppy_set.boxed_merge.14
  %r150 = icmp eq i64 %r146, 9222246136947933188
  %r151 = icmp eq i64 %r146, 9222246136947933187
  %r152 = icmp eq i64 %r146, 9222246136947933185
  %r153 = icmp eq i64 %r146, 9222246136947933186
  %r154 = or i1 %r151, %r152
  %r155 = or i1 %r154, %r153
  %r156 = or i1 %r150, %r155
  br i1 %r156, label %truthy.merge.25, label %truthy.obj.26

truthy.slow.24:                                   ; preds = %truthy.obj.26
  %r162 = call i32 @js_is_truthy(double %r145) #11
  %r163 = icmp ne i32 %r162, 0
  br label %truthy.merge.25

truthy.merge.25:                                  ; preds = %truthy.obj.26, %truthy.slow.24, %truthy.tag.23, %truthy.num.22
  %r164 = phi i1 [ %r149, %truthy.num.22 ], [ %r150, %truthy.tag.23 ], [ %r161, %truthy.obj.26 ], [ %r163, %truthy.slow.24 ]
  br i1 %r164, label %ternary.then.27, label %ternary.else.28

truthy.obj.26:                                    ; preds = %truthy.tag.23
  %r157 = lshr i64 %r146, 48
  %r158 = icmp eq i64 %r157, 32765
  %r159 = and i64 %r146, 281474976710655
  %r160 = icmp ne i64 %r159, 0
  %r161 = and i1 %r158, %r160
  br i1 %r161, label %truthy.merge.25, label %truthy.slow.24

ternary.then.27:                                  ; preds = %truthy.merge.25
  %r165 = load i32, ptr %r1, align 4
  %r166 = sitofp i32 %r165 to double
  br label %ternary.merge.29

ternary.else.28:                                  ; preds = %truthy.merge.25
  br label %ternary.merge.29

ternary.merge.29:                                 ; preds = %ternary.else.28, %ternary.then.27
  %r167 = phi double [ %r166, %ternary.then.27 ], [ 0.000000e+00, %ternary.else.28 ]
  %r168 = load i32, ptr %r9, align 4
  %r297.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r297.rs4i = ptrtoint ptr addrspace(1) %r297.rs4p to i64
  %r297.rs4o = call i64 asm "", "=r,0"(i64 %r297.rs4i) #11
  %r297 = bitcast i64 %r297.rs4o to double
  %r169 = bitcast double %r297 to i64
  %r295.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r295.rs4i = ptrtoint ptr addrspace(1) %r295.rs4p to i64
  %r295.rs4o = call i64 asm "", "=r,0"(i64 %r295.rs4i) #11
  %r295 = bitcast i64 %r295.rs4o to double
  %r296 = bitcast double %r295 to i64
  %r170 = and i64 %r296, 281474976710655
  %r171 = load double, ptr @diagnostic_fixture_ts_.str.4.handle, align 8
  %r172 = bitcast double %r167 to i64
  %r173 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r174 = icmp eq i8 %r173, 0
  %r293.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r293.rs4i = ptrtoint ptr addrspace(1) %r293.rs4p to i64
  %r293.rs4o = call i64 asm "", "=r,0"(i64 %r293.rs4i) #11
  %r293 = bitcast i64 %r293.rs4o to double
  %r294 = bitcast double %r293 to i64
  %r175 = lshr i64 %r294, 48
  %r176 = icmp eq i64 %r175, 32765
  %r290.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r290.rs4i = ptrtoint ptr addrspace(1) %r290.rs4p to i64
  %r290.rs4o = call i64 asm "", "=r,0"(i64 %r290.rs4i) #11
  %r290 = bitcast i64 %r290.rs4o to double
  %r291 = bitcast double %r290 to i64
  %r292 = and i64 %r291, 281474976710655
  %r177 = icmp ugt i64 %r292, 1048575
  %r178 = and i1 %r176, %r177
  %r179 = and i1 %r178, %r174
  br i1 %r179, label %class_field_inline.deref.32, label %class_field_inline.guardcall.33

class_field_sloppy_set.fast.30:                   ; preds = %class_field_inline.deref.32
  %r287.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r287.rs4i = ptrtoint ptr addrspace(1) %r287.rs4p to i64
  %r287.rs4o = call i64 asm "", "=r,0"(i64 %r287.rs4i) #11
  %r287 = bitcast i64 %r287.rs4o to double
  %r288 = bitcast double %r287 to i64
  %r289 = and i64 %r288, 281474976710655
  %r215 = inttoptr i64 %r289 to ptr
  %r283.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r283.rs4i = ptrtoint ptr addrspace(1) %r283.rs4p to i64
  %r283.rs4o = call i64 asm "", "=r,0"(i64 %r283.rs4i) #11
  %r283 = bitcast i64 %r283.rs4o to double
  %r284 = bitcast double %r283 to i64
  %r285 = and i64 %r284, 281474976710655
  %r286 = inttoptr i64 %r285 to ptr
  %r216 = getelementptr i8, ptr %r286, i64 16
  %r217 = getelementptr double, ptr %r216, i64 1
  %r218 = call double @js_array_numeric_value_to_raw_f64(double %r167) #11
  store double %r218, ptr %r217, align 8
  br label %class_field_sloppy_set.merge.31

class_field_sloppy_set.merge.31:                  ; preds = %class_field_inline.guardcall.33, %class_field_sloppy_set.fast.30
  %r220 = call i64 @js_closure_alloc(ptr @perry_closure_diagnostic_fixture_ts__4, i32 0)
  %r221 = or i64 %r220, 9222527611924643840
  %r222 = bitcast i64 %r221 to double
  %rs4gc.b6 = bitcast double %r222 to i64
  %rs4gc.s6 = inttoptr i64 %rs4gc.b6 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s6, ptr %r219, align 8
  %r223.rs4p = load ptr addrspace(1), ptr %r219, align 8
  %r223.rs4i = ptrtoint ptr addrspace(1) %r223.rs4p to i64
  %r223 = call i64 asm "", "=r,0"(i64 %r223.rs4i) #11
  %r224 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r225 = icmp ne i32 %r224, 0
  br i1 %r225, label %shadow.root.barrier.34, label %shadow.root.barrier.done.35

class_field_inline.deref.32:                      ; preds = %ternary.merge.29
  %r280.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r280.rs4i = ptrtoint ptr addrspace(1) %r280.rs4p to i64
  %r280.rs4o = call i64 asm "", "=r,0"(i64 %r280.rs4i) #11
  %r280 = bitcast i64 %r280.rs4o to double
  %r281 = bitcast double %r280 to i64
  %r282 = and i64 %r281, 281474976710655
  %r180 = inttoptr i64 %r282 to ptr
  %r276.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r276.rs4i = ptrtoint ptr addrspace(1) %r276.rs4p to i64
  %r276.rs4o = call i64 asm "", "=r,0"(i64 %r276.rs4i) #11
  %r276 = bitcast i64 %r276.rs4o to double
  %r277 = bitcast double %r276 to i64
  %r278 = and i64 %r277, 281474976710655
  %r279 = inttoptr i64 %r278 to ptr
  %r181 = getelementptr i8, ptr %r279, i64 -8
  %r182 = load i8, ptr %r181, align 1
  %r183 = icmp eq i8 %r182, 2
  %r272.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r272.rs4i = ptrtoint ptr addrspace(1) %r272.rs4p to i64
  %r272.rs4o = call i64 asm "", "=r,0"(i64 %r272.rs4i) #11
  %r272 = bitcast i64 %r272.rs4o to double
  %r273 = bitcast double %r272 to i64
  %r274 = and i64 %r273, 281474976710655
  %r275 = inttoptr i64 %r274 to ptr
  %r184 = getelementptr i8, ptr %r275, i64 -7
  %r185 = load i8, ptr %r184, align 1
  %r186 = and i8 %r185, -128
  %r187 = icmp eq i8 %r186, 0
  %r268.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r268.rs4i = ptrtoint ptr addrspace(1) %r268.rs4p to i64
  %r268.rs4o = call i64 asm "", "=r,0"(i64 %r268.rs4i) #11
  %r268 = bitcast i64 %r268.rs4o to double
  %r269 = bitcast double %r268 to i64
  %r270 = and i64 %r269, 281474976710655
  %r271 = inttoptr i64 %r270 to ptr
  %r188 = getelementptr i8, ptr %r271, i64 -6
  %r189 = load i16, ptr %r188, align 2
  %r264.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r264.rs4i = ptrtoint ptr addrspace(1) %r264.rs4p to i64
  %r264.rs4o = call i64 asm "", "=r,0"(i64 %r264.rs4i) #11
  %r264 = bitcast i64 %r264.rs4o to double
  %r265 = bitcast double %r264 to i64
  %r266 = and i64 %r265, 281474976710655
  %r267 = inttoptr i64 %r266 to ptr
  %r190 = getelementptr i8, ptr %r267, i64 0
  %r191 = load i32, ptr %r190, align 4
  %r192 = icmp eq i32 %r191, 1
  %r260.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r260.rs4i = ptrtoint ptr addrspace(1) %r260.rs4p to i64
  %r260.rs4o = call i64 asm "", "=r,0"(i64 %r260.rs4i) #11
  %r260 = bitcast i64 %r260.rs4o to double
  %r261 = bitcast double %r260 to i64
  %r262 = and i64 %r261, 281474976710655
  %r263 = inttoptr i64 %r262 to ptr
  %r193 = getelementptr i8, ptr %r263, i64 4
  %r194 = load i32, ptr %r193, align 4
  %r195 = icmp eq i32 %r194, %r168
  %r196 = and i1 %r183, %r187
  %r197 = and i1 %r196, %r192
  %r198 = and i1 %r197, %r195
  %r199 = and i16 %r189, 3072
  %r200 = icmp eq i16 %r199, 0
  %r201 = and i1 %r198, %r200
  %r202 = and i16 %r189, 4096
  %r203 = icmp ne i16 %r202, 0
  %r204 = and i1 %r201, %r203
  %r205 = and i16 %r189, 1
  %r206 = icmp eq i16 %r205, 0
  %r207 = and i1 %r204, %r206
  %r208 = and i16 %r189, 128
  %r209 = icmp eq i16 %r208, 0
  %r210 = and i1 %r207, %r209
  %r211 = and i64 %r172, 9218868437227405312
  %r212 = icmp ne i64 %r211, 9218868437227405312
  %r213 = and i1 %r210, %r212
  br i1 %r213, label %class_field_sloppy_set.fast.30, label %class_field_inline.guardcall.33

class_field_inline.guardcall.33:                  ; preds = %class_field_inline.deref.32, %ternary.merge.29
  %r259.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r259.rs4i = ptrtoint ptr addrspace(1) %r259.rs4p to i64
  %r259.rs4o = call i64 asm "", "=r,0"(i64 %r259.rs4i) #11
  %r259 = bitcast i64 %r259.rs4o to double
  %r214 = call double @js_put_value_set(double %r259, double %r171, double %r167, double %r259, i32 0)
  br label %class_field_sloppy_set.merge.31

shadow.root.barrier.34:                           ; preds = %class_field_sloppy_set.merge.31
  call void @js_write_barrier_root_nanbox(i64 %r223) #11
  br label %shadow.root.barrier.done.35

shadow.root.barrier.done.35:                      ; preds = %shadow.root.barrier.34, %class_field_sloppy_set.merge.31
  %r226.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r226.rs4i = ptrtoint ptr addrspace(1) %r226.rs4p to i64
  %r226.rs4o = call i64 asm "", "=r,0"(i64 %r226.rs4i) #11
  %r226 = bitcast i64 %r226.rs4o to double
  %r227 = bitcast double %r226 to i64
  %r228 = and i64 %r227, 281474976710655
  %r229 = inttoptr i64 %r228 to ptr
  %r230 = getelementptr i8, ptr %r229, i64 16
  %r231 = getelementptr double, ptr %r230, i64 0
  %r232 = load double, ptr %r231, align 8
  %r233 = call double @perry_fn_diagnostic_fixture_ts__allocating(double %r232)
  %r234 = load double, ptr @diagnostic_fixture_ts_.str.5.handle, align 8
  %r235 = call double @js_dynamic_string_or_number_add(double %r233, double %r234)
  %r236 = bitcast double %r235 to i64
  %rs4gc.s7 = inttoptr i64 %r236 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s7, ptr %r13, align 8
  %r237.rs4p = load ptr addrspace(1), ptr %r13, align 8
  %r237.rs4i = ptrtoint ptr addrspace(1) %r237.rs4p to i64
  %r237 = call i64 asm "", "=r,0"(i64 %r237.rs4i) #11
  %r238 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r239 = icmp ne i32 %r238, 0
  br i1 %r239, label %shadow.root.barrier.36, label %shadow.root.barrier.done.37

shadow.root.barrier.36:                           ; preds = %shadow.root.barrier.done.35
  call void @js_write_barrier_root_nanbox(i64 %r237) #11
  br label %shadow.root.barrier.done.37

shadow.root.barrier.done.37:                      ; preds = %shadow.root.barrier.36, %shadow.root.barrier.done.35
  %r240.rs4p = load ptr addrspace(1), ptr %r219, align 8
  %r240.rs4i = ptrtoint ptr addrspace(1) %r240.rs4p to i64
  %r240.rs4o = call i64 asm "", "=r,0"(i64 %r240.rs4i) #11
  %r240 = bitcast i64 %r240.rs4o to double
  %r241 = bitcast double %r240 to i64
  %rs4gc.s8 = inttoptr i64 %r241 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s8, ptr %r242, align 8
  %r243.rs4p = load ptr addrspace(1), ptr %r242, align 8
  %r243.rs4i = ptrtoint ptr addrspace(1) %r243.rs4p to i64
  %r243 = call i64 asm "", "=r,0"(i64 %r243.rs4i) #11
  %r244 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r245 = icmp ne i32 %r244, 0
  br i1 %r245, label %shadow.root.barrier.38, label %shadow.root.barrier.done.39

shadow.root.barrier.38:                           ; preds = %shadow.root.barrier.done.37
  call void @js_write_barrier_root_nanbox(i64 %r243) #11
  br label %shadow.root.barrier.done.39

shadow.root.barrier.done.39:                      ; preds = %shadow.root.barrier.38, %shadow.root.barrier.done.37
  %r246.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r246.rs4i = ptrtoint ptr addrspace(1) %r246.rs4p to i64
  %r246.rs4o = call i64 asm "", "=r,0"(i64 %r246.rs4i) #11
  %r246 = bitcast i64 %r246.rs4o to double
  %r247 = bitcast double %r246 to i64
  %r248 = and i64 %r247, 281474976710655
  %r249 = inttoptr i64 %r248 to ptr
  %r250 = getelementptr i8, ptr %r249, i64 16
  %r251 = getelementptr double, ptr %r250, i64 1
  %r252 = load double, ptr %r251, align 8
  %r253.rs4p = load ptr addrspace(1), ptr %r242, align 8
  %r253.rs4i = ptrtoint ptr addrspace(1) %r253.rs4p to i64
  %r253 = call i64 asm "", "=r,0"(i64 %r253.rs4i) #11
  %r254 = bitcast i64 %r253 to double
  %r255 = call double @perry_fn_diagnostic_fixture_ts__dynamicCall(double %r254, double %r252)
  store ptr addrspace(1) null, ptr %r242, align 8
  %r256.rs4p = load ptr addrspace(1), ptr %r13, align 8
  %r256.rs4i = ptrtoint ptr addrspace(1) %r256.rs4p to i64
  %r256 = call i64 asm "", "=r,0"(i64 %r256.rs4i) #11
  %r257 = bitcast i64 %r256 to double
  %r258 = call double @js_dynamic_string_or_number_add(double %r257, double %r255)
  store ptr addrspace(1) null, ptr %r13, align 8
  ret double %r258
}

; Function Attrs: inlinehint
define internal double @"perry_fn_diagnostic_fixture_ts__allocating$generic"(double %arg0) #9 gc "statepoint-example" {
entry.0:
  %r17 = alloca [1 x double], align 8
  %r1 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r1, align 8
  %rs4gc.b1 = bitcast double %arg0 to i64
  %rs4gc.s1 = inttoptr i64 %rs4gc.b1 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r1, align 8
  %r2.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r2.rs4i = ptrtoint ptr addrspace(1) %r2.rs4p to i64
  %r2.rs4o = call i64 asm "", "=r,0"(i64 %r2.rs4i) #11
  %r2 = bitcast i64 %r2.rs4o to double
  %r3 = bitcast double %r2 to i64
  %r4 = lshr i64 %r3, 48
  %r5 = icmp eq i64 %r4, 32767
  %r6 = icmp eq i64 %r4, 32761
  %r7 = or i1 %r5, %r6
  br i1 %r7, label %anystr.string.1, label %anystr.generic.2

anystr.string.1:                                  ; preds = %entry.0
  %r8 = call i64 @js_get_string_pointer_unified(double %r2)
  %r9 = inttoptr i64 %r8 to ptr
  %r10 = load i32, ptr %r9, align 4
  %r11 = call i32 @js_string_index_to_i32(double 1.000000e+00)
  %r12 = call i64 @js_string_slice(i64 %r8, i32 %r11, i32 %r10)
  %r13 = or i64 %r12, 9223090561878065152
  %r14 = bitcast i64 %r13 to double
  br label %anystr.merge.3

anystr.generic.2:                                 ; preds = %entry.0
  %r15 = ptrtoint ptr @diagnostic_fixture_ts_.str.6.dispatch to i64
  %r16 = or i64 %r15, 9221120237041090560
  %r18 = getelementptr double, ptr %r17, i64 0
  store double 1.000000e+00, ptr %r18, align 8
  %r19 = call double @js_typed_feedback_native_call_method_by_id(i64 3713526460397387776, double %r2, i64 %r16, ptr %r17, i64 1)
  br label %anystr.merge.3

anystr.merge.3:                                   ; preds = %anystr.generic.2, %anystr.string.1
  %r20 = phi double [ %r14, %anystr.string.1 ], [ %r19, %anystr.generic.2 ]
  %r21 = load double, ptr @diagnostic_fixture_ts_.str.0.handle, align 8
  %r22 = call double @js_string_concat_box(double %r20, double %r21)
  ret double %r22
}

; Function Attrs: noinline
define double @perry_fn_diagnostic_fixture_ts__allocating(double %arg0) #10 {
entry.0:
  %r1 = call i32 @js_typed_string_arg_guard(double %arg0)
  %r2 = icmp ne i32 %r1, 0
  br i1 %r2, label %spec_public.fast.1, label %spec_public.fallback.2

spec_public.fast.1:                               ; preds = %entry.0
  %r3 = call double @"perry_fn_diagnostic_fixture_ts__allocating$spec_b"(double %arg0)
  ret double %r3

spec_public.fallback.2:                           ; preds = %entry.0
  %r4 = call double @"perry_fn_diagnostic_fixture_ts__allocating$generic"(double %arg0)
  ret double %r4
}

; Function Attrs: inlinehint
define double @perry_fn_diagnostic_fixture_ts__dynamicCall(double %arg1, double %arg2) #9 gc "statepoint-example" {
entry.0:
  %r1 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r1, align 8
  %rs4gc.b1 = bitcast double %arg1 to i64
  %rs4gc.s1 = inttoptr i64 %rs4gc.b1 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r1, align 8
  %r2 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r2, align 8
  %rs4gc.b2 = bitcast double %arg2 to i64
  %rs4gc.s2 = inttoptr i64 %rs4gc.b2 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s2, ptr %r2, align 8
  %r3.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r3.rs4i = ptrtoint ptr addrspace(1) %r3.rs4p to i64
  %r3.rs4o = call i64 asm "", "=r,0"(i64 %r3.rs4i) #11
  %r3 = bitcast i64 %r3.rs4o to double
  %r4.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r4.rs4i = ptrtoint ptr addrspace(1) %r4.rs4p to i64
  %r4.rs4o = call i64 asm "", "=r,0"(i64 %r4.rs4i) #11
  %r4 = bitcast i64 %r4.rs4o to double
  %r5 = call i64 @js_closure_unbox_callee_checked(double %r3)
  %r7.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r7.rs4i = ptrtoint ptr addrspace(1) %r7.rs4p to i64
  %r7.rs4o = call i64 asm "", "=r,0"(i64 %r7.rs4i) #11
  %r7 = bitcast i64 %r7.rs4o to double
  %r6 = call double @js_closure_call1_receiverless(i64 %r5, double %r7)
  ret double %r6
}

; Function Attrs: inlinehint
define double @perry_fn_diagnostic_fixture_ts__exercise(double %arg3) #9 gc "statepoint-example" {
entry.0:
  %r2 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r2, align 8
  %rs4gc.b1 = bitcast double 0x7FFC000000000001 to i64
  %rs4gc.s1 = inttoptr i64 %rs4gc.b1 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r2, align 8
  %r6 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r6, align 8
  store ptr addrspace(1) null, ptr %r6, align 8
  %r10 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r10, align 8
  %r11 = load i64, ptr @perry_class_keys_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 4
  %rs4gc.s2 = inttoptr i64 %r11 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s2, ptr %r10, align 8
  %r13 = alloca i32, align 4
  %r14 = load i32, ptr @perry_class_shape_id_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 4
  store i32 %r14, ptr %r13, align 4
  %r17 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r17, align 8
  store ptr addrspace(1) null, ptr %r17, align 8
  %r222 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r222, align 8
  %rs4gc.b3 = bitcast double 0x7FFC000000000001 to i64
  %rs4gc.s3 = inttoptr i64 %rs4gc.b3 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s3, ptr %r222, align 8
  %r1 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r1, align 8
  %rs4gc.b4 = bitcast double %arg3 to i64
  %rs4gc.s4 = inttoptr i64 %rs4gc.b4 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s4, ptr %r1, align 8
  %r3 = load double, ptr @diagnostic_fixture_ts_.str.1.handle, align 8
  %r4.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r4.rs4i = ptrtoint ptr addrspace(1) %r4.rs4p to i64
  %r4.rs4o = call i64 asm "", "=r,0"(i64 %r4.rs4i) #11
  %r4 = bitcast i64 %r4.rs4o to double
  %r5 = bitcast double %r4 to i64
  %rs4gc.s5 = inttoptr i64 %r5 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s5, ptr %r6, align 8
  %r7.rs4p = load ptr addrspace(1), ptr %r6, align 8
  %r7.rs4i = ptrtoint ptr addrspace(1) %r7.rs4p to i64
  %r7 = call i64 asm "", "=r,0"(i64 %r7.rs4i) #11
  %r8 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r9 = icmp ne i32 %r8, 0
  br i1 %r9, label %shadow.root.barrier.1, label %shadow.root.barrier.done.2

shadow.root.barrier.1:                            ; preds = %entry.0
  call void @js_write_barrier_root_nanbox(i64 %r7) #11
  br label %shadow.root.barrier.done.2

shadow.root.barrier.done.2:                       ; preds = %shadow.root.barrier.1, %entry.0
  %r12.rs4p = load ptr addrspace(1), ptr %r10, align 8
  %r12.rs4i = ptrtoint ptr addrspace(1) %r12.rs4p to i64
  %r12 = call i64 asm "", "=r,0"(i64 %r12.rs4i) #11
  %r15 = load i32, ptr %r13, align 4
  %r16 = call i64 @js_object_alloc_class_inline_keys_stamped(i32 1, i32 0, i32 2, i64 %r12, i32 %r15)
  call void @js_gc_declare_typed_shape_layout(i64 %r16, i32 2, ptr @perry_typed_shape_raw_f64_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, i32 1, ptr @perry_typed_shape_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, i32 1) #11
  %rs4gc.s6 = inttoptr i64 %r16 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s6, ptr %r17, align 8
  %r18.rs4p = load ptr addrspace(1), ptr %r17, align 8
  %r18.rs4i = ptrtoint ptr addrspace(1) %r18.rs4p to i64
  %r18 = call i64 asm "", "=r,0"(i64 %r18.rs4i) #11
  %r19 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r20 = icmp ne i32 %r19, 0
  br i1 %r20, label %shadow.root.barrier.3, label %shadow.root.barrier.done.4

shadow.root.barrier.3:                            ; preds = %shadow.root.barrier.done.2
  call void @js_write_barrier_root_nanbox(i64 %r18) #11
  br label %shadow.root.barrier.done.4

shadow.root.barrier.done.4:                       ; preds = %shadow.root.barrier.3, %shadow.root.barrier.done.2
  %r21 = or i64 %r16, 9222527611924643840
  %r22 = bitcast i64 %r21 to double
  %r23 = load double, ptr @diagnostic_fixture_ts_.str.1.handle, align 8
  %r24.rs4p = load ptr addrspace(1), ptr %r6, align 8
  %r24.rs4i = ptrtoint ptr addrspace(1) %r24.rs4p to i64
  %r24 = call i64 asm "", "=r,0"(i64 %r24.rs4i) #11
  %r25 = bitcast i64 %r24 to double
  %r26 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r27 = icmp eq i8 %r26, 0
  %r28 = inttoptr i64 %r16 to ptr
  %r29 = getelementptr i8, ptr %r28, i64 -6
  %r30 = load i16, ptr %r29, align 2
  %r31 = and i16 %r30, 4096
  %r32 = icmp ne i16 %r31, 0
  %r33 = and i1 %r27, %r32
  %r34 = and i64 %r24, 9218868437227405312
  %r35 = icmp ne i64 %r34, 9218868437227405312
  %r36 = and i1 %r33, %r35
  br i1 %r36, label %ctor_prologue.fast.5, label %ctor_prologue.slow.6

ctor_prologue.fast.5:                             ; preds = %shadow.root.barrier.done.4
  %r37 = inttoptr i64 %r16 to ptr
  %r38 = getelementptr i8, ptr %r37, i64 16
  %r39 = bitcast double %r22 to i64
  %r40 = getelementptr double, ptr %r38, i64 0
  store double %r23, ptr %r40, align 8
  %r41 = ptrtoint ptr %r40 to i64
  %r42 = bitcast double %r23 to i64
  %r43 = lshr i64 %r42, 48
  %r44 = icmp eq i64 %r43, 0
  %r45 = icmp uge i64 %r42, 4096
  %r46 = and i1 %r44, %r45
  %r47 = icmp eq i64 %r43, 32765
  %r48 = icmp eq i64 %r43, 32767
  %r49 = icmp eq i64 %r43, 32762
  %r50 = or i1 %r47, %r48
  %r51 = or i1 %r50, %r49
  %r52 = or i1 %r51, %r46
  br i1 %r52, label %ctor_prologue.barrier.maybe.8, label %ctor_prologue.barrier.done.10

ctor_prologue.slow.6:                             ; preds = %shadow.root.barrier.done.4
  %r64 = call double @diagnostic_fixture_ts____AnonShape_2a938cab61a60894_constructor(double %r22, double %r23, double %r25)
  br label %ctor_prologue.merge.7

ctor_prologue.merge.7:                            ; preds = %ctor_prologue.barrier.done.10, %ctor_prologue.slow.6
  %r65 = phi double [ 0x7FFC000000000001, %ctor_prologue.barrier.done.10 ], [ %r64, %ctor_prologue.slow.6 ]
  %r66.rs4p = load ptr addrspace(1), ptr %r17, align 8
  %r66.rs4i = ptrtoint ptr addrspace(1) %r66.rs4p to i64
  %r66 = call i64 asm "", "=r,0"(i64 %r66.rs4i) #11
  %r67 = or i64 %r66, 9222527611924643840
  %r68 = bitcast i64 %r67 to double
  %r69 = bitcast double %r65 to i64
  %r70 = icmp eq i64 %r69, 9222246136947933185
  br i1 %r70, label %ctor_ret.merge.12, label %ctor_ret.override.11

ctor_prologue.barrier.maybe.8:                    ; preds = %ctor_prologue.fast.5
  %r53 = sub i64 %r16, 7
  %r54 = inttoptr i64 %r53 to ptr
  %r55 = load i8, ptr %r54, align 1
  %r56 = and i8 %r55, 32
  %r57 = icmp ne i8 %r56, 0
  %r58 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r59 = icmp ne i32 %r58, 0
  %r60 = or i1 %r57, %r59
  br i1 %r60, label %ctor_prologue.barrier.9, label %ctor_prologue.barrier.done.10

ctor_prologue.barrier.9:                          ; preds = %ctor_prologue.barrier.maybe.8
  call void @js_write_barrier_slot_validated_parent(i64 %r16, i64 %r41, i64 %r42) #11
  br label %ctor_prologue.barrier.done.10

ctor_prologue.barrier.done.10:                    ; preds = %ctor_prologue.barrier.9, %ctor_prologue.barrier.maybe.8, %ctor_prologue.fast.5
  %r61 = getelementptr double, ptr %r38, i64 1
  store double %r25, ptr %r61, align 8
  %r62 = ptrtoint ptr %r61 to i64
  %r63 = bitcast double %r25 to i64
  br label %ctor_prologue.merge.7

ctor_ret.override.11:                             ; preds = %ctor_prologue.merge.7
  %r71 = call double @js_ctor_return_override(double %r68, double %r65, i32 0)
  br label %ctor_ret.merge.12

ctor_ret.merge.12:                                ; preds = %ctor_ret.override.11, %ctor_prologue.merge.7
  %r72 = phi double [ %r68, %ctor_prologue.merge.7 ], [ %r71, %ctor_ret.override.11 ]
  store ptr addrspace(1) null, ptr %r6, align 8
  store ptr addrspace(1) null, ptr %r17, align 8
  %rs4gc.b7 = bitcast double %r72 to i64
  %rs4gc.s7 = inttoptr i64 %rs4gc.b7 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s7, ptr %r2, align 8
  %r73.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r73.rs4i = ptrtoint ptr addrspace(1) %r73.rs4p to i64
  %r73 = call i64 asm "", "=r,0"(i64 %r73.rs4i) #11
  %r74 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r75 = icmp ne i32 %r74, 0
  br i1 %r75, label %shadow.root.barrier.13, label %shadow.root.barrier.done.14

shadow.root.barrier.13:                           ; preds = %ctor_ret.merge.12
  call void @js_write_barrier_root_nanbox(i64 %r73) #11
  br label %shadow.root.barrier.done.14

shadow.root.barrier.done.14:                      ; preds = %shadow.root.barrier.13, %ctor_ret.merge.12
  %r76.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r76.rs4i = ptrtoint ptr addrspace(1) %r76.rs4p to i64
  %r76.rs4o = call i64 asm "", "=r,0"(i64 %r76.rs4i) #11
  %r76 = bitcast i64 %r76.rs4o to double
  %r77 = load double, ptr @diagnostic_fixture_ts_.str.2.handle, align 8
  %r78 = load i32, ptr %r13, align 4
  %r79 = bitcast double %r76 to i64
  %r80 = and i64 %r79, 281474976710655
  %r81 = load double, ptr @diagnostic_fixture_ts_.str.3.handle, align 8
  %r82 = bitcast double %r77 to i64
  %r83 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r84 = icmp eq i8 %r83, 0
  %r85 = lshr i64 %r79, 48
  %r86 = icmp eq i64 %r85, 32765
  %r87 = icmp ugt i64 %r80, 1048575
  %r88 = and i1 %r86, %r87
  %r89 = and i1 %r88, %r84
  br i1 %r89, label %class_field_inline.deref.17, label %class_field_inline.guardcall.18

class_field_sloppy_set.boxed_fast.15:             ; preds = %class_field_inline.deref.17
  %r119 = inttoptr i64 %r80 to ptr
  %r120 = getelementptr i8, ptr %r119, i64 16
  %r121 = getelementptr double, ptr %r120, i64 0
  %r122 = ptrtoint ptr %r121 to i64
  store double %r77, ptr %r121, align 8
  %r123 = bitcast double %r77 to i64
  %r124 = lshr i64 %r123, 48
  %r125 = icmp eq i64 %r124, 0
  %r126 = icmp uge i64 %r123, 4096
  %r127 = and i1 %r125, %r126
  %r128 = icmp eq i64 %r124, 32765
  %r129 = icmp eq i64 %r124, 32767
  %r130 = icmp eq i64 %r124, 32762
  %r131 = or i1 %r128, %r129
  %r132 = or i1 %r131, %r130
  %r133 = or i1 %r132, %r127
  br i1 %r133, label %class_field_set.gc_bookkeeping.19, label %class_field_set.gc_bookkeeping.done.20

class_field_sloppy_set.boxed_merge.16:            ; preds = %class_field_set.gc_bookkeeping.done.20, %class_field_inline.guardcall.18
  %r147.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r147.rs4i = ptrtoint ptr addrspace(1) %r147.rs4p to i64
  %r147.rs4o = call i64 asm "", "=r,0"(i64 %r147.rs4i) #11
  %r147 = bitcast i64 %r147.rs4o to double
  %r148.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r148.rs4i = ptrtoint ptr addrspace(1) %r148.rs4p to i64
  %r148.rs4o = call i64 asm "", "=r,0"(i64 %r148.rs4i) #11
  %r148 = bitcast i64 %r148.rs4o to double
  %r149 = call double @js_number_is_safe_integer(double %r148)
  %r150 = bitcast double %r149 to i64
  %r151 = and i64 %r150, 9221120237041090560
  %r152 = icmp ne i64 %r151, 9221120237041090560
  br i1 %r152, label %truthy.num.24, label %truthy.tag.25

class_field_inline.deref.17:                      ; preds = %shadow.root.barrier.done.14
  %r90 = inttoptr i64 %r80 to ptr
  %r91 = getelementptr i8, ptr %r90, i64 -8
  %r92 = load i8, ptr %r91, align 1
  %r93 = icmp eq i8 %r92, 2
  %r94 = getelementptr i8, ptr %r90, i64 -7
  %r95 = load i8, ptr %r94, align 1
  %r96 = and i8 %r95, -128
  %r97 = icmp eq i8 %r96, 0
  %r98 = getelementptr i8, ptr %r90, i64 -6
  %r99 = load i16, ptr %r98, align 2
  %r100 = getelementptr i8, ptr %r90, i64 0
  %r101 = load i32, ptr %r100, align 4
  %r102 = icmp eq i32 %r101, 1
  %r103 = getelementptr i8, ptr %r90, i64 4
  %r104 = load i32, ptr %r103, align 4
  %r105 = icmp eq i32 %r104, %r78
  %r106 = and i1 %r93, %r97
  %r107 = and i1 %r106, %r102
  %r108 = and i1 %r107, %r105
  %r109 = and i16 %r99, 3072
  %r110 = icmp eq i16 %r109, 0
  %r111 = and i1 %r108, %r110
  %r112 = and i16 %r99, 1
  %r113 = icmp eq i16 %r112, 0
  %r114 = and i1 %r111, %r113
  %r115 = and i16 %r99, 128
  %r116 = icmp eq i16 %r115, 0
  %r117 = and i1 %r114, %r116
  br i1 %r117, label %class_field_sloppy_set.boxed_fast.15, label %class_field_inline.guardcall.18

class_field_inline.guardcall.18:                  ; preds = %class_field_inline.deref.17, %shadow.root.barrier.done.14
  %r118 = call double @js_put_value_set(double %r76, double %r81, double %r77, double %r76, i32 0)
  br label %class_field_sloppy_set.boxed_merge.16

class_field_set.gc_bookkeeping.19:                ; preds = %class_field_sloppy_set.boxed_fast.15
  call void @js_string_addref_if_heap_string(double %r77) #11
  %r316.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r316.rs4i = ptrtoint ptr addrspace(1) %r316.rs4p to i64
  %r316.rs4o = call i64 asm "", "=r,0"(i64 %r316.rs4i) #11
  %r316 = bitcast i64 %r316.rs4o to double
  %r317 = bitcast double %r316 to i64
  %r318 = and i64 %r317, 281474976710655
  %r134 = inttoptr i64 %r318 to ptr
  %r312.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r312.rs4i = ptrtoint ptr addrspace(1) %r312.rs4p to i64
  %r312.rs4o = call i64 asm "", "=r,0"(i64 %r312.rs4i) #11
  %r312 = bitcast i64 %r312.rs4o to double
  %r313 = bitcast double %r312 to i64
  %r314 = and i64 %r313, 281474976710655
  %r315 = inttoptr i64 %r314 to ptr
  %r135 = getelementptr i8, ptr %r315, i64 -6
  %r136 = load i16, ptr %r135, align 2
  %r137 = and i16 %r136, -12288
  %r138 = icmp eq i16 %r137, -28672
  br i1 %r138, label %class_field_set.layout_note.done.22, label %class_field_set.layout_note.21

class_field_set.gc_bookkeeping.done.20:           ; preds = %class_field_set.barrier.23, %class_field_set.layout_note.done.22, %class_field_sloppy_set.boxed_fast.15
  br label %class_field_sloppy_set.boxed_merge.16

class_field_set.layout_note.21:                   ; preds = %class_field_set.gc_bookkeeping.19
  %r307.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r307.rs4i = ptrtoint ptr addrspace(1) %r307.rs4p to i64
  %r307.rs4o = call i64 asm "", "=r,0"(i64 %r307.rs4i) #11
  %r307 = bitcast i64 %r307.rs4o to double
  %r308 = bitcast double %r307 to i64
  %r309 = and i64 %r308, 281474976710655
  %r310 = load double, ptr @diagnostic_fixture_ts_.str.2.handle, align 8
  %r311 = bitcast double %r310 to i64
  call void @js_gc_note_slot_layout(i64 %r309, i32 0, i64 %r311) #11
  br label %class_field_set.layout_note.done.22

class_field_set.layout_note.done.22:              ; preds = %class_field_set.layout_note.21, %class_field_set.gc_bookkeeping.19
  %r304.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r304.rs4i = ptrtoint ptr addrspace(1) %r304.rs4p to i64
  %r304.rs4o = call i64 asm "", "=r,0"(i64 %r304.rs4i) #11
  %r304 = bitcast i64 %r304.rs4o to double
  %r305 = bitcast double %r304 to i64
  %r306 = and i64 %r305, 281474976710655
  %r139 = sub i64 %r306, 7
  %r140 = inttoptr i64 %r139 to ptr
  %r141 = load i8, ptr %r140, align 1
  %r142 = and i8 %r141, 32
  %r143 = icmp ne i8 %r142, 0
  %r144 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r145 = icmp ne i32 %r144, 0
  %r146 = or i1 %r143, %r145
  br i1 %r146, label %class_field_set.barrier.23, label %class_field_set.gc_bookkeeping.done.20

class_field_set.barrier.23:                       ; preds = %class_field_set.layout_note.done.22
  %r300.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r300.rs4i = ptrtoint ptr addrspace(1) %r300.rs4p to i64
  %r300.rs4o = call i64 asm "", "=r,0"(i64 %r300.rs4i) #11
  %r300 = bitcast i64 %r300.rs4o to double
  %r301 = bitcast double %r300 to i64
  %r302 = load double, ptr @diagnostic_fixture_ts_.str.2.handle, align 8
  %r303 = bitcast double %r302 to i64
  call void @js_write_barrier_slot(i64 %r301, i64 %r122, i64 %r303) #11
  br label %class_field_set.gc_bookkeeping.done.20

truthy.num.24:                                    ; preds = %class_field_sloppy_set.boxed_merge.16
  %r153 = fcmp one double %r149, 0.000000e+00
  br label %truthy.merge.27

truthy.tag.25:                                    ; preds = %class_field_sloppy_set.boxed_merge.16
  %r154 = icmp eq i64 %r150, 9222246136947933188
  %r155 = icmp eq i64 %r150, 9222246136947933187
  %r156 = icmp eq i64 %r150, 9222246136947933185
  %r157 = icmp eq i64 %r150, 9222246136947933186
  %r158 = or i1 %r155, %r156
  %r159 = or i1 %r158, %r157
  %r160 = or i1 %r154, %r159
  br i1 %r160, label %truthy.merge.27, label %truthy.obj.28

truthy.slow.26:                                   ; preds = %truthy.obj.28
  %r166 = call i32 @js_is_truthy(double %r149) #11
  %r167 = icmp ne i32 %r166, 0
  br label %truthy.merge.27

truthy.merge.27:                                  ; preds = %truthy.obj.28, %truthy.slow.26, %truthy.tag.25, %truthy.num.24
  %r168 = phi i1 [ %r153, %truthy.num.24 ], [ %r154, %truthy.tag.25 ], [ %r165, %truthy.obj.28 ], [ %r167, %truthy.slow.26 ]
  br i1 %r168, label %ternary.then.29, label %ternary.else.30

truthy.obj.28:                                    ; preds = %truthy.tag.25
  %r161 = lshr i64 %r150, 48
  %r162 = icmp eq i64 %r161, 32765
  %r163 = and i64 %r150, 281474976710655
  %r164 = icmp ne i64 %r163, 0
  %r165 = and i1 %r162, %r164
  br i1 %r165, label %truthy.merge.27, label %truthy.slow.26

ternary.then.29:                                  ; preds = %truthy.merge.27
  %r169.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r169.rs4i = ptrtoint ptr addrspace(1) %r169.rs4p to i64
  %r169.rs4o = call i64 asm "", "=r,0"(i64 %r169.rs4i) #11
  %r169 = bitcast i64 %r169.rs4o to double
  br label %ternary.merge.31

ternary.else.30:                                  ; preds = %truthy.merge.27
  br label %ternary.merge.31

ternary.merge.31:                                 ; preds = %ternary.else.30, %ternary.then.29
  %r170 = phi double [ %r169, %ternary.then.29 ], [ 0.000000e+00, %ternary.else.30 ]
  %r171 = load i32, ptr %r13, align 4
  %r299.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r299.rs4i = ptrtoint ptr addrspace(1) %r299.rs4p to i64
  %r299.rs4o = call i64 asm "", "=r,0"(i64 %r299.rs4i) #11
  %r299 = bitcast i64 %r299.rs4o to double
  %r172 = bitcast double %r299 to i64
  %r297.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r297.rs4i = ptrtoint ptr addrspace(1) %r297.rs4p to i64
  %r297.rs4o = call i64 asm "", "=r,0"(i64 %r297.rs4i) #11
  %r297 = bitcast i64 %r297.rs4o to double
  %r298 = bitcast double %r297 to i64
  %r173 = and i64 %r298, 281474976710655
  %r174 = load double, ptr @diagnostic_fixture_ts_.str.4.handle, align 8
  %r175 = bitcast double %r170 to i64
  %r176 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r177 = icmp eq i8 %r176, 0
  %r295.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r295.rs4i = ptrtoint ptr addrspace(1) %r295.rs4p to i64
  %r295.rs4o = call i64 asm "", "=r,0"(i64 %r295.rs4i) #11
  %r295 = bitcast i64 %r295.rs4o to double
  %r296 = bitcast double %r295 to i64
  %r178 = lshr i64 %r296, 48
  %r179 = icmp eq i64 %r178, 32765
  %r292.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r292.rs4i = ptrtoint ptr addrspace(1) %r292.rs4p to i64
  %r292.rs4o = call i64 asm "", "=r,0"(i64 %r292.rs4i) #11
  %r292 = bitcast i64 %r292.rs4o to double
  %r293 = bitcast double %r292 to i64
  %r294 = and i64 %r293, 281474976710655
  %r180 = icmp ugt i64 %r294, 1048575
  %r181 = and i1 %r179, %r180
  %r182 = and i1 %r181, %r177
  br i1 %r182, label %class_field_inline.deref.34, label %class_field_inline.guardcall.35

class_field_sloppy_set.fast.32:                   ; preds = %class_field_inline.deref.34
  %r289.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r289.rs4i = ptrtoint ptr addrspace(1) %r289.rs4p to i64
  %r289.rs4o = call i64 asm "", "=r,0"(i64 %r289.rs4i) #11
  %r289 = bitcast i64 %r289.rs4o to double
  %r290 = bitcast double %r289 to i64
  %r291 = and i64 %r290, 281474976710655
  %r218 = inttoptr i64 %r291 to ptr
  %r285.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r285.rs4i = ptrtoint ptr addrspace(1) %r285.rs4p to i64
  %r285.rs4o = call i64 asm "", "=r,0"(i64 %r285.rs4i) #11
  %r285 = bitcast i64 %r285.rs4o to double
  %r286 = bitcast double %r285 to i64
  %r287 = and i64 %r286, 281474976710655
  %r288 = inttoptr i64 %r287 to ptr
  %r219 = getelementptr i8, ptr %r288, i64 16
  %r220 = getelementptr double, ptr %r219, i64 1
  %r221 = call double @js_array_numeric_value_to_raw_f64(double %r170) #11
  store double %r221, ptr %r220, align 8
  br label %class_field_sloppy_set.merge.33

class_field_sloppy_set.merge.33:                  ; preds = %class_field_inline.guardcall.35, %class_field_sloppy_set.fast.32
  %r223 = call i64 @js_closure_alloc(ptr @perry_closure_diagnostic_fixture_ts__4, i32 0)
  %r224 = or i64 %r223, 9222527611924643840
  %r225 = bitcast i64 %r224 to double
  %rs4gc.b8 = bitcast double %r225 to i64
  %rs4gc.s8 = inttoptr i64 %rs4gc.b8 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s8, ptr %r222, align 8
  %r226.rs4p = load ptr addrspace(1), ptr %r222, align 8
  %r226.rs4i = ptrtoint ptr addrspace(1) %r226.rs4p to i64
  %r226 = call i64 asm "", "=r,0"(i64 %r226.rs4i) #11
  %r227 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r228 = icmp ne i32 %r227, 0
  br i1 %r228, label %shadow.root.barrier.36, label %shadow.root.barrier.done.37

class_field_inline.deref.34:                      ; preds = %ternary.merge.31
  %r282.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r282.rs4i = ptrtoint ptr addrspace(1) %r282.rs4p to i64
  %r282.rs4o = call i64 asm "", "=r,0"(i64 %r282.rs4i) #11
  %r282 = bitcast i64 %r282.rs4o to double
  %r283 = bitcast double %r282 to i64
  %r284 = and i64 %r283, 281474976710655
  %r183 = inttoptr i64 %r284 to ptr
  %r278.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r278.rs4i = ptrtoint ptr addrspace(1) %r278.rs4p to i64
  %r278.rs4o = call i64 asm "", "=r,0"(i64 %r278.rs4i) #11
  %r278 = bitcast i64 %r278.rs4o to double
  %r279 = bitcast double %r278 to i64
  %r280 = and i64 %r279, 281474976710655
  %r281 = inttoptr i64 %r280 to ptr
  %r184 = getelementptr i8, ptr %r281, i64 -8
  %r185 = load i8, ptr %r184, align 1
  %r186 = icmp eq i8 %r185, 2
  %r274.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r274.rs4i = ptrtoint ptr addrspace(1) %r274.rs4p to i64
  %r274.rs4o = call i64 asm "", "=r,0"(i64 %r274.rs4i) #11
  %r274 = bitcast i64 %r274.rs4o to double
  %r275 = bitcast double %r274 to i64
  %r276 = and i64 %r275, 281474976710655
  %r277 = inttoptr i64 %r276 to ptr
  %r187 = getelementptr i8, ptr %r277, i64 -7
  %r188 = load i8, ptr %r187, align 1
  %r189 = and i8 %r188, -128
  %r190 = icmp eq i8 %r189, 0
  %r270.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r270.rs4i = ptrtoint ptr addrspace(1) %r270.rs4p to i64
  %r270.rs4o = call i64 asm "", "=r,0"(i64 %r270.rs4i) #11
  %r270 = bitcast i64 %r270.rs4o to double
  %r271 = bitcast double %r270 to i64
  %r272 = and i64 %r271, 281474976710655
  %r273 = inttoptr i64 %r272 to ptr
  %r191 = getelementptr i8, ptr %r273, i64 -6
  %r192 = load i16, ptr %r191, align 2
  %r266.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r266.rs4i = ptrtoint ptr addrspace(1) %r266.rs4p to i64
  %r266.rs4o = call i64 asm "", "=r,0"(i64 %r266.rs4i) #11
  %r266 = bitcast i64 %r266.rs4o to double
  %r267 = bitcast double %r266 to i64
  %r268 = and i64 %r267, 281474976710655
  %r269 = inttoptr i64 %r268 to ptr
  %r193 = getelementptr i8, ptr %r269, i64 0
  %r194 = load i32, ptr %r193, align 4
  %r195 = icmp eq i32 %r194, 1
  %r262.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r262.rs4i = ptrtoint ptr addrspace(1) %r262.rs4p to i64
  %r262.rs4o = call i64 asm "", "=r,0"(i64 %r262.rs4i) #11
  %r262 = bitcast i64 %r262.rs4o to double
  %r263 = bitcast double %r262 to i64
  %r264 = and i64 %r263, 281474976710655
  %r265 = inttoptr i64 %r264 to ptr
  %r196 = getelementptr i8, ptr %r265, i64 4
  %r197 = load i32, ptr %r196, align 4
  %r198 = icmp eq i32 %r197, %r171
  %r199 = and i1 %r186, %r190
  %r200 = and i1 %r199, %r195
  %r201 = and i1 %r200, %r198
  %r202 = and i16 %r192, 3072
  %r203 = icmp eq i16 %r202, 0
  %r204 = and i1 %r201, %r203
  %r205 = and i16 %r192, 4096
  %r206 = icmp ne i16 %r205, 0
  %r207 = and i1 %r204, %r206
  %r208 = and i16 %r192, 1
  %r209 = icmp eq i16 %r208, 0
  %r210 = and i1 %r207, %r209
  %r211 = and i16 %r192, 128
  %r212 = icmp eq i16 %r211, 0
  %r213 = and i1 %r210, %r212
  %r214 = and i64 %r175, 9218868437227405312
  %r215 = icmp ne i64 %r214, 9218868437227405312
  %r216 = and i1 %r213, %r215
  br i1 %r216, label %class_field_sloppy_set.fast.32, label %class_field_inline.guardcall.35

class_field_inline.guardcall.35:                  ; preds = %class_field_inline.deref.34, %ternary.merge.31
  %r261.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r261.rs4i = ptrtoint ptr addrspace(1) %r261.rs4p to i64
  %r261.rs4o = call i64 asm "", "=r,0"(i64 %r261.rs4i) #11
  %r261 = bitcast i64 %r261.rs4o to double
  %r217 = call double @js_put_value_set(double %r261, double %r174, double %r170, double %r261, i32 0)
  br label %class_field_sloppy_set.merge.33

shadow.root.barrier.36:                           ; preds = %class_field_sloppy_set.merge.33
  call void @js_write_barrier_root_nanbox(i64 %r226) #11
  br label %shadow.root.barrier.done.37

shadow.root.barrier.done.37:                      ; preds = %shadow.root.barrier.36, %class_field_sloppy_set.merge.33
  %r229.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r229.rs4i = ptrtoint ptr addrspace(1) %r229.rs4p to i64
  %r229.rs4o = call i64 asm "", "=r,0"(i64 %r229.rs4i) #11
  %r229 = bitcast i64 %r229.rs4o to double
  %r230 = bitcast double %r229 to i64
  %r231 = and i64 %r230, 281474976710655
  %r232 = inttoptr i64 %r231 to ptr
  %r233 = getelementptr i8, ptr %r232, i64 16
  %r234 = getelementptr double, ptr %r233, i64 0
  %r235 = load double, ptr %r234, align 8
  %r236 = call double @perry_fn_diagnostic_fixture_ts__allocating(double %r235)
  %r237 = load double, ptr @diagnostic_fixture_ts_.str.5.handle, align 8
  %r238 = call double @js_dynamic_string_or_number_add(double %r236, double %r237)
  %r239 = bitcast double %r238 to i64
  %rs4gc.s9 = inttoptr i64 %r239 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s9, ptr %r6, align 8
  %r240.rs4p = load ptr addrspace(1), ptr %r6, align 8
  %r240.rs4i = ptrtoint ptr addrspace(1) %r240.rs4p to i64
  %r240 = call i64 asm "", "=r,0"(i64 %r240.rs4i) #11
  %r241 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r242 = icmp ne i32 %r241, 0
  br i1 %r242, label %shadow.root.barrier.38, label %shadow.root.barrier.done.39

shadow.root.barrier.38:                           ; preds = %shadow.root.barrier.done.37
  call void @js_write_barrier_root_nanbox(i64 %r240) #11
  br label %shadow.root.barrier.done.39

shadow.root.barrier.done.39:                      ; preds = %shadow.root.barrier.38, %shadow.root.barrier.done.37
  %r243.rs4p = load ptr addrspace(1), ptr %r222, align 8
  %r243.rs4i = ptrtoint ptr addrspace(1) %r243.rs4p to i64
  %r243.rs4o = call i64 asm "", "=r,0"(i64 %r243.rs4i) #11
  %r243 = bitcast i64 %r243.rs4o to double
  %r244 = bitcast double %r243 to i64
  %rs4gc.s10 = inttoptr i64 %r244 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s10, ptr %r17, align 8
  %r245.rs4p = load ptr addrspace(1), ptr %r17, align 8
  %r245.rs4i = ptrtoint ptr addrspace(1) %r245.rs4p to i64
  %r245 = call i64 asm "", "=r,0"(i64 %r245.rs4i) #11
  %r246 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r247 = icmp ne i32 %r246, 0
  br i1 %r247, label %shadow.root.barrier.40, label %shadow.root.barrier.done.41

shadow.root.barrier.40:                           ; preds = %shadow.root.barrier.done.39
  call void @js_write_barrier_root_nanbox(i64 %r245) #11
  br label %shadow.root.barrier.done.41

shadow.root.barrier.done.41:                      ; preds = %shadow.root.barrier.40, %shadow.root.barrier.done.39
  %r248.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r248.rs4i = ptrtoint ptr addrspace(1) %r248.rs4p to i64
  %r248.rs4o = call i64 asm "", "=r,0"(i64 %r248.rs4i) #11
  %r248 = bitcast i64 %r248.rs4o to double
  %r249 = bitcast double %r248 to i64
  %r250 = and i64 %r249, 281474976710655
  %r251 = inttoptr i64 %r250 to ptr
  %r252 = getelementptr i8, ptr %r251, i64 16
  %r253 = getelementptr double, ptr %r252, i64 1
  %r254 = load double, ptr %r253, align 8
  %r255.rs4p = load ptr addrspace(1), ptr %r17, align 8
  %r255.rs4i = ptrtoint ptr addrspace(1) %r255.rs4p to i64
  %r255 = call i64 asm "", "=r,0"(i64 %r255.rs4i) #11
  %r256 = bitcast i64 %r255 to double
  %r257 = call double @perry_fn_diagnostic_fixture_ts__dynamicCall(double %r256, double %r254)
  store ptr addrspace(1) null, ptr %r17, align 8
  %r258.rs4p = load ptr addrspace(1), ptr %r6, align 8
  %r258.rs4i = ptrtoint ptr addrspace(1) %r258.rs4p to i64
  %r258 = call i64 asm "", "=r,0"(i64 %r258.rs4i) #11
  %r259 = bitcast i64 %r258 to double
  %r260 = call double @js_dynamic_string_or_number_add(double %r259, double %r257)
  store ptr addrspace(1) null, ptr %r6, align 8
  ret double %r260
}

; Function Attrs: inlinehint
define internal double @"perry_closure_diagnostic_fixture_ts__4$typed_f64"(i64 %this_closure, double %arg8) #9 {
entry.0:
  %r1 = fadd double %arg8, 1.000000e+00
  ret double %r1
}

define internal double @"perry_closure_diagnostic_fixture_ts__4$generic"(i64 %this_closure, double %arg8) #8 gc "statepoint-example" {
entry.0:
  %r1 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r1, align 8
  %rs4gc.b1 = bitcast double %arg8 to i64
  %rs4gc.s1 = inttoptr i64 %rs4gc.b1 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r1, align 8
  %r2.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r2.rs4i = ptrtoint ptr addrspace(1) %r2.rs4p to i64
  %r2.rs4o = call i64 asm "", "=r,0"(i64 %r2.rs4i) #11
  %r2 = bitcast i64 %r2.rs4o to double
  %r3 = bitcast double %r2 to i64
  %r4 = and i64 %r3, -281474976710656
  %r5 = icmp ult i64 %r4, 9221401712017801216
  %r6 = icmp ugt i64 %r4, 9223090561878065152
  %r7 = or i1 %r5, %r6
  br i1 %r7, label %guarded_add.numeric.1, label %guarded_add.dynamic.2

guarded_add.numeric.1:                            ; preds = %entry.0
  %r8 = fadd double %r2, 1.000000e+00
  br label %guarded_add.merge.3

guarded_add.dynamic.2:                            ; preds = %entry.0
  %r9 = call double @js_dynamic_string_or_number_add(double %r2, double 1.000000e+00)
  br label %guarded_add.merge.3

guarded_add.merge.3:                              ; preds = %guarded_add.dynamic.2, %guarded_add.numeric.1
  %r10 = phi double [ %r8, %guarded_add.numeric.1 ], [ %r9, %guarded_add.dynamic.2 ]
  ret double %r10
}

define double @perry_closure_diagnostic_fixture_ts__4(i64 %this_closure, double %arg8) #8 {
entry.0:
  %r1 = bitcast double %arg8 to i64
  %r2 = lshr i64 %r1, 48
  %r3 = icmp ult i64 %r2, 32761
  %r4 = icmp ugt i64 %r2, 32767
  %r5 = or i1 %r3, %r4
  %r6 = and i64 %r1, -4294967296
  %r7 = icmp eq i64 %r6, 9222809086901354496
  %r8 = or i1 %r5, %r7
  br i1 %r8, label %typed_closure_public.fast.1, label %typed_closure_public.fallback.2

typed_closure_public.fast.1:                      ; preds = %entry.0
  %r9 = bitcast double %arg8 to i64
  %r10 = and i64 %r9, -4294967296
  %r11 = icmp eq i64 %r10, 9222809086901354496
  %r12 = trunc i64 %r9 to i32
  %r13 = sitofp i32 %r12 to double
  %r14 = select i1 %r11, double %r13, double %arg8
  %r15 = call double @"perry_closure_diagnostic_fixture_ts__4$typed_f64"(i64 %this_closure, double %r14)
  ret double %r15

typed_closure_public.fallback.2:                  ; preds = %entry.0
  %r16 = call double @"perry_closure_diagnostic_fixture_ts__4$generic"(i64 %this_closure, double %arg8)
  ret double %r16
}

define double @diagnostic_fixture_ts____AnonShape_2a938cab61a60894_constructor(double %this_arg, double %arg4, double %arg5) #8 gc "statepoint-example" {
entry.0:
  %r4 = alloca double, align 8
  %r7 = alloca i32, align 4
  %r8 = load i32, ptr @perry_class_shape_id_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 4
  store i32 %r8, ptr %r7, align 4
  %r1 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r1, align 8
  %rs4gc.b1 = bitcast double %this_arg to i64
  %rs4gc.s1 = inttoptr i64 %rs4gc.b1 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r1, align 8
  %r2 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r2, align 8
  %rs4gc.b2 = bitcast double %arg4 to i64
  %rs4gc.s2 = inttoptr i64 %rs4gc.b2 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s2, ptr %r2, align 8
  %r3 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r3, align 8
  %rs4gc.b3 = bitcast double %arg5 to i64
  %rs4gc.s3 = inttoptr i64 %rs4gc.b3 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s3, ptr %r3, align 8
  store double 0x7FFC000000000001, ptr %r4, align 8
  %r5.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r5.rs4i = ptrtoint ptr addrspace(1) %r5.rs4p to i64
  %r5.rs4o = call i64 asm "", "=r,0"(i64 %r5.rs4i) #11
  %r5 = bitcast i64 %r5.rs4o to double
  %r6.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r6.rs4i = ptrtoint ptr addrspace(1) %r6.rs4p to i64
  %r6.rs4o = call i64 asm "", "=r,0"(i64 %r6.rs4i) #11
  %r6 = bitcast i64 %r6.rs4o to double
  %r9 = load i32, ptr %r7, align 4
  %r10 = bitcast double %r5 to i64
  %r11 = and i64 %r10, 281474976710655
  %r12 = load double, ptr @diagnostic_fixture_ts_.str.3.handle, align 8
  %r13 = bitcast double %r12 to i64
  %r14 = and i64 %r13, 281474976710655
  %r15 = bitcast double %r6 to i64
  %r16 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r17 = icmp eq i8 %r16, 0
  %r18 = lshr i64 %r10, 48
  %r19 = icmp eq i64 %r18, 32765
  %r20 = icmp ugt i64 %r11, 1048575
  %r21 = and i1 %r19, %r20
  %r22 = and i1 %r21, %r17
  br i1 %r22, label %class_field_inline.deref.5, label %class_field_inline.guardcall.6

standalone.ctor.return.after.1:                   ; preds = %class_field_set.merge.14
  ret double 0x7FFC000000000001

class_field_set.fast.2:                           ; preds = %class_field_inline.guardcall.6, %class_field_inline.deref.5
  %r187.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r187.rs4i = ptrtoint ptr addrspace(1) %r187.rs4p to i64
  %r187.rs4o = call i64 asm "", "=r,0"(i64 %r187.rs4i) #11
  %r187 = bitcast i64 %r187.rs4o to double
  %r188 = bitcast double %r187 to i64
  %r189 = and i64 %r188, 281474976710655
  %r53 = inttoptr i64 %r189 to ptr
  %r183.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r183.rs4i = ptrtoint ptr addrspace(1) %r183.rs4p to i64
  %r183.rs4o = call i64 asm "", "=r,0"(i64 %r183.rs4i) #11
  %r183 = bitcast i64 %r183.rs4o to double
  %r184 = bitcast double %r183 to i64
  %r185 = and i64 %r184, 281474976710655
  %r186 = inttoptr i64 %r185 to ptr
  %r54 = getelementptr i8, ptr %r186, i64 16
  %r55 = getelementptr double, ptr %r54, i64 0
  %r56 = ptrtoint ptr %r55 to i64
  %r182.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r182.rs4i = ptrtoint ptr addrspace(1) %r182.rs4p to i64
  %r182.rs4o = call i64 asm "", "=r,0"(i64 %r182.rs4i) #11
  %r182 = bitcast i64 %r182.rs4o to double
  store double %r182, ptr %r55, align 8
  %r181.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r181.rs4i = ptrtoint ptr addrspace(1) %r181.rs4p to i64
  %r181.rs4o = call i64 asm "", "=r,0"(i64 %r181.rs4i) #11
  %r181 = bitcast i64 %r181.rs4o to double
  %r57 = bitcast double %r181 to i64
  %r179.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r179.rs4i = ptrtoint ptr addrspace(1) %r179.rs4p to i64
  %r179.rs4o = call i64 asm "", "=r,0"(i64 %r179.rs4i) #11
  %r179 = bitcast i64 %r179.rs4o to double
  %r180 = bitcast double %r179 to i64
  %r58 = lshr i64 %r180, 48
  %r59 = icmp eq i64 %r58, 0
  %r177.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r177.rs4i = ptrtoint ptr addrspace(1) %r177.rs4p to i64
  %r177.rs4o = call i64 asm "", "=r,0"(i64 %r177.rs4i) #11
  %r177 = bitcast i64 %r177.rs4o to double
  %r178 = bitcast double %r177 to i64
  %r60 = icmp uge i64 %r178, 4096
  %r61 = and i1 %r59, %r60
  %r62 = icmp eq i64 %r58, 32765
  %r63 = icmp eq i64 %r58, 32767
  %r64 = icmp eq i64 %r58, 32762
  %r65 = or i1 %r62, %r63
  %r66 = or i1 %r65, %r64
  %r67 = or i1 %r66, %r61
  br i1 %r67, label %class_field_set.gc_bookkeeping.7, label %class_field_set.gc_bookkeeping.done.8

class_field_set.fallback.3:                       ; preds = %class_field_inline.guardcall.6
  %r171.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r171.rs4i = ptrtoint ptr addrspace(1) %r171.rs4p to i64
  %r171.rs4o = call i64 asm "", "=r,0"(i64 %r171.rs4i) #11
  %r171 = bitcast i64 %r171.rs4o to double
  %r172 = bitcast double %r171 to i64
  %r173.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r173.rs4i = ptrtoint ptr addrspace(1) %r173.rs4p to i64
  %r173.rs4o = call i64 asm "", "=r,0"(i64 %r173.rs4i) #11
  %r173 = bitcast i64 %r173.rs4o to double
  %r174 = load double, ptr @diagnostic_fixture_ts_.str.3.handle, align 8
  %r175 = bitcast double %r174 to i64
  %r176 = and i64 %r175, 281474976710655
  call void @js_class_field_set_fallback(i64 3713526460397387777, i64 %r172, i64 %r176, double %r173)
  br label %class_field_set.merge.4

class_field_set.merge.4:                          ; preds = %class_field_set.gc_bookkeeping.done.8, %class_field_set.fallback.3
  %r81.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r81.rs4i = ptrtoint ptr addrspace(1) %r81.rs4p to i64
  %r81.rs4o = call i64 asm "", "=r,0"(i64 %r81.rs4i) #11
  %r81 = bitcast i64 %r81.rs4o to double
  %r82.rs4p = load ptr addrspace(1), ptr %r3, align 8
  %r82.rs4i = ptrtoint ptr addrspace(1) %r82.rs4p to i64
  %r82.rs4o = call i64 asm "", "=r,0"(i64 %r82.rs4i) #11
  %r82 = bitcast i64 %r82.rs4o to double
  %r83 = load i32, ptr %r7, align 4
  %r84 = bitcast double %r81 to i64
  %r85 = and i64 %r84, 281474976710655
  %r86 = load double, ptr @diagnostic_fixture_ts_.str.4.handle, align 8
  %r87 = bitcast double %r86 to i64
  %r88 = and i64 %r87, 281474976710655
  %r89 = bitcast double %r82 to i64
  %r90 = load volatile i8, ptr @PERRY_CLASS_FIELD_INLINE_GUARD_DISABLED, align 1
  %r91 = icmp eq i8 %r90, 0
  %r92 = lshr i64 %r84, 48
  %r93 = icmp eq i64 %r92, 32765
  %r94 = icmp ugt i64 %r85, 1048575
  %r95 = and i1 %r93, %r94
  %r96 = and i1 %r95, %r91
  br i1 %r96, label %class_field_inline.deref.15, label %class_field_inline.guardcall.16

class_field_inline.deref.5:                       ; preds = %entry.0
  %r23 = inttoptr i64 %r11 to ptr
  %r24 = getelementptr i8, ptr %r23, i64 -8
  %r25 = load i8, ptr %r24, align 1
  %r26 = icmp eq i8 %r25, 2
  %r27 = getelementptr i8, ptr %r23, i64 -7
  %r28 = load i8, ptr %r27, align 1
  %r29 = and i8 %r28, -128
  %r30 = icmp eq i8 %r29, 0
  %r31 = getelementptr i8, ptr %r23, i64 -6
  %r32 = load i16, ptr %r31, align 2
  %r33 = getelementptr i8, ptr %r23, i64 0
  %r34 = load i32, ptr %r33, align 4
  %r35 = icmp eq i32 %r34, 1
  %r36 = getelementptr i8, ptr %r23, i64 4
  %r37 = load i32, ptr %r36, align 4
  %r38 = icmp eq i32 %r37, %r9
  %r39 = and i1 %r26, %r30
  %r40 = and i1 %r39, %r35
  %r41 = and i1 %r40, %r38
  %r42 = and i16 %r32, 3072
  %r43 = icmp eq i16 %r42, 0
  %r44 = and i1 %r41, %r43
  %r45 = and i16 %r32, 1
  %r46 = icmp eq i16 %r45, 0
  %r47 = and i1 %r44, %r46
  %r48 = and i16 %r32, 128
  %r49 = icmp eq i16 %r48, 0
  %r50 = and i1 %r47, %r49
  br i1 %r50, label %class_field_set.fast.2, label %class_field_inline.guardcall.6

class_field_inline.guardcall.6:                   ; preds = %class_field_inline.deref.5, %entry.0
  %r51 = call i32 @js_typed_feedback_class_field_set_guard(i64 3713526460397387777, double %r5, i32 1, i32 %r9, i64 %r14, i32 0, double %r6, i32 0) #11
  %r52 = icmp ne i32 %r51, 0
  br i1 %r52, label %class_field_set.fast.2, label %class_field_set.fallback.3

class_field_set.gc_bookkeeping.7:                 ; preds = %class_field_set.fast.2
  %r170.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r170.rs4i = ptrtoint ptr addrspace(1) %r170.rs4p to i64
  %r170.rs4o = call i64 asm "", "=r,0"(i64 %r170.rs4i) #11
  %r170 = bitcast i64 %r170.rs4o to double
  call void @js_string_addref_if_heap_string(double %r170) #11
  %r167.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r167.rs4i = ptrtoint ptr addrspace(1) %r167.rs4p to i64
  %r167.rs4o = call i64 asm "", "=r,0"(i64 %r167.rs4i) #11
  %r167 = bitcast i64 %r167.rs4o to double
  %r168 = bitcast double %r167 to i64
  %r169 = and i64 %r168, 281474976710655
  %r68 = inttoptr i64 %r169 to ptr
  %r163.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r163.rs4i = ptrtoint ptr addrspace(1) %r163.rs4p to i64
  %r163.rs4o = call i64 asm "", "=r,0"(i64 %r163.rs4i) #11
  %r163 = bitcast i64 %r163.rs4o to double
  %r164 = bitcast double %r163 to i64
  %r165 = and i64 %r164, 281474976710655
  %r166 = inttoptr i64 %r165 to ptr
  %r69 = getelementptr i8, ptr %r166, i64 -6
  %r70 = load i16, ptr %r69, align 2
  %r71 = and i16 %r70, -12288
  %r72 = icmp eq i16 %r71, -28672
  br i1 %r72, label %class_field_set.layout_note.done.10, label %class_field_set.layout_note.9

class_field_set.gc_bookkeeping.done.8:            ; preds = %class_field_set.barrier.11, %class_field_set.layout_note.done.10, %class_field_set.fast.2
  br label %class_field_set.merge.4

class_field_set.layout_note.9:                    ; preds = %class_field_set.gc_bookkeeping.7
  %r158.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r158.rs4i = ptrtoint ptr addrspace(1) %r158.rs4p to i64
  %r158.rs4o = call i64 asm "", "=r,0"(i64 %r158.rs4i) #11
  %r158 = bitcast i64 %r158.rs4o to double
  %r159 = bitcast double %r158 to i64
  %r160 = and i64 %r159, 281474976710655
  %r161.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r161.rs4i = ptrtoint ptr addrspace(1) %r161.rs4p to i64
  %r161.rs4o = call i64 asm "", "=r,0"(i64 %r161.rs4i) #11
  %r161 = bitcast i64 %r161.rs4o to double
  %r162 = bitcast double %r161 to i64
  call void @js_gc_note_slot_layout(i64 %r160, i32 0, i64 %r162) #11
  br label %class_field_set.layout_note.done.10

class_field_set.layout_note.done.10:              ; preds = %class_field_set.layout_note.9, %class_field_set.gc_bookkeeping.7
  %r155.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r155.rs4i = ptrtoint ptr addrspace(1) %r155.rs4p to i64
  %r155.rs4o = call i64 asm "", "=r,0"(i64 %r155.rs4i) #11
  %r155 = bitcast i64 %r155.rs4o to double
  %r156 = bitcast double %r155 to i64
  %r157 = and i64 %r156, 281474976710655
  %r73 = sub i64 %r157, 7
  %r74 = inttoptr i64 %r73 to ptr
  %r75 = load i8, ptr %r74, align 1
  %r76 = and i8 %r75, 32
  %r77 = icmp ne i8 %r76, 0
  %r78 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r79 = icmp ne i32 %r78, 0
  %r80 = or i1 %r77, %r79
  br i1 %r80, label %class_field_set.barrier.11, label %class_field_set.gc_bookkeeping.done.8

class_field_set.barrier.11:                       ; preds = %class_field_set.layout_note.done.10
  %r151.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r151.rs4i = ptrtoint ptr addrspace(1) %r151.rs4p to i64
  %r151.rs4o = call i64 asm "", "=r,0"(i64 %r151.rs4i) #11
  %r151 = bitcast i64 %r151.rs4o to double
  %r152 = bitcast double %r151 to i64
  %r153.rs4p = load ptr addrspace(1), ptr %r2, align 8
  %r153.rs4i = ptrtoint ptr addrspace(1) %r153.rs4p to i64
  %r153.rs4o = call i64 asm "", "=r,0"(i64 %r153.rs4i) #11
  %r153 = bitcast i64 %r153.rs4o to double
  %r154 = bitcast double %r153 to i64
  call void @js_write_barrier_slot(i64 %r152, i64 %r56, i64 %r154) #11
  br label %class_field_set.gc_bookkeeping.done.8

class_field_set.fast.12:                          ; preds = %class_field_inline.guardcall.16, %class_field_inline.deref.15
  %r148.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r148.rs4i = ptrtoint ptr addrspace(1) %r148.rs4p to i64
  %r148.rs4o = call i64 asm "", "=r,0"(i64 %r148.rs4i) #11
  %r148 = bitcast i64 %r148.rs4o to double
  %r149 = bitcast double %r148 to i64
  %r150 = and i64 %r149, 281474976710655
  %r133 = inttoptr i64 %r150 to ptr
  %r144.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r144.rs4i = ptrtoint ptr addrspace(1) %r144.rs4p to i64
  %r144.rs4o = call i64 asm "", "=r,0"(i64 %r144.rs4i) #11
  %r144 = bitcast i64 %r144.rs4o to double
  %r145 = bitcast double %r144 to i64
  %r146 = and i64 %r145, 281474976710655
  %r147 = inttoptr i64 %r146 to ptr
  %r134 = getelementptr i8, ptr %r147, i64 16
  %r135 = getelementptr double, ptr %r134, i64 1
  %r143.rs4p = load ptr addrspace(1), ptr %r3, align 8
  %r143.rs4i = ptrtoint ptr addrspace(1) %r143.rs4p to i64
  %r143.rs4o = call i64 asm "", "=r,0"(i64 %r143.rs4i) #11
  %r143 = bitcast i64 %r143.rs4o to double
  %r136 = call double @js_array_numeric_value_to_raw_f64(double %r143) #11
  store double %r136, ptr %r135, align 8
  br label %class_field_set.merge.14

class_field_set.fallback.13:                      ; preds = %class_field_inline.guardcall.16
  %r137.rs4p = load ptr addrspace(1), ptr %r1, align 8
  %r137.rs4i = ptrtoint ptr addrspace(1) %r137.rs4p to i64
  %r137.rs4o = call i64 asm "", "=r,0"(i64 %r137.rs4i) #11
  %r137 = bitcast i64 %r137.rs4o to double
  %r138 = bitcast double %r137 to i64
  %r139.rs4p = load ptr addrspace(1), ptr %r3, align 8
  %r139.rs4i = ptrtoint ptr addrspace(1) %r139.rs4p to i64
  %r139.rs4o = call i64 asm "", "=r,0"(i64 %r139.rs4i) #11
  %r139 = bitcast i64 %r139.rs4o to double
  %r140 = load double, ptr @diagnostic_fixture_ts_.str.4.handle, align 8
  %r141 = bitcast double %r140 to i64
  %r142 = and i64 %r141, 281474976710655
  call void @js_class_field_set_fallback(i64 3713526460397387778, i64 %r138, i64 %r142, double %r139)
  br label %class_field_set.merge.14

class_field_set.merge.14:                         ; preds = %class_field_set.fallback.13, %class_field_set.fast.12
  br label %standalone.ctor.return.after.1

class_field_inline.deref.15:                      ; preds = %class_field_set.merge.4
  %r97 = inttoptr i64 %r85 to ptr
  %r98 = getelementptr i8, ptr %r97, i64 -8
  %r99 = load i8, ptr %r98, align 1
  %r100 = icmp eq i8 %r99, 2
  %r101 = getelementptr i8, ptr %r97, i64 -7
  %r102 = load i8, ptr %r101, align 1
  %r103 = and i8 %r102, -128
  %r104 = icmp eq i8 %r103, 0
  %r105 = getelementptr i8, ptr %r97, i64 -6
  %r106 = load i16, ptr %r105, align 2
  %r107 = getelementptr i8, ptr %r97, i64 0
  %r108 = load i32, ptr %r107, align 4
  %r109 = icmp eq i32 %r108, 1
  %r110 = getelementptr i8, ptr %r97, i64 4
  %r111 = load i32, ptr %r110, align 4
  %r112 = icmp eq i32 %r111, %r83
  %r113 = and i1 %r100, %r104
  %r114 = and i1 %r113, %r109
  %r115 = and i1 %r114, %r112
  %r116 = and i16 %r106, 3072
  %r117 = icmp eq i16 %r116, 0
  %r118 = and i1 %r115, %r117
  %r119 = and i16 %r106, 4096
  %r120 = icmp ne i16 %r119, 0
  %r121 = and i1 %r118, %r120
  %r122 = and i16 %r106, 1
  %r123 = icmp eq i16 %r122, 0
  %r124 = and i1 %r121, %r123
  %r125 = and i16 %r106, 128
  %r126 = icmp eq i16 %r125, 0
  %r127 = and i1 %r124, %r126
  %r128 = and i64 %r89, 9218868437227405312
  %r129 = icmp ne i64 %r128, 9218868437227405312
  %r130 = and i1 %r127, %r129
  br i1 %r130, label %class_field_set.fast.12, label %class_field_inline.guardcall.16

class_field_inline.guardcall.16:                  ; preds = %class_field_inline.deref.15, %class_field_set.merge.4
  %r131 = call i32 @js_typed_feedback_class_field_set_guard(i64 3713526460397387778, double %r81, i32 1, i32 %r83, i64 %r88, i32 1, double %r82, i32 1) #11
  %r132 = icmp ne i32 %r131, 0
  br i1 %r132, label %class_field_set.fast.12, label %class_field_set.fallback.13
}

define double @__perry_wrap_perry_fn_diagnostic_fixture_ts__allocating(i64 %this_closure, double %a0) #8 {
entry.0:
  %r1 = call double @perry_fn_diagnostic_fixture_ts__allocating(double %a0)
  ret double %r1
}

define double @__perry_wrap_perry_fn_diagnostic_fixture_ts__dynamicCall(i64 %this_closure, double %a0, double %a1) #8 {
entry.0:
  %r1 = call double @perry_fn_diagnostic_fixture_ts__dynamicCall(double %a0, double %a1)
  ret double %r1
}

define double @__perry_wrap_perry_fn_diagnostic_fixture_ts__exercise(i64 %this_closure, double %a0) #8 {
entry.0:
  %r1 = call double @perry_fn_diagnostic_fixture_ts__exercise(double %a0)
  ret double %r1
}

define internal double @__perry_wrap_perry_unknown_func_diagnostic_fixture_ts(i64 %this_closure, double %a0, double %a1, double %a2, double %a3, double %a4) #8 {
entry.0:
  ret double 0x7FFC000000000001
}

define void @diagnostic_fixture_ts__init() #8 {
entry.0:
  ret void
}

define i32 @main() #8 gc "statepoint-example" {
entry.0:
  %r3 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r3, align 8
  store ptr addrspace(1) null, ptr %r3, align 8
  %r8 = alloca ptr addrspace(1), align 8
  store ptr addrspace(1) null, ptr %r8, align 8
  store ptr addrspace(1) null, ptr %r8, align 8
  call void @js_set_process_entry_path(ptr @diagnostic_fixture_ts_.str.0, i32 76)
  call void @js_gc_init()
  call void @js_gc_write_barriers_emitted(i32 1)
  call void @__perry_init_strings_diagnostic_fixture_ts()
  %r1 = call double @"perry_fn_diagnostic_fixture_ts__exercise$spec_i32"(i32 7)
  %r2 = bitcast double %r1 to i64
  %rs4gc.s1 = inttoptr i64 %r2 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s1, ptr %r3, align 8
  %r4.rs4p = load ptr addrspace(1), ptr %r3, align 8
  %r4.rs4i = ptrtoint ptr addrspace(1) %r4.rs4p to i64
  %r4 = call i64 asm "", "=r,0"(i64 %r4.rs4i) #11
  %r5 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r6 = icmp ne i32 %r5, 0
  br i1 %r6, label %shadow.root.barrier.1, label %shadow.root.barrier.done.2

shadow.root.barrier.1:                            ; preds = %entry.0
  call void @js_write_barrier_root_nanbox(i64 %r4) #11
  br label %shadow.root.barrier.done.2

shadow.root.barrier.done.2:                       ; preds = %shadow.root.barrier.1, %entry.0
  %r7 = call i64 @js_array_alloc(i32 1)
  %rs4gc.s2 = inttoptr i64 %r7 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s2, ptr %r8, align 8
  %r9.rs4p = load ptr addrspace(1), ptr %r8, align 8
  %r9.rs4i = ptrtoint ptr addrspace(1) %r9.rs4p to i64
  %r9 = call i64 asm "", "=r,0"(i64 %r9.rs4i) #11
  %r10 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r11 = icmp ne i32 %r10, 0
  br i1 %r11, label %shadow.root.barrier.3, label %shadow.root.barrier.done.4

shadow.root.barrier.3:                            ; preds = %shadow.root.barrier.done.2
  call void @js_write_barrier_root_nanbox(i64 %r9) #11
  br label %shadow.root.barrier.done.4

shadow.root.barrier.done.4:                       ; preds = %shadow.root.barrier.3, %shadow.root.barrier.done.2
  %r12.rs4p = load ptr addrspace(1), ptr %r3, align 8
  %r12.rs4i = ptrtoint ptr addrspace(1) %r12.rs4p to i64
  %r12 = call i64 asm "", "=r,0"(i64 %r12.rs4i) #11
  %r13 = bitcast i64 %r12 to double
  %r14.rs4p = load ptr addrspace(1), ptr %r8, align 8
  %r14.rs4i = ptrtoint ptr addrspace(1) %r14.rs4p to i64
  %r14 = call i64 asm "", "=r,0"(i64 %r14.rs4i) #11
  %r15 = call i64 @js_array_push_f64(i64 %r14, double %r13)
  %rs4gc.s3 = inttoptr i64 %r15 to ptr addrspace(1)
  store ptr addrspace(1) %rs4gc.s3, ptr %r8, align 8
  %r16.rs4p = load ptr addrspace(1), ptr %r8, align 8
  %r16.rs4i = ptrtoint ptr addrspace(1) %r16.rs4p to i64
  %r16 = call i64 asm "", "=r,0"(i64 %r16.rs4i) #11
  %r17 = load atomic i32, ptr @PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT monotonic, align 4
  %r18 = icmp ne i32 %r17, 0
  br i1 %r18, label %shadow.root.barrier.5, label %shadow.root.barrier.done.6

shadow.root.barrier.5:                            ; preds = %shadow.root.barrier.done.4
  call void @js_write_barrier_root_nanbox(i64 %r16) #11
  br label %shadow.root.barrier.done.6

shadow.root.barrier.done.6:                       ; preds = %shadow.root.barrier.5, %shadow.root.barrier.done.4
  %r19.rs4p = load ptr addrspace(1), ptr %r8, align 8
  %r19.rs4i = ptrtoint ptr addrspace(1) %r19.rs4p to i64
  %r19 = call i64 asm "", "=r,0"(i64 %r19.rs4i) #11
  call void @js_console_log_spread(i64 %r19)
  store ptr addrspace(1) null, ptr %r3, align 8
  store ptr addrspace(1) null, ptr %r8, align 8
  %r20 = call i32 @js_promise_run_microtasks_event_loop()
  %r21 = call i32 @js_promise_run_microtasks_event_loop()
  %r22 = call i32 @js_promise_run_microtasks_event_loop()
  %r23 = call i32 @js_promise_run_microtasks_event_loop()
  call void @js_run_stdlib_pump()
  br label %event_loop.header.7

event_loop.header.7:                              ; preds = %event_loop.body_wait.12, %event_loop.body_check.11, %shadow.root.barrier.done.6
  %r24 = call i32 @js_event_loop_host_driven()
  %r25 = icmp ne i32 %r24, 0
  br i1 %r25, label %event_loop.host_return.9, label %event_loop.check_pending.8

event_loop.check_pending.8:                       ; preds = %event_loop.header.7
  %r26 = call i32 @js_timer_has_pending()
  %r27 = call i32 @js_callback_timer_has_pending()
  %r28 = call i32 @js_interval_timer_has_pending()
  %r29 = call i32 @js_stdlib_has_active_handles()
  %r30 = call i32 @js_bun_ffi_has_active_threadsafe_callbacks()
  %r31 = call i32 @js_microtasks_pending()
  %r32 = or i32 %r26, %r27
  %r33 = or i32 %r28, %r29
  %r34 = or i32 %r33, %r30
  %r35 = or i32 %r32, %r34
  %r36 = or i32 %r35, 0
  %r37 = or i32 %r36, %r31
  %r38 = icmp ne i32 %r37, 0
  br i1 %r38, label %event_loop.body.10, label %event_loop.exit.13

event_loop.host_return.9:                         ; preds = %event_loop.header.7
  call void @js_typed_feedback_maybe_dump_trace() #11
  ret i32 0

event_loop.body.10:                               ; preds = %event_loop.check_pending.8
  %r39 = call i32 @js_promise_run_microtasks_event_loop()
  call void @js_run_stdlib_pump()
  br label %event_loop.body_check.11

event_loop.body_check.11:                         ; preds = %event_loop.body.10
  %r40 = call i32 @js_timer_has_pending()
  %r41 = call i32 @js_callback_timer_has_pending()
  %r42 = call i32 @js_interval_timer_has_pending()
  %r43 = call i32 @js_stdlib_has_active_handles()
  %r44 = call i32 @js_bun_ffi_has_active_threadsafe_callbacks()
  %r45 = call i32 @js_microtasks_pending()
  %r46 = or i32 %r40, %r41
  %r47 = or i32 %r42, %r43
  %r48 = or i32 %r47, %r44
  %r49 = or i32 %r46, %r48
  %r50 = or i32 %r49, 0
  %r51 = or i32 %r50, %r45
  %r52 = icmp ne i32 %r51, 0
  br i1 %r52, label %event_loop.body_wait.12, label %event_loop.header.7

event_loop.body_wait.12:                          ; preds = %event_loop.body_check.11
  call void @js_wait_for_event()
  br label %event_loop.header.7

event_loop.exit.13:                               ; preds = %event_loop.check_pending.8
  call void @js_process_emit_before_exit_pending()
  %r53 = call i32 @js_promise_run_microtasks_event_loop()
  call void @js_process_run_exit_sequence()
  call void @js_process_run_finalization_exit()
  %r54 = call i32 @js_promise_run_promise_jobs()
  call void @js_trace_events_flush_output()
  call void @js_promise_report_unhandled_rejections()
  call void @js_gc_release_current_thread_collection_side_allocations()
  %r55 = call i32 @js_process_pending_exit_code()
  call void @js_typed_feedback_maybe_dump_trace() #11
  ret i32 %r55
}

define void @__perry_init_strings_diagnostic_fixture_ts_chunk0() #8 {
entry.0:
  %r1 = call i64 @js_string_from_bytes(ptr @diagnostic_fixture_ts_.str.0.bytes, i32 1)
  %r2 = call double @js_nanbox_string(i64 %r1)
  store double %r2, ptr @diagnostic_fixture_ts_.str.0.handle, align 8
  %r3 = ptrtoint ptr @diagnostic_fixture_ts_.str.0.handle to i64
  call void @js_gc_register_global_root(i64 %r3)
  %r4 = call i64 @js_string_from_bytes(ptr @diagnostic_fixture_ts_.str.1.bytes, i32 4)
  %r5 = call double @js_nanbox_string(i64 %r4)
  store double %r5, ptr @diagnostic_fixture_ts_.str.1.handle, align 8
  %r6 = ptrtoint ptr @diagnostic_fixture_ts_.str.1.handle to i64
  call void @js_gc_register_global_root(i64 %r6)
  %r7 = call i64 @js_string_from_bytes(ptr @diagnostic_fixture_ts_.str.2.bytes, i32 4)
  %r8 = call double @js_nanbox_string(i64 %r7)
  store double %r8, ptr @diagnostic_fixture_ts_.str.2.handle, align 8
  %r9 = ptrtoint ptr @diagnostic_fixture_ts_.str.2.handle to i64
  call void @js_gc_register_global_root(i64 %r9)
  %r10 = call i64 @js_string_from_bytes(ptr @diagnostic_fixture_ts_.str.3.bytes, i32 4)
  %r11 = call double @js_nanbox_string(i64 %r10)
  store double %r11, ptr @diagnostic_fixture_ts_.str.3.handle, align 8
  %r12 = ptrtoint ptr @diagnostic_fixture_ts_.str.3.handle to i64
  call void @js_gc_register_global_root(i64 %r12)
  %r13 = call i64 @js_string_from_bytes(ptr @diagnostic_fixture_ts_.str.4.bytes, i32 5)
  %r14 = call double @js_nanbox_string(i64 %r13)
  store double %r14, ptr @diagnostic_fixture_ts_.str.4.handle, align 8
  %r15 = ptrtoint ptr @diagnostic_fixture_ts_.str.4.handle to i64
  call void @js_gc_register_global_root(i64 %r15)
  %r16 = call i64 @js_string_from_bytes(ptr @diagnostic_fixture_ts_.str.5.bytes, i32 1)
  %r17 = call double @js_nanbox_string(i64 %r16)
  store double %r17, ptr @diagnostic_fixture_ts_.str.5.handle, align 8
  %r18 = ptrtoint ptr @diagnostic_fixture_ts_.str.5.handle to i64
  call void @js_gc_register_global_root(i64 %r18)
  %r19 = call i64 @js_string_from_bytes(ptr @diagnostic_fixture_ts_.str.6.bytes, i32 5)
  %r20 = call double @js_nanbox_string(i64 %r19)
  store double %r20, ptr @diagnostic_fixture_ts_.str.6.handle, align 8
  %r21 = ptrtoint ptr @diagnostic_fixture_ts_.str.6.handle to i64
  call void @js_gc_register_global_root(i64 %r21)
  call void @js_register_function_name_static(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__allocating, ptr @diagnostic_fixture_ts_.str.1, i32 10)
  call void @js_register_function_name_static(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__dynamicCall, ptr @diagnostic_fixture_ts_.str.2, i32 11)
  call void @js_register_function_name_static(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__exercise, ptr @diagnostic_fixture_ts_.str.3, i32 8)
  call void @js_register_function_name_static(ptr @perry_fn_diagnostic_fixture_ts__allocating, ptr @diagnostic_fixture_ts_.str.1, i32 10)
  call void @js_register_function_name_static(ptr @perry_fn_diagnostic_fixture_ts__dynamicCall, ptr @diagnostic_fixture_ts_.str.2, i32 11)
  call void @js_register_function_name_static(ptr @perry_fn_diagnostic_fixture_ts__exercise, ptr @diagnostic_fixture_ts_.str.3, i32 8)
  call void @js_register_function_name_static(ptr @diagnostic_fixture_ts____AnonShape_2a938cab61a60894_constructor, ptr @diagnostic_fixture_ts_.str.4, i32 32)
  call void @js_register_function_name_static(ptr @perry_closure_diagnostic_fixture_ts__4, ptr @diagnostic_fixture_ts_.str.5, i32 9)
  call void @js_register_function_source_static(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__allocating, ptr @diagnostic_fixture_ts_.str.6, i32 77, i32 1)
  call void @js_register_function_source_static(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__dynamicCall, ptr @diagnostic_fixture_ts_.str.7, i32 72, i32 1)
  call void @js_register_function_source_static(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__exercise, ptr @diagnostic_fixture_ts_.str.8, i32 307, i32 1)
  call void @js_register_function_source_static(ptr @perry_closure_diagnostic_fixture_ts__4, ptr @diagnostic_fixture_ts_.str.9, i32 20, i32 0)
  %r22 = call i64 @js_build_class_keys_array(i32 1, i32 2, ptr @perry_class_keys_packed_diagnostic_fixture_ts__0, i32 11)
  store i64 %r22, ptr @perry_class_keys_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 4
  call void @js_write_barrier_root_heap_word(i64 %r22)
  %r23 = ptrtoint ptr @perry_class_keys_diagnostic_fixture_ts____AnonShape_2a938cab61a60894 to i64
  call void @js_gc_register_global_root(i64 %r23)
  %r24 = call i32 @js_gc_typed_shape_id_for_keys(i32 1, i64 %r22, i32 2, ptr @perry_typed_shape_raw_f64_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, i32 1, ptr @perry_typed_shape_mask_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, i32 1)
  store i32 %r24, ptr @perry_class_shape_id_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 4
  %r25 = zext i32 %r24 to i64
  %r26 = shl i64 %r25, 32
  %r27 = or i64 %r26, 1
  %r28 = insertelement <2 x i64> <i64 174214611458, i64 0>, i64 %r27, i32 1
  store <2 x i64> %r28, ptr @perry_class_header_image_diagnostic_fixture_ts____AnonShape_2a938cab61a60894, align 8
  %r29 = ptrtoint ptr @diagnostic_fixture_ts____AnonShape_2a938cab61a60894_constructor to i64
  call void @js_register_class_constructor(i64 1, i64 %r29, i64 2, i64 0)
  call void @js_register_class_id(i32 1)
  call void @js_register_anon_shape_class_id(i32 1)
  call void @js_register_class_length(i32 1, i32 2)
  call void @js_register_closure_arity(ptr @perry_closure_diagnostic_fixture_ts__4, i32 1)
  call void @js_register_closure_length(ptr @perry_closure_diagnostic_fixture_ts__4, i32 1)
  call void @js_register_closure_arrow_function(ptr @perry_closure_diagnostic_fixture_ts__4)
  call void @js_register_closure_arity(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__allocating, i32 1)
  call void @js_register_closure_arity(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__dynamicCall, i32 2)
  call void @js_register_closure_arity(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__exercise, i32 1)
  call void @js_register_closure_length(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__allocating, i32 1)
  call void @js_register_closure_length(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__dynamicCall, i32 2)
  call void @js_register_closure_length(ptr @__perry_wrap_perry_fn_diagnostic_fixture_ts__exercise, i32 1)
  ret void
}

define void @__perry_init_strings_diagnostic_fixture_ts() #8 {
entry.0:
  call void @__perry_init_strings_diagnostic_fixture_ts_chunk0()
  ret void
}

attributes #0 = { nounwind willreturn memory(none) }
attributes #1 = { nounwind willreturn memory(read) }
attributes #2 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #4 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #5 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #6 = { nounwind willreturn }
attributes #7 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #8 = { "frame-pointer"="non-leaf" }
attributes #9 = { inlinehint "frame-pointer"="non-leaf" }
attributes #10 = { noinline "frame-pointer"="non-leaf" }
attributes #11 = { "gc-leaf-function" }
