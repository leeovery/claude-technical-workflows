#!/usr/bin/env bash
#
# migrate.sh
#
# Keeps workflow files in sync with the current system design.
# Runs all migration scripts in order, tracking progress to avoid redundant processing.
#
# Usage:
#   ./scripts/migrate.sh
#
# Tracking:
#   Migrations are tracked in docs/workflow/.state/migrations
#   Format: "migration_id" per line (e.g., "001", "002")
#   The orchestrator checks/records migration IDs — individual scripts don't track.
#   Delete the log file to force re-running all migrations.
#
# Adding new migrations:
#   1. Create scripts/migrations/NNN-description.sh (e.g., 002-spec-frontmatter.sh)
#   2. The script will be run automatically in numeric order
#   3. Each migration script receives helper functions via source: report_update, report_skip
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
TRACKING_FILE="docs/workflow/.state/migrations"

# Track counts for final report
FILES_UPDATED=0
FILES_SKIPPED=0
MIGRATIONS_RUN=0

# Ensure state directory exists
mkdir -p "$(dirname "$TRACKING_FILE")"

# Self-healing: merge entries from old locations into .state/migrations
OLD_CACHE_LOG="docs/workflow/.cache/migrations.log"
OLD_CACHE_FILE="docs/workflow/.cache/migrations"
if [ -f "$OLD_CACHE_LOG" ] || [ -f "$OLD_CACHE_FILE" ]; then
    { cat "$OLD_CACHE_LOG" 2>/dev/null; cat "$OLD_CACHE_FILE" 2>/dev/null; cat "$TRACKING_FILE" 2>/dev/null; } | sort -u > "${TRACKING_FILE}.tmp"
    mv "${TRACKING_FILE}.tmp" "$TRACKING_FILE"
    rm -f "$OLD_CACHE_LOG" "$OLD_CACHE_FILE"
fi

# Touch tracking file if it doesn't exist
touch "$TRACKING_FILE"

#
# Helper function: Report a file update (for migration scripts to call)
# Usage: report_update "filepath" "description"
#
report_update() {
    local filepath="$1"
    local description="$2"
    echo "  ✓ $filepath ($description)"
    FILES_UPDATED=$((FILES_UPDATED + 1))
}

#
# Helper function: Report a file skip (for migration scripts to call)
# Usage: report_skip "filepath"
#
report_skip() {
    local filepath="$1"
    FILES_SKIPPED=$((FILES_SKIPPED + 1))
}

# Export functions and variables for migration scripts
export -f report_update report_skip
export TRACKING_FILE FILES_UPDATED FILES_SKIPPED

#
# Main: Run all migrations in order
#

# Check if migrations directory exists and has scripts
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo "No migrations directory found at $MIGRATIONS_DIR"
    exit 0
fi

# Find all migration scripts, sorted by name (numeric order)
mapfile -t MIGRATION_SCRIPTS < <(find "$MIGRATIONS_DIR" -name "*.sh" -type f | sort)

if [ ${#MIGRATION_SCRIPTS[@]} -eq 0 ]; then
    echo "No migration scripts found."
    exit 0
fi

# One-time: convert old per-file format to per-migration format
# Old: "docs/workflow/discussion/auth.md: 001" → extracts "001"
# New: "001" → already correct
if grep -q ': [0-9]' "$TRACKING_FILE" 2>/dev/null; then
    grep -oE '[0-9]+$' "$TRACKING_FILE" | sort -u > "${TRACKING_FILE}.tmp"
    mv "${TRACKING_FILE}.tmp" "$TRACKING_FILE"
fi

for script in "${MIGRATION_SCRIPTS[@]}"; do
    # Extract migration ID from filename (e.g., "001" from "001-discussion-frontmatter.sh")
    migration_id=$(basename "$script" .sh | grep -oE '^[0-9]+')

    if [ -z "$migration_id" ]; then
        echo "Warning: Skipping $script (no numeric prefix)"
        continue
    fi

    # Global check — skip entire migration if already recorded
    if grep -q "^${migration_id}$" "$TRACKING_FILE" 2>/dev/null; then
        continue
    fi

    # Source and run the migration script
    # The script has access to: report_update, report_skip
    # shellcheck source=/dev/null
    source "$script"

    echo "$migration_id" >> "$TRACKING_FILE"
    MIGRATIONS_RUN=$((MIGRATIONS_RUN + 1))
done

# Report results
if [ "$FILES_UPDATED" -gt 0 ]; then
    echo ""
    echo "$FILES_UPDATED file(s) migrated. Review with \`git diff\`, then proceed."
else
    echo "[SKIP] No changes needed"
fi
