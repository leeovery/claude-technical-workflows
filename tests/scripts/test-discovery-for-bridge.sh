#!/bin/bash
#
# Tests the bridge discovery script against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/workflow/bridge/scripts/discovery.sh"

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
    bash "$DISCOVERY_SCRIPT" "$@" 2>/dev/null
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

assert_exit_code() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$actual" -eq "$expected" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Expected exit code $expected, got $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ──────────────────────────────────────
# Argument parsing tests
# ──────────────────────────────────────

test_missing_work_type_flag() {
    echo -e "${YELLOW}Test: Missing work type flag${NC}"
    setup_fixture

    cd "$TEST_DIR"
    local output=$(bash "$DISCOVERY_SCRIPT" 2>&1 || true)
    local exit_code=$?

    assert_contains "$output" 'error:' "Outputs error message"
    echo ""
}

test_unknown_argument() {
    echo -e "${YELLOW}Test: Unknown argument${NC}"
    setup_fixture

    cd "$TEST_DIR"
    local output=$(bash "$DISCOVERY_SCRIPT" --unknown 2>&1 || true)

    assert_contains "$output" 'error:' "Outputs error for unknown flag"
    echo ""
}

test_feature_without_topic() {
    echo -e "${YELLOW}Test: --feature without --topic${NC}"
    setup_fixture

    cd "$TEST_DIR"
    local output=$(bash "$DISCOVERY_SCRIPT" --feature 2>&1 || true)

    assert_contains "$output" 'error:' "Outputs error when topic missing"
    assert_contains "$output" '--topic' "Error mentions --topic"
    echo ""
}

test_bugfix_without_topic() {
    echo -e "${YELLOW}Test: --bugfix without --topic${NC}"
    setup_fixture

    cd "$TEST_DIR"
    local output=$(bash "$DISCOVERY_SCRIPT" --bugfix 2>&1 || true)

    assert_contains "$output" 'error:' "Outputs error when topic missing"
    echo ""
}

test_greenfield_without_topic() {
    echo -e "${YELLOW}Test: --greenfield works without --topic${NC}"
    setup_fixture

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'work_type: "greenfield"' "Work type is greenfield"
    assert_contains "$output" 'topic: ""' "Topic is empty"
    echo ""
}

# ──────────────────────────────────────
# Feature pipeline tests
# ──────────────────────────────────────

test_feature_fresh() {
    echo -e "${YELLOW}Test: Feature - fresh state (no artifacts)${NC}"
    setup_fixture

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'work_type: "feature"' "Work type is feature"
    assert_contains "$output" 'topic: "auth-flow"' "Topic is auth-flow"
    assert_contains "$output" 'next_phase: "unknown"' "Next phase is unknown (no artifacts)"
    echo ""
}

test_feature_discussion_in_progress() {
    echo -e "${YELLOW}Test: Feature - discussion in progress${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: in-progress
work_type: feature
---
# Discussion
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "discussion"' "Next phase is discussion"
    assert_contains "$output" 'discussion:' "Has discussion section"
    echo ""
}

test_feature_discussion_concluded() {
    echo -e "${YELLOW}Test: Feature - discussion concluded${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
# Discussion
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    echo ""
}

test_feature_spec_concluded() {
    echo -e "${YELLOW}Test: Feature - spec concluded, no plan${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/auth-flow"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    echo ""
}

test_feature_plan_concluded() {
    echo -e "${YELLOW}Test: Feature - plan concluded${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/auth-flow"
    mkdir -p "$TEST_DIR/.workflows/planning/auth-flow"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/auth-flow/plan.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    echo ""
}

test_feature_research_exists() {
    echo -e "${YELLOW}Test: Feature - research exists with work_type${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/auth-flow.md" << 'EOF'
---
topic: auth-flow
work_type: feature
date: 2026-01-20
---
# Research
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'research:' "Has research section"
    assert_contains "$output" 'exists: true' "Research exists"
    assert_contains "$output" 'next_phase: "research"' "Next phase is research"
    echo ""
}

test_feature_research_concluded() {
    echo -e "${YELLOW}Test: Feature - research concluded, next is discussion${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
# Research
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "discussion"' "Next phase is discussion"
    echo ""
}

