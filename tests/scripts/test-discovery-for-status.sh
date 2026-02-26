#!/bin/bash
#
# Tests the discovery script for /status command against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/status/scripts/discovery.sh"

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
# Test: Empty state (no workflow files)
#
test_empty_state() {
    echo -e "${YELLOW}Test: Empty state (no workflow files)${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'research:' "Has research section"
    assert_contains "$output" 'discussions:' "Has discussions section"
    assert_contains "$output" 'specifications:' "Has specifications section"
    assert_contains "$output" 'plans:' "Has plans section"
    assert_contains "$output" 'implementation:' "Has implementation section"
    assert_contains "$output" 'count: 0' "Counts are zero"

    echo ""
}

#
# Test: Research files detected
#
test_research_files() {
    echo -e "${YELLOW}Test: Research files detected${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/market-analysis.md" << 'EOF'
---
topic: market-analysis
---

# Market Analysis
EOF

    cat > "$TEST_DIR/.workflows/research/tech-feasibility.md" << 'EOF'
---
topic: tech-feasibility
---

# Tech Feasibility
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'exists: true' "Research exists"
    assert_contains "$output" '"market-analysis"' "Found market-analysis"
    assert_contains "$output" '"tech-feasibility"' "Found tech-feasibility"
    assert_contains "$output" 'count: 2' "Research count is 2"

    echo ""
}

#
# Test: Discussion status detection
#
test_discussions() {
    echo -e "${YELLOW}Test: Discussion status detection${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
---

# Auth Flow
EOF

    cat > "$TEST_DIR/.workflows/discussion/caching.md" << 'EOF'
---
topic: caching
status: in-progress
---

# Caching
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow"
    assert_contains "$output" 'name: "caching"' "Found caching"
    assert_contains "$output" 'count: 2' "Discussion count is 2"
    assert_contains "$output" 'concluded: 1' "Concluded count is 1"
    assert_contains "$output" 'in_progress: 1' "In-progress count is 1"

    echo ""
}

#
# Test: Specification with multiple sources (many-to-one)
#
test_spec_multiple_sources() {
    echo -e "${YELLOW}Test: Specification with multiple sources (many-to-one)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/auth-system"
    cat > "$TEST_DIR/.workflows/specification/auth-system/specification.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
sources:
  - name: auth-flow
    status: incorporated
  - name: session-management
    status: incorporated
---

# Auth System Specification
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-system"' "Found auth-system spec"
    assert_contains "$output" 'status: "concluded"' "Status is concluded"
    assert_contains "$output" 'type: "feature"' "Type is feature"
    assert_contains "$output" 'name: "auth-flow"' "Source auth-flow found"
    assert_contains "$output" 'name: "session-management"' "Source session-management found"
    assert_contains "$output" 'status: "incorporated"' "Sources marked incorporated"
    assert_contains "$output" 'feature: 1' "Feature count is 1"

    echo ""
}

#
# Test: Specification with pending source
#
test_spec_pending_source() {
    echo -e "${YELLOW}Test: Specification with pending source${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/billing"
    cat > "$TEST_DIR/.workflows/specification/billing/specification.md" << 'EOF'
---
topic: billing
status: in-progress
type: feature
sources:
  - name: payment-processing
    status: incorporated
  - name: rate-limiting
    status: pending
---

# Billing Specification
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "pending"' "Pending source detected"
    assert_contains "$output" 'status: "incorporated"' "Incorporated source detected"

    echo ""
}

#
# Test: Cross-cutting specification
#
test_crosscutting_spec() {
    echo -e "${YELLOW}Test: Cross-cutting specification${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/caching-policy"
    cat > "$TEST_DIR/.workflows/specification/caching-policy/specification.md" << 'EOF'
---
topic: caching-policy
status: concluded
type: cross-cutting
---

# Caching Policy
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'type: "cross-cutting"' "Type is cross-cutting"
    assert_contains "$output" 'crosscutting: 1' "Cross-cutting count is 1"
    assert_contains "$output" 'feature: 0' "Feature count is 0"

    echo ""
}

