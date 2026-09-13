#!/bin/bash
# git for this lane that only WRITES under /tmp (codex sandbox-safe): objects/refs live in /tmp/lane-nsclass.git (shared with the main repo's objects), index in /tmp.
# usage: ./lane-git.sh status | add -A | commit -m ... | push -u fork fix/10222-namespace-classes | log --oneline -3   (branch: fix/10222-namespace-classes)
export GIT_DIR=/tmp/lane-nsclass.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-nsclass GIT_INDEX_FILE=/tmp/lane-nsclass.index
[ -f "$GIT_INDEX_FILE" ] || git read-tree HEAD
exec git "$@"