test_feature_spec_in_progress() {
    echo -e "${YELLOW}Test: Feature - concluded discussion + in-progress spec${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/auth-flow"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
# Discussion
EOF
    cat > "$TEST_DIR/.workflows/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: in-progress
work_type: feature
---
# Specification
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    echo ""
}

test_feature_plan_in_progress() {
    echo -e "${YELLOW}Test: Feature - concluded spec + in-progress plan${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/auth-flow"
    mkdir -p "$TEST_DIR/.workflows/planning/auth-flow"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/auth-flow/specification.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/auth-flow/plan.md" << 'EOF'
---
topic: auth-flow
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    echo ""
}

test_feature_impl_in_progress() {
    echo -e "${YELLOW}Test: Feature - concluded plan + in-progress implementation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/auth-flow"
    mkdir -p "$TEST_DIR/.workflows/implementation/auth-flow"
    cat > "$TEST_DIR/.workflows/planning/auth-flow/plan.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/implementation/auth-flow/tracking.md" << 'EOF'
---
topic: auth-flow
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    echo ""
}

test_feature_impl_completed_with_review() {
    echo -e "${YELLOW}Test: Feature - completed impl + review exists = done${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/implementation/auth-flow"
    mkdir -p "$TEST_DIR/.workflows/review/auth-flow/r1"
    cat > "$TEST_DIR/.workflows/implementation/auth-flow/tracking.md" << 'EOF'
---
topic: auth-flow
status: completed
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/review/auth-flow/r1/review.md" << 'EOF'
---
topic: auth-flow
work_type: feature
---
# Review
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'next_phase: "done"' "Next phase is done"
    echo ""
}

# ──────────────────────────────────────
# Bugfix pipeline tests
# ──────────────────────────────────────

test_bugfix_fresh() {
    echo -e "${YELLOW}Test: Bugfix - fresh state${NC}"
    setup_fixture

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'work_type: "bugfix"' "Work type is bugfix"
    assert_contains "$output" 'topic: "login-crash"' "Topic is login-crash"
    assert_contains "$output" 'next_phase: "unknown"' "Next phase is unknown"
    echo ""
}

test_bugfix_investigation_concluded() {
    echo -e "${YELLOW}Test: Bugfix - investigation concluded${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
# Investigation
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    echo ""
}

test_bugfix_full_pipeline() {
    echo -e "${YELLOW}Test: Bugfix - implementation completed${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/specification/login-crash"
    mkdir -p "$TEST_DIR/.workflows/planning/login-crash"
    mkdir -p "$TEST_DIR/.workflows/implementation/login-crash"

    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/specification/login-crash/specification.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/planning/login-crash/plan.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/implementation/login-crash/tracking.md" << 'EOF'
---
topic: login-crash
status: completed
work_type: bugfix
---
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'next_phase: "review"' "Next phase is review"
    echo ""
}

test_bugfix_investigation_in_progress() {
    echo -e "${YELLOW}Test: Bugfix - investigation in progress${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: in-progress
work_type: bugfix
---
# Investigation
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'next_phase: "investigation"' "Next phase is investigation"
    echo ""
}

test_bugfix_spec_in_progress() {
    echo -e "${YELLOW}Test: Bugfix - concluded investigation + in-progress spec${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/specification/login-crash"
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/specification/login-crash/specification.md" << 'EOF'
---
topic: login-crash
status: in-progress
work_type: bugfix
---
# Specification
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    echo ""
}

test_bugfix_spec_concluded() {
    echo -e "${YELLOW}Test: Bugfix - concluded spec, no plan${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/specification/login-crash"
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/specification/login-crash/specification.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    echo ""
}

test_bugfix_impl_completed_with_review() {
    echo -e "${YELLOW}Test: Bugfix - completed impl + review = done${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/specification/login-crash"
    mkdir -p "$TEST_DIR/.workflows/planning/login-crash"
    mkdir -p "$TEST_DIR/.workflows/implementation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/review/login-crash/r1"

    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/specification/login-crash/specification.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/planning/login-crash/plan.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/implementation/login-crash/tracking.md" << 'EOF'
---
topic: login-crash
status: completed
work_type: bugfix
---
EOF
    cat > "$TEST_DIR/.workflows/review/login-crash/r1/review.md" << 'EOF'
---
topic: login-crash
work_type: bugfix
---
# Review
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'next_phase: "done"' "Next phase is done"
    echo ""
}