#
# Test: Superseded specification
#
test_superseded_spec() {
    echo -e "${YELLOW}Test: Superseded specification${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/old-auth"
    mkdir -p "$TEST_DIR/.workflows/specification/auth-system"
    cat > "$TEST_DIR/.workflows/specification/old-auth/specification.md" << 'EOF'
---
topic: old-auth
status: superseded
type: feature
superseded_by: auth-system
---

# Old Auth Specification
EOF

    cat > "$TEST_DIR/.workflows/specification/auth-system/specification.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
---

# Auth System Specification
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'superseded_by: "auth-system"' "Superseded_by field extracted"
    assert_contains "$output" 'superseded: 1' "Superseded count is 1"
    assert_contains "$output" 'active: 1' "Active count is 1"
    assert_contains "$output" 'count: 2' "Total count includes superseded"

    echo ""
}

#
# Test: Specification with no sources
#
test_spec_no_sources() {
    echo -e "${YELLOW}Test: Specification with no sources${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/quick-feature"
    cat > "$TEST_DIR/.workflows/specification/quick-feature/specification.md" << 'EOF'
---
topic: quick-feature
status: concluded
type: feature
---

# Quick Feature

Created via /start-feature with no discussions.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'sources: \[\]' "Empty sources array"

    echo ""
}

#
# Test: Plan with external dependencies
#
test_plan_with_deps() {
    echo -e "${YELLOW}Test: Plan with external dependencies${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/billing"
    cat > "$TEST_DIR/.workflows/planning/billing/plan.md" << 'EOF'
---
topic: billing
status: concluded
format: local-markdown
specification: billing/specification.md
external_dependencies:
  - topic: auth-system
    description: User authentication
    state: unresolved
---

# Billing Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'has_unresolved_deps: true' "Unresolved deps detected"
    assert_contains "$output" 'topic: "auth-system"' "Dep topic extracted"
    assert_contains "$output" 'state: "unresolved"' "Dep state extracted"

    echo ""
}

#
# Test: Plan with resolved dependencies
#
test_plan_resolved_deps() {
    echo -e "${YELLOW}Test: Plan with resolved dependencies${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/billing"
    cat > "$TEST_DIR/.workflows/planning/billing/plan.md" << 'EOF'
---
topic: billing
status: concluded
format: local-markdown
specification: billing/specification.md
external_dependencies:
  - topic: auth-system
    description: User authentication
    state: resolved
    task_id: auth-system-1-3
---

# Billing Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'has_unresolved_deps: false' "No unresolved deps"
    assert_contains "$output" 'state: "resolved"' "Resolved state extracted"
    assert_contains "$output" 'task_id: "auth-system-1-3"' "Task ID extracted"

    echo ""
}

#
# Test: Plan with empty dependencies array
#
test_plan_empty_deps() {
    echo -e "${YELLOW}Test: Plan with empty dependencies array${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/simple"
    cat > "$TEST_DIR/.workflows/planning/simple/plan.md" << 'EOF'
---
topic: simple
status: concluded
format: local-markdown
specification: simple/specification.md
external_dependencies: []
---

# Simple Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'external_deps:' "External deps section exists"
    assert_contains "$output" 'has_unresolved_deps: false' "No unresolved deps"

    echo ""
}

