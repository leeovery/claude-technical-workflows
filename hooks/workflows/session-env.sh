#!/usr/bin/env bash
#
# session-env.sh
#
# SessionStart hook (startup|resume|clear).
# Reads session_id from stdin JSON and writes it to CLAUDE_ENV_FILE
# so entry-point skills can reference the session ID.
#

# Extract session_id from stdin JSON
session_id=$(cat | grep -o '"session_id" *: *"[^"]*"' | sed 's/.*: *"//;s/"//')

if [ -z "$session_id" ]; then
  echo "[session-env] WARNING: Could not parse session_id from stdin" >&2
  exit 0
fi

if [ -z "$CLAUDE_ENV_FILE" ]; then
  echo "[session-env] WARNING: CLAUDE_ENV_FILE not set — cannot persist CLAUDE_SESSION_ID" >&2
  exit 0
fi

echo "export CLAUDE_SESSION_ID=${session_id}" >> "$CLAUDE_ENV_FILE"

exit 0
