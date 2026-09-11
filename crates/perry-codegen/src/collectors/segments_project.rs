//! Guarded record projection with a real iterator and runtime fallback.
//!
//! This pass keeps the original string-consuming body, next/done boundary,
//! projection binding position, and generated close scaffold. It does not
//! invoke the older segment-view pass or substitute string/RegExp operations.

use std::collections::{HashMap, HashSet};

use perry_hir::{types::Type, CompareOp, Expr, Module, Stmt};

use super::segview::{
    collect_segment_for_of_sites, for_each_expr_in_stmt_shallow, for_each_stmt_list,
    max_local_id_in_module, SegmentForOfSite,
};

fn segments_project_setting(value: Option<&str>) -> bool {
    // Unset uses the measured explicit-on lowering. Preserve the existing
    // interpretation of supplied values: only "1" enables; "0" is the
    // comparison/bisection control.
    matches!(value, None | Some("1"))
}

pub fn segments_project_enabled() -> bool {
    match std::env::var("PERRY_SEGMENTS_PROJECT") {
        Ok(value) => segments_project_setting(Some(&value)),
        Err(std::env::VarError::NotPresent) => segments_project_setting(None),
        Err(std::env::VarError::NotUnicode(_)) => false,
    }
}

pub fn segments_project_diag_enabled() -> bool {
    std::env::var("PERRY_SEGMENTS_PROJECT_DIAG").is_ok_and(|v| v == "1")
}

fn call(name: &str, args: Vec<Expr>) -> Expr {
    Expr::Call {
        callee: Box::new(Expr::ExternFuncRef {
            name: name.into(),
            param_types: vec![Type::Any; args.len()],
            return_type: Type::Any,
        }),
        args,
        type_args: Vec::new(),
        byte_offset: 0,
    }
}

fn local(id: u32) -> Expr {
    Expr::LocalGet(id)
}

fn let_any(id: u32, name: &str, value: Expr) -> Stmt {
    Stmt::Let {
        id,
        name: name.into(),
        ty: Type::Any,
        mutable: true,
        init: Some(value),
    }
}

fn conditional(condition: Expr, yes: Expr, no: Expr) -> Expr {
    Expr::Conditional {
        condition: Box::new(condition),
        then_expr: Box::new(yes),
        else_expr: Box::new(no),
    }
}

fn active(cursor: u32) -> Expr {
    Expr::Compare {
        op: CompareOp::Ne,
        left: Box::new(local(cursor)),
        right: Box::new(Expr::Number(0.0)),
    }
}

fn pick(cursor: u32, yes: Expr, no: Expr) -> Expr {
    conditional(active(cursor), yes, no)
}

fn refs(stmts: &[Stmt]) -> HashMap<u32, usize> {
    let mut all = Vec::new();
    let mut visited = HashSet::new();
    for stmt in stmts {
        perry_hir::collect_local_refs_stmt(stmt, &mut all, &mut visited);
    }
    let mut counts = HashMap::new();
    for id in all {
        *counts.entry(id).or_default() += 1;
    }
    counts
}

#[derive(Default)]
struct Facts {
    refs: HashMap<u32, usize>,
    boxed: HashSet<u32>,
    tdz: HashSet<u32>,
    max_id: u32,
}

impl Facts {
    fn collect(stmts: &[Stmt]) -> Self {
        let mut facts = Self {
            refs: refs(stmts),
            ..Self::default()
        };
        for_each_stmt_list(stmts, &mut |list| {
            for stmt in list {
                match stmt {
                    Stmt::Let { id, .. } => facts.max_id = facts.max_id.max(*id),
                    Stmt::For {
                        init: Some(init), ..
                    } => {
                        if let Stmt::Let { id, .. } = init.as_ref() {
                            facts.max_id = facts.max_id.max(*id);
                        }
                    }
                    Stmt::PreallocateBoxes(ids) | Stmt::ReleaseBoxes(ids) => {
                        facts.boxed.extend(ids.iter().copied());
                    }
                    Stmt::PreallocateTdzBoxes(ids) => {
                        facts.boxed.extend(ids.iter().copied());
                        facts.tdz.extend(ids.iter().copied());
                    }
                    _ => {}
                }
                for_each_expr_in_stmt_shallow(stmt, &mut |expr| facts.closure_facts(expr));
            }
        });
        for id in facts.refs.keys().chain(facts.boxed.iter()) {
            facts.max_id = facts.max_id.max(*id);
        }
        facts
    }

