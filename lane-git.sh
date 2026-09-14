#!/bin/bash
# git for this lane that only WRITES under /tmp (codex sandbox-safe): objects/refs live in /tmp/lane-prune.git (shared with the main repo's objects), index in /tmp.
# usage: ./lane-git.sh status | add -A | commit -m ... | push -u fork feat/10180-prune-unused-reexports | log --oneline -3   (branch: feat/10180-prune-unused-reexports)
export GIT_DIR=/tmp/lane-prune.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-prune GIT_INDEX_FILE=/tmp/lane-prune.index
[ -f "$GIT_INDEX_FILE" ] || git read-tree HEAD
exec git "$@"
