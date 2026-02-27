#!/bin/bash
#
# Tests the discovery script for workflow-start (unified entry point).
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/workflow-start/scripts/discovery.sh"

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
# Fresh state
# ──────────────────────────────────────

test_fresh_state() {
    echo -e "${YELLOW}Test: Fresh state (no artifacts)${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'greenfield:' "Has greenfield section"
    assert_contains "$output" 'features:' "Has features section"
    assert_contains "$output" 'bugfixes:' "Has bugfixes section"
    assert_contains "$output" 'has_any_work: false' "No work exists"
    assert_contains "$output" 'feature_count: 0' "Feature count is 0"
    assert_contains "$output" 'bugfix_count: 0' "Bugfix count is 0"
    assert_contains "$output" 'research_count: 0' "Research count is 0"
    echo ""
}

# ──────────────────────────────────────
# Greenfield section
# ──────────────────────────────────────

test_greenfield_research() {
    echo -e "${YELLOW}Test: Greenfield research files${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-20
---
# Research
EOF
    cat > "$TEST_DIR/.workflows/research/market.md" << 'EOF'
---
topic: market
date: 2026-01-21
---
# Market
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'research_count: 2' "Research count is 2"
    assert_contains "$output" 'has_any_work: true' "Has work"
    echo ""
}

test_greenfield_discussions() {
    echo -e "${YELLOW}Test: Greenfield discussions (filters by work_type)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"

    # Greenfield discussion (no work_type = defaults to greenfield)
    cat > "$TEST_DIR/.workflows/discussion/auth-design.md" << 'EOF'
---
topic: auth-design
status: concluded
---
# Auth Design
EOF

    # Explicit greenfield
    cat > "$TEST_DIR/.workflows/discussion/data-model.md" << 'EOF'
---
topic: data-model
status: in-progress
work_type: greenfield
---
# Data Model
EOF

    # Feature discussion — should NOT appear in greenfield section
    cat > "$TEST_DIR/.workflows/discussion/search-feature.md" << 'EOF'
---
topic: search-feature
status: concluded
work_type: feature
---
# Search Feature
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'discussion_count: 2' "Greenfield discussion count is 2"
    assert_contains "$output" 'discussion_concluded: 1' "One concluded greenfield discussion"
    # in_progress count is in the phase detail section (not state summary)
    assert_contains "$output" 'in_progress: 1' "One in-progress greenfield discussion"
    echo ""
}

test_greenfield_specifications() {
    echo -e "${YELLOW}Test: Greenfield specifications with types${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/core-features"
    mkdir -p "$TEST_DIR/.workflows/specification/error-handling"

    cat > "$TEST_DIR/.workflows/specification/core-features/specification.md" << 'EOF'
---
topic: core-features
status: concluded
work_type: greenfield
type: feature
---
EOF

    cat > "$TEST_DIR/.workflows/specification/error-handling/specification.md" << 'EOF'
---
topic: error-handling
status: in-progress
work_type: greenfield
type: cross-cutting
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'specification_count: 2' "Spec count is 2"
    assert_contains "$output" 'specification_concluded: 1' "One concluded spec"
    echo ""
}

test_greenfield_plans_and_impl() {
    echo -e "${YELLOW}Test: Greenfield plans and implementation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/core-features"
    mkdir -p "$TEST_DIR/.workflows/implementation/core-features"

    cat > "$TEST_DIR/.workflows/planning/core-features/plan.md" << 'EOF'
---
topic: core-features
status: concluded
work_type: greenfield
---
EOF

    cat > "$TEST_DIR/.workflows/implementation/core-features/tracking.md" << 'EOF'
---
topic: core-features
status: in-progress
work_type: greenfield
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'plan_count: 1' "Plan count is 1"
    assert_contains "$output" 'plan_concluded: 1' "Plan is concluded"
    assert_contains "$output" 'implementation_count: 1' "Impl count is 1"
    assert_contains "$output" 'implementation_completed: 0' "No completed implementations"
    echo ""
}

