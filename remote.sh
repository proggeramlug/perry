#!/bin/bash
# usage: ./remote.sh '<shell command>'   — syncs this worktree's current files (committed or not) to the perrymaster lane worktree and runs the command there.
# The remote shell has cargo/rustc (nightly), LLVM 22, its own CARGO_TARGET_DIR (lanes/target-nsclass), $OPENCODE_SRC (OpenCode v1.18.30 + node_modules).
# Sandbox-safe: all git writes go to /tmp/lane-ctorarity2.git and /tmp (see ./lane-git.sh for commits/pushes).
set -e
CMD="$*"; [ -n "$CMD" ] || { echo "usage: ./remote.sh '<command>'"; exit 2; }
export GIT_DIR=/tmp/lane-ctorarity2.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-ctorarity-rebase GIT_INDEX_FILE=/tmp/lane-ctorarity2.sync-index
rm -f "$GIT_INDEX_FILE"; git read-tree HEAD; git add -A "$GIT_WORK_TREE" >/dev/null
tree=$(git write-tree); head=$(git rev-parse HEAD)
sync_stamp=/tmp/lane-ctorarity2.last-sync
commit=""
if [ -f "$sync_stamp" ]; then
  read -r previous_tree previous_head previous_commit < "$sync_stamp"
  if [ "$previous_tree" = "$tree" ] && [ "$previous_head" = "$head" ]; then
    commit="$previous_commit"
  fi
fi
if [ -z "$commit" ]; then
  commit=$(git commit-tree "$tree" -p "$head" -m "lane sync $(date +%s)")
  printf '%s %s %s\n' "$tree" "$head" "$commit" > "$sync_stamp"
fi
git push -q -f fork "$commit:refs/heads/lane/ctorarity-sync"
ssh -o BatchMode=yes root@perrymaster.skelpo.net "cd /root/claude-opencode/lanes/wt-ctorarity && git fetch -q fork lane/ctorarity-sync && git checkout -q --detach FETCH_HEAD && . /root/claude-opencode/lanes/env-ctorarity.sh && cd /root/claude-opencode/lanes/wt-ctorarity && {
$CMD
}"
