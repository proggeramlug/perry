#!/bin/bash
# sandbox-safe git for this lane: objects/refs in /tmp/perry-regexp-lane.git, index in /tmp. usage: ./lane-git.sh <git args>
export GIT_DIR=/tmp/perry-regexp-lane.git GIT_WORK_TREE=/Users/amlug/projects/perry/agent-trees/opencode-regex-cache GIT_INDEX_FILE=/tmp/lane-regex-cache.index
[ -f "$GIT_INDEX_FILE" ] || git read-tree HEAD
exec git "$@"
