#!/bin/bash
#
# Integration test for the migration orchestrator using real workflow data.
# Copies workflow files from a source project, runs migrate.sh, and verifies:
#   - Old per-file log is normalized to per-migration format
#   - All migrations skip (files already in post-migration format)
#   - No files are modified
#   - Second run also skips cleanly
#   - Fresh run (no log) executes all migrations without corrupting files
#
# Usage:
#   bash tests/scripts/test-migration-integration.sh /path/to/source/docs/workflow
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."
MIGRATE_SCRIPT="$PROJECT_ROOT/skills/migrate/scripts/migrate.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Source workflow directory (passed as argument)
SOURCE_WORKFLOW="${1:?Usage: $0 /path/to/source/docs/workflow}"

if [ ! -d "$SOURCE_WORKFLOW" ]; then
    echo "Error: Source workflow directory not found: $SOURCE_WORKFLOW"
    exit 1
fi

# Create a temporary working directory
WORK_DIR=$(mktemp -d)
trap "rm -rf $WORK_DIR" EXIT

echo "Source:    $SOURCE_WORKFLOW"
echo "Work dir:  $WORK_DIR"
echo ""

#
# Helper functions
#

assert_equals() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Expected: $expected"
        echo -e "    Actual:   $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_contains() {
    local content="$1"
    local expected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if echo "$content" | grep -q -- "$expected"; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Expected to find: $expected"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_not_contains() {
    local content="$1"
    local unexpected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if ! echo "$content" | grep -q -- "$unexpected"; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Should NOT find: $unexpected"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local description="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    File not found: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

copy_fresh() {
    rm -rf "$WORK_DIR/docs"
    cp -R "$(dirname "$SOURCE_WORKFLOW")" "$WORK_DIR/docs"
    # Remove session files (ephemeral, not relevant)
    rm -rf "$WORK_DIR/docs/workflow/.cache/sessions"
}

run_migrate() {
    cd "$WORK_DIR"
    bash "$MIGRATE_SCRIPT" 2>&1
}

# Snapshot all workflow file checksums for comparison
snapshot_files() {
    find "$WORK_DIR/docs/workflow" -type f -not -path '*/.cache/*' -not -name '.DS_Store' | sort | while read -r f; do
        md5 -q "$f" 2>/dev/null || md5sum "$f" 2>/dev/null | awk '{print $1}'
    done
}

# ============================================================================
# TEST 1: Log normalization (per-file → per-migration)
# ============================================================================

echo -e "${YELLOW}Test: Old per-file log normalized to per-migration format${NC}"
copy_fresh

# Verify we start with old format
old_log=$(cat "$WORK_DIR/docs/workflow/.cache/migrations.log")
assert_contains "$old_log" ": 001" "Old log has per-file format entries"

old_line_count=$(wc -l < "$WORK_DIR/docs/workflow/.cache/migrations.log" | tr -d ' ')
TESTS_RUN=$((TESTS_RUN + 1))
if [ "$old_line_count" -gt 7 ]; then
    echo -e "  ${GREEN}✓${NC} Old log has $old_line_count entries (more than 7 — per-file bloat)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${RED}✗${NC} Old log should have more than 7 entries (has $old_line_count)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

run_migrate > /dev/null

# Check normalized log
new_log=$(cat "$WORK_DIR/docs/workflow/.cache/migrations.log")
new_line_count=$(wc -l < "$WORK_DIR/docs/workflow/.cache/migrations.log" | tr -d ' ')

assert_equals "$new_line_count" "8" "Normalized log has exactly 8 entries"
assert_not_contains "$new_log" ": " "No per-file colon-space entries remain"

# Verify each migration ID is present
for id in 001 002 003 004 005 006 007 008; do
    assert_contains "$new_log" "^${id}$" "Migration $id recorded"
done

echo ""

# ============================================================================
# TEST 2: First run applies pending migrations, second run skips all
# ============================================================================

echo -e "${YELLOW}Test: First run applies pending migrations, second run fully skips${NC}"
copy_fresh

# First run — normalizes log + runs any new migrations (e.g. 008)
run_migrate > /dev/null