# ──────────────────────────────────────
# Cross-pipeline isolation tests
# ──────────────────────────────────────

test_feature_ignores_investigation() {
    echo -e "${YELLOW}Test: Feature - ignores investigation artifacts${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/auth-flow"
    cat > "$TEST_DIR/.workflows/investigation/auth-flow/investigation.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: bugfix
---
# Investigation
EOF

    local output=$(run_discovery --feature --topic auth-flow)

    assert_contains "$output" 'investigation:' "Has investigation section"
    assert_contains "$output" 'exists: false' "Investigation shows exists: false"
    echo ""
}

test_bugfix_ignores_research() {
    echo -e "${YELLOW}Test: Bugfix - ignores research artifacts${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/login-crash.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: feature
---
# Research
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'research:' "Has research section"
    assert_contains "$output" 'exists: false' "Research shows exists: false"
    echo ""
}

test_bugfix_ignores_discussion() {
    echo -e "${YELLOW}Test: Bugfix - ignores discussion artifacts${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/login-crash.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: feature
---
# Discussion
EOF

    local output=$(run_discovery --bugfix --topic login-crash)

    assert_contains "$output" 'discussion:' "Has discussion section"
    assert_contains "$output" 'exists: false' "Discussion shows exists: false"
    echo ""
}

# ──────────────────────────────────────
# Greenfield discovery tests
# ──────────────────────────────────────

test_greenfield_fresh() {
    echo -e "${YELLOW}Test: Greenfield - fresh state${NC}"
    setup_fixture

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'work_type: "greenfield"' "Work type is greenfield"
    assert_contains "$output" 'research:' "Has research section"
    assert_contains "$output" 'discussions:' "Has discussions section"
    assert_contains "$output" 'specifications:' "Has specifications section"
    assert_contains "$output" 'plans:' "Has plans section"
    assert_contains "$output" 'implementation:' "Has implementation section"
    assert_contains "$output" 'has_any_work: false' "No work exists"
    echo ""
}

test_greenfield_with_discussions() {
    echo -e "${YELLOW}Test: Greenfield - with discussions${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/topic-a.md" << 'EOF'
---
topic: topic-a
status: concluded
work_type: greenfield
---
# Discussion A
EOF
    cat > "$TEST_DIR/.workflows/discussion/topic-b.md" << 'EOF'
---
topic: topic-b
status: in-progress
work_type: greenfield
---
# Discussion B
EOF

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'discussion_count: 2' "Discussion count is 2"
    assert_contains "$output" 'discussion_concluded: 1' "One concluded discussion"
    assert_contains "$output" 'discussion_in_progress: 1' "One in-progress discussion"
    assert_contains "$output" 'has_any_work: true' "Has work"
    echo ""
}

test_greenfield_filters_by_work_type() {
    echo -e "${YELLOW}Test: Greenfield - filters out non-greenfield discussions${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/gf-topic.md" << 'EOF'
---
topic: gf-topic
status: concluded
work_type: greenfield
---
# Greenfield Discussion
EOF
    cat > "$TEST_DIR/.workflows/discussion/feature-topic.md" << 'EOF'
---
topic: feature-topic
status: concluded
work_type: feature
---
# Feature Discussion
EOF

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'discussion_count: 1' "Only counts greenfield discussions"
    assert_contains "$output" 'name: "gf-topic"' "Found greenfield topic"
    assert_not_contains "$output" 'name: "feature-topic"' "Excluded feature topic"
    echo ""
}

