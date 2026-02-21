#!/usr/bin/env bash
#
# write-session-state.sh
#
# Helper script called by entry-point skills to save session state for
# compaction recovery.
#
# Usage:
#   write-session-state.sh "<topic>" "<skill-path>" "<artifact-path>" [--pipeline "<after-conclude instructions>"]
#
# Requires CLAUDE_SESSION_ID in environment (set by session-env.sh).
#

# Resolve project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$PROJECT_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
fi

if [ -z "$CLAUDE_SESSION_ID" ]; then
  echo "[write-session-state] WARNING: CLAUDE_SESSION_ID not set — session state will not be saved" >&2
  exit 0
fi

topic="$1"
skill="$2"
artifact="$3"
pipeline_content=""

# Parse optional --pipeline flag
shift 3 || true
while [ $# -gt 0 ]; do
  case "$1" in
    --pipeline)
      pipeline_content="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

SESSIONS_DIR="$PROJECT_DIR/.workflows/.cache/sessions"
mkdir -p "$SESSIONS_DIR"

SESSION_FILE="$SESSIONS_DIR/${CLAUDE_SESSION_ID}.yaml"

# Write base fields
cat > "$SESSION_FILE" <<EOF
topic: ${topic}
skill: ${skill}
artifact: ${artifact}
EOF

# Append pipeline section if provided
if [ -n "$pipeline_content" ]; then
  cat >> "$SESSION_FILE" <<EOF
pipeline:
  after_conclude: |
$(echo "$pipeline_content" | sed 's/^/    /')
EOF
fi

exit 0
