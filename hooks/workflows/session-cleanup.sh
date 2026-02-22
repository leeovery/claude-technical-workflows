#!/usr/bin/env bash
#
# session-cleanup.sh
#
# SessionEnd hook.
# Reads session_id from stdin JSON and removes the session state file if it exists.
#

# Resolve project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$PROJECT_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
fi

# Extract session_id from stdin JSON
session_id=$(cat | grep -o '"session_id" *: *"[^"]*"' | sed 's/.*: *"//;s/"//')

if [ -n "$session_id" ]; then
  session_file="$PROJECT_DIR/.workflows/.cache/sessions/${session_id}.yaml"
  if [ -f "$session_file" ]; then
    rm -f "$session_file"
  fi
fi

exit 0