test_greenfield_specs_and_plans() {
    echo -e "${YELLOW}Test: Greenfield - specs and plans${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/core-features"
    mkdir -p "$TEST_DIR/.workflows/planning/core-features"

    cat > "$TEST_DIR/.workflows/specification/core-features/specification.md" << 'EOF'
---
topic: core-features
status: concluded
work_type: greenfield
type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/core-features/plan.md" << 'EOF'
---
topic: core-features
status: in-progress
work_type: greenfield
---
EOF

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'specification_count: 1' "Spec count is 1"
    assert_contains "$output" 'specification_concluded: 1' "Spec is concluded"
    assert_contains "$output" 'plan_count: 1' "Plan count is 1"
    assert_contains "$output" 'plan_in_progress: 1' "Plan is in-progress"
    assert_contains "$output" 'has_plan: true' "Spec shows has_plan"
    echo ""
}

test_greenfield_with_research() {
    echo -e "${YELLOW}Test: Greenfield - with research files${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/market-analysis.md" << 'EOF'
---
topic: market-analysis
status: in-progress
work_type: greenfield
---
# Market Analysis
EOF
    cat > "$TEST_DIR/.workflows/research/tech-stack.md" << 'EOF'
---
topic: tech-stack
status: concluded
work_type: greenfield
---
# Tech Stack
EOF

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'research:' "Has research section"
    assert_contains "$output" 'exists: true' "Research exists"
    assert_contains "$output" '"market-analysis"' "Lists market-analysis file"
    assert_contains "$output" '"tech-stack"' "Lists tech-stack file"
    assert_contains "$output" 'count: 2' "Research count is 2"
    echo ""
}

test_greenfield_with_implementation() {
    echo -e "${YELLOW}Test: Greenfield - with implementation tracking${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/implementation/core-features"
    cat > "$TEST_DIR/.workflows/implementation/core-features/tracking.md" << 'EOF'
---
topic: core-features
status: in-progress
work_type: greenfield
---
# Implementation Tracking
EOF

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'implementation:' "Has implementation section"
    assert_contains "$output" 'topic: "core-features"' "Has core-features entry"
    assert_contains "$output" 'implementation_count: 1' "Implementation count is 1"
    assert_contains "$output" 'implementation_in_progress: 1' "One in-progress implementation"
    echo ""
}

test_greenfield_impl_with_review() {
    echo -e "${YELLOW}Test: Greenfield - implementation with review${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/implementation/core-features"
    mkdir -p "$TEST_DIR/.workflows/review/core-features/r1"
    cat > "$TEST_DIR/.workflows/implementation/core-features/tracking.md" << 'EOF'
---
topic: core-features
status: completed
work_type: greenfield
---
# Implementation Tracking
EOF
    cat > "$TEST_DIR/.workflows/review/core-features/r1/review.md" << 'EOF'
---
topic: core-features
work_type: greenfield
---
# Review
EOF

    local output=$(run_discovery --greenfield)

    assert_contains "$output" 'has_review: true' "Has review flag is true"
    echo ""
}

# ──────────────────────────────────────
# Run all tests
# ──────────────────────────────────────

echo "=========================================="
echo "Running bridge discovery script tests"
echo "=========================================="
echo ""

# Argument parsing
test_missing_work_type_flag
test_unknown_argument
test_feature_without_topic
test_bugfix_without_topic
test_greenfield_without_topic

# Feature pipeline
test_feature_fresh
test_feature_discussion_in_progress
test_feature_discussion_concluded
test_feature_spec_concluded
test_feature_spec_in_progress
test_feature_plan_concluded
test_feature_plan_in_progress
test_feature_impl_in_progress
test_feature_impl_completed_with_review
test_feature_research_exists
test_feature_research_concluded

# Bugfix pipeline
test_bugfix_fresh
test_bugfix_investigation_in_progress
test_bugfix_investigation_concluded
test_bugfix_spec_in_progress
test_bugfix_spec_concluded
test_bugfix_full_pipeline
test_bugfix_impl_completed_with_review

# Cross-pipeline isolation
test_feature_ignores_investigation
test_bugfix_ignores_research
test_bugfix_ignores_discussion

# Greenfield
test_greenfield_fresh
test_greenfield_with_discussions
test_greenfield_filters_by_work_type
test_greenfield_specs_and_plans
test_greenfield_with_research
test_greenfield_with_implementation
test_greenfield_impl_with_review

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
