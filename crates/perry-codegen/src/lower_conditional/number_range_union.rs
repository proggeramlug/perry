//! Closed constant comparison unions over one ordinary local.
//!
//! Raw Numbers use derived bounds and a balanced interval tree. Other values
//! keep the original ordered comparisons, including every coercion callback.

use anyhow::Result;
use perry_hir::{CompareOp, Expr, LogicalOp};

use crate::expr::{lower_expr, FnCtx};
use crate::types::{I1, I64};

use super::lower_expr_with_truthy;

#[derive(Clone, Copy)]
struct Interval {
    low: f64,
    high: f64,
}

fn literal(expr: &Expr) -> Option<f64> {
    let value = match expr {
        Expr::Number(value) => *value,
        Expr::Integer(value) => *value as f64,
        _ => return None,
    };
    value.is_finite().then_some(value)
}

/// Normalize the operand order without evaluating either operand.
fn comparison(expr: &Expr) -> Option<(u32, CompareOp, f64)> {
    let Expr::Compare { op, left, right } = expr else {
        return None;
    };
    match (left.as_ref(), right.as_ref()) {
        (Expr::LocalGet(id), constant) => Some((*id, *op, literal(constant)?)),
        (constant, Expr::LocalGet(id)) => {
            let reversed = match op {
                CompareOp::Eq => CompareOp::Eq,
                CompareOp::Ge => CompareOp::Le,
                CompareOp::Le => CompareOp::Ge,
                _ => return None,
            };
            Some((*id, reversed, literal(constant)?))
        }
        _ => None,
    }
}

fn collect(
    expr: &Expr,
    local: &mut Option<u32>,
    intervals: &mut Vec<Interval>,
    comparisons: &mut usize,
) -> Option<()> {
    if let Expr::Logical { op: LogicalOp::Or, left, right } = expr {
        collect(left, local, intervals, comparisons)?;
        return collect(right, local, intervals, comparisons);
    }
    let (id, low, high, count) = match expr {
        Expr::Compare { .. } => {
            let (id, CompareOp::Eq, value) = comparison(expr)? else {
                return None;
            };
            (id, value, value, 1)
        }
        Expr::Logical { op: LogicalOp::And, left, right } => {
            let (a, first_op, first) = comparison(left)?;
            let (b, second_op, second) = comparison(right)?;
            if a != b {
                return None;
            }
            match (first_op, second_op) {
                (CompareOp::Ge, CompareOp::Le) => (a, first, second, 2),
                (CompareOp::Le, CompareOp::Ge) => (a, second, first, 2),
                _ => return None,
            }
        }
        _ => return None,
    };
    if local.is_some_and(|previous| previous != id) {
        return None;
    }
    *local = Some(id);
    *comparisons += count;
    if low <= high {
        intervals.push(Interval { low, high });
    }
    Some(())
}

/// Emit only comparison leaves through ordinary lowering; retain the source
/// short-circuit order without recursively re-entering this optimization.
fn emit_original(
    ctx: &mut FnCtx<'_>,
    expr: &Expr,
    yes: &str,
    no: &str,
) -> Result<()> {
    match expr {
        Expr::Logical { op: LogicalOp::Or, left, right } => {
            let next = ctx.new_block("range.original.or");
            let next_label = ctx.block_label(next);
            emit_original(ctx, left, yes, &next_label)?;
            ctx.current_block = next;
            emit_original(ctx, right, yes, no)
        }
        Expr::Logical { op: LogicalOp::And, left, right } => {
            let next = ctx.new_block("range.original.and");
            let next_label = ctx.block_label(next);
            emit_original(ctx, left, &next_label, no)?;
            ctx.current_block = next;
            emit_original(ctx, right, yes, no)
        }
        Expr::Compare { .. } => {
            let (_, truthy) = lower_expr_with_truthy(ctx, expr)?;
            ctx.block().cond_br(&truthy, yes, no);
            Ok(())
        }
        _ => unreachable!("collect admitted only comparisons and Boolean chains"),
    }
}

fn emit_tree(
    ctx: &mut FnCtx<'_>,
    value: &str,
    intervals: &[Interval],
    yes: &str,
    no: &str,
) {
    let middle = intervals.len() / 2;
    let interval = intervals[middle];
    let left = (middle != 0).then(|| ctx.new_block("range.left"));
    let right = (middle + 1 < intervals.len()).then(|| ctx.new_block("range.right"));
    let upper = ctx.new_block("range.upper");
    let left_label = left.map(|block| ctx.block_label(block)).unwrap_or_else(|| no.to_owned());
    let right_label = right.map(|block| ctx.block_label(block)).unwrap_or_else(|| no.to_owned());
    let upper_label = ctx.block_label(upper);

    let low = crate::nanbox::double_literal(interval.low);
    let below = ctx.block().fcmp("olt", value, &low);
    ctx.block().cond_br(&below, &left_label, &upper_label);
    ctx.current_block = upper;
    let high = crate::nanbox::double_literal(interval.high);
    let inside = ctx.block().fcmp("ole", value, &high);
    ctx.block().cond_br(&inside, yes, &right_label);

    if let Some(left) = left {
        ctx.current_block = left;
        emit_tree(ctx, value, &intervals[..middle], yes, no);
    }
    if let Some(right) = right {
        ctx.current_block = right;
        emit_tree(ctx, value, &intervals[middle + 1..], yes, no);
    }
}