    fn closure_facts(&mut self, expr: &Expr) {
        if let Expr::Closure {
            params,
            captures,
            mutable_captures,
            ..
        } = expr
        {
            // Closure conversion can replace body reads with environment reads.
            // Capture metadata is therefore part of the nonescape proof too.
            self.boxed
                .extend(captures.iter().chain(mutable_captures).copied());
            for param in params {
                self.max_id = self.max_id.max(param.id);
            }
        }
        perry_hir::walker::walk_expr_children(expr, &mut |child| self.closure_facts(child));
    }
}

fn input_is_pure(expr: &Expr, facts: &Facts) -> bool {
    match expr {
        Expr::LocalGet(id) => !facts.tdz.contains(id),
        Expr::Undefined
        | Expr::Null
        | Expr::Bool(_)
        | Expr::Number(_)
        | Expr::Integer(_)
        | Expr::String(_)
        | Expr::WtfString(_) => true,
        _ => false,
    }
}

fn return_get(expr: &Expr, iter: u32) -> bool {
    matches!(expr, Expr::PropertyGet { object, property, .. }
        if property == "return" && matches!(object.as_ref(), Expr::LocalGet(id) if *id == iter))
}

fn return_call(expr: &Expr, iter: u32) -> bool {
    let Expr::Call { callee, args, .. } = expr else {
        return false;
    };
    if return_get(callee, iter) && args.is_empty() {
        return true;
    }
    matches!(callee.as_ref(), Expr::ExternFuncRef { name, .. } if name == "js_iterator_result_validate")
        && args.len() == 1
        && matches!(&args[0], Expr::Call { callee, args, .. } if return_get(callee, iter) && args.is_empty())
}

fn close_guard(stmt: &Stmt, iter: u32) -> bool {
    let Stmt::If {
        condition,
        then_branch,
        else_branch: None,
    } = stmt
    else {
        return false;
    };
    matches!(condition, Expr::Compare { op: CompareOp::LooseNe, left, right }
        if return_get(left, iter) && matches!(right.as_ref(), Expr::Null))
        && matches!(then_branch.as_slice(), [Stmt::Expr(expr)] if return_call(expr, iter))
}

/// Only exact compiler-generated close guards are accepted. For proof, erase
/// their two iterator references in a clone; for emission, wrap those same
/// receivers. Other iterator references make the candidate decline.
fn close_guards(list: &mut Vec<Stmt>, iter: u32, cursor: Option<u32>) -> usize {
    let mut found = 0;
    for stmt in list {
        if close_guard(stmt, iter) {
            found += 1;
            replace_close_receivers(stmt, iter, cursor);
        } else {
            walk_stmt(
                stmt,
                &mut |child| found += close_guards(child, iter, cursor),
                &mut |_| {},
            );
        }
    }
    found
}

fn replace_close_receivers(stmt: &mut Stmt, iter: u32, cursor: Option<u32>) {
    walk_stmt(
        stmt,
        &mut |list| {
            for stmt in list {
                replace_close_receivers(stmt, iter, cursor);
            }
        },
        &mut |expr| {
            if let Expr::PropertyGet {
                object, property, ..
            } = expr
            {
                if property == "return"
                    && matches!(object.as_ref(), Expr::LocalGet(id) if *id == iter)
                {
                    *object = Box::new(match cursor {
                        Some(cursor) => pick(
                            cursor,
                            call("js_segments_project_observe_iterator", vec![local(cursor)]),
                            local(iter),
                        ),
                        None => Expr::Undefined,
                    });
                }
            }
        },
    );
}

