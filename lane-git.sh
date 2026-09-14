#!/bin/bash
# git for this lane that only WRITES under /tmp (codex sandbox-safe): objects/refs live in /tmp/lane-literal.git (shared with the main repo's objects), index in /tmp.
# usage: ./lane-git.sh status | add -A | commit -m ... | push -u fork perf/10173-record-literal-cliff | log --oneline -3   (branch: perf/10173-record-literal-cliff)
export GIT_DIR=/tmp/lane-literal.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-literal GIT_INDEX_FILE=/tmp/lane-literal.index
[ -f "$GIT_INDEX_FILE" ] || git read-tree HEAD
exec git "$@"
