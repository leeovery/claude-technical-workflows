#!/bin/bash
#
# Tests the discovery script for /start-review against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/start-review/scripts/discovery.sh"

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
mkdir -p "$TEST_DIR/.workflows/planning"
output=$(run_discovery)

assert_contains "$output" "exists: false" "Plans don't exist (empty dir)"
assert_contains "$output" "scenario: \"no_plans\"" "Scenario is no_plans"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Single plan with full frontmatter${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/user-auth"
cat > "$TEST_DIR/.workflows/planning/user-auth/plan.md" << 'EOF'
---
topic: user-auth
status: in-progress
date: 2024-01-15
format: local-markdown
specification: user-auth/specification.md
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
assert_contains "$output" "specification: \"user-auth/specification.md\"" "Specification extracted"
assert_contains "$output" "scenario: \"single_plan\"" "Scenario is single_plan"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Multiple plans${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/feature-a"
mkdir -p "$TEST_DIR/.workflows/planning/feature-b"

cat > "$TEST_DIR/.workflows/planning/feature-a/plan.md" << 'EOF'
---
topic: feature-a
status: in-progress
date: 2024-01-10
format: local-markdown
specification: feature-a/specification.md
---

# Implementation Plan: Feature A
EOF

cat > "$TEST_DIR/.workflows/planning/feature-b/plan.md" << 'EOF'
---
topic: feature-b
status: concluded
date: 2024-01-20
format: local-markdown
specification: feature-b/specification.md
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

echo -e "${YELLOW}Test: Plan with linked specification that exists${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/with-spec"
mkdir -p "$TEST_DIR/.workflows/specification/with-spec"

cat > "$TEST_DIR/.workflows/planning/with-spec/plan.md" << 'EOF'
---
topic: with-spec
status: in-progress
date: 2024-03-01
format: local-markdown
specification: with-spec/specification.md
---

# Implementation Plan: With Spec
EOF

cat > "$TEST_DIR/.workflows/specification/with-spec/specification.md" << 'EOF'
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
mkdir -p "$TEST_DIR/.workflows/planning/no-spec"

cat > "$TEST_DIR/.workflows/planning/no-spec/plan.md" << 'EOF'
---
topic: no-spec
status: in-progress
date: 2024-03-01
format: local-markdown
specification: missing-spec/specification.md
---

# Implementation Plan: No Spec
EOF

output=$(run_discovery)

assert_contains "$output" "specification_exists: false" "Specification exists flag is false"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with missing frontmatter fields (defaults)${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/minimal"

cat > "$TEST_DIR/.workflows/planning/minimal/plan.md" << 'EOF'
---
topic: minimal
---

# Implementation Plan: Minimal
EOF

output=$(run_discovery)

assert_contains "$output" "name: \"minimal\"" "Name from filename"
assert_contains "$output" "topic: \"minimal\"" "Topic from frontmatter"
assert_contains "$output" "status: \"unknown\"" "Status defaults to unknown"
assert_contains "$output" "format: \"MISSING\"" "Missing format flagged"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with plan_id${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/with-plan-id"

cat > "$TEST_DIR/.workflows/planning/with-plan-id/plan.md" << 'EOF'
---
topic: with-plan-id
status: in-progress
date: 2024-05-01
format: beads
specification: with-plan-id/specification.md
plan_id: my-project-abc123
---

# Implementation Plan: With Plan ID
EOF

output=$(run_discovery)

assert_contains "$output" "plan_id: \"my-project-abc123\"" "Plan ID extracted"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan without plan_id${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/no-plan-id"

cat > "$TEST_DIR/.workflows/planning/no-plan-id/plan.md" << 'EOF'
---
topic: no-plan-id
status: in-progress
date: 2024-05-01
format: local-markdown
specification: no-plan-id/specification.md
---

# Implementation Plan: No Plan ID
EOF

output=$(run_discovery)

assert_not_contains "$output" "plan_id:" "No plan_id when not present"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with no review${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/no-review"

cat > "$TEST_DIR/.workflows/planning/no-review/plan.md" << 'EOF'
---
topic: no-review
status: concluded
format: local-markdown
specification: no-review/specification.md
---

# Plan: No Review
EOF

output=$(run_discovery)

assert_contains "$output" "review_count: 0" "Review count is 0 when no review exists"
assert_not_contains "$output" "latest_review_version:" "No latest_review_version when unreviewed"
assert_not_contains "$output" "latest_review_verdict:" "No latest_review_verdict when unreviewed"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with single review${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/single-review"
mkdir -p "$TEST_DIR/.workflows/review/single-review/r1"

cat > "$TEST_DIR/.workflows/planning/single-review/plan.md" << 'EOF'
---
topic: single-review
status: concluded
format: local-markdown
specification: single-review/specification.md
---

# Plan: Single Review
EOF

cat > "$TEST_DIR/.workflows/review/single-review/r1/review.md" << 'EOF'
---
topic: single-review
---

**QA Verdict**: Approve

# Review: Single Review
EOF

output=$(run_discovery)

assert_contains "$output" "review_count: 1" "Review count is 1"
assert_contains "$output" "latest_review_version: 1" "Latest review version is 1"
assert_contains "$output" 'latest_review_verdict: "Approve"' "Latest verdict is Approve"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with multiple reviews${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/multi-review"
mkdir -p "$TEST_DIR/.workflows/review/multi-review/r1"
mkdir -p "$TEST_DIR/.workflows/review/multi-review/r2"

cat > "$TEST_DIR/.workflows/planning/multi-review/plan.md" << 'EOF'
---
topic: multi-review
status: concluded
format: local-markdown
specification: multi-review/specification.md
---

# Plan: Multi Review
EOF

cat > "$TEST_DIR/.workflows/review/multi-review/r1/review.md" << 'EOF'
---
topic: multi-review
---

**QA Verdict**: Request Changes

# Review: Multi Review r1
EOF

cat > "$TEST_DIR/.workflows/review/multi-review/r2/review.md" << 'EOF'
---
topic: multi-review
---

**QA Verdict**: Approve

# Review: Multi Review r2
EOF

output=$(run_discovery)

assert_contains "$output" "review_count: 2" "Review count is 2"
assert_contains "$output" "latest_review_version: 2" "Latest review version is 2"
assert_contains "$output" 'latest_review_verdict: "Approve"' "Latest verdict from r2 (not r1)"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Review dir exists but no review.md files${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/empty-review"
mkdir -p "$TEST_DIR/.workflows/review/empty-review/r1"

cat > "$TEST_DIR/.workflows/planning/empty-review/plan.md" << 'EOF'
---
topic: empty-review
status: concluded
format: local-markdown
specification: empty-review/specification.md
---

# Plan: Empty Review
EOF

# r1 directory exists but no review.md inside it

output=$(run_discovery)

assert_contains "$output" "review_count: 0" "Review count is 0 when review dir has no review.md"
assert_not_contains "$output" "latest_review_version:" "No latest_review_version for empty review dir"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Review script does not output implementation section${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/test"

cat > "$TEST_DIR/.workflows/planning/test/plan.md" << 'EOF'
---
topic: test
status: concluded
format: local-markdown
specification: test/specification.md
---

# Plan: Test
EOF

output=$(run_discovery)

assert_not_contains "$output" "implementation:" "No implementation section"
assert_not_contains "$output" "dependency_resolution:" "No dependency_resolution section"
assert_not_contains "$output" "environment:" "No environment section"
assert_not_contains "$output" "plans_concluded_count:" "No plans_concluded_count"
assert_not_contains "$output" "plans_ready_count:" "No plans_ready_count"
assert_not_contains "$output" "plans_in_progress_count:" "No plans_in_progress_count"
assert_not_contains "$output" "plans_completed_count:" "No plans_completed_count"
assert_not_contains "$output" "external_deps:" "No external_deps"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with implementation in-progress${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/impl-wip"
mkdir -p "$TEST_DIR/.workflows/implementation/impl-wip"

cat > "$TEST_DIR/.workflows/planning/impl-wip/plan.md" << 'EOF'
---
topic: impl-wip
status: concluded
format: local-markdown
specification: impl-wip/specification.md
---

# Plan: Impl WIP
EOF

cat > "$TEST_DIR/.workflows/implementation/impl-wip/tracking.md" << 'EOF'
---
topic: impl-wip
status: in-progress
---

# Implementation Tracking
EOF

output=$(run_discovery)

assert_contains "$output" 'implementation_status: "in-progress"' "Implementation status is in-progress"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with implementation completed${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/impl-done"
mkdir -p "$TEST_DIR/.workflows/implementation/impl-done"

cat > "$TEST_DIR/.workflows/planning/impl-done/plan.md" << 'EOF'
---
topic: impl-done
status: concluded
format: local-markdown
specification: impl-done/specification.md
---

# Plan: Impl Done
EOF

cat > "$TEST_DIR/.workflows/implementation/impl-done/tracking.md" << 'EOF'
---
topic: impl-done
status: completed
---

# Implementation Tracking
EOF

output=$(run_discovery)

assert_contains "$output" 'implementation_status: "completed"' "Implementation status is completed"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Implemented count with mixed plans${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/has-impl"
mkdir -p "$TEST_DIR/.workflows/planning/no-impl"
mkdir -p "$TEST_DIR/.workflows/implementation/has-impl"

cat > "$TEST_DIR/.workflows/planning/has-impl/plan.md" << 'EOF'
---
topic: has-impl
status: concluded
format: local-markdown
specification: has-impl/specification.md
---

# Plan: Has Impl
EOF

cat > "$TEST_DIR/.workflows/implementation/has-impl/tracking.md" << 'EOF'
---
topic: has-impl
status: in-progress
---

# Implementation Tracking
EOF

cat > "$TEST_DIR/.workflows/planning/no-impl/plan.md" << 'EOF'
---
topic: no-impl
status: concluded
format: local-markdown
specification: no-impl/specification.md
---

# Plan: No Impl
EOF

output=$(run_discovery)

assert_contains "$output" "implemented_count: 1" "Implemented count is 1 (one plan with tracking)"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Reviewed plan count${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/reviewed-topic"
mkdir -p "$TEST_DIR/.workflows/planning/unreviewed-topic"
mkdir -p "$TEST_DIR/.workflows/review/reviewed-topic/r1"

cat > "$TEST_DIR/.workflows/planning/reviewed-topic/plan.md" << 'EOF'
---
topic: reviewed-topic
status: concluded
format: local-markdown
specification: reviewed-topic/specification.md
---

# Plan: Reviewed Topic
EOF

cat > "$TEST_DIR/.workflows/planning/unreviewed-topic/plan.md" << 'EOF'
---
topic: unreviewed-topic
status: concluded
format: local-markdown
specification: unreviewed-topic/specification.md
---

# Plan: Unreviewed Topic
EOF

cat > "$TEST_DIR/.workflows/review/reviewed-topic/r1/review.md" << 'EOF'
---
topic: reviewed-topic
---

**QA Verdict**: Approve

# Review
EOF

output=$(run_discovery)

assert_contains "$output" "reviewed_plan_count: 1" "Reviewed plan count is 1"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: All reviewed true${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/all-rev"
mkdir -p "$TEST_DIR/.workflows/implementation/all-rev"
mkdir -p "$TEST_DIR/.workflows/review/all-rev/r1"

cat > "$TEST_DIR/.workflows/planning/all-rev/plan.md" << 'EOF'
---
topic: all-rev
status: concluded
format: local-markdown
specification: all-rev/specification.md
---

# Plan
EOF

cat > "$TEST_DIR/.workflows/implementation/all-rev/tracking.md" << 'EOF'
---
topic: all-rev
status: completed
---

# Tracking
EOF

cat > "$TEST_DIR/.workflows/review/all-rev/r1/review.md" << 'EOF'
---
topic: all-rev
---

**QA Verdict**: Approve

# Review
EOF

output=$(run_discovery)

assert_contains "$output" "all_reviewed: true" "All reviewed is true when all implemented plans are reviewed"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: All reviewed false${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/rev-yes"
mkdir -p "$TEST_DIR/.workflows/planning/rev-no"
mkdir -p "$TEST_DIR/.workflows/implementation/rev-yes"
mkdir -p "$TEST_DIR/.workflows/implementation/rev-no"
mkdir -p "$TEST_DIR/.workflows/review/rev-yes/r1"

cat > "$TEST_DIR/.workflows/planning/rev-yes/plan.md" << 'EOF'
---
topic: rev-yes
status: concluded
format: local-markdown
specification: rev-yes/specification.md
---

# Plan
EOF

cat > "$TEST_DIR/.workflows/planning/rev-no/plan.md" << 'EOF'
---
topic: rev-no
status: concluded
format: local-markdown
specification: rev-no/specification.md
---

# Plan
EOF

cat > "$TEST_DIR/.workflows/implementation/rev-yes/tracking.md" << 'EOF'
---
topic: rev-yes
status: completed
---

# Tracking
EOF

cat > "$TEST_DIR/.workflows/implementation/rev-no/tracking.md" << 'EOF'
---
topic: rev-no
status: completed
---

# Tracking
EOF

cat > "$TEST_DIR/.workflows/review/rev-yes/r1/review.md" << 'EOF'
---
topic: rev-yes
---

**QA Verdict**: Approve

# Review
EOF

output=$(run_discovery)

assert_contains "$output" "all_reviewed: false" "All reviewed is false when not all implemented plans are reviewed"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Reviews section with existing review${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/rev-section"
mkdir -p "$TEST_DIR/.workflows/review/rev-section/r1"

cat > "$TEST_DIR/.workflows/planning/rev-section/plan.md" << 'EOF'
---
topic: rev-section
status: concluded
format: local-markdown
specification: rev-section/specification.md
---

# Plan
EOF

cat > "$TEST_DIR/.workflows/review/rev-section/r1/review.md" << 'EOF'
---
topic: rev-section
---

**QA Verdict**: Approve

# Review
EOF

output=$(run_discovery)

assert_contains "$output" "reviews:" "Reviews section exists"
assert_contains "$output" "exists: true" "Reviews exists is true"
assert_contains "$output" 'topic: "rev-section"' "Review topic appears in reviews section"
assert_contains "$output" "latest_version: 1" "Latest version is 1"
assert_contains "$output" "Approve" "Latest verdict contains Approve"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Reviews section empty (no review dir)${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/no-rev-dir"

cat > "$TEST_DIR/.workflows/planning/no-rev-dir/plan.md" << 'EOF'
---
topic: no-rev-dir
status: concluded
format: local-markdown
specification: no-rev-dir/specification.md
---

# Plan
EOF

output=$(run_discovery)

assert_contains "$output" "reviews:" "Reviews section exists"
# The second "exists: false" in output corresponds to the reviews section
# (first one is from plans section which is true here)
# Use a more specific check: reviews section followed by exists: false
assert_not_contains "$output" "entries:" "No entries in reviews section"

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