#
# Test: Implementation tracking
#
test_implementation_tracking() {
    echo -e "${YELLOW}Test: Implementation tracking${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/auth-system/tasks"
    mkdir -p "$TEST_DIR/.workflows/implementation/auth-system"

    # Create plan with tasks
    cat > "$TEST_DIR/.workflows/planning/auth-system/plan.md" << 'EOF'
---
topic: auth-system
status: concluded
format: local-markdown
---

# Auth System Plan
EOF

    cat > "$TEST_DIR/.workflows/planning/auth-system/tasks/auth-system-1-1.md" << 'EOF'
---
task_id: auth-system-1-1
---
Task 1
EOF

    cat > "$TEST_DIR/.workflows/planning/auth-system/tasks/auth-system-1-2.md" << 'EOF'
---
task_id: auth-system-1-2
---
Task 2
EOF

    cat > "$TEST_DIR/.workflows/planning/auth-system/tasks/auth-system-1-3.md" << 'EOF'
---
task_id: auth-system-1-3
---
Task 3
EOF

    # Create tracking file
    cat > "$TEST_DIR/.workflows/implementation/auth-system/tracking.md" << 'EOF'
---
status: in-progress
current_phase: 1
current_task: auth-system-1-2
completed_tasks:
  - auth-system-1-1
completed_phases: []
---

# Auth System Implementation
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'topic: "auth-system"' "Implementation topic found"
    assert_contains "$output" 'status: "in-progress"' "Status is in-progress"
    assert_contains "$output" 'current_phase: 1' "Current phase is 1"
    assert_contains "$output" 'completed_tasks: 1' "1 completed task"
    assert_contains "$output" 'total_tasks: 3' "3 total tasks from plan"
    assert_contains "$output" 'in_progress: 1' "1 in-progress implementation"

    echo ""
}

#
# Test: Completed implementation
#
test_completed_implementation() {
    echo -e "${YELLOW}Test: Completed implementation${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/auth-system/tasks"
    mkdir -p "$TEST_DIR/.workflows/implementation/auth-system"

    cat > "$TEST_DIR/.workflows/planning/auth-system/plan.md" << 'EOF'
---
topic: auth-system
status: concluded
format: local-markdown
---

# Auth System Plan
EOF

    cat > "$TEST_DIR/.workflows/planning/auth-system/tasks/auth-system-1-1.md" << 'EOF'
---
task_id: auth-system-1-1
---
Task 1
EOF

    cat > "$TEST_DIR/.workflows/implementation/auth-system/tracking.md" << 'EOF'
---
status: completed
current_phase: ~
current_task: ~
completed_tasks:
  - auth-system-1-1
completed_phases:
  - 1
---

# Auth System Implementation
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "completed"' "Status is completed"
    assert_contains "$output" 'completed_tasks: 1' "1 completed task"
    assert_contains "$output" 'completed_phases: 1' "1 completed phase"
    assert_contains "$output" 'completed: 1' "Completed count is 1"

    echo ""
}

#
# Test: Implementation with inline completed_phases format
#
test_implementation_inline_phases() {
    echo -e "${YELLOW}Test: Implementation with inline completed_phases format${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/implementation/auth-system"

    cat > "$TEST_DIR/.workflows/implementation/auth-system/tracking.md" << 'EOF'
---
status: in-progress
current_phase: 3
completed_tasks:
  - auth-system-1-1
  - auth-system-1-2
  - auth-system-2-1
completed_phases: [1, 2]
---

# Auth System Implementation
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'completed_tasks: 3' "3 completed tasks"
    assert_contains "$output" 'completed_phases: 2' "2 completed phases (inline format)"

    echo ""
}

