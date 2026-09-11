#!/usr/bin/env python3
"""Conservative static allocation-to-barrier coverage, never an elision proof.

No memory-load alias recovery, no pointer arithmetic, and all CFG joins kill
facts. A fact means only an exact allocation return with no intervening call
classified as possibly collecting. The allocation may already be old/published.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

NAME = r'(?:[-A-Za-z$._0-9]+|"[^"\n]+")'
VALUE = r'%(?:[-A-Za-z$._0-9]+|"[^"\n]+")'
LABEL = re.compile(r'^(' + NAME + r'):\s*(?:;.*)?$')
RESULT = re.compile(r'^(' + VALUE + r')\s*=\s*(.*)$')
CALL = re.compile(r'\b(call|invoke|callbr)\b')
TARGET = re.compile(r'([@%]' + NAME + r')\s*\(')

# Exact user-pointer returns inspected in runtime object/alloc.rs,
# array/alloc.rs and closure/alloc.rs. Singletons, constructors returning an
# input, inline allocator state and raw-header returns are deliberately absent.
ALLOCATORS = {
    'js_object_alloc', 'js_object_alloc_null_proto',
    'js_object_alloc_with_parent', 'js_object_alloc_fast',
    'js_object_alloc_fast_with_parent', 'js_object_alloc_with_shape',
    'js_object_alloc_class_with_keys', 'js_object_alloc_class_inline_keys',
    'js_object_alloc_class_inline_keys_stamped',
    'js_array_alloc', 'js_array_alloc_with_length', 'js_array_alloc_literal',
    'js_closure_alloc', 'js_closure_alloc_init',
}
BARRIERS = {
    'js_write_barrier', 'js_write_barrier_slot',
    'js_write_barrier_slot_validated_parent',
}
# These exact exports are already CannotCollect in gc_call_effects.rs.
# This is not a substitute for that table: other helpers need an explicit
# CannotCollect-only summary, or a separately counted extra-leaf hypothesis.
BOOKKEEPING = BARRIERS | {
    'js_gc_note_slot_layout', 'js_gc_note_slot_layout_aware',
    'js_string_addref', 'js_string_addref_if_heap_string',
    'js_write_barrier_root_nanbox', 'js_write_barrier_root_heap_word',
}


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def clean_name(name):
    return name.strip('"')


def parse(ir):
    """Accept LLVM's ordinary printer dialect; reject unsupported CFG shapes."""
    groups = {m[1] for m in re.finditer(
        r'^attributes\s+#(\d+)\s*=\s*\{[^\n]*"gc-leaf-function"[^\n]*\}',
        ir, re.M)}
    declaration_leaves = set()
    for line in ir.splitlines():
        if line.startswith('declare '):
            m = TARGET.search(line)
            if m and ('"gc-leaf-function"' in line or
                      groups.intersection(re.findall(r'#(\d+)', line))):
                declaration_leaves.add(clean_name(m[1][1:]))
    functions = []
    current = None
    pending = ''
    for lineno, raw in enumerate(ir.splitlines(), 1):
        line = raw.strip()
        if current is None:
            if not line.startswith('define '):
                continue
            m = TARGET.search(line)
            if not m or not line.endswith('{'):
                raise ValueError(f'unsupported function header at line {lineno}')
            current = {'name': clean_name(m[1][1:]), 'blocks': {}, 'errors': []}
            block = 'entry.unlabeled'
            current['blocks'][block] = []
            continue
        if not line or line.startswith(';'):
            continue
        if line == '}':
            if pending:
                current['errors'].append('unterminated multiline instruction')
            if not current['blocks']['entry.unlabeled'] and len(current['blocks']) > 1:
                del current['blocks']['entry.unlabeled']
            functions.append(current)
            current = None
            pending = ''
            continue
        label = LABEL.fullmatch(line)
        if label and not pending:
            block = clean_name(label[1])
            current['blocks'][block] = []
            continue
        # Normal LLVM output wraps invoke destinations and switch tables.
        pending = (pending + ' ' + line).strip()
        balanced = pending.count('(') == pending.count(')') and pending.count('[') == pending.count(']')
        if not balanced or ('invoke ' in pending and ' unwind label ' not in pending):
            continue
        current['blocks'][block].append((lineno, pending))
        pending = ''
    if current is not None:
        raise ValueError('unterminated function')
    return functions, groups, declaration_leaves


