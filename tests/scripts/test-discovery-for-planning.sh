#!/bin/bash
#
# Tests the discovery-for-planning.sh script against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/start-planning/scripts/discovery.sh"

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

    if echo "$output" | grep -q "$expected"; then
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

    if ! echo "$output" | grep -q "$pattern"; then
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

#
# Test: No specifications (fresh state)
#
test_no_specs() {
    echo -e "${YELLOW}Test: No specifications (fresh state)${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'specifications:' "Has specifications section"
    assert_contains "$output" 'exists: false' "Specifications exists: false"
    assert_contains "$output" 'feature: \[\]' "Feature specs empty"
    assert_contains "$output" 'crosscutting: \[\]' "Crosscutting specs empty"
    assert_contains "$output" 'scenario: "no_specs"' "Scenario is no_specs"
    assert_contains "$output" 'feature: 0' "Feature count is 0"
    assert_contains "$output" 'feature_ready: 0' "Feature ready count is 0"

    echo ""
}

#
# Test: Single feature specification (Building)
#
test_single_spec_in_progress() {
    echo -e "${YELLOW}Test: Single feature specification (in-progress)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: in-progress
type: feature
---

# Specification: Auth System
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'exists: true' "Specifications exist"
    assert_contains "$output" 'name: "auth-system"' "Found auth-system spec"
    assert_contains "$output" 'status: "in-progress"' "Status is in-progress"
    assert_contains "$output" 'has_plan: false' "No plan exists"
    assert_contains "$output" 'feature: 1' "Feature count is 1"
    assert_contains "$output" 'feature_ready: 0' "Feature ready count is 0"
    assert_contains "$output" 'scenario: "nothing_actionable"' "Scenario is nothing_actionable"

    echo ""
}

#
# Test: Single feature specification (Complete, no plan)
#
test_single_spec_concluded_no_plan() {
    echo -e "${YELLOW}Test: Single feature specification (concluded, no plan)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
---

# Specification: Auth System
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "concluded"' "Status is concluded"
    assert_contains "$output" 'has_plan: false' "No plan exists"
    assert_contains "$output" 'feature_ready: 1' "Feature ready count is 1"
    assert_contains "$output" 'scenario: "has_options"' "Scenario is has_options"

    echo ""
}

#
# Test: Single feature specification (Complete, has plan)
#
test_single_spec_concluded_with_plan() {
    echo -e "${YELLOW}Test: Single feature specification (concluded, has plan)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
---

# Specification: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: local-markdown
status: planning
---

# Implementation Plan: Auth System
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'has_plan: true' "Plan exists"
    assert_contains "$output" 'plan_status: "planning"' "Plan status extracted"
    assert_contains "$output" 'feature_ready: 0' "Feature ready count is 0 (has plan)"
    assert_contains "$output" 'feature_with_plan: 1' "Feature with plan count is 1"
    assert_contains "$output" 'scenario: "has_options"' "Scenario is has_options (plan exists to continue)"
    assert_contains "$output" 'has_plans: true' "has_plans is true"

    echo ""
}

#
# Test: Multiple feature specifications
#
test_multiple_feature_specs() {
    echo -e "${YELLOW}Test: Multiple feature specifications${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
---

# Specification: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/specification/billing.md" << 'EOF'
---
topic: billing
status: concluded
type: feature
---

# Specification: Billing
EOF

    cat > "$TEST_DIR/docs/workflow/specification/dashboard.md" << 'EOF'
---
topic: dashboard
status: in-progress
type: feature
---

# Specification: Dashboard
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-system"' "Found auth-system"
    assert_contains "$output" 'name: "billing"' "Found billing"
    assert_contains "$output" 'name: "dashboard"' "Found dashboard"
    assert_contains "$output" 'feature: 3' "Feature count is 3"
    assert_contains "$output" 'feature_ready: 2' "Feature ready count is 2"
    assert_contains "$output" 'scenario: "has_options"' "Scenario is has_options"

    echo ""
}

#
# Test: Cross-cutting specifications
#
test_crosscutting_specs() {
    echo -e "${YELLOW}Test: Cross-cutting specifications${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/specification/caching-strategy.md" << 'EOF'
---
topic: caching-strategy
status: concluded
type: cross-cutting
---

# Specification: Caching Strategy
EOF

    cat > "$TEST_DIR/docs/workflow/specification/rate-limiting.md" << 'EOF'
---
topic: rate-limiting
status: concluded
type: cross-cutting
---

# Specification: Rate Limiting
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "caching-strategy"' "Found caching-strategy"
    assert_contains "$output" 'name: "rate-limiting"' "Found rate-limiting"
    assert_contains "$output" 'crosscutting: 2' "Crosscutting count is 2"
    assert_contains "$output" 'feature: 0' "Feature count is 0"
    # With no feature specs and no plans, scenario should be nothing_actionable
    assert_contains "$output" 'scenario: "nothing_actionable"' "Scenario is nothing_actionable"

    echo ""
}

