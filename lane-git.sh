#!/bin/bash
# git for this lane that only WRITES under /tmp (codex sandbox-safe): objects/refs live in /tmp/lane-worker.git (shared with the main repo's objects), index in /tmp.
# usage: ./lane-git.sh status | add -A | commit -m ... | push -u fork fix/worker-path-await-helper | log --oneline -3   (branch: fix/worker-path-await-helper)
export GIT_DIR=/tmp/lane-worker.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-worker GIT_INDEX_FILE=/tmp/lane-worker.index
[ -f "$GIT_INDEX_FILE" ] || git read-tree HEAD
exec git "$@"
