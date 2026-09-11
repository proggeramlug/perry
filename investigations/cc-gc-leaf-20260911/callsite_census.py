#!/usr/bin/env python3
"""Static call/GC census of completed observational LLVM emissions.

No source/binary optimization or dynamic-frequency inference. llvm-dis must
match the producer (LLVM 22). A --text-root mirror may supply stage .ll files,
while original .bc files and completion byte lengths remain authoritative.
"""
import argparse
from collections import Counter, defaultdict
from contextlib import contextmanager
import csv
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

NAME = r'(?:[-a-zA-Z$._0-9]+|"(?:\\[0-9a-fA-F]{2}|[^"\\])*")'
TOKEN = r'[@%]' + NAME
TARGET = re.compile(r'(' + TOKEN + r')\s*\(')
OP = re.compile(r'^(?:(' + '%' + NAME + r')\s*=\s*)?(?:(?:tail|musttail|notail)\s+)?(call|invoke|callbr)\s+')
LABEL = re.compile(r'^(' + NAME + r'):\s*$')
RESULT = re.compile(r'^(' + '%' + NAME + r')\s*=\s*')
STAGES = ('pre-rs4gc', 'post-rs4gc', 'post-opt')
METRICS = ('callsites', 'statepoints', 'leaf_callsites', 'gc_live_operands',
           'gc_relocate_intrinsics', 'relocates_attributed', 'relocates_unattributed')
# Exact callable-dispatch exports from closure/dispatch/{calln,value_call}.rs
# and object/native_call_method.rs. Getter-capable property helpers are not
# literal callable-dispatch wrappers and remain in the runtime category.
DISPATCH_WRAPPERS = frozenset({
    'js_native_call_method', 'js_native_call_method_str_key',
    'js_native_call_method_by_id', 'js_native_call_method_apply_by_id',
    'js_native_call_method_value', 'js_native_call_method_apply',
    'js_native_call_method_value_apply', 'js_native_call_method_nullsafe',
    'js_native_call_value', 'js_closure_call_array',
    'js_closure_call_apply_with_spread', 'js_closure_call1_receiverless',
    'js_closure_call0', 'js_closure_call1', 'js_closure_call2',
    'js_closure_call3', 'js_closure_call4', 'js_closure_call5',
    'js_closure_call6', 'js_closure_call7', 'js_closure_call8',
    'js_closure_call9', 'js_closure_call10', 'js_closure_call11',
    'js_closure_call12', 'js_closure_call13', 'js_closure_call14',
    'js_closure_call15', 'js_closure_call16',
})


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for part in iter(lambda: f.read(1 << 20), b''):
            h.update(part)
    return h.hexdigest()


def name(token):
    value = token[1:] if token.startswith(('@', '%')) else token
    if value.startswith('"'):
        value = value[1:-1]
        decoded, i = bytearray(), 0
        while i < len(value):
            if value[i] == '\\':
                decoded.append(int(value[i + 1:i + 3], 16)); i += 3
            else:
                decoded.extend(value[i].encode('utf-8')); i += 1
        value = decoded.decode('utf-8', errors='surrogateescape')
    return value


def uncomment(line):
    quoted = False
    for i, c in enumerate(line):
        if c == '"':
            quoted = not quoted
        elif c == ';' and not quoted:
            return line[:i].strip()
    return line.strip()


def split_top(text, separator=','):
    """Split LLVM operands, retaining commas in types/constant expressions."""
    stack, parts, start, quoted = [], [], 0, False
    pairs = {')': '(', ']': '[', '}': '{', '>': '<'}
    for i, c in enumerate(text):
        if c == '"':
            quoted = not quoted
        elif not quoted:
            if c in '([{<':
                stack.append(c)
            elif c in ')]}>':
                if not stack or stack.pop() != pairs[c]:
                    raise ValueError('unbalanced operand delimiters')
            elif c == separator and not stack:
                parts.append(text[start:i].strip())
                start = i + 1
    if quoted or stack:
        raise ValueError('unterminated operand/quoted string')
    parts.append(text[start:].strip())
    return parts


def closing_paren(text, opening):
    depth, quoted = 0, False
    for i in range(opening, len(text)):
        c = text[i]
        if c == '"':
            quoted = not quoted
        elif not quoted:
            if c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    return i
    raise ValueError('unterminated call arguments')


