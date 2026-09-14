#!/bin/bash
# usage: ./remote.sh '<shell command>'   — syncs this worktree's current files (committed or not) to perrymaster lanes/wt-regex-cache and runs the command there.
# Sandbox-safe: all git writes go to /tmp/perry-regexp-lane.git and /tmp.
set -e
CMD="$*"; [ -n "$CMD" ] || { echo "usage: ./remote.sh '<command>'"; exit 2; }
export GIT_DIR=/tmp/perry-regexp-lane.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-regex-cache GIT_INDEX_FILE=/tmp/lane-regex-cache.sync-index
rm -f "$GIT_INDEX_FILE"; git read-tree HEAD; git add -A "$GIT_WORK_TREE" >/dev/null
tree=$(git write-tree); head=$(git rev-parse HEAD)
commit=$(git commit-tree "$tree" -p "$head" -m "lane sync $(date +%s)")
git push -q -f fork "$commit:refs/heads/lane/regex-cache-sync"
ssh -o BatchMode=yes root@perrymaster.skelpo.net "cd /root/claude-opencode/lanes/wt-regex-cache && git fetch -q fork lane/regex-cache-sync && git checkout -q --detach FETCH_HEAD && . /root/claude-opencode/lanes/env-regex-cache.sh && cd /root/claude-opencode/lanes/wt-regex-cache && $CMD"