#
# Test: Mixed feature and cross-cutting
#
test_mixed_specs() {
    echo -e "${YELLOW}Test: Mixed feature and cross-cutting specifications${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
---

# Specification: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/specification/caching-strategy.md" << 'EOF'
---
topic: caching-strategy
status: concluded
type: cross-cutting
---

# Specification: Caching Strategy
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature: 1' "Feature count is 1"
    assert_contains "$output" 'crosscutting: 1' "Crosscutting count is 1"
    assert_contains "$output" 'feature_ready: 1' "Feature ready count is 1"
    assert_contains "$output" 'scenario: "has_options"' "Scenario is has_options"

    echo ""
}

#
# Test: Specification without type defaults to feature
#
test_spec_default_type() {
    echo -e "${YELLOW}Test: Specification without type defaults to feature${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/specification/legacy-feature.md" << 'EOF'
---
topic: legacy-feature
status: concluded
---

# Specification: Legacy Feature

No type field - should default to feature.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "legacy-feature"' "Found legacy-feature"
    assert_contains "$output" 'feature: 1' "Counted as feature"
    assert_contains "$output" 'feature_ready: 1' "Ready for planning"

    echo ""
}

#
# Test: Plans section
#
test_plans_section() {
    echo -e "${YELLOW}Test: Plans section${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: local-markdown
status: In Progress
---

# Implementation Plan: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/planning/billing.md" << 'EOF'
---
format: linear
status: Ready
---

# Implementation Plan: Billing
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'plans:' "Has plans section"
    assert_contains "$output" 'exists: true' "Plans exist"
    assert_contains "$output" 'name: "auth-system"' "Found auth-system plan"
    assert_contains "$output" 'format: "local-markdown"' "Found local-markdown format"
    assert_contains "$output" 'format: "linear"' "Found linear format"
    assert_contains "$output" 'status: "In Progress"' "Found In Progress status"
    assert_contains "$output" 'status: "Ready"' "Found Ready status"
    assert_contains "$output" 'common_format: ""' "Mixed formats yield empty common_format"

    echo ""
}

#
# Test: Plan without format shows MISSING
#
test_plan_missing_format() {
    echo -e "${YELLOW}Test: Plan without format shows MISSING${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/planning/old-plan.md" << 'EOF'
---
status: Draft
---

# Implementation Plan: Old Plan

No format field.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'format: "MISSING"' "Missing format flagged"
    assert_contains "$output" 'common_format: ""' "Only MISSING formats yield empty common_format"

    echo ""
}

#
# Test: Plan with plan_id
#
test_plan_with_plan_id() {
    echo -e "${YELLOW}Test: Plan with plan_id${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/planning/with-plan-id.md" << 'EOF'
---
topic: with-plan-id
status: in-progress
format: beads
plan_id: my-epic-abc123
---

# Implementation Plan: With Plan ID
EOF

    cat > "$TEST_DIR/docs/workflow/planning/without-plan-id.md" << 'EOF'
---
topic: without-plan-id
status: in-progress
format: local-markdown
---

# Implementation Plan: Without Plan ID
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'plan_id: "my-epic-abc123"' "Plan ID extracted when present"
    # The plan without plan_id should not have the field
    # Check that output doesn't have plan_id right after without-plan-id entry
    # This is tricky to test, so we just verify the one with plan_id works

    echo ""
}

#
# Test: Concluded plan shows plan_status concluded and is actionable
#
test_concluded_plan_is_actionable() {
    echo -e "${YELLOW}Test: Concluded plan is actionable (review/revise)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
---

# Specification: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: local-markdown
status: concluded
---

# Implementation Plan: Auth System
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'has_plan: true' "Plan exists"
    assert_contains "$output" 'plan_status: "concluded"' "Plan status is concluded"
    assert_contains "$output" 'feature_with_plan: 1' "Feature with plan count is 1"
    assert_contains "$output" 'scenario: "has_options"' "Scenario is has_options (concluded plan is reviewable)"

    echo ""
}