def call_parts(text):
    match = OP.match(text)
    if not match:
        raise ValueError('not a call instruction')
    target = TARGET.search(text, match.end())
    if not target or re.search(r'\b(?:asm|inttoptr|bitcast)\b', text[match.end():target.start()]):
        if re.search(r'\basm\b', text[match.end():]):
            # Assembly strings can contain @foo(...); find arguments only
            # after the two quoted asm strings, never inside either string.
            asm = re.search(r'\basm\s+(?:sideeffect\s+)?(?:alignstack\s+)?(?:inteldialect\s+)?"(?:\\[0-9a-fA-F]{2}|[^"\\])*"\s*,\s*"(?:\\[0-9a-fA-F]{2}|[^"\\])*"\s*\(', text[match.end():])
            if not asm:
                raise ValueError('unsupported inline assembly call syntax')
            opening = match.end() + asm.end() - 1
            target_token = '<inline-asm>'
        else:
            raise ValueError('unsupported constant-expression or missing call target')
    else:
        opening, target_token = target.end() - 1, target[1]
    end = closing_paren(text, opening)
    args = split_top(text[opening + 1:end]) if text[opening + 1:end].strip() else []
    return match[1], match[2], target_token, args, text[end + 1:]


def call_complete(text):
    try:
        _, op, _, _, suffix = call_parts(text)
        split_top(suffix)  # also checks operand-bundle delimiters
        if op == 'invoke' and not re.search(r'\bto label\s+%' + NAME + r'\s+unwind label\s+%' + NAME, suffix):
            return False
        if op == 'callbr' and not re.search(r'\bto label\s+%' + NAME + r'\s*\[', suffix):
            return False
        return True
    except ValueError as error:
        if 'unterminated' in str(error):
            return False
        raise


def records(lines):
    """LLVM printer records; only call instructions need multiline assembly."""
    fn, block, pending, first_line = None, None, '', 0
    for lineno, raw in enumerate(lines, 1):
        line = uncomment(raw)
        if not line:
            continue
        if pending:
            pending += ' ' + line
            if call_complete(pending):
                yield ('call', fn, block, first_line, pending)
                pending = ''
            continue
        if fn is None:
            if line.startswith('define '):
                m = TARGET.search(line)
                if not m or not m[1].startswith('@') or not line.endswith('{'):
                    raise ValueError(f'unsupported definition header at line {lineno}')
                fn, block = name(m[1]), '<unlabeled-entry>'
                yield ('define', fn, block, lineno, line)
            elif line.startswith('declare '):
                yield ('declare', None, None, lineno, line)
            elif line.startswith('attributes #'):
                yield ('attributes', None, None, lineno, line)
            elif line.startswith('@') and re.search(r'(?<![%@A-Za-z0-9_.-])alias\b', re.sub(r'"(?:\\[0-9a-fA-F]{2}|[^"\\])*"', '""', line)):
                yield ('alias', None, None, lineno, line)
            continue
        if line == '}':
            yield ('end', fn, block, lineno, line)
            fn, block = None, None
        elif LABEL.match(line):
            block = name(LABEL.match(line)[1])
            yield ('block', fn, block, lineno, line)
        elif OP.match(line):
            if call_complete(line):
                yield ('call', fn, block, lineno, line)
            else:
                pending, first_line = line, lineno
        elif re.search(r'=\s*landingpad\s+token\b', line):
            yield ('landingpad', fn, block, lineno, line)
    if pending or fn is not None:
        raise ValueError('truncated LLVM function or call instruction')


def attr_refs(text):
    # Quoted strings and metadata do not confer call attributes.
    unquoted = re.sub(r'"(?:\\[0-9a-fA-F]{2}|[^"\\])*"', '""', text)
    return set(re.findall(r'#(\d+)\b', unquoted))


def leaf_attr(text, groups):
    refs = attr_refs(text)
    missing = refs - groups.keys()
    if missing:
        raise ValueError('missing attribute groups: ' + ','.join(sorted(missing)))
    return '"gc-leaf-function"' in text or any('"gc-leaf-function"' in groups[r] for r in refs)


def header_leaf(header, groups):
    if not header:
        return False
    target = TARGET.search(header)
    if not target:
        raise ValueError('missing function header target')
    return leaf_attr(header[closing_paren(header, target.end() - 1) + 1:], groups)


def local_linkage(header):
    return bool(re.match(r'define\s+(?:dso_local\s+)?(?:internal|private)\b', header))


def function_id(unit, symbol):
    return unit + '::' + symbol


def value_token(operand):
    """A typed pointer/token operand with a direct global or SSA value."""
    # Names within elementtype(...) precede the final operand and are not
    # selected. Constant-expression callees are deliberately not guessed.
    m = re.search(r'(' + TOKEN + r')\s*$', operand)
    if not m:
        raise ValueError('unsupported pointer/token operand: ' + operand[:100])
    prefix = operand[:m.start()]
    if re.search(r'\b(?:bitcast|inttoptr|select|blockaddress)\b', prefix):
        raise ValueError('unsupported constant-expression callee/token')
    return m[1]


