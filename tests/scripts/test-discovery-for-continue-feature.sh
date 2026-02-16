#!/bin/bash
#
# Tests the continue-feature discovery script against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/continue-feature/scripts/discovery.sh"

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
# Test: Empty workflow (no topics)
#
test_no_topics() {
    echo -e "${YELLOW}Test: Empty workflow (no topics)${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'topics:' "Has topics section"
    assert_contains "$output" 'topic_count: 0' "Topic count is 0"
    assert_contains "$output" 'scenario: "no_topics"' "Scenario is no_topics"

    echo ""
}

#
# Test: Discussion only (in-progress)
#
test_discussion_in_progress() {
    echo -e "${YELLOW}Test: Discussion only (in-progress)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: in-progress
---

# Auth Flow Discussion
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow topic"
    assert_contains "$output" 'next_phase: "discussion"' "Next phase is discussion"
    assert_contains "$output" 'actionable: true' "Topic is actionable"
    assert_contains "$output" 'topic_count: 1' "Topic count is 1"
    assert_contains "$output" 'scenario: "single_topic"' "Scenario is single_topic"

    echo ""
}

#
# Test: Discussion only (concluded)
#
test_discussion_concluded() {
    echo -e "${YELLOW}Test: Discussion only (concluded)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
---

# Auth Flow Discussion
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow topic"
    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    assert_contains "$output" 'actionable: true' "Topic is actionable"

    echo ""
}

#
# Test: Spec concluded, no plan
#
test_spec_concluded_no_plan() {
    echo -e "${YELLOW}Test: Spec concluded, no plan${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/specification/auth-flow"

    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
---

# Auth Flow Discussion
EOF

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
type: feature
---

# Auth Flow Specification
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow topic"
    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    assert_contains "$output" 'actionable: true' "Topic is actionable"

    echo ""
}

#
# Test: Spec in-progress
#
test_spec_in_progress() {
    echo -e "${YELLOW}Test: Spec in-progress${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification/auth-flow"

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: in-progress
type: feature
---

# Auth Flow Specification
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    assert_contains "$output" 'actionable: true' "Topic is actionable"

    echo ""
}

#
# Test: Plan in-progress
#
test_plan_in_progress() {
    echo -e "${YELLOW}Test: Plan in-progress${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification/auth-flow"
    mkdir -p "$TEST_DIR/docs/workflow/planning/auth-flow"

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
type: feature
---

# Auth Flow Specification
EOF

    cat > "$TEST_DIR/docs/workflow/planning/auth-flow/plan.md" << 'EOF'
---
topic: auth-flow
status: in-progress
format: tick
---

# Auth Flow Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    assert_contains "$output" 'format: "tick"' "Plan format extracted"
    assert_contains "$output" 'actionable: true' "Topic is actionable"

    echo ""
}

#
# Test: Plan concluded, no implementation
#
test_plan_concluded_no_impl() {
    echo -e "${YELLOW}Test: Plan concluded, no implementation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification/auth-flow"
    mkdir -p "$TEST_DIR/docs/workflow/planning/auth-flow"

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
type: feature
---

# Auth Flow Specification
EOF

    cat > "$TEST_DIR/docs/workflow/planning/auth-flow/plan.md" << 'EOF'
---
topic: auth-flow
status: concluded
format: tick
---

# Auth Flow Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    assert_contains "$output" 'actionable: true' "Topic is actionable"

    echo ""
}

#
# Test: Implementation in-progress
#
test_implementation_in_progress() {
    echo -e "${YELLOW}Test: Implementation in-progress${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification/auth-flow"
    mkdir -p "$TEST_DIR/docs/workflow/planning/auth-flow"
    mkdir -p "$TEST_DIR/docs/workflow/implementation/auth-flow"

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
type: feature
---

# Auth Flow Specification
EOF

    cat > "$TEST_DIR/docs/workflow/planning/auth-flow/plan.md" << 'EOF'
---
topic: auth-flow
status: concluded
format: tick
---

# Auth Flow Plan
EOF

    cat > "$TEST_DIR/docs/workflow/implementation/auth-flow/tracking.md" << 'EOF'
---
topic: auth-flow
status: in-progress
current_phase: 1
---

# Auth Flow Implementation
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    assert_contains "$output" 'actionable: true' "Topic is actionable"

    echo ""
}

#
# Test: Implementation complete
#
test_implementation_complete() {
    echo -e "${YELLOW}Test: Implementation complete${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification/auth-flow"
    mkdir -p "$TEST_DIR/docs/workflow/planning/auth-flow"
    mkdir -p "$TEST_DIR/docs/workflow/implementation/auth-flow"

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
type: feature
---

# Auth Flow Specification
EOF

    cat > "$TEST_DIR/docs/workflow/planning/auth-flow/plan.md" << 'EOF'
---
topic: auth-flow
status: concluded
format: tick
---

# Auth Flow Plan
EOF

    cat > "$TEST_DIR/docs/workflow/implementation/auth-flow/tracking.md" << 'EOF'
---
topic: auth-flow
status: completed
---

# Auth Flow Implementation
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "done"' "Next phase is done"
    assert_contains "$output" 'actionable: false' "Topic is not actionable"

    echo ""
}