test_greenfield_superseded_spec_excluded() {
    echo -e "${YELLOW}Test: Greenfield superseded spec excluded from counts${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/portal"
    mkdir -p "$TEST_DIR/.workflows/specification/zw"

    cat > "$TEST_DIR/.workflows/specification/portal/specification.md" << 'EOF'
---
topic: portal
status: concluded
work_type: greenfield
type: feature
---
EOF

    cat > "$TEST_DIR/.workflows/specification/zw/specification.md" << 'EOF'
---
topic: zw
status: superseded
superseded_by: portal
work_type: greenfield
type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'specification_count: 1' "Superseded spec excluded from count"
    assert_contains "$output" 'specification_concluded: 1' "Only concluded spec counted"
    assert_not_contains "$output" 'name: "zw"' "Superseded spec not listed"
    echo ""
}

# ──────────────────────────────────────
# Features section
# ──────────────────────────────────────

test_feature_topic_discovery() {
    echo -e "${YELLOW}Test: Feature topics discovered from discussions${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature_count: 1' "Feature count is 1"
    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow topic"
    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    assert_contains "$output" 'phase_label: "ready for specification"' "Phase label is ready for specification"
    echo ""
}

test_feature_multi_phase() {
    echo -e "${YELLOW}Test: Feature topic with multiple phases${NC}"
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

    local output=$(run_discovery)

    assert_contains "$output" 'feature_count: 1' "Feature count is 1 (deduplicated)"
    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning (plan in-progress)"
    assert_contains "$output" 'phase_label: "planning (in-progress)"' "Phase label is planning (in-progress)"
    echo ""
}

test_feature_deduplication() {
    echo -e "${YELLOW}Test: Feature topic deduplicated across phases${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/search"

    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature_count: 1' "Only one feature topic (deduplicated)"
    assert_contains "$output" 'phase_label: "specification (in-progress)"' "Phase label is specification (in-progress)"
    echo ""
}

test_feature_from_spec_only() {
    echo -e "${YELLOW}Test: Feature discovered from specification only${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/search"
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature_count: 1' "Feature count is 1"
    assert_contains "$output" 'name: "search"' "Found search topic"
    assert_contains "$output" 'exists: false' "Discussion does not exist"
    assert_contains "$output" 'exists: true' "Specification exists"
    echo ""
}

test_feature_from_plan_only() {
    echo -e "${YELLOW}Test: Feature discovered from plan only${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/search"
    cat > "$TEST_DIR/.workflows/planning/search/plan.md" << 'EOF'
---
topic: search
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature_count: 1' "Feature count is 1"
    assert_contains "$output" 'name: "search"' "Found search topic"
    echo ""
}

test_feature_phase_detail_fields() {
    echo -e "${YELLOW}Test: Feature per-topic phase detail output${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/billing"
    mkdir -p "$TEST_DIR/.workflows/planning/billing"

    cat > "$TEST_DIR/.workflows/discussion/billing.md" << 'EOF'
---
topic: billing
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/billing/specification.md" << 'EOF'
---
topic: billing
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/billing/plan.md" << 'EOF'
---
topic: billing
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery)

    # Extract just the billing topic block from features section
    local feature_block=$(echo "$output" | sed -n '/name: "billing"/,/^    - name:/p' | head -20)

    assert_contains "$feature_block" 'discussion:' "Has discussion section"
    assert_contains "$feature_block" 'specification:' "Has specification section"
    assert_contains "$feature_block" 'plan:' "Has plan section"
    assert_contains "$feature_block" 'implementation:' "Has implementation section"
    assert_contains "$feature_block" 'review:' "Has review section"

    # Discussion, spec, plan exist
    # Implementation and review do not — check the full output for exists: false (appears for impl + review)
    local impl_block=$(echo "$output" | sed -n '/name: "billing"/,/^    - name:/p' | sed -n '/implementation:/,/review:/p')
    assert_contains "$impl_block" 'exists: false' "Implementation does not exist"

    local review_block=$(echo "$output" | sed -n '/name: "billing"/,/^  count:/p' | sed -n '/review:/,/$/p')
    assert_contains "$review_block" 'exists: false' "Review does not exist"
    echo ""
}

test_feature_next_phase_discussion() {
    echo -e "${YELLOW}Test: Feature with in-progress discussion → next_phase discussion${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "discussion"' "Next phase is discussion"
    assert_contains "$output" 'phase_label: "discussion (in-progress)"' "Phase label is discussion (in-progress)"
    echo ""
}