def inventory(lines):
    result = {'definitions': {}, 'groups': {}, 'declarations': {}, 'aliases': {}, 'shadow': set()}
    for kind, fn, block, lineno, text in records(lines):
        if kind == 'define':
            if fn in result['definitions']:
                raise ValueError('duplicate function definition: ' + fn)
            result['definitions'][fn] = text
        elif kind == 'declare':
            m = TARGET.search(text)
            if not m:
                raise ValueError('unsupported declaration')
            result['declarations'][name(m[1])] = text
        elif kind == 'attributes':
            m = re.fullmatch(r'attributes #(\d+) = (\{.*\})', text)
            if not m or m[1] in result['groups']:
                raise ValueError('invalid/duplicate attribute group')
            result['groups'][m[1]] = m[2]
        elif kind == 'alias':
            m = re.match(r'(@' + NAME + r')\s*=.*?\balias\s+(.*)$', text)
            if not m:
                raise ValueError('unsupported global alias')
            parts = split_top(m[2])
            target = value_token(parts[-1])
            if not target.startswith('@'):
                raise ValueError('alias target is not direct')
            result['aliases'][name(m[1])] = name(target)
        elif kind == 'call':
            target = call_parts(text)[2]
            if target.startswith('@js_shadow_'):
                result['shadow'].add(fn)
    # Attribute definitions appear after functions in ordinary LLVM output.
    for decl in list(result['definitions'].values()) + list(result['declarations'].values()):
        header_leaf(decl, result['groups'])
    return result


def resolve_alias(symbol, aliases):
    seen = set()
    while symbol in aliases:
        if symbol in seen:
            raise ValueError('cyclic global alias: ' + symbol)
        seen.add(symbol)
        symbol = aliases[symbol]
    return symbol


def root_kind(fn, pre):
    if fn not in pre['definitions']:
        return 'post-created-unclassified'
    header = pre['definitions'][fn]
    if 'gc "statepoint-example"' in header:
        return 'native'
    return 'shadow-observed' if fn in pre['shadow'] else 'no-root-mechanism-observed'


def classify(token, all_definitions, audit, aliases, nonruntime=frozenset(), local_definitions=None, unit='<fixture>'):
    if token == '<inline-asm>':
        return 'inline-asm', token
    if token.startswith('%'):
        return 'dynamic-dispatch', '<indirect>'
    if not token.startswith('@'):
        raise ValueError('unclassified call target ' + token)
    symbol = resolve_alias(name(token), aliases)
    if symbol.startswith('llvm.'):
        return 'LLVM', symbol
    if local_definitions and symbol in local_definitions:
        identity = function_id(unit, symbol) if local_linkage(local_definitions[symbol]) else symbol
        return 'static-user', identity
    if symbol in all_definitions:
        return 'static-user', symbol
    if audit.get(symbol, {}).get('runtime_locations'):
        if symbol in DISPATCH_WRAPPERS:
            return 'dynamic-dispatch', symbol
        return 'runtime', symbol
    if symbol in nonruntime:
        return 'nonruntime-external', symbol
    # Missing runtime source identity is not proof of a non-runtime symbol.
    return 'external-unclassified', symbol


def gc_live(suffix):
    matches = list(re.finditer(r'"gc-live"\s*\(', suffix))
    if len(matches) > 1:
        raise ValueError('multiple gc-live bundles on one statepoint')
    if not matches:
        return 0
    opening = matches[0].end() - 1
    end = closing_paren(suffix, opening)
    values = suffix[opening + 1:end].strip()
    return len(split_top(values)) if values else 0