#
# Test: Full workflow state across all phases
#
test_full_workflow() {
    echo -e "${YELLOW}Test: Full workflow state across all phases${NC}"
    setup_fixture

    # Research
    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/market-analysis.md" << 'EOF'
---
topic: market-analysis
---
Research
EOF

    # Discussions (3 total: 2 concluded into 1 spec, 1 in-progress)
    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
---
Discussion
EOF
    cat > "$TEST_DIR/.workflows/discussion/session-mgmt.md" << 'EOF'
---
topic: session-mgmt
status: concluded
---
Discussion
EOF
    cat > "$TEST_DIR/.workflows/discussion/caching.md" << 'EOF'
---
topic: caching
status: in-progress
---
Discussion
EOF

    # Specifications (1 feature with 2 sources, 1 cross-cutting)
    mkdir -p "$TEST_DIR/.workflows/specification/auth-system"
    mkdir -p "$TEST_DIR/.workflows/specification/caching-policy"
    cat > "$TEST_DIR/.workflows/specification/auth-system/specification.md" << 'EOF'
---
topic: auth-system
status: concluded
type: feature
sources:
  - name: auth-flow
    status: incorporated
  - name: session-mgmt
    status: incorporated
---
Spec
EOF
    cat > "$TEST_DIR/.workflows/specification/caching-policy/specification.md" << 'EOF'
---
topic: caching-policy
status: in-progress
type: cross-cutting
sources:
  - name: caching
    status: pending
---
Spec
EOF

    # Plan
    mkdir -p "$TEST_DIR/.workflows/planning/auth-system/tasks"
    cat > "$TEST_DIR/.workflows/planning/auth-system/plan.md" << 'EOF'
---
topic: auth-system
status: concluded
format: local-markdown
specification: auth-system/specification.md
external_dependencies: []
---
Plan
EOF
    cat > "$TEST_DIR/.workflows/planning/auth-system/tasks/auth-system-1-1.md" << 'EOF'
---
task_id: auth-system-1-1
---
Task
EOF
    cat > "$TEST_DIR/.workflows/planning/auth-system/tasks/auth-system-1-2.md" << 'EOF'
---
task_id: auth-system-1-2
---
Task
EOF

    # Implementation
    mkdir -p "$TEST_DIR/.workflows/implementation/auth-system"
    cat > "$TEST_DIR/.workflows/implementation/auth-system/tracking.md" << 'EOF'
---
status: in-progress
current_phase: 1
current_task: auth-system-1-2
completed_tasks:
  - auth-system-1-1
completed_phases: []
---
Tracking
EOF

    local output=$(run_discovery)

    # Research
    assert_contains "$output" '"market-analysis"' "Research file found"

    # Discussions
    assert_contains "$output" 'concluded: 2' "2 concluded discussions"
    assert_contains "$output" 'in_progress: 1' "1 in-progress discussion"

    # Specifications
    assert_contains "$output" 'active: 2' "2 active specifications"
    assert_contains "$output" 'feature: 1' "1 feature spec"
    assert_contains "$output" 'crosscutting: 1' "1 cross-cutting spec"
    # auth-system spec has 2 sources
    assert_contains "$output" 'name: "auth-flow"' "Source auth-flow found"
    assert_contains "$output" 'name: "session-mgmt"' "Source session-mgmt found"

    # Plans
    assert_contains "$output" 'concluded: 1' "1 concluded plan"

    # Implementation
    assert_contains "$output" 'completed_tasks: 1' "1 completed task"
    assert_contains "$output" 'total_tasks: 2' "2 total tasks"

    echo ""
}

#
# Test: Plan status counts
#
test_plan_status_counts() {
    echo -e "${YELLOW}Test: Plan status counts${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/auth-system"
    mkdir -p "$TEST_DIR/.workflows/planning/billing"

    cat > "$TEST_DIR/.workflows/planning/auth-system/plan.md" << 'EOF'
---
topic: auth-system
status: concluded
format: local-markdown
specification: auth-system/specification.md
external_dependencies: []
---
Plan
EOF

    cat > "$TEST_DIR/.workflows/planning/billing/plan.md" << 'EOF'
---
topic: billing
status: planning
format: local-markdown
specification: billing/specification.md
external_dependencies: []
---
Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'count: 2' "2 plans total"
    assert_contains "$output" 'concluded: 1' "1 concluded"
    assert_contains "$output" 'in_progress: 1' "1 in-progress (planning status)"

    echo ""
}

