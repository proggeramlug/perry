use super::*;
use perry_hir::{CatchClause, UnaryOp};

const ITER: u32 = 10;
const RESULT: u32 = 11;
const RECORD: u32 = 12;
const SEGMENT: u32 = 13;

fn get(object: Expr, property: &str) -> Expr {
    Expr::PropertyGet {
        object: Box::new(object),
        property: property.into(),
        byte_offset: 123,
    }
}

fn invoke(callee: Expr, args: Vec<Expr>) -> Expr {
    Expr::Call {
        callee: Box::new(callee),
        args,
        type_args: Vec::new(),
        byte_offset: 456,
    }
}

fn close() -> Stmt {
    Stmt::If {
        condition: Expr::Compare {
            op: CompareOp::LooseNe,
            left: Box::new(get(local(ITER), "return")),
            right: Box::new(Expr::Null),
        },
        then_branch: vec![Stmt::Expr(call(
            "js_iterator_result_validate",
            vec![invoke(get(local(ITER), "return"), Vec::new())],
        ))],
        else_branch: None,
    }
}

fn region() -> Vec<Stmt> {
    vec![
        let_any(
            ITER,
            "__arr_10",
            Expr::GetIterator(Box::new(invoke(get(local(0), "segment"), vec![local(1)]))),
        ),
        Stmt::For {
            init: Some(Box::new(let_any(
                RESULT,
                "__result_11",
                call("js_for_of_next", vec![local(ITER)]),
            ))),
            condition: Some(Expr::Unary {
                op: UnaryOp::Not,
                operand: Box::new(get(local(RESULT), "done")),
            }),
            update: Some(Expr::LocalSet(
                RESULT,
                Box::new(call("js_for_of_next", vec![local(ITER)])),
            )),
            body: vec![
                let_any(RECORD, "__destruct_12", get(local(RESULT), "value")),
                let_any(SEGMENT, "segment", get(local(RECORD), "segment")),
                Stmt::Try {
                    body: vec![Stmt::Expr(Expr::StringCodePointAt {
                        string: Box::new(local(SEGMENT)),
                        index: Box::new(Expr::Number(0.0)),
                    })],
                    catch: Some(CatchClause {
                        param: Some((14, "error".into())),
                        body: vec![close(), Stmt::Throw(local(14))],
                    }),
                    finally: None,
                },
            ],
        },
    ]
}

fn fixture_module() -> Module {
    let mut module = Module::new("projection-test");
    module.init = region();
    module
}

fn debug(value: &impl std::fmt::Debug) -> String {
    format!("{value:?}")
}

fn loop_body(module: &mut Module) -> &mut Vec<Stmt> {
    let index = module
        .init
        .iter()
        .position(|stmt| matches!(stmt, Stmt::For { .. }))
        .unwrap();
    let Stmt::For { body, .. } = &mut module.init[index] else {
        unreachable!()
    };
    body
}

fn lowered_witness(module: &Module) -> bool {
    let text = debug(&module.init);
    text.contains("js_segments_project_can_open")
        && text.contains("js_segments_project_open")
        && text.contains("js_segments_project_iterator")
        && text.matches("js_segments_project_next").count() == 2
        && text.matches("js_segments_project_segment").count() == 1
        && text.matches("js_segments_project_observe_iterator").count() == 2
        && !text.contains("__destruct_12")
        && !text.contains("js_segments_view_")
}

#[test]
fn default_matches_explicit_on_and_disabled_hir_has_a_distinct_cache_input() {
    let mut default = fixture_module();
    let mut explicit_on = fixture_module();
    let mut disabled = fixture_module();
    let original = debug(&disabled.init);
    assert_eq!(
        segments_project_rewrite_module(&mut default, segments_project_setting(None), false),
        1
    );
    assert_eq!(
        segments_project_rewrite_module(
            &mut explicit_on,
            segments_project_setting(Some("1")),
            false,
        ),
        1
    );
    assert_eq!(
        segments_project_rewrite_module(&mut disabled, segments_project_setting(Some("0")), false),
        0
    );
    assert!(lowered_witness(&default));
    assert_eq!(debug(&default.init), debug(&explicit_on.init));
    assert_eq!(debug(&disabled.init), original);
    assert!(!lowered_witness(&disabled));
    // run_pipeline fingerprints this same post-rewrite HIR for object reuse.
    let hash = perry_hir::stable_hash::hash_module;
    assert_eq!(hash(&default), hash(&explicit_on));
    assert_ne!(hash(&default), hash(&disabled));
    for value in ["0", "off", "false", "", "unexpected"] {
        assert!(!segments_project_setting(Some(value)));
    }
}