def function_counts(lines, inv, pre, all_definitions, audit, nonruntime=frozenset()):
    """Yield sparse block/callee metrics, bounded in memory to one function."""
    rows, statepoints, unwind, relocates, landingpads = None, {}, defaultdict(set), [], {}
    for kind, fn, block, lineno, text in records(lines):
        if kind == 'define':
            rows, statepoints, unwind, relocates, landingpads = defaultdict(Counter), {}, defaultdict(set), [], {}
        elif kind == 'landingpad':
            landingpads[RESULT.match(text)[1]] = block
        elif kind == 'call':
            result, op, target, args, suffix = call_parts(text)
            category, callee = classify(target, all_definitions, audit, inv['aliases'], nonruntime, inv['definitions'], inv.get('unit', '<fixture>'))
            is_statepoint = category == 'LLVM' and callee.startswith('llvm.experimental.gc.statepoint.')
            if is_statepoint:
                if len(args) < 5 or not re.fullmatch(r'i64\s+-?\d+', args[0]) or not re.fullmatch(r'i32\s+\d+', args[1]):
                    raise ValueError(f'malformed statepoint at {fn}:{block}:{lineno}')
                category, callee = classify(value_token(args[2]), all_definitions, audit, inv['aliases'], nonruntime, inv['definitions'], inv.get('unit', '<fixture>'))
                if result is None or result in statepoints:
                    raise ValueError('missing/duplicate statepoint result')
                statepoints[result] = (category, callee)
                dest = re.search(r'\bunwind label\s+(%' + NAME + r')', suffix)
                if dest:
                    unwind[name(dest[1])].add(result)
            key = (fn, block, root_kind(fn, pre), category, callee)
            rows[key]['callsites'] += 1
            rows[key]['statepoints'] += int(is_statepoint)
            if is_statepoint:
                rows[key]['gc_live_operands'] += gc_live(suffix)
            else:
                raw_symbol = resolve_alias(name(target), inv['aliases']) if target.startswith('@') else None
                declaration = inv['declarations'].get(raw_symbol, inv['definitions'].get(raw_symbol, ''))
                rows[key]['leaf_callsites'] += int(leaf_attr(suffix, inv['groups']) or header_leaf(declaration, inv['groups']))
            if category == 'LLVM' and callee.startswith('llvm.experimental.gc.relocate.'):
                if len(args) != 3:
                    raise ValueError('malformed gc.relocate operand count')
                rows[key]['gc_relocate_intrinsics'] += 1
                relocates.append((key, value_token(args[0])))
        elif kind == 'end':
            for original_key, token in relocates:
                if token in statepoints:
                    candidates = {token}
                elif token in landingpads and landingpads[token] in unwind:
                    candidates = unwind[landingpads[token]]
                else:
                    raise ValueError(f'unresolved gc.relocate token in {fn}: {token}')
                callees = {statepoints[t] for t in candidates}
                if len(callees) == 1:
                    category, callee = next(iter(callees))
                    key = original_key[:3] + (category, callee)
                    rows[key]['relocates_attributed'] += 1
                else:
                    rows[original_key]['relocates_unattributed'] += 1
            yield fn, rows


def reviewed_extra(row):
    return (row.get('audit_status') == 'reviewed' and row.get('current_effect') == 'Unknown'
            and row.get('may_collect') == 'no' and row.get('may_reenter_js') == 'no')


def visible_definitions(pre_units):
    visible = defaultdict(list)
    for unit, inv in pre_units.items():
        for symbol, header in inv['definitions'].items():
            if not local_linkage(header) and not re.match(r'define\s+available_externally\b', header):
                visible[symbol].append(function_id(unit, symbol))
    return visible


def resolve_function(unit, symbol, pre_units, visible, cross_unit):
    if symbol in pre_units[unit]['definitions']:
        return function_id(unit, symbol)
    candidates = visible.get(symbol, [])
    return candidates[0] if cross_unit and len(candidates) == 1 else None


def effect_graph(lines, unit, inv, audit, pre_units, visible, cross_unit):
    """Actual pre-IR edges, with local symbol scope retained explicitly."""
    effects = {}
    for kind, fn, block, lineno, text in records(lines):
        if kind == 'define':
            effects[function_id(unit, fn)] = {'edges': set(), 'base_blocked': False,
                'extra_blocked': False, 'reasons': set()}
        elif kind == 'call':
            effect = effects[function_id(unit, fn)]
            _, _, token, _, suffix = call_parts(text)
            symbol = resolve_alias(name(token), inv['aliases']) if token.startswith('@') else None
            declaration = inv['declarations'].get(symbol, inv['definitions'].get(symbol, ''))
            if leaf_attr(suffix, inv['groups']) or header_leaf(declaration, inv['groups']):
                continue
            if symbol and symbol.startswith('llvm.'):
                if symbol.startswith('llvm.experimental.gc.statepoint.'):
                    raise ValueError('pre-RS4GC graph unexpectedly already contains a statepoint')
                continue
            target = resolve_function(unit, symbol, pre_units, visible, cross_unit) if symbol else None
            if target:
                effect['edges'].add(target)
                continue
            row = audit.get(symbol, {})
            if row.get('current_effect') == 'CannotCollect':
                continue
            effect['base_blocked'] = True
            if not reviewed_extra(row):
                effect['extra_blocked'] = True
                if symbol and symbol in visible and len(visible[symbol]) > 1:
                    reason = 'ambiguous-visible-definition:' + symbol
                elif symbol and symbol in visible:
                    reason = 'outside-unit:' + symbol
                else:
                    reason = 'unproven:' + (symbol or token)
                effect['reasons'].add(reason)
    return effects


def proven_functions(graph, blocked_field):
    blocked = {fn for fn, e in graph.items() if e[blocked_field]}
    callers = defaultdict(set)
    for fn, effect in graph.items():
        for target in effect['edges']:
            if target not in graph:
                raise ValueError('unresolved graph edge: ' + target)
            callers[target].add(fn)
    pending = list(blocked)
    while pending:
        for caller in callers[pending.pop()]:
            if caller not in blocked:
                blocked.add(caller); pending.append(caller)
    return set(graph) - blocked