test_feature_next_phase_impl_from_plan() {
    echo -e "${YELLOW}Test: Feature with concluded plan → next_phase implementation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/search"
    mkdir -p "$TEST_DIR/.workflows/planning/search"

    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/search/plan.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    assert_contains "$output" 'phase_label: "ready for implementation"' "Phase label is ready for implementation"
    echo ""
}

test_feature_next_phase_review() {
    echo -e "${YELLOW}Test: Feature with completed impl + no review → next_phase review${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/search"
    mkdir -p "$TEST_DIR/.workflows/planning/search"
    mkdir -p "$TEST_DIR/.workflows/implementation/search"

    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/search/plan.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/implementation/search/tracking.md" << 'EOF'
---
topic: search
status: completed
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "review"' "Next phase is review"
    assert_contains "$output" 'phase_label: "ready for review"' "Phase label is ready for review"
    echo ""
}

test_feature_next_phase_done() {
    echo -e "${YELLOW}Test: Feature with completed impl + review → next_phase done${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/search"
    mkdir -p "$TEST_DIR/.workflows/planning/search"
    mkdir -p "$TEST_DIR/.workflows/implementation/search"
    mkdir -p "$TEST_DIR/.workflows/review/search/r1"

    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/search/plan.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/implementation/search/tracking.md" << 'EOF'
---
topic: search
status: completed
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/review/search/r1/review.md" << 'EOF'
---
topic: search
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "done"' "Next phase is done"
    assert_contains "$output" 'phase_label: "pipeline complete"' "Phase label is pipeline complete (feature)"
    echo ""
}

test_feature_superseded_spec_excluded() {
    echo -e "${YELLOW}Test: Feature with superseded spec excluded from topics${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/old-search"

    cat > "$TEST_DIR/.workflows/specification/old-search/specification.md" << 'EOF'
---
topic: old-search
status: superseded
superseded_by: new-search
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'feature_count: 0' "Superseded feature spec not collected as topic"
    echo ""
}

test_feature_next_phase_superseded() {
    echo -e "${YELLOW}Test: Feature with superseded spec → next_phase superseded${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/search"

    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: superseded
superseded_by: unified-search
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "superseded"' "Next phase is superseded"
    assert_contains "$output" 'phase_label: "superseded"' "Phase label is superseded (feature)"
    echo ""
}

test_feature_next_phase_planning() {
    echo -e "${YELLOW}Test: Feature with concluded spec (no plan) → next_phase planning${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/search"

    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    assert_contains "$output" 'phase_label: "ready for planning"' "Phase label is ready for planning"
    echo ""
}

# ──────────────────────────────────────
# Bugfixes section
# ──────────────────────────────────────

test_bugfix_from_investigation() {
    echo -e "${YELLOW}Test: Bugfix discovered from investigation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: in-progress
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'bugfix_count: 1' "Bugfix count is 1"
    assert_contains "$output" 'name: "login-crash"' "Found login-crash bugfix"
    assert_contains "$output" 'next_phase: "investigation"' "Next phase is investigation"
    assert_contains "$output" 'phase_label: "investigation (in-progress)"' "Phase label is investigation (in-progress)"
    echo ""
}

test_bugfix_concluded_investigation() {
    echo -e "${YELLOW}Test: Bugfix with concluded investigation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: concluded
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "specification"' "Next phase is specification"
    assert_contains "$output" 'phase_label: "ready for specification"' "Phase label is ready for specification (bugfix)"
    echo ""
}

test_bugfix_full_pipeline() {
    echo -e "${YELLOW}Test: Bugfix through full pipeline${NC}"
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
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "done"' "Next phase is done"
    assert_contains "$output" 'phase_label: "pipeline complete"' "Phase label is pipeline complete (bugfix)"
    echo ""
}

test_bugfix_superseded_spec_excluded() {
    echo -e "${YELLOW}Test: Bugfix with superseded spec excluded from topics${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/old-fix"

    cat > "$TEST_DIR/.workflows/specification/old-fix/specification.md" << 'EOF'
---
topic: old-fix
status: superseded
superseded_by: new-fix
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'bugfix_count: 0' "Superseded bugfix spec not collected as topic"
    echo ""
}