def call_info(text):
    cm = CALL.search(text)
    if not cm:
        return None
    target = TARGET.search(text, cm.end())
    if not target:
        return cm[1], None, None
    token = target[1]
    # A constant-expression callee is outside this parser's accepted subset.
    between = text[cm.end():target.start()]
    if re.search(r'\b(bitcast|inttoptr|asm)\b', between):
        return cm[1], None, None
    name = clean_name(token[1:]) if token.startswith('@') else None
    args = text[target.end():]
    # First argument of all admitted barrier ABIs is an integer parent.
    first = re.match(r'\s*i64\s+(' + VALUE + r'|[-0-9]+)\s*[,)]', args)
    return cm[1], name, first[1] if first else None


def analyze_function(fn, groups, declaration_leaves, extra_leaves, noncollecting):
    blocks = fn['blocks']
    if not blocks:
        return {'function': fn['name'], 'excluded': ['empty function']}
    successors = {}
    predecessors = {b: set() for b in blocks}
    for b, instructions in blocks.items():
        end = instructions[-1][1] if instructions else ''
        if re.match(r'(ret\b|resume\b|unreachable\b)', end):
            successors[b] = []
        elif re.match(r'(br\b|switch\b)', end) or re.search(r'\binvoke\b', end):
            successors[b] = [clean_name(x) for x in re.findall(r'\blabel\s+%(' + NAME + ')', end)]
            if not successors[b]:
                fn['errors'].append(f'missing CFG successors: {b}')
        else:
            fn['errors'].append(f'unsupported terminator in {b}: {end[:100]}')
        for dest in successors.get(b, []):
            if dest not in blocks:
                fn['errors'].append(f'unknown destination {dest}')
            else:
                predecessors[dest].add(b)
    if fn['errors']:
        return {'function': fn['name'], 'excluded': fn['errors']}
    entry = next(iter(blocks))
    reachable = {entry}
    todo = [entry]
    while todo:
        for dest in successors[todo.pop()]:
            if dest not in reachable:
                reachable.add(dest)
                todo.append(dest)

    def transfer(b, state, record=False):
        state = dict(state)
        rows = []
        for line, text in blocks[b]:
            result = RESULT.match(text)
            lhs, op = result.groups() if result else (None, text)
            call = call_info(op)
            if call:
                kind, callee, parent = call
                fact = state.get(parent)
                if record and callee in BARRIERS:
                    rows.append({'line': line, 'block': b, 'callee': callee,
                                 'parent': parent, 'allocation_origin': fact,
                                 'direct_explicit_barrier': True})
                # A statepoint exemption is not necessarily no collection:
                # AllocNoReentry under SAFEPOINT_ONLY also gets gc-leaf but
                # permits the conservative allocation valve. Leaf attributes
                # alone therefore never establish freshness in this census.
                leaf = callee in BOOKKEEPING or callee in noncollecting or callee in extra_leaves
                if callee in ALLOCATORS:
                    leaf = False
                if not leaf:
                    state.clear()
                # Invoke results exist only on the normal edge. Exclude both
                # edges here rather than leak an allocation fact into unwind.
                if lhs and kind == 'call' and callee in ALLOCATORS:
                    state[lhs] = f'{fn["name"]}:{line}:{callee}'
                elif lhs:
                    state.pop(lhs, None)
            elif lhs:
                alias = re.match(r'(?:bitcast|ptrtoint|inttoptr)\s+.*?(' + VALUE + r')\s+to\s+', op)
                if alias and alias[1] in state:
                    state[lhs] = state[alias[1]]
                else:
                    # phi/select/gep/load/arithmetic require extra proof.
                    state.pop(lhs, None)
        return state, rows

    outputs = {b: {} for b in reachable}
    # Joins and loop headers deliberately kill freshness, even if all inputs
    # appear equal. Single-predecessor chains still propagate real identities.
    for _ in range(len(blocks) + 1):
        changed = False
        for b in blocks:
            if b not in reachable:
                continue
            pred = predecessors[b] & reachable
            incoming = outputs[next(iter(pred))] if len(pred) == 1 and b != entry else {}
            out, _ = transfer(b, incoming)
            if out != outputs[b]:
                outputs[b] = out
                changed = True
        if not changed:
            break
    else:
        return {'function': fn['name'], 'excluded': ['dataflow did not converge']}
    rows = []
    for b in blocks:
        if b not in reachable:
            continue
        pred = predecessors[b] & reachable
        incoming = outputs[next(iter(pred))] if len(pred) == 1 and b != entry else {}
        rows.extend(transfer(b, incoming, True)[1])
    return {'function': fn['name'], 'barriers': rows,
            'reachable_blocks': len(reachable),
            'join_blocks_killing_facts': sum(len(predecessors[b] & reachable) > 1 for b in reachable)}


