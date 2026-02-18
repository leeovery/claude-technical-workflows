#!/usr/bin/env bash
#
# compact-recovery.sh
#
# SessionStart hook (compact).
# Reads session_id from stdin, looks for saved session state,
# and injects recovery context so the model can resume work.
#

set -eo pipefail

# Read session_id from stdin JSON
session_id=$(jq -r '.session_id // empty' < /dev/stdin)

if [ -z "$session_id" ]; then
  exit 0
fi

SESSION_FILE="$CLAUDE_PROJECT_DIR/docs/workflow/.cache/sessions/${session_id}.yaml"

if [ ! -f "$SESSION_FILE" ]; then
  exit 0
fi

# Parse YAML fields (simple key: value format)
topic=$(grep '^topic:' "$SESSION_FILE" | awk '{print $2}')
skill=$(grep '^skill:' "$SESSION_FILE" | awk '{print $2}')
artifact=$(grep '^artifact:' "$SESSION_FILE" | awk '{print $2}')

# Check for pipeline section
has_pipeline=false
if grep -q '^pipeline:' "$SESSION_FILE"; then
  has_pipeline=true
  # Extract after_conclude content (indented block after "after_conclude: |")
  pipeline_content=$(awk '
    /^  after_conclude:/ { capture=1; next }
    capture && /^[^ ]/ { exit }
    capture && /^    / { sub(/^    /, ""); print }
  ' "$SESSION_FILE")
fi

# Build additionalContext
context="CONTEXT COMPACTION — SESSION RECOVERY

Context was just compacted. Follow these instructions carefully.

─── IMMEDIATE: Resume current work ───

You are working on topic '${topic}'.
Skill: ${skill}

1. Re-read that skill file completely
2. Follow its 'Resuming After Context Refresh' section
3. Re-read the artifact: ${artifact}
4. Continue working until the skill reaches its natural conclusion

The files on disk are authoritative — not the conversation summary."

if [ "$has_pipeline" = true ] && [ -n "$pipeline_content" ]; then
  context="${context}

─── AFTER CONCLUSION ONLY ───

${pipeline_content}

Do NOT enter plan mode or invoke continue-feature until the current
phase is complete. Finish the current phase first."
fi

# Escape for JSON and output
json_context=$(printf '%s' "$context" | jq -Rs '.')
echo "{ \"hookSpecificOutput\": { \"hookEventName\": \"SessionStart\", \"additionalContext\": ${json_context} } }"

exit 0
