#!/bin/bash
# usage: ./remote.sh '<shell command>'   — syncs this worktree's current files (committed or not) to the perrymaster lane worktree and runs the command there.
# The remote shell has cargo/rustc (nightly), LLVM 22, its own CARGO_TARGET_DIR (lanes/target-nsclass), $OPENCODE_SRC (OpenCode v1.18.30 + node_modules).
# Sandbox-safe: all git writes go to /tmp/lane-nsclass.git and /tmp (see ./lane-git.sh for commits/pushes).
set -e
CMD="$*"; [ -n "$CMD" ] || { echo "usage: ./remote.sh '<command>'"; exit 2; }
export GIT_DIR=/tmp/lane-nsclass.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-nsclass GIT_INDEX_FILE=/tmp/lane-nsclass.sync-index
rm -f "$GIT_INDEX_FILE"; git read-tree HEAD; git add -A "$GIT_WORK_TREE" >/dev/null
tree=$(git write-tree); head=$(git rev-parse HEAD)
commit=$(git commit-tree "$tree" -p "$head" -m "lane sync $(date +%s)")
git push -q -f fork "$commit:refs/heads/lane/nsclass-sync"
ssh -o BatchMode=yes root@perrymaster.skelpo.net "cd /root/claude-opencode/lanes/wt-nsclass && git fetch -q fork lane/nsclass-sync && git checkout -q --detach FETCH_HEAD && . /root/claude-opencode/lanes/env-nsclass.sh && cd /root/claude-opencode/lanes/wt-nsclass && $CMD"