pub(super) fn try_lower(
    ctx: &mut FnCtx<'_>,
    op: LogicalOp,
    left: &Expr,
    right: &Expr,
) -> Result<Option<String>> {
    if op != LogicalOp::Or {
        return Ok(None);
    }
    let mut local = None;
    let mut intervals = Vec::new();
    let mut comparisons = 0usize;
    if collect(left, &mut local, &mut intervals, &mut comparisons).is_none()
        || collect(right, &mut local, &mut intervals, &mut comparisons).is_none()
        || intervals.is_empty()
    {
        return Ok(None);
    }
    let id = local.expect("nonempty interval union has a local");
    // Restrict the once-read guard to ordinary local storage. Captures,
    // variable boxes, globals and materialized records retain existing code.
    if !ctx.locals.contains_key(&id)
        || ctx.closure_captures.contains_key(&id)
        || ctx.boxed_vars.contains(&id)
        || ctx.module_globals.contains_key(&id)
        || ctx.pod_records.contains_key(&id)
    {
        return Ok(None);
    }
    intervals.sort_by(|a, b| a.low.total_cmp(&b.low));
    let mut merged: Vec<Interval> = Vec::with_capacity(intervals.len());
    for interval in intervals {
        if let Some(previous) = merged.last_mut() {
            if interval.low <= previous.high {
                previous.high = previous.high.max(interval.high);
                continue;
            }
        }
        // Do not join adjacent integer endpoints: fractions between them
        // are real Number inputs and must preserve the original gap.
        merged.push(interval);
    }
    // A structural code-size/probe-cost gate, derived from the tree depth:
    // two tag comparisons, two outer bounds, and two comparisons per level.
    let depth = (usize::BITS - merged.len().leading_zeros()) as usize;
    if comparisons <= 4 + 2 * depth {
        return Ok(None);
    }

    let value = lower_expr(ctx, &Expr::LocalGet(id))?;
    let is_number = crate::stmt::emit_js_value_is_number(ctx, &value);
    let bounds = ctx.new_block("range.bounds");
    let tree = ctx.new_block("range.tree");
    let original = ctx.new_block("range.original");
    let yes = ctx.new_block("range.yes");
    let no = ctx.new_block("range.no");
    let merge = ctx.new_block("range.merge");
    let bounds_label = ctx.block_label(bounds);
    let tree_label = ctx.block_label(tree);
    let original_label = ctx.block_label(original);
    let yes_label = ctx.block_label(yes);
    let no_label = ctx.block_label(no);
    let merge_label = ctx.block_label(merge);
    ctx.block().cond_br(&is_number, &bounds_label, &original_label);

    ctx.current_block = bounds;
    let low = crate::nanbox::double_literal(merged[0].low);
    let high = crate::nanbox::double_literal(merged.last().unwrap().high);
    let above_low = ctx.block().fcmp("oge", &value, &low);
    let below_high = ctx.block().fcmp("ole", &value, &high);
    let in_bounds = ctx.block().and(I1, &above_low, &below_high);
    ctx.block().cond_br(&in_bounds, &tree_label, &no_label);
    ctx.current_block = tree;
    emit_tree(ctx, &value, &merged, &yes_label, &no_label);

    ctx.current_block = original;
    let original_right = ctx.new_block("range.original.right");
    let original_right_label = ctx.block_label(original_right);
    emit_original(ctx, left, &yes_label, &original_right_label)?;
    ctx.current_block = original_right;
    emit_original(ctx, right, &yes_label, &no_label)?;

    ctx.current_block = yes;
    ctx.block().br(&merge_label);
    ctx.current_block = no;
    ctx.block().br(&merge_label);
    ctx.current_block = merge;
    let truthy = ctx.block().phi(I1, &[("true", &yes_label), ("false", &no_label)]);
    let bits = ctx.block().select(
        I1,
        &truthy,
        I64,
        crate::nanbox::TAG_TRUE_I64,
        crate::nanbox::TAG_FALSE_I64,
    );
    let result = ctx.block().bitcast_i64_to_double(&bits);
    if ctx.truthy_call_result_requested {
        ctx.pending_truthy_call_result = Some((result.clone(), truthy));
    }
    Ok(Some(result))
}
