#!/usr/bin/env bash
#
# compact-recovery.sh
#
# SessionStart hook (compact).
# Reads session_id from stdin, looks for saved session state,
# and injects recovery context so the model can resume work.
#

# Resolve project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$PROJECT_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
fi

# Extract session_id from stdin JSON
session_id=$(cat | grep -o '"session_id" *: *"[^"]*"' | sed 's/.*: *"//;s/"//')

if [ -z "$session_id" ]; then
  exit 0
fi

SESSION_FILE="$PROJECT_DIR/.workflows/.cache/sessions/${session_id}.yaml"

if [ ! -f "$SESSION_FILE" ]; then
  exit 0
fi

# Parse YAML fields (simple key: value format)
topic=$(grep '^topic:' "$SESSION_FILE" | awk '{print $2}')
skill=$(grep '^skill:' "$SESSION_FILE" | awk '{print $2}')
artifact=$(grep '^artifact:' "$SESSION_FILE" | awk '{print $2}')

# Build additionalContext
context="CONTEXT COMPACTION — SESSION RECOVERY

Context was just compacted. Follow these instructions carefully.

─── IMMEDIATE: Resume current work ───
$([ -n "$topic" ] && echo "
You are working on topic '${topic}'.")
Skill: ${skill}

1. Re-read that skill file completely
2. Follow its 'Resuming After Context Refresh' section
3. Re-read the artifact: ${artifact}
4. Continue working until the skill reaches its natural conclusion

The files on disk are authoritative — not the conversation summary.

When the processing skill concludes, it will invoke workflow:bridge automatically
if the artifact has a work_type set. Do not manually handle pipeline continuation."

# Escape context for JSON output
json_context=$(printf '%s' "$context" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')
json_context="\"${json_context%\\n}\""

echo "{ \"hookSpecificOutput\": { \"hookEventName\": \"SessionStart\", \"additionalContext\": ${json_context} } }"

exit 0
