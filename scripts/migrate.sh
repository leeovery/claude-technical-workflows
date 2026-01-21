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
#   Migrations are tracked in docs/workflow/.cache/migrations.log
#   Format: "filepath: migration_id" (one per line, append-only)
#   Delete the log file to force re-running all migrations.
#
# Adding new migrations:
#   1. Create scripts/migrations/NNN-description.sh (e.g., 002-spec-frontmatter.sh)
#   2. The script will be run automatically in numeric order
#   3. Each migration script receives helper functions via source
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
TRACKING_FILE="docs/workflow/.cache/migrations.log"

# Track counts for final report
FILES_UPDATED=0
FILES_SKIPPED=0
MIGRATIONS_RUN=0

# Ensure cache directory exists
mkdir -p "$(dirname "$TRACKING_FILE")"

# Touch tracking file if it doesn't exist
touch "$TRACKING_FILE"

#
# Helper function: Check if a migration has been applied to a file
# Usage: is_migrated "filepath" "migration_id"
# Returns: 0 if migrated, 1 if not
#
is_migrated() {
    local filepath="$1"
    local migration_id="$2"
    grep -q "^${filepath}: ${migration_id}$" "$TRACKING_FILE" 2>/dev/null
}

#
# Helper function: Record that a migration was applied to a file
# Usage: record_migration "filepath" "migration_id"
#
record_migration() {
    local filepath="$1"
    local migration_id="$2"
    echo "${filepath}: ${migration_id}" >> "$TRACKING_FILE"
}

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
export -f is_migrated record_migration report_update report_skip
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

echo "Running migrations..."
echo ""

for script in "${MIGRATION_SCRIPTS[@]}"; do
    # Extract migration ID from filename (e.g., "001" from "001-discussion-frontmatter.sh")
    migration_id=$(basename "$script" .sh | grep -oE '^[0-9]+')
    migration_name=$(basename "$script" .sh)

    if [ -z "$migration_id" ]; then
        echo "Warning: Skipping $script (no numeric prefix)"
        continue
    fi

    echo "$migration_name:"

    # Source and run the migration script
    # The script has access to: is_migrated, record_migration, report_update, report_skip
    # shellcheck source=/dev/null
    source "$script"

    MIGRATIONS_RUN=$((MIGRATIONS_RUN + 1))
    echo ""
done

#
# Final report
#
if [ "$FILES_UPDATED" -gt 0 ]; then
    echo "$FILES_UPDATED file(s) updated. Review with \`git diff\`, then proceed."
else
    echo "All documents up to date."
fi
