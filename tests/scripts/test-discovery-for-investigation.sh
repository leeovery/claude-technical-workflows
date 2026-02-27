#!/bin/bash
#
# Tests the discovery script for start-investigation.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/start-investigation/scripts/discovery.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Create a temporary directory for test fixtures
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

echo "Test directory: $TEST_DIR"
echo ""

#
# Helper functions
#

setup_fixture() {
    rm -rf "$TEST_DIR/.workflows"
    mkdir -p "$TEST_DIR/.workflows"
}

run_discovery() {
    cd "$TEST_DIR"
    /bin/bash "$DISCOVERY_SCRIPT" 2>/dev/null
}

assert_contains() {
    local output="$1"
    local expected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if echo "$output" | grep -qF -- "$expected"; then
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
    local output="$1"
    local pattern="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if ! echo "$output" | grep -qF -- "$pattern"; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Did not expect to find: $pattern"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ──────────────────────────────────────
# Tests
# ──────────────────────────────────────

test_fresh_state() {
    echo -e "${YELLOW}Test: Fresh state (no investigations)${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'investigations:' "Has investigations section"
    assert_contains "$output" 'exists: false' "No investigations exist"
    assert_contains "$output" 'total: 0' "Total count is 0"
    assert_contains "$output" 'in_progress: 0' "In-progress count is 0"
    assert_contains "$output" 'concluded: 0' "Concluded count is 0"
    assert_contains "$output" 'scenario: "fresh"' "Scenario is fresh"
    echo ""
}

test_single_in_progress() {
    echo -e "${YELLOW}Test: Single in-progress investigation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: in-progress
work_type: bugfix
date: 2026-02-20
---
# Investigation: Login Crash
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'exists: true' "Investigations exist"
    assert_contains "$output" 'topic: "login-crash"' "Found login-crash topic"
    assert_contains "$output" 'status: "in-progress"' "Status is in-progress"
    assert_contains "$output" 'work_type: "bugfix"' "Work type is bugfix"
    assert_contains "$output" 'date: "2026-02-20"' "Date extracted"
    assert_contains "$output" 'total: 1' "Total count is 1"
    assert_contains "$output" 'in_progress: 1' "In-progress count is 1"
    assert_contains "$output" 'concluded: 0' "Concluded count is 0"
    assert_contains "$output" 'scenario: "has_investigations"' "Scenario is has_investigations"
    echo ""
}

test_single_concluded() {
    echo -e "${YELLOW}Test: Single concluded investigation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/null-pointer"
    cat > "$TEST_DIR/.workflows/investigation/null-pointer/investigation.md" << 'EOF'
---
topic: null-pointer
status: concluded
work_type: bugfix
date: 2026-02-18
---
# Investigation: Null Pointer
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "concluded"' "Status is concluded"
    assert_contains "$output" 'total: 1' "Total count is 1"
    assert_contains "$output" 'in_progress: 0' "In-progress count is 0"
    assert_contains "$output" 'concluded: 1' "Concluded count is 1"
    echo ""
}

test_multiple_mixed() {
    echo -e "${YELLOW}Test: Multiple investigations with mixed statuses${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/investigation/null-pointer"
    mkdir -p "$TEST_DIR/.workflows/investigation/timeout-error"

    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: in-progress
work_type: bugfix
---
EOF

    cat > "$TEST_DIR/.workflows/investigation/null-pointer/investigation.md" << 'EOF'
---
topic: null-pointer
status: concluded
work_type: bugfix
---
EOF

    cat > "$TEST_DIR/.workflows/investigation/timeout-error/investigation.md" << 'EOF'
---
topic: timeout-error
status: in-progress
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'total: 3' "Total count is 3"
    assert_contains "$output" 'in_progress: 2' "In-progress count is 2"
    assert_contains "$output" 'concluded: 1' "Concluded count is 1"
    assert_contains "$output" 'topic: "login-crash"' "Found login-crash"
    assert_contains "$output" 'topic: "null-pointer"' "Found null-pointer"
    assert_contains "$output" 'topic: "timeout-error"' "Found timeout-error"
    echo ""
}

test_no_status_defaults_in_progress() {
    echo -e "${YELLOW}Test: Missing status defaults to in-progress${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/legacy-bug"
    cat > "$TEST_DIR/.workflows/investigation/legacy-bug/investigation.md" << 'EOF'
---
topic: legacy-bug
work_type: bugfix
---
# Investigation without status
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "in-progress"' "Status defaults to in-progress"
    assert_contains "$output" 'in_progress: 1' "Counted as in-progress"
    echo ""
}

test_no_work_type_defaults_bugfix() {
    echo -e "${YELLOW}Test: Missing work_type defaults to bugfix${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/old-bug"
    cat > "$TEST_DIR/.workflows/investigation/old-bug/investigation.md" << 'EOF'
---
topic: old-bug
status: in-progress
---
# Investigation without work_type
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'work_type: "bugfix"' "Work type defaults to bugfix"
    echo ""
}

test_empty_investigation_dir() {
    echo -e "${YELLOW}Test: Investigation directory exists but is empty${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation"

    local output=$(run_discovery)

    assert_contains "$output" 'exists: false' "No investigations exist"
    assert_contains "$output" 'scenario: "fresh"' "Scenario is fresh"
    echo ""
}

test_dir_without_investigation_file() {
    echo -e "${YELLOW}Test: Investigation directory without investigation.md${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/orphan-dir"
    echo "not an investigation" > "$TEST_DIR/.workflows/investigation/orphan-dir/notes.md"

    local output=$(run_discovery)

    # Dir is non-empty so exists: true, but no valid investigation files
    assert_contains "$output" 'exists: true' "Dir exists (non-empty)"
    assert_contains "$output" 'total: 0' "Total count is 0"
    assert_not_contains "$output" 'topic: "orphan-dir"' "Orphan dir not listed"
    assert_contains "$output" 'scenario: "fresh"' "Scenario is fresh (no valid investigations)"
    echo ""
}

test_date_field_absent_when_missing() {
    echo -e "${YELLOW}Test: Date field absent when missing from frontmatter${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/no-date-bug"
    cat > "$TEST_DIR/.workflows/investigation/no-date-bug/investigation.md" << 'EOF'
---
topic: no-date-bug
status: in-progress
work_type: bugfix
---
# Investigation without date
EOF

    local output=$(run_discovery)

    assert_not_contains "$output" 'date:' "Date line is absent when no date in frontmatter"
    echo ""
}

test_no_frontmatter_file() {
    echo -e "${YELLOW}Test: Investigation file with no frontmatter${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/raw-bug"
    cat > "$TEST_DIR/.workflows/investigation/raw-bug/investigation.md" << 'EOF'
# Just body content, no frontmatter delimiters

Some investigation notes here.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "in-progress"' "Status defaults to in-progress"
    assert_contains "$output" 'work_type: "bugfix"' "Work type defaults to bugfix"
    assert_not_contains "$output" 'date:' "Date line is absent"
    echo ""
}

test_topic_from_dirname_not_frontmatter() {
    echo -e "${YELLOW}Test: Topic comes from directory name, not frontmatter${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/dir-name"
    cat > "$TEST_DIR/.workflows/investigation/dir-name/investigation.md" << 'EOF'
---
topic: different-name
status: in-progress
work_type: bugfix
---
# Investigation
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'topic: "dir-name"' "Topic is directory name"
    assert_not_contains "$output" 'topic: "different-name"' "Frontmatter topic not used"
    echo ""
}

# ──────────────────────────────────────
# Run all tests
# ──────────────────────────────────────

echo "=========================================="
echo "Running discovery-for-investigation tests"
echo "=========================================="
echo ""

test_fresh_state
test_single_in_progress
test_single_concluded
test_multiple_mixed
test_no_status_defaults_in_progress
test_no_work_type_defaults_bugfix
test_empty_investigation_dir
test_dir_without_investigation_file
test_date_field_absent_when_missing
test_no_frontmatter_file
test_topic_from_dirname_not_frontmatter

#
# Summary
#
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Total:  $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
