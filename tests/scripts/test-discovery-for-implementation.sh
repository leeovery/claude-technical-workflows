#!/bin/bash
#
# Tests the discovery-for-implementation.sh script against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../scripts/discovery-for-implementation.sh"

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
    # Clean up from previous test
    rm -rf "$TEST_DIR/docs"
    mkdir -p "$TEST_DIR/docs/workflow"
}

run_discovery() {
    cd "$TEST_DIR"
    bash "$DISCOVERY_SCRIPT" 2>/dev/null
}

assert_contains() {
    local output="$1"
    local expected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if echo "$output" | grep -q -- "$expected"; then
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

    if ! echo "$output" | grep -q -- "$pattern"; then
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

# ============================================================================
# TEST CASES
# ============================================================================

echo -e "${YELLOW}Test: No planning directory${NC}"
setup_fixture
# Don't create planning directory
output=$(run_discovery)

assert_contains "$output" "plans:" "Has plans section"
assert_contains "$output" "exists: false" "Plans don't exist"
assert_contains "$output" "count: 0" "Plan count is 0"
assert_contains "$output" "scenario: \"no_plans\"" "Scenario is no_plans"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Empty planning directory${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"
output=$(run_discovery)

assert_contains "$output" "exists: false" "Plans don't exist (empty dir)"
assert_contains "$output" "scenario: \"no_plans\"" "Scenario is no_plans"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Single plan with full frontmatter${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"
cat > "$TEST_DIR/docs/workflow/planning/user-auth.md" << 'EOF'
---
topic: user-auth
status: in-progress
date: 2024-01-15
format: local-markdown
specification: user-auth.md
---

# Implementation Plan: User Authentication

## Overview

Content here.
EOF

output=$(run_discovery)

assert_contains "$output" "exists: true" "Plans exist"
assert_contains "$output" "count: 1" "Plan count is 1"
assert_contains "$output" "name: \"user-auth\"" "Plan name extracted"
assert_contains "$output" "topic: \"user-auth\"" "Topic extracted"
assert_contains "$output" "status: \"in-progress\"" "Status extracted"
assert_contains "$output" "date: \"2024-01-15\"" "Date extracted"
assert_contains "$output" "format: \"local-markdown\"" "Format extracted"
assert_contains "$output" "specification: \"user-auth.md\"" "Specification extracted"
assert_contains "$output" "scenario: \"single_plan\"" "Scenario is single_plan"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Multiple plans${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/feature-a.md" << 'EOF'
---
topic: feature-a
status: in-progress
date: 2024-01-10
format: local-markdown
specification: feature-a.md
---

# Implementation Plan: Feature A
EOF

cat > "$TEST_DIR/docs/workflow/planning/feature-b.md" << 'EOF'
---
topic: feature-b
status: concluded
date: 2024-01-20
format: local-markdown
specification: feature-b.md
---

# Implementation Plan: Feature B
EOF

output=$(run_discovery)

assert_contains "$output" "count: 2" "Plan count is 2"
assert_contains "$output" "name: \"feature-a\"" "First plan found"
assert_contains "$output" "name: \"feature-b\"" "Second plan found"
assert_contains "$output" "scenario: \"multiple_plans\"" "Scenario is multiple_plans"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with concluded status${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/completed-feature.md" << 'EOF'
---
topic: completed-feature
status: concluded
date: 2024-02-01
format: local-markdown
specification: completed-feature.md
---

# Implementation Plan: Completed Feature
EOF

output=$(run_discovery)

assert_contains "$output" "status: \"concluded\"" "Concluded status preserved"
assert_contains "$output" "scenario: \"single_plan\"" "Concluded plans still shown"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with linked specification that exists${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"
mkdir -p "$TEST_DIR/docs/workflow/specification"

cat > "$TEST_DIR/docs/workflow/planning/with-spec.md" << 'EOF'
---
topic: with-spec
status: in-progress
date: 2024-03-01
format: local-markdown
specification: with-spec.md
---

# Implementation Plan: With Spec
EOF

cat > "$TEST_DIR/docs/workflow/specification/with-spec.md" << 'EOF'
---
topic: with-spec
status: concluded
---

# Specification: With Spec
EOF

output=$(run_discovery)

assert_contains "$output" "specification_exists: true" "Specification exists flag is true"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with linked specification that doesn't exist${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/no-spec.md" << 'EOF'
---
topic: no-spec
status: in-progress
date: 2024-03-01
format: local-markdown
specification: missing-spec.md
---

# Implementation Plan: No Spec
EOF

output=$(run_discovery)

assert_contains "$output" "specification_exists: false" "Specification exists flag is false"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Environment setup file exists with setup required${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/test.md" << 'EOF'
---
topic: test
status: in-progress
date: 2024-01-01
format: local-markdown
specification: test.md
---

# Implementation Plan: Test
EOF

cat > "$TEST_DIR/docs/workflow/environment-setup.md" << 'EOF'
# Environment Setup

Run the following commands:

1. npm install
2. cp .env.example .env
EOF

output=$(run_discovery)

assert_contains "$output" "setup_file_exists: true" "Setup file exists"
assert_contains "$output" "requires_setup: true" "Setup is required"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Environment setup file with no special setup required${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/test.md" << 'EOF'
---
topic: test
status: in-progress
date: 2024-01-01
format: local-markdown
specification: test.md
---

# Implementation Plan: Test
EOF

cat > "$TEST_DIR/docs/workflow/environment-setup.md" << 'EOF'
# Environment Setup

No special setup required.
EOF

output=$(run_discovery)

assert_contains "$output" "setup_file_exists: true" "Setup file exists"
assert_contains "$output" "requires_setup: false" "No setup required"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: No environment setup file${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/test.md" << 'EOF'
---
topic: test
status: in-progress
date: 2024-01-01
format: local-markdown
specification: test.md
---

# Implementation Plan: Test
EOF

output=$(run_discovery)

assert_contains "$output" "setup_file_exists: false" "Setup file doesn't exist"
assert_contains "$output" "requires_setup: unknown" "Setup requirement unknown"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with missing frontmatter fields (defaults)${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/minimal.md" << 'EOF'
---
topic: minimal
---

# Implementation Plan: Minimal
EOF

output=$(run_discovery)

assert_contains "$output" "name: \"minimal\"" "Name from filename"
assert_contains "$output" "topic: \"minimal\"" "Topic from frontmatter"
assert_contains "$output" "status: \"unknown\"" "Status defaults to unknown"
assert_contains "$output" "format: \"local-markdown\"" "Format defaults to local-markdown"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan without frontmatter (legacy edge case)${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/no-frontmatter.md" << 'EOF'
# Implementation Plan: No Frontmatter

## Overview

This plan has no frontmatter at all.
EOF

output=$(run_discovery)

assert_contains "$output" "name: \"no-frontmatter\"" "Name from filename"
assert_contains "$output" "topic: \"no-frontmatter\"" "Topic defaults to filename"
assert_contains "$output" "status: \"unknown\"" "Status defaults to unknown"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Different format value${NC}"
setup_fixture
mkdir -p "$TEST_DIR/docs/workflow/planning"

cat > "$TEST_DIR/docs/workflow/planning/beads-plan.md" << 'EOF'
---
topic: beads-plan
status: in-progress
date: 2024-04-01
format: beads
specification: beads-plan.md
---

# Implementation Plan: Beads Plan
EOF

output=$(run_discovery)

assert_contains "$output" "format: \"beads\"" "Non-default format preserved"

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
