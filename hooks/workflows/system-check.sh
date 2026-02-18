#!/usr/bin/env bash
#
# system-check.sh
#
# Bootstrap hook for workflow skills. Two responsibilities:
# 1. Hook installation: ensure .claude/settings.json has workflow hooks configured
# 2. Run migrations: call migrate.sh and report if files were updated
#
# This script is called as a PreToolUse hook. Stdin contains JSON about the
# tool being called (not used by this script).
#

set -eo pipefail

SETTINGS_FILE="$CLAUDE_PROJECT_DIR/.claude/settings.json"
MIGRATE_SCRIPT="$CLAUDE_PROJECT_DIR/.claude/skills/migrate/scripts/migrate.sh"

# ─── Hook Installation ───

install_hooks() {
  local hooks_config
  hooks_config=$(cat <<'HOOKJSON'
{
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
}
HOOKJSON
)

  if [ -f "$SETTINGS_FILE" ]; then
    # Merge hooks into existing settings, preserving all other keys
    local merged
    merged=$(jq -s '.[0] * .[1]' "$SETTINGS_FILE" <(echo "$hooks_config"))
    echo "$merged" > "$SETTINGS_FILE"
  else
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    echo "$hooks_config" | jq '.' > "$SETTINGS_FILE"
  fi
}

# Check if hooks are already configured
needs_hooks=false
if [ ! -f "$SETTINGS_FILE" ]; then
  needs_hooks=true
elif ! jq -e '.hooks.SessionStart' "$SETTINGS_FILE" >/dev/null 2>&1; then
  needs_hooks=true
fi

if [ "$needs_hooks" = true ]; then
  install_hooks
  cat <<'EOF'
{ "continue": false, "stopReason": "Workflow hooks configured. Restart Claude Code to activate compaction recovery, then re-invoke your skill." }
EOF
  exit 0
fi

# ─── Run Migrations ───

if [ -x "$MIGRATE_SCRIPT" ]; then
  migration_output=$(cd "$CLAUDE_PROJECT_DIR" && bash "$MIGRATE_SCRIPT" 2>&1) || true

  # Check if migrations actually updated files (output contains "migrated")
  if echo "$migration_output" | grep -q "migrated"; then
    # Build additionalContext with migration report
    context="MIGRATIONS APPLIED\n\n${migration_output}\n\nReview the changes with \`git diff\`, then proceed with your original task."
    # Escape for JSON
    json_context=$(printf '%s' "$context" | jq -Rs '.')
    echo "{ \"hookSpecificOutput\": { \"additionalContext\": ${json_context} } }"
    exit 0
  fi
fi

# No changes needed — silent exit
exit 0
