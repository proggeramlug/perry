#!/usr/bin/env python3
"""Locate native GC calls and their normal-flow loop/block regions.

This measures caller instruction-region coverage, never saved instructions or
cycles. Input is exact GNU objdump x86-64 output without raw instruction bytes,
plus exact compact-map return PCs. Indirect jumps make a function unsupported.
"""
import bisect
import re


def parse_disassembly(text, symbol):
    current = False
    instructions = []
    for line in text.splitlines():
        if line.startswith('Disassembly of section '):
            current = False
            continue
        header = re.fullmatch(r'([0-9a-fA-F]+) <(.+)>:', line.strip())
        if header:
            current = header[2] == symbol
            continue
        if not current:
            continue
        match = re.match(r'^\s*([0-9a-fA-F]+):\s+([a-z][a-z0-9.]*)\s*(.*?)\s*$', line)
        if match:
            instructions.append((int(match[1], 16), match[2], match[3]))
        elif line.strip():
            raise ValueError('unparsed instruction line: ' + line[:200])
    if not instructions:
        raise ValueError('no instructions for exact symbol ' + symbol)
    if [row[0] for row in instructions] != sorted({row[0] for row in instructions}):
        raise ValueError('duplicate or out-of-order instruction addresses')
    return instructions


def target(operand):
    match = re.match(r'^([0-9a-fA-F]+)\s+<([^>]+)>', operand)
    if match:
        return int(match[1], 16), match[2]
    return None, None


def components(edges):
    """Iterative Kosaraju: a giant generated function cannot exhaust recursion."""
    visited, order = set(), []
    for start in edges:
        if start in visited:
            continue
        stack = [(start, False)]
        while stack:
            node, done = stack.pop()
            if done:
                order.append(node)
            elif node not in visited:
                visited.add(node)
                stack.append((node, True))
                stack.extend((child, False) for child in edges[node] if child not in visited)
    reverse = {node: [] for node in edges}
    for node, children in edges.items():
        for child in children:
            reverse[child].append(node)
    found, groups = set(), []
    for start in reversed(order):
        if start in found:
            continue
        group, stack = set(), [start]
        found.add(start)
        while stack:
            node = stack.pop()
            group.add(node)
            for child in reverse[node]:
                if child not in found:
                    found.add(child)
                    stack.append(child)
        groups.append(group)
    assert set().union(*groups) == set(edges)
    return groups


def analyze(instructions, function_end, gc_return_pcs, candidates):
    addresses = [row[0] for row in instructions]
    existing = set(addresses)
    assert addresses[-1] < function_end
    leaders = {addresses[0]}
    edges, calls = {}, []
    for index, (address, mnemonic, operand) in enumerate(instructions):
        if mnemonic in ('rep', 'repz', 'repnz', 'bnd'):
            parts = operand.split(None, 1)
            if parts and (parts[0].startswith(('ret', 'j', 'call', 'loop'))):
                mnemonic, operand = parts[0], parts[1] if len(parts) > 1 else ''
        following = addresses[index + 1] if index + 1 < len(addresses) else None
        destination, name = target(operand)
        if mnemonic in ('call', 'callq'):
            if name in candidates and following in gc_return_pcs:
                calls.append({'address': address, 'return_pc': following, 'callee': name})
            edges[address] = [following] if following is not None else []
        elif mnemonic.startswith('j') or mnemonic.startswith('loop'):
            if destination is None:
                raise ValueError('indirect/undecoded branch at ' + hex(address))
            unconditional = mnemonic in ('jmp', 'jmpq')
            children = []
            if destination in existing:
                children.append(destination)
                leaders.add(destination)
            elif addresses[0] <= destination < function_end:
                raise ValueError('branch target is not an instruction boundary')
            if following is not None:
                leaders.add(following)
                if not unconditional:
                    children.append(following)
            edges[address] = children
        elif mnemonic.startswith('ret') or mnemonic in ('ud2', 'hlt', 'int3'):
            edges[address] = []
            if following is not None:
                leaders.add(following)
        else:
            edges[address] = [following] if following is not None else []
    reached, todo = set(), [addresses[0]]
    while todo:
        node = todo.pop()
        if node not in reached:
            reached.add(node)
            todo.extend(edges[node])
    calls = [row for row in calls if row['address'] in reached]
    groups = components(edges)
    cyclic = [g for g in groups if len(g) > 1 or next(iter(g)) in edges[next(iter(g))]]
    selected = [g for g in cyclic if any(row['address'] in g for row in calls)]
    loop_addresses = set().union(*selected) if selected else set()
    ordered_leaders = sorted(leaders)
    block_id = {address: ordered_leaders[bisect.bisect_right(ordered_leaders, address) - 1]
                for address in addresses}
    selected_blocks = {block_id[row['address']] for row in calls}
    block_addresses = {a for a in reached if block_id[a] in selected_blocks}
    for row in calls:
        row['in_cyclic_region'] = row['address'] in loop_addresses
        row['basic_block'] = block_id[row['address']]
    return {'calls': calls, 'loop_addresses': loop_addresses,
            'block_addresses': block_addresses, 'addresses': addresses,
            'function_end': function_end, 'loop_regions': len(selected),
            'reachable_instructions': len(reached), 'instructions': len(addresses)}


def locate_ip(result, ip):
    index = bisect.bisect_right(result['addresses'], ip) - 1
    if index < 0 or ip >= result['function_end']:
        raise ValueError('IP outside exact function')
    instruction = result['addresses'][index]
    return {'instruction': instruction,
            'candidate_call': any(row['address'] == instruction for row in result['calls']),
            'candidate_loop': instruction in result['loop_addresses'],
            'candidate_block': instruction in result['block_addresses']}