def statepoint_opportunities(lines, unit, inv, pre_units, visible, newly_local, newly_global, audit,
                            existing_global=frozenset(), full_global=frozenset()):
    """Per-function post-opt sites; hypothesis arms overlap and are not added."""
    counts = defaultdict(Counter)
    for kind, fn, block, lineno, text in records(lines):
        if kind != 'call':
            continue
        _, _, token, args, suffix = call_parts(text)
        if not token.startswith('@llvm.experimental.gc.statepoint.'):
            continue
        target_token = value_token(args[2])
        if not target_token.startswith('@'):
            continue
        symbol = resolve_alias(name(target_token), inv['aliases'])
        target = resolve_function(unit, symbol, pre_units, visible, True)
        # Local helpers introduced by optimization have no pre-definition
        # identity; do not match their name to an unrelated global definition.
        if symbol in inv['definitions'] and symbol not in pre_units[unit]['definitions']:
            target = None
        groups = []
        local_target = resolve_function(unit, symbol, pre_units, visible, False)
        if local_target in newly_local:
            groups.append(('new-local-user', target))
        if target in newly_global:
            groups.append(('new-unique-visible-user', target))
        if target in existing_global:
            groups.append(('existing-proof-user', target))
        if target in full_global:
            groups.append(('full-unique-visible-user', target))
        if target is None and reviewed_extra(audit.get(symbol, {})):
            groups.append(('direct-reviewed-runtime', symbol))
        for key in groups:
            counts[key + (unit, fn)]['statepoints'] += 1
            counts[key + (unit, fn)]['gc_live_operands'] += gc_live(suffix)
    return counts


@contextmanager
def llvm_lines(path, llvm_dis, text_root=None):
    mirror = text_root / path.parent.name / (path.stem + '.ll') if text_root else None
    if mirror is not None:
        if not mirror.is_file():
            raise ValueError('missing converted IR mirror: ' + str(mirror))
        with mirror.open(encoding='utf-8') as source:
            yield source
        return
    # stderr goes to a temporary file to avoid deadlock on an error stream;
    # only the final 4 KiB of a tool failure is reported.
    with tempfile.TemporaryFile(mode='w+t') as errors:
        process = subprocess.Popen([llvm_dis, str(path), '-o', '-'], stdout=subprocess.PIPE,
                                   stderr=errors, text=True, encoding='utf-8')
        try:
            yield process.stdout
        except BaseException:
            process.stdout.close()
            process.terminate()
            process.wait()
            raise
        else:
            process.stdout.close()
            status = process.wait()
            if status:
                errors.seek(0, 2)
                size = errors.tell()
                errors.seek(max(0, size - 4096))
                raise ValueError(f'llvm-dis exited {status}: {errors.read()}')


def read_attempts(root):
    accepted, abandoned = [], []
    directories = sorted(p for p in root.iterdir() if p.is_dir())
    if not directories:
        raise ValueError('no capture attempt directories')
    for directory in directories:
        if not re.fullmatch(r'pid-\d+-attempt-\d+', directory.name):
            raise ValueError('unexpected directory in capture root: ' + directory.name)
        if not (directory / 'complete.json').exists():
            abandoned.append({'attempt': directory.name, 'status': 'incomplete-unavailable',
                              'present_files': sorted(p.name for p in directory.iterdir())})
            continue
        meta = json.loads((directory / 'attempt.json').read_text())
        complete = json.loads((directory / 'complete.json').read_text())
        if meta.get('schema') != 1 or complete.get('schema') != 1 or complete.get('status') != 'llvm-emission-succeeded':
            raise ValueError('unsupported/invalid completion schema: ' + directory.name)
        if directory.name != f"pid-{meta['pid']}-attempt-{meta['attempt']}" or meta.get('snapshot_format') != 'llvm-bitcode':
            raise ValueError('invalid attempt identity/format')
        if not isinstance(meta.get('native_roots_requested'), bool):
            raise ValueError('missing native-root mode')
        if (type(meta.get('pid')) is not int or meta['pid'] <= 0 or type(meta.get('attempt')) is not int or meta['attempt'] < 0
                or meta.get('emission') not in ('object', 'assembly')
                or type(complete.get('emitted_bytes')) is not int or complete['emitted_bytes'] <= 0
                or type(complete.get('bounded_o0_machine_emission')) is not bool):
            raise ValueError('missing/invalid emission completion identity')
        snapshots = complete.get('snapshots', [])
        if [s.get('file') for s in snapshots] != [s + '.bc' for s in STAGES]:
            raise ValueError('missing/reordered snapshot stages')
        for snapshot in snapshots:
            path = directory / snapshot['file']
            if not path.is_file() or path.stat().st_size != snapshot.get('bytes'):
                raise ValueError('snapshot missing or length mismatch: ' + str(path))
            snapshot['sha256'] = sha(path)
        accepted.append({'directory': directory, 'metadata': meta, 'completion': complete,
                         'attempt_json_sha256': sha(directory / 'attempt.json'),
                         'complete_json_sha256': sha(directory / 'complete.json')})
    if not accepted:
        raise ValueError('no completed LLVM emissions; unavailable is not zero')
    if len({a['metadata']['pid'] for a in accepted}) != 1:
        raise ValueError('multiple compiler PIDs: use one fresh per-compile capture root')
    return accepted, abandoned


