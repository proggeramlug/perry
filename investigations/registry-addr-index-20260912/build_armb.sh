#!/bin/bash
# Arm B: the address-index change without the census counters, built in the same
# source path and target dir so cargo stays incremental.
set -u
SRC=/root/worktrees/canonical-filter-census-20260912
PRISTINE=/root/worktrees/cc-own-read-cache-0911
S=/root/cc-perf-native-recv-0909/canonical-filter-census-20260912
OUT=/root/cc-perf-native-recv-0909/registry-addr-index-20260912
TARGET=$S/target
LOCK=/root/rig9831/lock
OWNER="registry-addr-index-armb-20260912 $$"
mkdir -p "$OUT"
deadline=$(( $(date +%s) + 7200 ))
while ! mkdir "$LOCK" 2>/dev/null; do
  [ "$(date +%s)" -lt "$deadline" ] || { echo "LOCK_TIMEOUT"; exit 75; }
  echo "WAIT_CAMPAIGN_LOCK"; sleep 10
done
echo "$OWNER" > "$LOCK/owner"
cleanup() { [ "$(cat "$LOCK/owner" 2>/dev/null)" = "$OWNER" ] && { rm -f "$LOCK/owner"; rmdir "$LOCK"; }; }
trap cleanup EXIT

# Restore the census-free files, then apply the index change only.
cp -a "$PRISTINE/crates/perry-runtime/src/native_handle.rs" "$SRC/crates/perry-runtime/src/native_handle.rs"
cp -a "$PRISTINE/crates/perry-runtime/src/hot_diag.rs" "$SRC/crates/perry-runtime/src/hot_diag.rs"
rm -f "$SRC/crates/perry-runtime/src/hot_diag/canonical_filter.rs"
cp -a /tmp/armb-files/canonical.rs "$SRC/crates/perry-runtime/src/native_handle/canonical.rs"
cp -a /tmp/armb-files/registry_latch.rs "$SRC/crates/perry-runtime/src/registry_latch.rs"
cp -a /tmp/armb-files/symbol.rs "$SRC/crates/perry-runtime/src/symbol.rs"
grep -c canonical_census "$SRC/crates/perry-runtime/src/native_handle/canonical.rs" && { echo "CENSUS STILL PRESENT"; exit 1; }
for f in crates/perry-runtime/src/registry_latch.rs crates/perry-runtime/src/native_handle/canonical.rs \
         crates/perry-runtime/src/native_handle.rs crates/perry-runtime/src/hot_diag.rs; do
  ( cd "$SRC" && sha256sum $f )
done > "$OUT/source-receipt.sha256"
cat "$OUT/source-receipt.sha256"

export PATH=/root/.cargo/bin:/usr/lib/llvm-22/bin:/usr/bin:/bin
export CARGO_TARGET_DIR=$TARGET
export LLVM_SYS_221_PREFIX=/usr/lib/llvm-22
export RUST_TEST_THREADS=1
for v in $(env | grep -o "^PERRY_[A-Z_]*"); do unset $v; done
export PERRY_BUILD_COMMIT=cc-native-recv-0909

cd "$SRC" || exit 1
echo "=== focused tests $(date -u +%FT%TZ) ==="
nice -n19 cargo test --locked --offline --release -j4 -p perry-runtime --lib registry_latch -- --test-threads=1 > "$OUT/focused-tests.log" 2>&1
echo "tests exit=$?"; grep -E "test result" "$OUT/focused-tests.log" | tail -1

echo "=== shipping archives $(date -u +%FT%TZ) ==="
ARGV=$(python3 -c "import json;print(' '.join(json.load(open('/root/cc-perf-native-recv-0909/runtime-own-read-cache-20260911/shipping.command.json'))['argv']))")
nice -n19 $ARGV > "$OUT/shipping.log" 2>&1
echo "shipping exit=$?"; grep -E "^(error|    Finished)" "$OUT/shipping.log" | tail -2

echo "=== compile cc $(date -u +%FT%TZ) ==="
HOMEDIR=$OUT/compile-home; rm -rf "$HOMEDIR"; mkdir -p "$HOMEDIR/.claude"
cd /root/cc-perf-native-recv-0909/cc-control || exit 1
env -i PATH=$PATH HOME=$HOMEDIR CLAUDE_CONFIG_DIR=$HOMEDIR/.claude \
  PERRY_RUNTIME_DIR=$TARGET/release PERRY_KEEP_SYMBOLS=1 PERRY_DISABLE_BUILD_CACHE=1 \
  PERRY_CACHE_DIR=/root/cc-perf-native-recv-0909/property-key-dispatch-20260911/object-cache \
  PERRY_SEGMENTS_PROJECT=1 PERRY_SEGVIEW=0 PERRY_SEGMENTS_PROJECT_DIAG=1 \
  PERRY_REGEX_ENGINE=default PERRY_REGEX_DIAG=0 \
  /usr/bin/time -v nice -n19 /root/cc-perf-native-recv-0909/gc-leaf-census-20260911/target/release/perry compile \
  --no-auto-optimize --enable-wasm-runtime /root/cc-perf-native-recv-0909/cc-control/cli_2.1.112.js \
  -o "$OUT/cc-index" > "$OUT/compile.log" 2>&1
echo "compile exit=$?"
ls -la "$OUT/cc-index" 2>/dev/null && sha256sum "$OUT/cc-index"
echo "=== done $(date -u +%FT%TZ) ==="