fn unwrap_for(stmt: &mut Stmt) -> &mut Stmt {
    match stmt {
        Stmt::Labeled { body, .. } => unwrap_for(body),
        other => other,
    }
}

fn candidate(window: &[Stmt], facts: &Facts) -> Result<SegmentForOfSite, &'static str> {
    let Some(Stmt::Let {
        id: iter,
        init: Some(Expr::GetIterator(subject)),
        ..
    }) = window.first()
    else {
        return Err("not_iterator_producer");
    };
    let Expr::Call { callee, args, .. } = subject.as_ref() else {
        return Err("not_segment_call");
    };
    if !matches!(callee.as_ref(), Expr::PropertyGet { property, .. } if property == "segment")
        || args.len() != 1
    {
        return Err("not_segment_call");
    }
    if !input_is_pure(&args[0], facts) {
        return Err("input_not_pure");
    }
    let site = collect_segment_for_of_sites(window)
        .into_iter()
        .find(|site| site.iter_id == *iter)
        .ok_or("head_not_canonical")?;
    if !site.fires() || site.record_keys != ["segment"] {
        return Err("record_not_single_projection");
    }
    if [site.iter_id, site.result_id, site.record_id]
        .iter()
        .any(|id| facts.boxed.contains(id))
    {
        return Err("protocol_local_captured");
    }
    if facts.refs.get(&site.record_id).copied().unwrap_or(0) != 1 {
        return Err("record_extra_use");
    }
    // result.done, result.value, and the result LocalSet in the update.
    if facts.refs.get(&site.result_id).copied().unwrap_or(0) != 3 {
        return Err("result_extra_use");
    }
    let mut proof = vec![window[1].clone()];
    let close_count = close_guards(&mut proof, *iter, None);
    if refs(&proof).get(iter).copied().unwrap_or(0) != 2
        || facts.refs.get(iter).copied().unwrap_or(0) != 2 + close_count * 2
    {
        return Err("iterator_extra_use");
    }
    Ok(site)
}