#
# Test: Mix of ready specs and existing plans
#
test_mixed_ready_and_plans() {
    echo -e "${YELLOW}Test: Mix of ready specs and existing plans${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    mkdir -p "$TEST_DIR/docs/workflow/planning"

    # Ready spec (no plan)
    cat > "$TEST_DIR/docs/workflow/specification/billing.md" << 'EOF'
---
topic: billing
status: concluded
type: feature
---

# Specification: Billing
EOF

    # Spec with in-progress plan
    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
---

# Specification: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: local-markdown
status: planning
---

# Implementation Plan: Auth System
EOF

    # In-progress spec (not ready)
    cat > "$TEST_DIR/docs/workflow/specification/dashboard.md" << 'EOF'
---
topic: dashboard
status: in-progress
type: feature
---

# Specification: Dashboard
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature: 3' "Feature count is 3"
    assert_contains "$output" 'feature_ready: 1' "Feature ready count is 1"
    assert_contains "$output" 'feature_with_plan: 1' "Feature with plan count is 1"
    assert_contains "$output" 'scenario: "has_options"' "Scenario is has_options"

    echo ""
}

#
# Test: All specs in-progress with no plans is nothing_actionable
#
test_all_in_progress_nothing_actionable() {
    echo -e "${YELLOW}Test: All specs in-progress with no plans${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: in-progress
type: feature
---

# Specification: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/specification/billing.md" << 'EOF'
---
topic: billing
status: in-progress
type: feature
---

# Specification: Billing
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature: 2' "Feature count is 2"
    assert_contains "$output" 'feature_ready: 0' "Feature ready count is 0"
    assert_contains "$output" 'feature_with_plan: 0' "Feature with plan count is 0"
    assert_contains "$output" 'scenario: "nothing_actionable"' "Scenario is nothing_actionable"

    echo ""
}

#
# Test: common_format empty when no plans exist
#
test_common_format_no_plans() {
    echo -e "${YELLOW}Test: common_format empty when no plans exist${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'common_format: ""' "No plans yields empty common_format"

    echo ""
}

#
# Test: common_format with single plan
#
test_common_format_single_plan() {
    echo -e "${YELLOW}Test: common_format with single plan${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: local-markdown
status: planning
---

# Implementation Plan: Auth System
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'common_format: "local-markdown"' "Single plan format becomes common_format"

    echo ""
}

#
# Test: common_format with multiple same format
#
test_common_format_multiple_same() {
    echo -e "${YELLOW}Test: common_format with multiple same format${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: beads
status: planning
---

# Implementation Plan: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/planning/billing.md" << 'EOF'
---
format: beads
status: Ready
---

# Implementation Plan: Billing
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'common_format: "beads"' "Multiple same format yields common_format"

    echo ""
}

#
# Test: common_format empty with mixed formats
#
test_common_format_mixed() {
    echo -e "${YELLOW}Test: common_format empty with mixed formats${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: local-markdown
status: planning
---

# Implementation Plan: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/planning/billing.md" << 'EOF'
---
format: linear
status: Ready
---

# Implementation Plan: Billing
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'common_format: ""' "Mixed formats yield empty common_format"

    echo ""
}

#
# Test: common_format ignores MISSING format
#
test_common_format_missing_ignored() {
    echo -e "${YELLOW}Test: common_format ignores MISSING format${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/planning"

    cat > "$TEST_DIR/docs/workflow/planning/auth-system.md" << 'EOF'
---
format: local-markdown
status: planning
---

# Implementation Plan: Auth System
EOF

    cat > "$TEST_DIR/docs/workflow/planning/old-plan.md" << 'EOF'
---
status: Draft
---

# Implementation Plan: Old Plan

No format field.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'common_format: "local-markdown"' "MISSING format ignored, common_format from valid plans"

    echo ""
}

#
# Run all tests
#
echo "=========================================="
echo "Running discovery-for-planning.sh tests"
echo "=========================================="
echo ""

test_no_specs
test_single_spec_in_progress
test_single_spec_concluded_no_plan
test_single_spec_concluded_with_plan
test_multiple_feature_specs
test_crosscutting_specs
test_mixed_specs
test_spec_default_type
test_plans_section
test_plan_missing_format
test_plan_with_plan_id
test_concluded_plan_is_actionable
test_mixed_ready_and_plans
test_all_in_progress_nothing_actionable
test_common_format_no_plans
test_common_format_single_plan
test_common_format_multiple_same
test_common_format_mixed
test_common_format_missing_ignored

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
