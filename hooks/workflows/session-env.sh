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

if [ -n "$session_id" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export CLAUDE_SESSION_ID=${session_id}" > "$CLAUDE_ENV_FILE"
fi

exit 0