fn rewrite(list: &mut Vec<Stmt>, index: usize, site: &SegmentForOfSite, fresh: &mut u32) {
    let Expr::GetIterator(subject) = (match &list[index] {
        Stmt::Let {
            init: Some(expr), ..
        } => expr.clone(),
        _ => unreachable!(),
    }) else {
        unreachable!()
    };
    let Expr::Call { callee, args, .. } = subject.as_ref() else {
        unreachable!()
    };
    let Expr::PropertyGet { object, .. } = callee.as_ref() else {
        unreachable!()
    };
    let receiver_expr = object.as_ref().clone();
    let receiver = *fresh;
    let admitted = receiver + 1;
    let input = receiver + 2;
    let cursor = receiver + 3;
    *fresh += 4;

    let mut fallback = subject.as_ref().clone();
    let Expr::Call {
        callee,
        args: fallback_args,
        ..
    } = &mut fallback
    else {
        unreachable!()
    };
    let Expr::PropertyGet {
        object: fallback_receiver,
        ..
    } = callee.as_mut()
    else {
        unreachable!()
    };
    *fallback_receiver = Box::new(local(receiver));
    // If can_open declined, the original argument remains below the original
    // method read. Otherwise that read was proved plain, and a pure argument
    // can be saved once for an input-based decline from open.
    fallback_args[0] = conditional(local(admitted), local(input), args[0].clone());

    let Stmt::For {
        init,
        condition,
        update,
        body,
    } = unwrap_for(&mut list[index + 1])
    else {
        unreachable!()
    };
    let Some(init) = init else { unreachable!() };
    let Stmt::Let {
        init: Some(next), ..
    } = init.as_mut()
    else {
        unreachable!()
    };
    *next = pick(
        cursor,
        call("js_segments_project_next", vec![local(cursor)]),
        next.clone(),
    );
    *condition = Some(pick(
        cursor,
        Expr::Compare {
            op: CompareOp::Eq,
            left: Box::new(local(site.result_id)),
            right: Box::new(Expr::Number(1.0)),
        },
        condition.take().unwrap(),
    ));
    let Some(Expr::LocalSet(_, next)) = update else {
        unreachable!()
    };
    **next = pick(
        cursor,
        call("js_segments_project_next", vec![local(cursor)]),
        next.as_ref().clone(),
    );

    let Stmt::Let {
        init: Some(record_value),
        ..
    } = &body[0]
    else {
        unreachable!()
    };
    let Stmt::Let {
        init: Some(project),
        ..
    } = &body[1]
    else {
        unreachable!()
    };
    let mut fallback_projection = project.clone();
    let Expr::PropertyGet { object, .. } = &mut fallback_projection else {
        unreachable!()
    };
    *object = Box::new(record_value.clone());
    let projected = pick(
        cursor,
        call("js_segments_project_segment", vec![local(cursor)]),
        fallback_projection,
    );
    // Keep the original binding's type, mutability, position, and surrounding
    // Try structure; only the nonescaping intermediate record disappears.
    body.remove(0);
    let Stmt::Let { init, .. } = &mut body[0] else {
        unreachable!()
    };
    *init = Some(projected);
    close_guards(body, site.iter_id, Some(cursor));

    let prefix = vec![
        let_any(receiver, "__segments_project_receiver", receiver_expr),
        let_any(
            admitted,
            "__segments_project_admitted",
            call("js_segments_project_can_open", vec![local(receiver)]),
        ),
        let_any(
            input,
            "__segments_project_input",
            conditional(local(admitted), args[0].clone(), Expr::Undefined),
        ),
        let_any(
            cursor,
            "__segments_project_cursor",
            conditional(
                local(admitted),
                call(
                    "js_segments_project_open",
                    vec![local(receiver), local(input)],
                ),
                Expr::Number(0.0),
            ),
        ),
        let_any(
            site.iter_id,
            "__segments_project_iterator",
            pick(
                cursor,
                call("js_segments_project_iterator", vec![local(cursor)]),
                Expr::GetIterator(Box::new(fallback)),
            ),
        ),
    ];
    list.splice(index..=index, prefix);
    // Normal exhaustion and local break reach these releases. Return/throw
    // leave through the unchanged frame/close machinery. The runtime also
    // clears state on exhaustion; do not observe/materialize to release it.
    let clear = [cursor, receiver, input, site.iter_id]
        .map(|id| Stmt::Expr(Expr::LocalSet(id, Box::new(Expr::Undefined))));
    list.splice(index + 6..index + 6, clear);
}

/// Exhaustive statement descent; expression children use the shared walker.
/// `lists` owns recursion into statement lists (including closure bodies).
fn walk_stmt(
    stmt: &mut Stmt,
    lists: &mut impl FnMut(&mut Vec<Stmt>),
    exprs: &mut impl FnMut(&mut Expr),
) {
    match stmt {
        Stmt::Let { init, .. } | Stmt::Return(init) => {
            if let Some(expr) = init {
                walk_expr(expr, lists, exprs);
            }
        }
        Stmt::Expr(expr) | Stmt::Throw(expr) => walk_expr(expr, lists, exprs),
        Stmt::If {
            condition,
            then_branch,
            else_branch,
        } => {
            walk_expr(condition, lists, exprs);
            lists(then_branch);
            if let Some(branch) = else_branch {
                lists(branch);
            }
        }
        Stmt::While { condition, body } | Stmt::DoWhile { condition, body } => {
            walk_expr(condition, lists, exprs);
            lists(body);
        }
        Stmt::For {
            init,
            condition,
            update,
            body,
        } => {
            if let Some(init) = init {
                walk_stmt(init, lists, exprs);
            }
            if let Some(condition) = condition {
                walk_expr(condition, lists, exprs);
            }
            if let Some(update) = update {
                walk_expr(update, lists, exprs);
            }
            lists(body);
        }
        Stmt::Labeled { body, .. } => walk_stmt(body, lists, exprs),
        Stmt::Try {
            body,
            catch,
            finally,
        } => {
            lists(body);
            if let Some(catch) = catch {
                lists(&mut catch.body);
            }
            if let Some(finally) = finally {
                lists(finally);
            }
        }
        Stmt::Switch {
            discriminant,
            cases,
        } => {
            walk_expr(discriminant, lists, exprs);
            for case in cases {
                if let Some(test) = &mut case.test {
                    walk_expr(test, lists, exprs);
                }
                lists(&mut case.body);
            }
        }
        Stmt::Break
        | Stmt::Continue
        | Stmt::LabeledBreak(_)
        | Stmt::LabeledContinue(_)
        | Stmt::PreallocateBoxes(_)
        | Stmt::PreallocateTdzBoxes(_)
        | Stmt::ReleaseBoxes(_) => {}
    }
}

