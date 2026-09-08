"""Reviewed source pins for weak indices of nonmoving collector cells.

These addresses are real GC addresses, deliberately not roots. Recognition,
matching-address deletion, and native-only thread teardown form their lifetime
contract. Pins require review when those bodies change; they do not infer an
arbitrary call graph or establish collection of cycles in owner side tables.
"""
from __future__ import annotations

import hashlib
import re
import tempfile
from pathlib import Path, PurePosixPath

ROLES = ("allocator", "recognizer", "weak_delete", "gc_cleanup", "native_release", "thread_teardown")


def weak_index_contract_problems(entry: dict, root: Path | None) -> list[str]:
    label = f"{entry.get('file', '?')}:{entry.get('name', '?')}: weak_nonmoving_index"
    errors = []
    contract = entry.get("contract", {})
    pins = contract.get("sources", {}) if isinstance(contract, dict) else {}
    if root is None or not isinstance(pins, dict) or not pins:
        return [f"{label} requires source root and contract.sources pins"]
    texts = {}
    for rel, digest in pins.items():
        path = PurePosixPath(rel)
        if (path.is_absolute() or ".." in path.parts or "\\" in rel
                or not rel.startswith("crates/") or path.suffix != ".rs"):
            errors.append(f"{label}: invalid source path {rel!r}")
            continue
        target = root / rel
        if not target.is_file() or not target.resolve().is_relative_to(root.resolve()):
            errors.append(f"{label}: source missing/outside repository: {rel}")
            continue
        text = target.read_text(encoding="utf-8")
        texts[rel] = text
        if hashlib.sha256(text.encode("utf-8")).hexdigest() != digest:
            errors.append(f"{label}: source changed: {rel}; re-audit before updating pin")
    if entry.get("file") not in texts:
        errors.append(f"{label}: must pin the weak holder file")
    for role in ROLES:
        boundary = contract.get(role, {})
        if not isinstance(boundary, dict):
            boundary = {}
        rel, function = boundary.get("file"), boundary.get("function")
        if (rel not in texts or not isinstance(function, str)
                or not re.fullmatch(r"[A-Za-z_]\w*", function)
                or not re.search(r"\bfn\s+" + re.escape(function) + r"\s*(?:<|\()", texts.get(rel, ""))):
            errors.append(f"{label}: {role} must name a function in pinned source")
    return errors


def weak_index_contract_self_test() -> list[str]:
    errors = []
    with tempfile.TemporaryDirectory(prefix="weak-index-contract-") as temporary:
        root = Path(temporary)
        rel = "crates/fixture.rs"
        source = root / rel
        source.parent.mkdir()
        text = "\n".join(f"fn {role}() {{}}" for role in ROLES)
        source.write_text(text)
        contract = {role: {"file": rel, "function": role} for role in ROLES}
        contract["sources"] = {rel: hashlib.sha256(text.encode()).hexdigest()}
        entry = {"file": rel, "name": "INDEX", "contract": contract}
        if weak_index_contract_problems(entry, root):
            errors.append("weak index checker rejected its valid source contract")
        for role in ROLES:
            changed = {**entry, "contract": {k: v for k, v in contract.items() if k != role}}
            if not weak_index_contract_problems(changed, root):
                errors.append(f"weak index checker accepted missing {role}")
        source.write_text(text + "\nfn changed() {}")
        if not weak_index_contract_problems(entry, root):
            errors.append("weak index checker accepted changed source")
        if not weak_index_contract_problems(entry, None):
            errors.append("weak index checker accepted missing source root")
    return errors