def analyze(ir, extra=(), noncollecting=()):
    functions, groups, declared = parse(ir)
    strict = [analyze_function(f, groups, declared, set(), set(noncollecting)) for f in functions]
    hypothetical = [analyze_function(f, groups, declared, set(extra), set(noncollecting)) for f in functions]
    def rows(result):
        return {(f['function'], b['line']): b for f in result
                for b in f.get('barriers', [])}
    sr, hr = rows(strict), rows(hypothetical)
    strict_hits = [b for b in sr.values() if b['allocation_origin']]
    extra_hits = [b for k, b in hr.items() if b['allocation_origin'] and
                  not sr.get(k, {}).get('allocation_origin')]
    return {'schema': 1, 'measurement': 'static syntactic sites, not executions or saved CPU',
            'allocation_generation': 'unknown: fresh return may be old or published',
            'layout_incremental_string_sharing_elision_claim': False,
            'strict_barrier_sites': len(sr), 'strict_fresh_origin_sites': len(strict_hits),
            'extra_leaf_fresh_origin_sites': len(extra_hits),
            'strict_hits': strict_hits, 'extra_leaf_hits': extra_hits,
            'extra_leaf_hypotheses': sorted(extra), 'functions': strict,
            'explicit_noncollecting_summaries': sorted(noncollecting),
            'allocation_summaries': sorted(ALLOCATORS),
            'limitations': ['all joins kill facts', 'loads/phi/select/gep/tag arithmetic are not aliases',
                            'allocating invoke results excluded',
                            'only direct explicit barrier calls counted; hidden helper stores excluded',
                            'complete backend emission is not object/link identity']}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--ir', type=Path, required=True)
    ap.add_argument('--attempt-dir', type=Path)
    ap.add_argument('--extra-leaves', type=Path, help='JSON list of hypothetical callee names')
    ap.add_argument('--noncollecting-callees', type=Path,
                    help='JSON list of independently audited CannotCollect names; not AllocNoReentry')
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    if args.attempt_dir:
        for filename in ('attempt.json', 'complete.json'):
            json.loads((args.attempt_dir / filename).read_text())
        if args.ir.resolve().parent != args.attempt_dir.resolve():
            ap.error('IR must be in the supplied completed attempt directory')
    extra = json.loads(args.extra_leaves.read_text()) if args.extra_leaves else []
    if not isinstance(extra, list) or not all(isinstance(x, str) for x in extra):
        ap.error('extra-leaves must be a JSON list of names')
    leaves = json.loads(args.noncollecting_callees.read_text()) if args.noncollecting_callees else []
    if not isinstance(leaves, list) or not all(isinstance(x, str) for x in leaves):
        ap.error('noncollecting-callees must be a JSON list of names')
    result = analyze(args.ir.read_text(), extra, leaves)
    result['input'] = {'path': str(args.ir), 'sha256': digest(args.ir),
                       'completed_attempt_checked': bool(args.attempt_dir)}
    result['summary_inputs'] = {str(p): digest(p) for p in
                               (args.extra_leaves, args.noncollecting_callees) if p}
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('strict_barrier_sites', 'strict_fresh_origin_sites',
                                          'extra_leaf_fresh_origin_sites')}))
    return 2 if any('excluded' in f for f in result['functions']) else 0


if __name__ == '__main__':
    sys.exit(main())