#[test]
fn enabled_emission_and_disabled_control_are_distinct_and_witness_can_fail() {
    let mut enabled = fixture_module();
    let mut disabled = fixture_module();
    let before = debug(&disabled.init);
    assert_eq!(
        segments_project_rewrite_module(&mut disabled, false, false),
        0
    );
    assert_eq!(debug(&disabled.init), before);
    assert!(
        !lowered_witness(&disabled),
        "disabled control must fail the emission witness"
    );
    assert_eq!(
        segments_project_rewrite_module(&mut enabled, true, false),
        1
    );
    assert!(lowered_witness(&enabled));
    let mut sabotage = enabled.clone();
    // Removing the projection binding leaves the ordinary body but must make
    // the work-removal witness fail, independently of the pass return count.
    loop_body(&mut sabotage).remove(0);
    assert!(!lowered_witness(&sabotage));
}

#[test]
fn input_stays_below_method_lookup_on_admission_decline() {
    let mut module = fixture_module();
    let original_input = local(1);
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 1);
    let Stmt::Let {
        id: receiver,
        init: Some(Expr::LocalGet(0)),
        ..
    } = &module.init[0]
    else {
        panic!("receiver must be saved once")
    };
    let Stmt::Let {
        id: admitted,
        init: Some(Expr::Call { callee, .. }),
        ..
    } = &module.init[1]
    else {
        panic!("nonobserving guard precedes input")
    };
    assert!(
        matches!(callee.as_ref(), Expr::ExternFuncRef { name, .. } if name == "js_segments_project_can_open")
    );
    let Stmt::Let {
        id: input,
        init:
            Some(Expr::Conditional {
                condition,
                then_expr,
                else_expr,
            }),
        ..
    } = &module.init[2]
    else {
        panic!("input must be lazy")
    };
    assert!(matches!(condition.as_ref(), Expr::LocalGet(id) if id == admitted));
    assert_eq!(debug(then_expr), debug(&Box::new(original_input.clone())));
    assert!(matches!(else_expr.as_ref(), Expr::Undefined));
    let Stmt::Let {
        id: iter,
        init:
            Some(Expr::Conditional {
                then_expr,
                else_expr,
                ..
            }),
        ..
    } = &module.init[4]
    else {
        panic!("real iterator selection")
    };
    assert_eq!(*iter, ITER);
    assert!(debug(then_expr).contains("js_segments_project_iterator"));
    let Expr::GetIterator(subject) = else_expr.as_ref() else {
        panic!("original GetIterator retained")
    };
    let Expr::Call {
        callee,
        args,
        byte_offset,
        ..
    } = subject.as_ref()
    else {
        panic!("original method call retained")
    };
    assert_eq!(*byte_offset, 456);
    assert!(
        matches!(callee.as_ref(), Expr::PropertyGet { object, property, byte_offset: 123 }
        if property == "segment" && matches!(object.as_ref(), Expr::LocalGet(id) if id == receiver))
    );
    let Expr::Conditional {
        condition,
        then_expr,
        else_expr,
    } = &args[0]
    else {
        panic!("input-based open decline reuses saved input")
    };
    assert!(matches!(condition.as_ref(), Expr::LocalGet(id) if id == admitted));
    assert!(matches!(then_expr.as_ref(), Expr::LocalGet(id) if id == input));
    assert_eq!(debug(else_expr), debug(&Box::new(original_input)));
}

#[test]
fn binding_position_and_complete_user_body_remain_in_place() {
    let mut module = fixture_module();
    let before = loop_body(&mut module).clone();
    let Stmt::Try {
        body: user_before, ..
    } = &before[2]
    else {
        unreachable!()
    };
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 1);
    let body = loop_body(&mut module);
    assert!(matches!(body.first(), Some(Stmt::Let { id: SEGMENT, .. })));
    let Stmt::Try {
        body: user_after,
        catch,
        ..
    } = &body[1]
    else {
        panic!("original user-body Try must stay after projection")
    };
    assert_eq!(debug(user_before), debug(user_after));
    assert_eq!(
        debug(&catch.as_ref().unwrap().body[1]),
        debug(&Stmt::Throw(local(14)))
    );
    assert!(
        debug(&catch.as_ref().unwrap().body[0]).contains("js_segments_project_observe_iterator")
    );
    let Stmt::For { condition, .. } = &module.init[5] else {
        unreachable!()
    };
    assert!(
        !debug(condition).contains("observe_iterator"),
        "normal exhaustion must not materialize"
    );
}