# Snapshot the now-fully-migrated state
before=$(snapshot_files)

# Second run — everything should skip at orchestrator level
output=$(run_migrate)
after=$(snapshot_files)

assert_contains "$output" "No changes needed" "Second run: no changes needed"
assert_equals "$after" "$before" "Second run: no files modified"

echo ""

# ============================================================================
# TEST 3: Third run also skips (stable state)
# ============================================================================

echo -e "${YELLOW}Test: Third run also skips — stable state${NC}"
before=$(snapshot_files)

output=$(run_migrate)
after=$(snapshot_files)

assert_contains "$output" "No changes needed" "Third run: no changes needed"
assert_equals "$after" "$before" "Third run: no files modified"

echo ""

# ============================================================================
# TEST 4: Fresh run (no log) — all migrations execute, content guards prevent corruption
# ============================================================================

echo -e "${YELLOW}Test: Fresh run with no log — content guards prevent corruption${NC}"

# Snapshot the fully-migrated files (from tests above)
before=$(snapshot_files)

# Delete the migration log to simulate fresh project
rm "$WORK_DIR/docs/workflow/.cache/migrations.log"

output=$(run_migrate)
after=$(snapshot_files)

# Log should exist with all migrations
assert_file_exists "$WORK_DIR/docs/workflow/.cache/migrations.log" "Log file created"
fresh_log=$(cat "$WORK_DIR/docs/workflow/.cache/migrations.log")
fresh_count=$(wc -l < "$WORK_DIR/docs/workflow/.cache/migrations.log" | tr -d ' ')

assert_equals "$fresh_count" "8" "Fresh log has exactly 8 entries"

for id in 001 002 003 004 005 006 007 008; do
    assert_contains "$fresh_log" "^${id}$" "Fresh run: migration $id recorded"
done

# Content guards should prevent any changes — files already in post-migration format
assert_equals "$after" "$before" "Fresh run: no files corrupted (content guards worked)"
assert_contains "$output" "No changes needed" "Fresh run: output confirms no changes"

echo ""

# ============================================================================
# TEST 5: Verify specific file integrity
# ============================================================================

echo -e "${YELLOW}Test: Spot-check file integrity after fresh migration run${NC}"

# Discussion files should still have frontmatter
for disc_file in "$WORK_DIR/docs/workflow/discussion/"*.md; do
    [ -f "$disc_file" ] || continue
    first_line=$(head -1 "$disc_file")
    name=$(basename "$disc_file")
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$first_line" = "---" ]; then
        echo -e "  ${GREEN}✓${NC} discussion/$name has frontmatter"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} discussion/$name should start with ---"
        echo -e "    Actual first line: $first_line"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

# Specs should be in topic directories
for spec_dir in "$WORK_DIR/docs/workflow/specification"/*/; do
    [ -d "$spec_dir" ] || continue
    name=$(basename "$spec_dir")
    assert_file_exists "${spec_dir}specification.md" "specification/$name/specification.md exists"
done

# Plans should be in topic directories
for plan_dir in "$WORK_DIR/docs/workflow/planning"/*/; do
    [ -d "$plan_dir" ] || continue
    name=$(basename "$plan_dir")
    assert_file_exists "${plan_dir}plan.md" "planning/$name/plan.md exists"
done

# Plans with local-markdown format should have tasks/ subdirectory
for plan_dir in "$WORK_DIR/docs/workflow/planning"/*/; do
    [ -d "$plan_dir" ] || continue
    name=$(basename "$plan_dir")
    if [ -d "${plan_dir}tasks" ]; then
        task_count=$(find "${plan_dir}tasks" -name "*.md" -type f | wc -l | tr -d ' ')
        TESTS_RUN=$((TESTS_RUN + 1))
        if [ "$task_count" -gt 0 ]; then
            echo -e "  ${GREEN}✓${NC} planning/$name/tasks/ has $task_count task files"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "  ${RED}✗${NC} planning/$name/tasks/ is empty"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
done

echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "========================================"
echo -e "Tests run: $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "========================================"

if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi
