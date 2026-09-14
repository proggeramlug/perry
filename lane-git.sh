#!/bin/bash
# git for this lane that only WRITES under /tmp (codex sandbox-safe): objects/refs live in /tmp/lane-ctorarity2.git (shared with the main repo's objects), index in /tmp.
# usage: ./lane-git.sh status | add -A | commit -m ... | push -u fork fix/10258-ctor-arity-all-heritage | log --oneline -3   (branch: fix/10258-ctor-arity-all-heritage)
export GIT_DIR=/tmp/lane-ctorarity2.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-ctorarity-rebase GIT_INDEX_FILE=/tmp/lane-ctorarity2.index
[ -f "$GIT_INDEX_FILE" ] || git read-tree HEAD
exec git "$@"