#[test]
fn effectful_and_tdz_inputs_decline_without_changing_hir() {
    for input in [call("effectful_input", Vec::new()), get(local(1), "value")] {
        let mut module = fixture_module();
        let Stmt::Let {
            init: Some(Expr::GetIterator(subject)),
            ..
        } = &mut module.init[0]
        else {
            unreachable!()
        };
        let Expr::Call { args, .. } = subject.as_mut() else {
            unreachable!()
        };
        args[0] = input;
        let before = debug(&module.init);
        assert_eq!(segments_project_rewrite_module(&mut module, true, false), 0);
        assert_eq!(debug(&module.init), before);
    }
    let mut module = fixture_module();
    module.init.insert(0, Stmt::PreallocateTdzBoxes(vec![1]));
    let before = debug(&module.init);
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 0);
    assert_eq!(debug(&module.init), before);
}

#[test]
fn extra_protocol_uses_and_noncanonical_return_reads_decline() {
    for id in [ITER, RESULT, RECORD] {
        let mut module = fixture_module();
        module.init.push(Stmt::Expr(local(id)));
        assert_eq!(
            segments_project_rewrite_module(&mut module, true, false),
            0,
            "extra use of {id}"
        );
    }
    let mut module = fixture_module();
    loop_body(&mut module).push(Stmt::Expr(get(local(ITER), "return")));
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 0);
}

#[test]
fn converted_closure_capture_metadata_alone_declines() {
    let mut module = fixture_module();
    // Converted body need not still contain LocalGet(RECORD).
    loop_body(&mut module).push(Stmt::Expr(Expr::Closure {
        func_id: 88,
        params: Vec::new(),
        return_type: Type::Any,
        body: vec![Stmt::Return(Some(Expr::Undefined))],
        captures: vec![RECORD],
        mutable_captures: Vec::new(),
        captures_this: false,
        captures_new_target: false,
        enclosing_class: None,
        is_arrow: true,
        is_async: false,
        is_generator: false,
        is_strict: false,
    }));
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 0);
}

#[test]
fn result_and_record_shapes_are_not_generalized() {
    let mut module = fixture_module();
    loop_body(&mut module).insert(2, let_any(20, "index", get(local(RECORD), "index")));
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 0);
    let mut module = fixture_module();
    let Stmt::For { condition, .. } = &mut module.init[1] else {
        unreachable!()
    };
    *condition = Some(Expr::Bool(true));
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 0);
}

#[test]
fn labels_and_legal_exit_releases_keep_real_iterator() {
    let mut module = fixture_module();
    let loop_stmt = module.init.remove(1);
    module.init.push(Stmt::Labeled {
        label: "outer".into(),
        body: Box::new(loop_stmt),
    });
    assert_eq!(segments_project_rewrite_module(&mut module, true, false), 1);
    assert!(matches!(&module.init[5], Stmt::Labeled { label, .. } if label == "outer"));
    assert_eq!(module.init.len(), 10);
    assert!(module.init[6..].iter().all(|stmt| matches!(stmt, Stmt::Expr(Expr::LocalSet(_, value)) if matches!(value.as_ref(), Expr::Undefined))));
}

#[test]
fn diagnostics_do_not_change_emitted_hir() {
    let mut plain = fixture_module();
    let mut diagnostic = fixture_module();
    assert_eq!(segments_project_rewrite_module(&mut plain, true, false), 1);
    assert_eq!(
        segments_project_rewrite_module(&mut diagnostic, true, true),
        1
    );
    assert_eq!(debug(&plain.init), debug(&diagnostic.init));
}

#[test]
fn all_six_runtime_entries_have_exact_f64_declarations() {
    let mut module = crate::module::LlModule::new("x86_64-unknown-linux-gnu");
    crate::runtime_decls::declare_phase_b_strings(&mut module);
    let declarations: Vec<_> = module.declaration_lines().collect();
    for (name, arity) in [
        ("can_open", 1),
        ("open", 2),
        ("iterator", 1),
        ("next", 1),
        ("segment", 1),
        ("observe_iterator", 1),
    ] {
        let full_name = format!("js_segments_project_{name}");
        let line = declarations
            .iter()
            .find(|(name, _)| *name == full_name)
            .expect("projection declaration missing")
            .1;
        assert!(line.starts_with("declare double "));
        let params = line.split_once('(').unwrap().1.split_once(')').unwrap().0;
        assert_eq!(params.split(',').count(), arity);
        assert!(params.split(',').all(|param| param.trim() == "double"));
    }
}
