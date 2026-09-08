#!/usr/bin/env python3
"""Source checks by default; --run builds real runtime-linked fixtures in a copy.

Run --run only on the authorized build host, under its build lock and nice policy.
Every Cargo invocation uses -j4. The runner snapshots tracked and new source files
without .git/build outputs, then changes only that disposable copy. Each mutant
must compile successfully and fail exactly one named fixture at its intended
assertion. Compile failures, zero-test filters, other failures, and passes reject
sabotage. No standalone native model substitutes for the linked collector.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CANONICAL = "crates/perry-runtime/src/native_handle/canonical.rs"
HEADER = "crates/perry-runtime/src/native_handle.rs"
CORE = "crates/perry-native-registration/src/lib.rs"
MALLOC = "crates/perry-runtime/src/gc/malloc.rs"
EXPANDO = "crates/perry-runtime/src/object/handle_expando.rs"
TESTS = "crates/perry-runtime/src/gc/tests/native_handle_canonical.rs"
PREFIX = "gc::tests::native_handle_canonical::"
FIXTURES = {
    "equal_ids_in_distinct_domains_keep_distinct_wrappers",
    "publication_handoff_balances_wrapper_leases",
    "rejected_publications_release_the_offered_ownership",
    "worker_retirement_preserves_retained_wrapper_identity",
    "wrapper_and_operation_leases_release_independently",
    "disposed_wrapper_still_runs_gc_cleanup_once",
    "publication_retirement_forced_orders",
    "old_cleanup_preserves_a_replacement_weak_entry",
    "reentrant_publication_balances_unpublished_candidate",
    "js_thread_exit_releases_native_metadata_without_gc",
    "disposed_cleanup_takes_native_metadata_once",
    "acyclic_owner_child_moves_with_existing_scanner",
}


@dataclass(frozen=True)
class Mutation:
    name: str
    path: str
    edits: tuple[tuple[str, str], ...]
    fixture: str
    message: str


def case(name, path, anchor, replacement, fixture, message):
    return Mutation(name, path, ((anchor, replacement),), fixture, message)


MUTATIONS = [
    case("domain_rejection_lease_leak", CANONICAL,
         "return Err(PublicationError::WrongDomain);",
         "std::mem::forget(lease); return Err(PublicationError::WrongDomain);",
         "rejected_publications_release_the_offered_ownership", "rejected publication must release offered ownership"),
    case("kind_rejection_lease_leak", CANONICAL,
         "return Err(PublicationError::WrongLeaseKind);",
         "std::mem::forget(lease); return Err(PublicationError::WrongLeaseKind);",
         "rejected_publications_release_the_offered_ownership", "rejected publication must release offered ownership"),
    case("type_rejection_lease_leak", CANONICAL,
         "if let Some(value) = lookup(identity, type_id)? {",
         "let hit = match lookup(identity, type_id) { Ok(hit) => hit, Err(error) => { std::mem::forget(lease); return Err(error); } }; if let Some(value) = hit {",
         "rejected_publications_release_the_offered_ownership", "rejected publication must release offered ownership"),
    # Keep the native box allocated in this mutant, so the intended state
    # assertion is independent of allocator behavior during test-thread exit.
    Mutation("metadata_take_omission", CANONICAL, (
        ("let metadata = std::mem::replace(&mut (*handle).registration, ptr::null_mut());",
         "let metadata = (*handle).registration;"),
        ("drop(registration.wrapper.take());\n    Some(identity)",
         "drop(registration.wrapper.take());\n    std::mem::forget(registration);\n    Some(identity)"),
    ), "disposed_cleanup_takes_native_metadata_once", "cleanup must take native metadata before release"),
    case("owner_child_slot_visit_omission", EXPANDO,
         "visitor.visit_nanbox_f64_slot(&mut v);", "let _ = &visitor;",
         "acyclic_owner_child_moves_with_existing_scanner", "owner child slot must hold the moved value"),
    Mutation("domain_key_collapse", CANONICAL, (
        ("let existing = CANONICAL.with(|index| index.borrow().get(&identity).copied());",
         "let existing = CANONICAL.with(|index| index.borrow().iter().find(|(key, _)| key.numeric_id() == identity.numeric_id()).map(|(_, addr)| *addr));"),
        ("if registration.identity == identity {",
         "if registration.identity.numeric_id() == identity.numeric_id() {"),
    ), "equal_ids_in_distinct_domains_keep_distinct_wrappers",
       "independent domains must not share a canonical wrapper"),
    case("cache_hit_lease_leak", CANONICAL,
         "drop(lease);\n        return Ok(value);", "std::mem::forget(lease);\n        return Ok(value);",
         "publication_handoff_balances_wrapper_leases", "cache hit must not retain an extra wrapper lease"),
    case("published_wrapper_lease_omission", CANONICAL,
         "wrapper: Some(lease),", "wrapper: { drop(lease); None },",
         "publication_handoff_balances_wrapper_leases", "published cell must retain its wrapper lease"),
    case("publication_domain_omission", CANONICAL,
         "if identity.domain() != expected_domain {", "if false && identity.domain() != expected_domain {",
         "rejected_publications_release_the_offered_ownership", "publication must reject another domain"),
    case("publication_kind_omission", CANONICAL,
         "if lease.kind() != NativeLeaseKind::Wrapper {", "if false && lease.kind() != NativeLeaseKind::Wrapper {",
         "rejected_publications_release_the_offered_ownership", "publication must reject an operation lease"),
    case("publication_type_omission", CANONICAL,
         "if (*handle).type_id != type_id {", "if false && (*handle).type_id != type_id {",
         "rejected_publications_release_the_offered_ownership", "publication must reject inconsistent runtime type"),
    case("retained_identity_omission", CANONICAL,
         "(identity.domain() == expected_domain).then_some(identity)",
         "(false && identity.domain() == expected_domain).then_some(identity)",
         "worker_retirement_preserves_retained_wrapper_identity", "retirement must preserve retained wrapper identity"),
    case("recognition_domain_omission", CANONICAL,
         "(identity.domain() == expected_domain).then_some(identity)",
         "(true || identity.domain() == expected_domain).then_some(identity)",
         "equal_ids_in_distinct_domains_keep_distinct_wrappers", "wrong domain must reject representation recognition"),
    case("recognition_type_omission", CANONICAL,
         "|| (*handle).type_id != expected_type_id", "|| (false && (*handle).type_id != expected_type_id)",
         "equal_ids_in_distinct_domains_keep_distinct_wrappers", "wrong type must reject representation recognition"),
    case("disposal_erases_recognition", CANONICAL,
         "|| (*handle).type_id != expected_type_id", "|| (*handle).finalized != 0\n        || (*handle).type_id != expected_type_id",
         "disposed_wrapper_still_runs_gc_cleanup_once", "disposal must preserve representation identity"),
    case("operation_dropped_before_closure", CANONICAL,
         "let result = operation(identity);\n    drop(lease);", "drop(lease);\n    let result = operation(identity);",
         "wrapper_and_operation_leases_release_independently", "operation must hold registration after wrapper collection"),
    case("operation_completion_leak", CANONICAL,
         "let result = operation(identity);\n    drop(lease);", "let result = operation(identity);\n    std::mem::forget(lease);",
         "wrapper_and_operation_leases_release_independently", "operation completion must release its lease"),
    case("operation_registry_substitution", CANONICAL,
         "registry.acquire(identity, NativeLeaseKind::Operation)?",
         "registry.acquire(registry.identity(identity.numeric_id())?, NativeLeaseKind::Operation)?",
         "equal_ids_in_distinct_domains_keep_distinct_wrappers", "operation acquisition must use the exact authoritative registry"),
    case("retired_operation_acquisition", CORE,
         "if slot.identity != identity || slot.phase != Phase::Live {\n            return None;\n        }\n        let count = match kind {",
         "if slot.identity != identity {\n            return None;\n        }\n        let count = match kind {",
         "worker_retirement_preserves_retained_wrapper_identity", "retirement must prevent new operation acquisition"),
    case("disposed_operation_acquisition", CANONICAL,
         "if (*handle).finalized != 0 {", "if false && (*handle).finalized != 0 {",
         "disposed_wrapper_still_runs_gc_cleanup_once", "disposal must reject new operations"),
    case("disposed_gc_cleanup_omission", HEADER,
         "canonical::cleanup_for_gc(handle);", "if (*handle).finalized == 0 { canonical::cleanup_for_gc(handle); }",
         "disposed_wrapper_still_runs_gc_cleanup_once", "disposed wrapper must release its wrapper lease at collection"),
    case("weak_removal_omission", CANONICAL,
         "index.remove(&identity);", "let _ = &identity;",
         "publication_handoff_balances_wrapper_leases", "collection must remove the weak entry"),
    case("matching_address_omission", CANONICAL,
         "if index.get(&identity).copied() == Some(addr) {", "if true || index.get(&identity).copied() == Some(addr) {",
         "old_cleanup_preserves_a_replacement_weak_entry", "old cleanup must not remove the replacement entry"),
    case("owner_cleanup_omission", CANONICAL,
         "crate::object::handle_expando::clear_plain_expando_for_gc(handle as i64);", "let _ = handle;",
         "worker_retirement_preserves_retained_wrapper_identity", "collection must remove owner state"),
    case("publication_recheck_omission", CANONICAL,
         "match lookup(identity, type_id) {", "match Ok::<Option<f64>, PublicationError>(None) {",
         "reentrant_publication_balances_unpublished_candidate", "reentrant publication must return the installed winner"),
    case("unpublished_candidate_lease_leak", CANONICAL,
         "let _ = release_native_metadata(handle);\n            winner.map", "let _ = handle;\n            winner.map",
         "reentrant_publication_balances_unpublished_candidate", "unpublished candidate must release its wrapper lease"),
    case("thread_exit_lease_omission", MALLOC,
         "if (*header).obj_type == GC_TYPE_NATIVE_HANDLE {", "if false && (*header).obj_type == GC_TYPE_NATIVE_HANDLE {",
         "js_thread_exit_releases_native_metadata_without_gc", "JS thread teardown must release native wrapper ownership"),
    Mutation("exact_acquisition_substitution", CORE, (
        ("if slot.identity != identity || slot.phase != Phase::Live {\n            return None;\n        }\n        let count = match kind {",
         "if slot.phase != Phase::Live {\n            return None;\n        }\n        let count = match kind {"),
        ("Some(NativeRegistrationLease {\n            registry: self.clone(),\n            identity,\n            kind,\n        })",
         "Some(NativeRegistrationLease {\n            registry: self.clone(),\n            identity: slot.identity,\n            kind,\n        })"),
    ), "publication_retirement_forced_orders", "publication must not substitute another registration"),
]


def function_body(source: str, name: str) -> str:
    start = re.search(rf"\bfn {name}\b[^{{]*{{", source)
    assert start, name
    depth = 1
    end = start.end()
    while depth:
        assert end < len(source), name
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    return source[start.start():end]


def source_checks(source):
    names = set(re.findall(r"#\[test\]\s*fn (\w+)", source[TESTS]))
    assert names == FIXTURES, names ^ FIXTURES
    assert len({m.name for m in MUTATIONS}) == len(MUTATIONS)
    for mutation in MUTATIONS:
        assert mutation.fixture in FIXTURES, mutation.name
        assert mutation.message in function_body(source[TESTS], mutation.fixture), mutation.name
        for anchor, _ in mutation.edits:
            assert source[mutation.path].count(anchor) == 1, (mutation.name, anchor)
    release = function_body(source[CANONICAL], "release_native_metadata")
    assert "drop(registration.wrapper.take())" in release
    assert all(word not in release for word in ("CANONICAL", "with(", "finalizer", "handle_expando"))
    worker = function_body(source[TESTS], "worker_retirement_preserves_retained_wrapper_identity")
    assert "std::thread::spawn(move || retire(&worker_registry, identity))" in worker
    assert "ConservativeScanDisabledGuard::new()" in worker
    assert "fixture must run a real full collection" in function_body(source[TESTS], "collect")
    print(f"SOURCE CHECK: {len(FIXTURES)} runtime-linked fixtures; {len(MUTATIONS)} mutation cases", flush=True)


def run(argv, cwd, timeout=3600):
    environment = {**os.environ, "RUST_TEST_THREADS": "1"}
    if argv[0] == "cargo":
        environment["CARGO_TARGET_DIR"] = str(Path(cwd) / "target")
    result = subprocess.run(argv, cwd=cwd, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=timeout, env=environment)
    return result


def require_success(result, label):
    assert result.returncode == 0, (label, result.returncode, result.stdout)
    return result.stdout


def build(directory, profile, logs, label):
    result = run(["cargo", "test", "--locked", "-j4", "-p", "perry-runtime", "--lib",
                  "--profile", profile, "--no-run", "--message-format=json"], directory)
    (logs / f"{label}.build.log").write_text(result.stdout)
    output = require_success(result, f"{label}: compile failure is not successful sabotage")
    artifacts = []
    for line in output.splitlines():
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        if (row.get("reason") == "compiler-artifact" and row.get("executable")
                and row.get("target", {}).get("name") == "perry_runtime"
                and row.get("profile", {}).get("test")):
            artifacts.append(row)
    assert len(artifacts) == 1, (label, artifacts)
    row = artifacts[0]
    assert row.get("fresh") is False, (label, "expected a rebuilt runtime test artifact")
    binary = Path(row["executable"])
    assert binary.is_file(), binary
    print(f"ARTIFACT {label} {binary} sha256={hashlib.sha256(binary.read_bytes()).hexdigest()} mtime_ns={binary.stat().st_mtime_ns}", flush=True)
    return binary


def check_listing(binary, directory):
    output = require_success(run([str(binary), PREFIX, "--list"], directory), "fixture listing")
    actual = set(re.findall(rf"^{PREFIX}(\w+): test$", output, re.M))
    assert actual == FIXTURES, ("runtime fixture enumeration", output)


def clean_run(binary, directory, logs, label):
    result = run([str(binary), PREFIX, "--test-threads=1"], directory)
    (logs / f"{label}.test.log").write_text(result.stdout)
    output = require_success(result, label)
    assert f"{len(FIXTURES)} passed; 0 failed" in output, output
    for fixture in FIXTURES:
        assert f"test {PREFIX}{fixture} ... ok" in output, fixture
    print(output, flush=True)


def check_sabotage(result, mutation):
    assert result.returncode != 0, (mutation.name, "mutant unexpectedly passed", result.stdout)
    assert ("0 passed; 1 failed" in result.stdout
            and mutation.message in result.stdout
            and f"test {PREFIX}{mutation.fixture} ... FAILED" in result.stdout), (
                mutation.name, "not the intended assertion failure", result.stdout)


def self_check_verdicts():
    # Source-only positive/negative controls for the runner itself. No compiler.
    mutation = MUTATIONS[0]
    expected = f"test {PREFIX}{mutation.fixture} ... FAILED\n{mutation.message}\n0 passed; 1 failed"
    check_sabotage(subprocess.CompletedProcess([], 101, expected), mutation)
    for code, output in [(0, expected), (101, "could not compile"),
                         (0, "0 passed; 0 failed"), (101, "unrelated assertion\n0 passed; 1 failed")]:
        try:
            check_sabotage(subprocess.CompletedProcess([], code, output), mutation)
        except AssertionError:
            continue
        raise AssertionError("runner accepted an invalid sabotage outcome")
    try:
        require_success(subprocess.CompletedProcess([], 101, expected), "compile control")
    except AssertionError:
        pass
    else:
        raise AssertionError("runner accepted a failed compile")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run", action="store_true")
    parser.add_argument("--profile", default="perry-dev")
    parser.add_argument("--logs", type=Path, help="persistent evidence directory (required for --run)")
    args = parser.parse_args()
    paths = {CANONICAL, HEADER, CORE, MALLOC, EXPANDO, TESTS}
    source = {p: (ROOT / p).read_text() for p in paths}
    hashes = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    source_checks(source)
    self_check_verdicts()
    for path, digest in sorted(hashes.items()):
        print(f"SOURCE SHA256 {path} {digest}", flush=True)
    if not args.run:
        print("Source/runner controls passed; no compilation or behavioral execution.")
        return
    assert args.logs, "--run requires --logs for retained build/test evidence"
    logs = args.logs.resolve()
    logs.mkdir(parents=True, exist_ok=False)
    files = require_success(run(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], ROOT), "source manifest").split("\0")
    with tempfile.TemporaryDirectory(prefix="receiver-wrapper-") as temporary:
        directory = Path(temporary) / "source"
        directory.mkdir()
        snapshot = {}
        for name in sorted(set(filter(None, files))):
            src = ROOT / name
            if not src.exists():
                continue
            dst = directory / name
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst, follow_symlinks=False)
            snapshot[name] = hashlib.sha256(src.read_bytes()).hexdigest()
        (logs / "source-manifest.json").write_text(json.dumps(snapshot, indent=2) + "\n")
        clean = build(directory, args.profile, logs, "clean")
        check_listing(clean, directory)
        clean_run(clean, directory, logs, "clean")
        for mutation in MUTATIONS:
            for path, text in source.items():
                (directory / path).write_text(text)
            changed = source[mutation.path]
            for anchor, replacement in mutation.edits:
                changed = changed.replace(anchor, replacement)
            (directory / mutation.path).write_text(changed)
            binary = build(directory, args.profile, logs, mutation.name)
            result = run([str(binary), PREFIX + mutation.fixture, "--exact", "--test-threads=1"], directory)
            (logs / f"{mutation.name}.test.log").write_text(result.stdout)
            check_sabotage(result, mutation)
            print(f"SABOTAGE {mutation.name}: intended assertion failed", flush=True)
        for path, text in source.items():
            (directory / path).write_text(text)
        clean = build(directory, args.profile, logs, "clean-restored")
        check_listing(clean, directory)
        clean_run(clean, directory, logs, "clean-restored")
    for path, digest in hashes.items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
    print("Original source hashes unchanged; clean suite rerun passed.")


if __name__ == "__main__":
    main()
