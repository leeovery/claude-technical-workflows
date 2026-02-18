#!/usr/bin/env bash
#
# system-check.sh
#
# Bootstrap hook for workflow skills. Ensures project-level hooks
# (compaction recovery, session tracking) are installed in
# .claude/settings.json.
#
# Called as a PreToolUse hook from skill frontmatter.
# Uses jq if available, falls back to node, then to manual instructions.
#

# Consume stdin (PreToolUse sends JSON — must be drained)
cat > /dev/null 2>&1 || true

# Resolve project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$PROJECT_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
fi

SETTINGS_FILE="$PROJECT_DIR/.claude/settings.json"

# ─── Detection (grep only) ───

has_our_hooks() {
  [ -f "$SETTINGS_FILE" ] &&
    grep -q "hooks/workflows/session-env.sh" "$SETTINGS_FILE" 2>/dev/null &&
    grep -q "hooks/workflows/compact-recovery.sh" "$SETTINGS_FILE" 2>/dev/null &&
    grep -q "hooks/workflows/session-cleanup.sh" "$SETTINGS_FILE" 2>/dev/null
}

if has_our_hooks; then
  exit 0
fi

# ─── Hook JSON templates ───
# $CLAUDE_PROJECT_DIR below is intentionally literal (expanded by Claude Code at runtime)
# shellcheck disable=SC2016
HOOKS_ONLY='{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/session-env.sh" }]
      },
      {
        "matcher": "compact",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/compact-recovery.sh" }]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/session-cleanup.sh" }]
      }
    ]
  }
}'

# ─── Installation ───

mkdir -p "$(dirname "$SETTINGS_FILE")"

if [ ! -f "$SETTINGS_FILE" ] || [ ! -s "$SETTINGS_FILE" ]; then
  # No file or empty — write fresh
  printf '%s\n' "$HOOKS_ONLY" > "$SETTINGS_FILE"

elif command -v jq >/dev/null 2>&1; then
  # Merge using jq — append our entries to existing arrays
  merged=$(jq \
    --argjson ours "$HOOKS_ONLY" \
    '
      .hooks //= {} |
      .hooks.SessionStart = ((.hooks.SessionStart // []) + $ours.hooks.SessionStart) |
      .hooks.SessionEnd = ((.hooks.SessionEnd // []) + $ours.hooks.SessionEnd)
    ' "$SETTINGS_FILE")
  printf '%s\n' "$merged" > "$SETTINGS_FILE"

elif command -v node >/dev/null 2>&1; then
  # Merge using node
  node -e "
    const fs = require('fs');
    const existing = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
    const ours = JSON.parse(process.argv[2]);
    existing.hooks = existing.hooks || {};
    existing.hooks.SessionStart = (existing.hooks.SessionStart || []).concat(ours.hooks.SessionStart);
    existing.hooks.SessionEnd = (existing.hooks.SessionEnd || []).concat(ours.hooks.SessionEnd);
    fs.writeFileSync(process.argv[1], JSON.stringify(existing, null, 2) + '\n');
  " "$SETTINGS_FILE" "$HOOKS_ONLY"

else
  # No tools available — write hooks to separate file with instructions
  printf '%s\n' "$HOOKS_ONLY" > "${SETTINGS_FILE%.json}.workflow-hooks.json"
  echo '{ "continue": false, "stopReason": "Your .claude/settings.json needs workflow hooks but neither jq nor node is available to merge automatically. The hooks have been written to .claude/settings.workflow-hooks.json — please merge the SessionStart and SessionEnd entries into your settings.json, then restart Claude Code." }'
  exit 0
fi

echo '{ "continue": false, "stopReason": "Workflow hooks configured. Restart Claude Code to activate compaction recovery, then re-invoke your skill." }'
exit 0