test_bugfix_next_phase_superseded() {
    echo -e "${YELLOW}Test: Bugfix with superseded spec → next_phase superseded${NC}"
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
status: superseded
superseded_by: auth-crash
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "superseded"' "Next phase is superseded"
    assert_contains "$output" 'phase_label: "superseded"' "Phase label is superseded (bugfix)"
    echo ""
}

test_bugfix_from_discussion() {
    echo -e "${YELLOW}Test: Bugfix discovered from discussion with work_type bugfix${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/null-pointer.md" << 'EOF'
---
topic: null-pointer
status: in-progress
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'bugfix_count: 1' "Bugfix count is 1"
    assert_contains "$output" 'name: "null-pointer"' "Found null-pointer bugfix"
    assert_contains "$output" 'phase_label: "unknown"' "Phase label is unknown (bugfix from discussion only)"
    echo ""
}

test_bugfix_from_spec() {
    echo -e "${YELLOW}Test: Bugfix discovered from spec with work_type bugfix${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/null-pointer"
    cat > "$TEST_DIR/.workflows/specification/null-pointer/specification.md" << 'EOF'
---
topic: null-pointer
status: in-progress
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'bugfix_count: 1' "Bugfix count is 1"
    assert_contains "$output" 'name: "null-pointer"' "Found null-pointer bugfix"
    assert_contains "$output" 'phase_label: "specification (in-progress)"' "Phase label is specification (in-progress)"
    echo ""
}

test_bugfix_deduplication_across_phases() {
    echo -e "${YELLOW}Test: Bugfix deduplicated across investigation + spec + plan${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/specification/login-crash"
    mkdir -p "$TEST_DIR/.workflows/planning/login-crash"

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
status: in-progress
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'bugfix_count: 1' "Only one bugfix topic (deduplicated)"
    assert_contains "$output" 'phase_label: "planning (in-progress)"' "Phase label is planning (in-progress) for bugfix"
    echo ""
}

# ──────────────────────────────────────
# Phase label disambiguation
# ──────────────────────────────────────

test_feature_phase_label_impl_in_progress() {
    echo -e "${YELLOW}Test: Feature impl in-progress → phase_label implementation (in-progress)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/specification/search"
    mkdir -p "$TEST_DIR/.workflows/planning/search"
    mkdir -p "$TEST_DIR/.workflows/implementation/search"

    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/search/specification.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/planning/search/plan.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/implementation/search/tracking.md" << 'EOF'
---
topic: search
status: in-progress
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    assert_contains "$output" 'phase_label: "implementation (in-progress)"' "Phase label is implementation (in-progress)"
    echo ""
}

test_bugfix_phase_label_impl_in_progress() {
    echo -e "${YELLOW}Test: Bugfix impl in-progress → phase_label implementation (in-progress)${NC}"
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
status: in-progress
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    assert_contains "$output" 'phase_label: "implementation (in-progress)"' "Phase label is implementation (in-progress) for bugfix"
    echo ""
}

test_bugfix_phase_label_ready_for_planning() {
    echo -e "${YELLOW}Test: Bugfix spec concluded, no plan → phase_label ready for planning${NC}"
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

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "planning"' "Next phase is planning"
    assert_contains "$output" 'phase_label: "ready for planning"' "Phase label is ready for planning (bugfix)"
    echo ""
}

test_bugfix_phase_label_ready_for_impl() {
    echo -e "${YELLOW}Test: Bugfix plan concluded → phase_label ready for implementation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"
    mkdir -p "$TEST_DIR/.workflows/specification/login-crash"
    mkdir -p "$TEST_DIR/.workflows/planning/login-crash"

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

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "implementation"' "Next phase is implementation"
    assert_contains "$output" 'phase_label: "ready for implementation"' "Phase label is ready for implementation (bugfix)"
    echo ""
}

test_bugfix_phase_label_ready_for_review() {
    echo -e "${YELLOW}Test: Bugfix impl completed → phase_label ready for review${NC}"
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

    local output=$(run_discovery)

    assert_contains "$output" 'next_phase: "review"' "Next phase is review"
    assert_contains "$output" 'phase_label: "ready for review"' "Phase label is ready for review (bugfix)"
    echo ""
}