#
# Test: Spec defaults to feature type when missing
#
test_spec_default_type() {
    echo -e "${YELLOW}Test: Spec defaults to feature type when missing${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/legacy"
    cat > "$TEST_DIR/.workflows/specification/legacy/specification.md" << 'EOF'
---
topic: legacy
status: concluded
---
No type field
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'type: "feature"' "Defaults to feature"
    assert_contains "$output" 'feature: 1' "Counted as feature"

    echo ""
}

#
# Test: Plan specification link
#
test_plan_spec_link() {
    echo -e "${YELLOW}Test: Plan specification link${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/auth-system"
    cat > "$TEST_DIR/.workflows/planning/auth-system/plan.md" << 'EOF'
---
topic: auth-system
status: concluded
format: local-markdown
specification: auth-system/specification.md
---
Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'specification: "auth-system/specification.md"' "Specification link extracted"

    echo ""
}

#
# Test: Plan defaults specification to {name}.md when missing
#
test_plan_default_spec() {
    echo -e "${YELLOW}Test: Plan defaults specification when missing${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/auth-system"
    cat > "$TEST_DIR/.workflows/planning/auth-system/plan.md" << 'EOF'
---
topic: auth-system
status: concluded
format: local-markdown
---
Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'specification: "auth-system/specification.md"' "Defaults to {name}/specification.md"

    echo ""
}

#
# Test: Discussion work_type output
#
test_discussion_work_type_output() {
    echo -e "${YELLOW}Test: Discussion work_type output${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/with-type.md" << 'EOF'
---
topic: with-type
status: in-progress
work_type: feature
---
Discussion
EOF

    cat > "$TEST_DIR/.workflows/discussion/no-type.md" << 'EOF'
---
topic: no-type
status: in-progress
---
Discussion
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'work_type: "feature"' "Explicit work_type is feature"
    assert_contains "$output" 'work_type: "greenfield"' "Missing work_type defaults to greenfield"

    echo ""
}

#
# Test: Spec work_type output
#
test_spec_work_type_output() {
    echo -e "${YELLOW}Test: Spec work_type output${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/specification/bugfix-spec"
    cat > "$TEST_DIR/.workflows/specification/bugfix-spec/specification.md" << 'EOF'
---
topic: bugfix-spec
status: concluded
type: feature
work_type: bugfix
---
Spec
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'work_type: "bugfix"' "Spec work_type is bugfix"

    echo ""
}

#
# Test: Plan work_type output
#
test_plan_work_type_output() {
    echo -e "${YELLOW}Test: Plan work_type output${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/feature-plan"
    cat > "$TEST_DIR/.workflows/planning/feature-plan/plan.md" << 'EOF'
---
topic: feature-plan
status: concluded
format: local-markdown
work_type: feature
---
Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'work_type: "feature"' "Plan work_type is feature"

    echo ""
}

#
# Test: Plan in-progress status counted
#
test_plan_in_progress_status_counted() {
    echo -e "${YELLOW}Test: Plan in-progress status counted${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/planning/wip-plan"
    cat > "$TEST_DIR/.workflows/planning/wip-plan/plan.md" << 'EOF'
---
topic: wip-plan
status: in-progress
format: local-markdown
---
Plan
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'in_progress: 1' "in-progress status counted in in_progress total"

    echo ""
}

#
# Run all tests
#
echo "=========================================="
echo "Running discovery-for-status.sh tests"
echo "=========================================="
echo ""

test_empty_state
test_research_files
test_discussions
test_spec_multiple_sources
test_spec_pending_source
test_crosscutting_spec
test_superseded_spec
test_spec_no_sources
test_plan_with_deps
test_plan_resolved_deps
test_plan_empty_deps
test_implementation_tracking
test_completed_implementation
test_implementation_inline_phases
test_full_workflow
test_plan_status_counts
test_spec_default_type
test_plan_spec_link
test_plan_default_spec
test_discussion_work_type_output
test_spec_work_type_output
test_plan_work_type_output
test_plan_in_progress_status_counted

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
