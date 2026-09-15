#!/bin/bash
# git for this lane that only WRITES under /tmp (codex sandbox-safe): objects/refs live in /tmp/lane-proxyfetch.git (shared with the main repo's objects), index in /tmp.
# usage: ./lane-git.sh status | add -A | commit -m ... | push -u fork fix/10178-esbuild-cycle-exports | log --oneline -3   (branch: fix/10270-proxy-value-shapes)
export GIT_DIR=/tmp/lane-proxyfetch.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-proxyfetch GIT_INDEX_FILE=/tmp/lane-proxyfetch.index
[ -f "$GIT_INDEX_FILE" ] || git read-tree HEAD
exec git "$@"