fn walk_expr(
    expr: &mut Expr,
    lists: &mut impl FnMut(&mut Vec<Stmt>),
    exprs: &mut impl FnMut(&mut Expr),
) {
    exprs(expr);
    if let Expr::Closure { body, .. } = expr {
        lists(body);
    }
    perry_hir::walker::walk_expr_children_mut(expr, &mut |child| walk_expr(child, lists, exprs));
}

fn rewrite_region(
    list: &mut Vec<Stmt>,
    facts: &Facts,
    fresh: &mut u32,
    diag: bool,
    region: &str,
) -> usize {
    let mut count = 0;
    for stmt in list.iter_mut() {
        walk_stmt(
            stmt,
            &mut |nested| count += rewrite_region(nested, facts, fresh, diag, region),
            &mut |_| {},
        );
    }
    let mut index = 0;
    while index + 1 < list.len() {
        match candidate(&list[index..=index + 1], facts) {
            Ok(site) if *fresh <= u32::MAX - 4 => {
                if diag {
                    eprintln!("[segments-project] {region} iter={} record={} verdict=lowered next=2 segment=1 body=preserved", site.iter_id, site.record_id);
                }
                rewrite(list, index, &site, fresh);
                count += 1;
                index += 10;
            }
            Err(reason)
                if diag && reason != "not_iterator_producer" && reason != "not_segment_call" =>
            {
                eprintln!("[segments-project] {region} verdict={reason}");
                index += 1;
            }
            _ => index += 1,
        }
    }
    count
}

/// Explicit arguments make enabled/disabled and diagnostic-only controls
/// testable without changing the environment shared by compiler tests.
pub fn segments_project_rewrite_module(module: &mut Module, enabled: bool, diag: bool) -> usize {
    if !enabled {
        return 0;
    }
    let mut fresh = max_local_id_in_module(module);
    let mut regions = Vec::new();
    regions.push((&mut module.init, format!("{}::<init>", module.name)));
    for function in &mut module.functions {
        regions.push((&mut function.body, function.name.clone()));
    }
    for class in &mut module.classes {
        if let Some(constructor) = &mut class.constructor {
            regions.push((&mut constructor.body, format!("{}.constructor", class.name)));
        }
        for method in class.methods.iter_mut().chain(&mut class.static_methods) {
            regions.push((&mut method.body, format!("{}.{}", class.name, method.name)));
        }
        for (name, function) in class.getters.iter_mut().chain(&mut class.setters) {
            regions.push((&mut function.body, format!("{}.{name}", class.name)));
        }
    }
    let facts: Vec<Facts> = regions
        .iter()
        .map(|(body, _)| Facts::collect(body))
        .collect();
    for region_facts in &facts {
        fresh = fresh.max(region_facts.max_id);
    }
    let Some(mut fresh) = fresh.checked_add(1) else {
        return 0;
    };
    let mut count = 0;
    for ((body, name), facts) in regions.into_iter().zip(facts) {
        count += rewrite_region(body, &facts, &mut fresh, diag, &name);
    }
    if diag {
        eprintln!(
            "[segments-project] REWROTE {count} site(s) in module {}",
            module.name
        );
    }
    count
}

#[cfg(test)]
#[path = "segments_project_tests.rs"]
mod tests;
