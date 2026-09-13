#!/bin/bash
# usage: ./remote.sh '<shell command>'   — syncs this worktree's current files (committed or not) to the perrymaster lane worktree and runs the command there
# The remote shell has: cargo/rustc (nightly), LLVM 22, a warm shared CARGO_TARGET_DIR, $OPENCODE_SRC (OpenCode v1.18.30 with node_modules) and $OPENTUI_CORE (the failing package dir).
# Examples: ./remote.sh 'cargo test -p perry-codegen --lib some_test'   ./remote.sh 'cargo build --release -p perry && ./target/release/perry compile $OPENTUI_CORE/index.node.js --no-link --output /tmp/o.o --cache-dir /tmp/c'
set -e
CMD="$*"; [ -n "$CMD" ] || { echo "usage: ./remote.sh '<command>'"; exit 2; }
GD=$(git rev-parse --git-dir)
export GIT_INDEX_FILE="$GD/lane-sync-index"; cp "$GD/index" "$GIT_INDEX_FILE" 2>/dev/null || true
git add -A . >/dev/null
tree=$(git write-tree); unset GIT_INDEX_FILE
commit=$(git commit-tree "$tree" -p HEAD -m "lane sync $(date +%s)")
git push -q -f fork "$commit:refs/heads/lane/nsspread-sync"
ssh -o BatchMode=yes root@perrymaster.skelpo.net "cd /root/claude-opencode/lanes/wt-nsspread && git fetch -q fork lane/nsspread-sync && git checkout -q --detach FETCH_HEAD && . /root/claude-opencode/lanes/env-nsspread.sh && cd /root/claude-opencode/lanes/wt-nsspread && $CMD"