def read_audit(path):
    with path.open(newline='') as f:
        rows = list(csv.DictReader(f))
    required = {'helper', 'audit_status', 'current_effect', 'may_collect', 'may_reenter_js', 'runtime_locations'}
    if not rows or not required.issubset(rows[0]):
        raise ValueError('missing helper-audit columns')
    if len({r['helper'] for r in rows}) != len(rows):
        raise ValueError('duplicate helper-audit names')
    return {r['helper']: r for r in rows}


def analyze(root, audit_path, output, llvm_dis='llvm-dis', text_root=None, nonruntime_path=None):
    if output.exists() and any(output.iterdir()):
        raise ValueError('analysis output directory must be empty; preserve prior attempts')
    audit_sha = sha(audit_path)
    nonruntime = frozenset(nonruntime_path.read_text().splitlines()) if nonruntime_path else frozenset()
    if '' in nonruntime or any(x != x.strip() for x in nonruntime):
        raise ValueError('nonruntime list must contain one exact symbol per line')
    tool = None
    if text_root is None:
        resolved = shutil.which(llvm_dis)
        if resolved is None:
            raise ValueError('llvm-dis executable not found')
        result = subprocess.run([resolved, '--version'], capture_output=True, text=True)
        if result.returncode != 0 or not re.search(r'LLVM version 22\.', result.stdout):
            raise ValueError('matching LLVM 22 llvm-dis is required: ' + result.stdout[:200])
        llvm_dis = resolved
        tool = {'path': str(Path(resolved).resolve()), 'version': result.stdout.strip()}
    attempts, abandoned = read_attempts(root)
    audit = read_audit(audit_path)
    inventories, all_defs, unit_keys = {}, set(), set()
    mirror_receipts = []
    for attempt in attempts:
        directory = attempt['directory']
        for stage in STAGES:
            path = directory / (stage + '.bc')
            with llvm_lines(path, llvm_dis, text_root) as lines:
                inv = inventory(lines)
            inv['unit'] = directory.name
            inventories[(directory.name, stage)] = inv
            all_defs.update(symbol for symbol, header in inv['definitions'].items() if not local_linkage(header))
            if text_root:
                mirror = text_root / directory.name / (stage + '.ll')
                mirror_receipts.append({'path': str(mirror), 'sha256': sha(mirror)})
        definitions = inventories[(directory.name, STAGES[0])]['definitions']
        if not definitions:
            raise ValueError('cannot identify an emitted unit with no function definitions')
        key = tuple(sorted(definitions))
        if key in unit_keys:
            raise ValueError('duplicate successful pre-definition set; refuse double counting')
        unit_keys.add(key)
    pre_units = {a['directory'].name: inventories[(a['directory'].name, STAGES[0])] for a in attempts}
    visible = visible_definitions(pre_units)
    graphs = {'unit-local': {}, 'unique-visible-cross-unit': {}}
    for attempt in attempts:
        directory = attempt['directory']
        for mode in graphs:
            with llvm_lines(directory / 'pre-rs4gc.bc', llvm_dis, text_root) as lines:
                graphs[mode].update(effect_graph(lines, directory.name, pre_units[directory.name],
                    audit, pre_units, visible, mode == 'unique-visible-cross-unit'))
    proof_sets = {}
    for mode, graph in graphs.items():
        baseline = proven_functions(graph, 'base_blocked')
        augmented = proven_functions(graph, 'extra_blocked')
        if not baseline.issubset(augmented):
            raise ValueError('adding noncollecting summaries unexpectedly removed a proof')
        proof_sets[mode] = {'baseline': baseline, 'augmented': augmented, 'new': augmented - baseline}
    opportunities = defaultdict(Counter)
    conflicts = nonruntime.intersection(all_defs) | {s for s in nonruntime if audit.get(s, {}).get('runtime_locations')}
    if conflicts:
        raise ValueError('nonruntime identity conflicts with definition/audit: ' + ','.join(sorted(conflicts)))
    output.mkdir(parents=True, exist_ok=True)
    totals, per_callee, per_caller = Counter(), defaultdict(Counter), defaultdict(Counter)
    categories, modes = defaultdict(Counter), defaultdict(Counter)
    block_path = output / 'by-block.csv.gz'
    with gzip.open(block_path, 'wt', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(('attempt', 'stage', 'caller', 'block', 'root_mode', 'category', 'callee') + METRICS)
        for attempt in attempts:
            directory = attempt['directory']
            pre = inventories[(directory.name, STAGES[0])]
            for stage in STAGES:
                inv = inventories[(directory.name, stage)]
                with llvm_lines(directory / (stage + '.bc'), llvm_dis, text_root) as lines:
                    for fn, rows in function_counts(lines, inv, pre, all_defs, audit, nonruntime):
                        for key, metrics in sorted(rows.items()):
                            caller, block, mode, category, callee = key
                            writer.writerow((directory.name, stage) + key + tuple(metrics[m] for m in METRICS))
                            per_callee[(stage, category, callee)].update(metrics)
                            per_caller[(stage, directory.name, caller, mode)].update(metrics)
                            categories[(stage, category)].update(metrics)
                            modes[(stage, mode)].update(metrics)
                            for metric in METRICS:
                                totals[(stage, metric)] += metrics[metric]
            inv = inventories[(directory.name, 'post-opt')]
            with llvm_lines(directory / 'post-opt.bc', llvm_dis, text_root) as lines:
                found = statepoint_opportunities(lines, directory.name, inv, pre_units, visible,
                    proof_sets['unit-local']['new'], proof_sets['unique-visible-cross-unit']['new'], audit,
                    proof_sets['unique-visible-cross-unit']['baseline'], proof_sets['unique-visible-cross-unit']['augmented'])
            for key, counts in found.items():
                opportunities[key].update(counts)
    def write_csv(filename, fields, table):
        with (output / filename).open('w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(tuple(fields) + METRICS)
            for key, values in sorted(table.items()):
                writer.writerow(key + tuple(values[m] for m in METRICS))
    write_csv('by-callee.csv', ('stage', 'category', 'callee'), per_callee)
    write_csv('by-caller.csv', ('stage', 'attempt', 'caller', 'root_mode'), per_caller)
    with (output / 'definitions.csv').open('w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(('stage', 'attempt', 'symbol', 'linkage_scope', 'pre_root_mode'))
        for (unit, stage), inv in sorted(inventories.items()):
            for symbol, header in sorted(inv['definitions'].items()):
                writer.writerow((stage, unit, symbol, 'unit-local' if local_linkage(header) else 'visible',
                                 root_kind(symbol, pre_units[unit])))
    with (output / 'newly-proven-functions.csv').open('w', newline='') as f:
        writer = csv.writer(f); writer.writerow(('hypothesis', 'function_identity'))
        for mode, sets in proof_sets.items():
            for identity in sorted(sets['new']):
                writer.writerow((mode, identity))
    with (output / 'post-opt-hypothesis-targets.csv').open('w', newline='') as f:
        writer = csv.writer(f); writer.writerow(('hypothesis', 'callee_identity', 'attempt', 'caller', 'statepoints', 'gc_live_operands'))
        for key, counts in sorted(opportunities.items()):
            writer.writerow(key + (counts['statepoints'], counts['gc_live_operands']))
    candidates, already_classified = [], []
    for symbol, row in audit.items():
        pre = per_callee[(STAGES[0], 'runtime', symbol)]
        if not pre['callsites'] or row['audit_status'] != 'reviewed' or row['may_collect'] != 'no' or row['may_reenter_js'] != 'no':
            continue
        record = {'helper': symbol, 'current_effect': row['current_effect'],
                  'pre_callsites': pre['callsites'], 'pre_already_annotated_leaf': pre['leaf_callsites'],
                  'pre_unmarked_callsites': pre['callsites'] - pre['leaf_callsites'],
                  'post_rs4gc_statepoints': per_callee[(STAGES[1], 'runtime', symbol)]['statepoints'],
                  'post_opt_statepoints': per_callee[(STAGES[2], 'runtime', symbol)]['statepoints'],
                  'post_opt_gc_live_operands': per_callee[(STAGES[2], 'runtime', symbol)]['gc_live_operands'],
                  'audit_reason': row.get('reason'), 'proof': row.get('proof')}
        (candidates if row['current_effect'] == 'Unknown' else already_classified).append(record)
    order = lambda row: (-row['pre_callsites'], row['helper'])
    if sha(audit_path) != audit_sha:
        raise ValueError('helper audit changed during analysis')
    for stage in STAGES:
        for metric in METRICS:
            if sum(values[metric] for (s, _), values in categories.items() if s == stage) != totals[(stage, metric)]:
                raise ValueError('category totals do not reconcile')
    summary = {
        'schema': 1, 'status': 'complete-static-emission-census',
        'measurement_kind': 'emitted LLVM sites, not executed calls or CPU savings',
        'helper_audit_sha256': audit_sha,
        'nonruntime_list_sha256': sha(nonruntime_path) if nonruntime_path else None, 'analyzer_sha256': sha(Path(__file__)),
        'llvm_dis': tool,
        'accepted_attempts': [{**a, 'directory': str(a['directory'])} for a in attempts],
        'excluded_incomplete_attempts': abandoned, 'converted_ir_receipts': mirror_receipts,
        'totals': {stage: {m: totals[(stage, m)] for m in METRICS} for stage in STAGES},
        'categories': [{'stage': k[0], 'category': k[1], **dict(v)} for k, v in sorted(categories.items())],
        'root_modes': [{'stage': k[0], 'root_mode': k[1], **dict(v)} for k, v in sorted(modes.items())],
        'top20_reviewed_unknown_never_collect_helpers': sorted(candidates, key=order)[:20],
        'already_classified_reviewed_never_collect_helpers': sorted(already_classified, key=order),
        'dynamic_dispatch_wrapper_ledger': {symbol: {field: audit.get(symbol, {}).get(field, '')
            for field in ('runtime_locations', 'current_effect', 'may_collect', 'may_reenter_js')}
            for symbol in sorted(DISPATCH_WRAPPERS)},
        'dynamic_dispatch_origins': [
            {'stage': stage, 'origin': origin, **{m: sum(v[m] for (s, cat, callee), v in per_callee.items()
                if s == stage and cat == 'dynamic-dispatch' and (callee == '<indirect>') == (origin == 'indirect-IR')) for m in METRICS}}
            for stage in STAGES for origin in ('indirect-IR', 'exact-runtime-wrapper')],
        'offline_leaf_hypothesis': {
            'extra_reviewed_runtime_summaries': sum(reviewed_extra(row) for row in audit.values()),
            'scopes': {mode: {'definitions': len(graphs[mode]), 'existing_proven': len(sets['baseline']),
                             'with_extra_proven': len(sets['augmented']), 'newly_proven': len(sets['new'])}
                       for mode, sets in proof_sets.items()},
            'post_opt_opportunities': {kind: {m: sum(v[m] for (k, _, _, _), v in opportunities.items() if k == kind)
                                             for m in ('statepoints', 'gc_live_operands')}
                                      for kind in ('direct-reviewed-runtime', 'new-local-user', 'new-unique-visible-user', 'existing-proof-user', 'full-unique-visible-user')},
            'ambiguous_visible_symbols': len([s for s, ids in visible.items() if len(ids) > 1]),
            'ambiguous_visible_examples': dict([(s, ids[:20]) for s, ids in sorted(visible.items()) if len(ids) > 1][:100]),
            'scope_limit': 'LLVM units erase original module membership. Unit-local is a lower bound; cross-unit includes existing same-module partitions plus distinct source modules and cannot all be called new whole-program IPA. Unique visible definitions only; private/internal names are unit-qualified, ambiguous external definitions are unresolved.',
            'contract': 'Existing actual leaf attributes, LLVM intrinsics and current CannotCollect summaries are the baseline. No AllocNoReentry contract is newly assumed. Augmented inference changes only the reviewed Unknown/no-collect/no-reentry set. Hypothesis arms overlap and must not be added.',
        },
        'limitations': [
            'Completion proves LLVM buffer emission; bind separately to successful outer compilation/link and accepted unit outputs.',
            'A text-root mirror is separately hash-bound, but byte lengths validate original bitcode; conversion provenance must be retained by the caller.',
            'post-rs4gc includes always-inline, mem2reg and SCCP; post-opt sites differ through inlining/DCE/cloning.',
            'No statepoint-report textual_calls field is used. Relocate intrinsics count as LLVM call instructions; their separate attributed metric must not be added to callsites.',
            'Ambiguous exceptional relocate tokens remain explicitly unattributed; live bundle count is operand fanout, not distinct objects.',
            'external-unclassified means no runtime identity in this finite audit; only an explicit exact-name list establishes nonruntime-external.',
            'Function definitions emitted in separate units can subsequently be folded or discarded by the linker; this is not a linked-machine-site census.',
        ],
        'outputs': {p.name: {'sha256': sha(p), 'bytes': p.stat().st_size} for p in (block_path, output/'by-callee.csv', output/'by-caller.csv', output/'definitions.csv', output/'newly-proven-functions.csv', output/'post-opt-hypothesis-targets.csv')},
    }
    (output / 'summary.json').write_text(json.dumps(summary, indent=2, sort_keys=True) + '\n')
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--captures', type=Path, required=True)
    parser.add_argument('--helper-audit', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--llvm-dis', default='llvm-dis')
    parser.add_argument('--text-root', type=Path)
    parser.add_argument('--nonruntime-external', type=Path)
    args = parser.parse_args()
    result = analyze(args.captures, args.helper_audit, args.output, args.llvm_dis, args.text_root, args.nonruntime_external)
    print(json.dumps({'status': result['status'], 'accepted_attempts': len(result['accepted_attempts']),
                      'excluded_attempts': len(result['excluded_incomplete_attempts']),
                      'totals': result['totals']}, sort_keys=True))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, TypeError) as error:
        print('callsite census FAILED: ' + str(error), file=sys.stderr)
        sys.exit(1)
