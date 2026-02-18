#!/usr/bin/env bash
#
# session-cleanup.sh
#
# SessionEnd hook.
# Reads session_id from stdin JSON and removes the session state file if it exists.
#

set -eo pipefail

# Read session_id from stdin JSON
session_id=$(jq -r '.session_id // empty' < /dev/stdin)

if [ -n "$session_id" ]; then
  session_file="$CLAUDE_PROJECT_DIR/docs/workflow/.cache/sessions/${session_id}.yaml"
  if [ -f "$session_file" ]; then
    rm -f "$session_file"
  fi
fi

exit 0