#
# Test: Multiple topics at different phases
#
test_multiple_topics() {
    echo -e "${YELLOW}Test: Multiple topics at different phases${NC}"
    setup_fixture

    # Topic 1: Discussion in-progress
    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: in-progress
---

# Auth Flow Discussion
EOF

    # Topic 2: Spec concluded, ready for planning
    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/specification/billing"
    cat > "$TEST_DIR/docs/workflow/discussion/billing.md" << 'EOF'
---
topic: billing
status: concluded
---

# Billing Discussion
EOF
    cat > "$TEST_DIR/docs/workflow/specification/billing/specification.md" << 'EOF'
---
topic: billing
status: concluded
type: feature
---

# Billing Specification
EOF

    # Topic 3: Implementation complete
    mkdir -p "$TEST_DIR/docs/workflow/specification/dashboard"
    mkdir -p "$TEST_DIR/docs/workflow/planning/dashboard"
    mkdir -p "$TEST_DIR/docs/workflow/implementation/dashboard"
    cat > "$TEST_DIR/docs/workflow/specification/dashboard/specification.md" << 'EOF'
---
topic: dashboard
status: concluded
type: feature
---

# Dashboard Specification
EOF
    cat > "$TEST_DIR/docs/workflow/planning/dashboard/plan.md" << 'EOF'
---
topic: dashboard
status: concluded
format: local-markdown
---

# Dashboard Plan
EOF
    cat > "$TEST_DIR/docs/workflow/implementation/dashboard/tracking.md" << 'EOF'
---
topic: dashboard
status: completed
---

# Dashboard Implementation
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow"
    assert_contains "$output" 'name: "billing"' "Found billing"
    assert_contains "$output" 'name: "dashboard"' "Found dashboard"
    assert_contains "$output" 'topic_count: 3' "Topic count is 3"
    assert_contains "$output" 'actionable_count: 2' "Actionable count is 2"
    assert_contains "$output" 'scenario: "multiple_topics"' "Scenario is multiple_topics"

    echo ""
}

#
# Test: Cross-cutting specs are excluded
#
test_crosscutting_excluded() {
    echo -e "${YELLOW}Test: Cross-cutting specs are excluded${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification/caching-strategy"
    cat > "$TEST_DIR/docs/workflow/specification/caching-strategy/specification.md" << 'EOF'
---
topic: caching-strategy
status: concluded
type: cross-cutting
---

# Caching Strategy
EOF

    local output=$(run_discovery)

    assert_not_contains "$output" 'name: "caching-strategy"' "Cross-cutting spec excluded"
    assert_contains "$output" 'topic_count: 0' "Topic count is 0"
    assert_contains "$output" 'scenario: "no_topics"' "Scenario is no_topics"

    echo ""
}

#
# Test: Spec without discussion (spec-only entry via start-feature old path)
#
test_spec_without_discussion() {
    echo -e "${YELLOW}Test: Spec without discussion${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification/quick-feature"
    cat > "$TEST_DIR/docs/workflow/specification/quick-feature/specification.md" << 'EOF'
---
topic: quick-feature
status: concluded
type: feature
---

# Quick Feature Specification
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "quick-feature"' "Found spec-only topic"
    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    assert_contains "$output" 'actionable: true' "Topic is actionable"
    assert_contains "$output" 'topic_count: 1' "Topic count is 1"

    echo ""
}

#
# Test: Discussion without status defaults to in-progress
#
test_discussion_default_status() {
    echo -e "${YELLOW}Test: Discussion without status defaults to in-progress${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/legacy-topic.md" << 'EOF'
---
topic: legacy-topic
---

# Legacy Topic Discussion

No status field.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "legacy-topic"' "Found legacy topic"
    assert_contains "$output" 'next_phase: "discussion"' "Next phase is discussion (default in-progress)"
    assert_contains "$output" 'actionable: true' "Topic is actionable"

    echo ""
}

#
# Test: Topic deduplication (same name in discussion and spec)
#
test_topic_deduplication() {
    echo -e "${YELLOW}Test: Topic deduplication${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/specification/auth-flow"

    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
---

# Auth Flow Discussion
EOF

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: in-progress
type: feature
---

# Auth Flow Specification
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'topic_count: 1' "Topic count is 1 (deduplicated)"
    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification (in-progress spec takes priority)"

    echo ""
}

#
# Run all tests
#
echo "=========================================="
echo "Running discovery-for-continue-feature.sh tests"
echo "=========================================="
echo ""

test_no_topics
test_discussion_in_progress
test_discussion_concluded
test_spec_concluded_no_plan
test_spec_in_progress
test_plan_in_progress
test_plan_concluded_no_impl
test_implementation_in_progress
test_implementation_complete
test_multiple_topics
test_crosscutting_excluded
test_spec_without_discussion
test_discussion_default_status
test_topic_deduplication

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