# ──────────────────────────────────────
# Mixed work types
# ──────────────────────────────────────

test_mixed_work_types() {
    echo -e "${YELLOW}Test: Mixed greenfield, feature, and bugfix artifacts${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    mkdir -p "$TEST_DIR/.workflows/discussion"
    mkdir -p "$TEST_DIR/.workflows/investigation/login-crash"

    # Greenfield research
    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-20
---
EOF

    # Greenfield discussion
    cat > "$TEST_DIR/.workflows/discussion/arch-design.md" << 'EOF'
---
topic: arch-design
status: in-progress
work_type: greenfield
---
EOF

    # Feature discussion
    cat > "$TEST_DIR/.workflows/discussion/search.md" << 'EOF'
---
topic: search
status: concluded
work_type: feature
---
EOF

    # Bugfix investigation
    cat > "$TEST_DIR/.workflows/investigation/login-crash/investigation.md" << 'EOF'
---
topic: login-crash
status: in-progress
work_type: bugfix
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'research_count: 1' "One research file"
    assert_contains "$output" 'discussion_count: 1' "One greenfield discussion"
    assert_contains "$output" 'feature_count: 1' "One feature topic"
    assert_contains "$output" 'bugfix_count: 1' "One bugfix topic"
    assert_contains "$output" 'has_any_work: true' "Has work"
    echo ""
}

test_greenfield_excludes_feature_specs() {
    echo -e "${YELLOW}Test: Greenfield section excludes feature specs${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/gf-spec"
    mkdir -p "$TEST_DIR/.workflows/specification/feat-spec"

    cat > "$TEST_DIR/.workflows/specification/gf-spec/specification.md" << 'EOF'
---
topic: gf-spec
status: concluded
work_type: greenfield
type: feature
---
EOF
    cat > "$TEST_DIR/.workflows/specification/feat-spec/specification.md" << 'EOF'
---
topic: feat-spec
status: concluded
work_type: feature
---
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'specification_count: 1' "Only one greenfield spec"
    assert_contains "$output" 'specification_concluded: 1' "Greenfield spec is concluded"
    echo ""
}

test_no_workflows_dir() {
    echo -e "${YELLOW}Test: No .workflows directory at all${NC}"
    rm -rf "$TEST_DIR/.workflows"

    local output=$(run_discovery)

    assert_contains "$output" 'has_any_work: false' "No work exists"
    assert_contains "$output" 'feature_count: 0' "Feature count is 0"
    assert_contains "$output" 'bugfix_count: 0' "Bugfix count is 0"
    assert_contains "$output" 'research_count: 0' "Research count is 0"
    echo ""
}

# ──────────────────────────────────────
# Run all tests
# ──────────────────────────────────────

echo "=========================================="
echo "Running discovery-for-start tests"
echo "=========================================="
echo ""

# Fresh state
test_fresh_state

# Greenfield
test_greenfield_research
test_greenfield_discussions
test_greenfield_specifications
test_greenfield_plans_and_impl
test_greenfield_superseded_spec_excluded

# Features
test_feature_topic_discovery
test_feature_multi_phase
test_feature_deduplication
test_feature_from_spec_only
test_feature_from_plan_only
test_feature_phase_detail_fields
test_feature_next_phase_discussion
test_feature_next_phase_impl_from_plan
test_feature_next_phase_review
test_feature_next_phase_done
test_feature_next_phase_planning
test_feature_superseded_spec_excluded
test_feature_next_phase_superseded

# Bugfixes
test_bugfix_from_investigation
test_bugfix_concluded_investigation
test_bugfix_full_pipeline
test_bugfix_superseded_spec_excluded
test_bugfix_next_phase_superseded
test_bugfix_from_discussion
test_bugfix_from_spec
test_bugfix_deduplication_across_phases

# Phase label disambiguation
test_feature_phase_label_impl_in_progress
test_bugfix_phase_label_impl_in_progress
test_bugfix_phase_label_ready_for_planning
test_bugfix_phase_label_ready_for_impl
test_bugfix_phase_label_ready_for_review

# Mixed
test_mixed_work_types
test_greenfield_excludes_feature_specs
test_no_workflows_dir

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
