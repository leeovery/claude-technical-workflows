#!/bin/bash
#
# Tests the discovery script for /start-implementation against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/start-implementation/scripts/discovery.sh"

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

echo -e "${YELLOW}Test: Plan with concluded status${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/completed-feature"

cat > "$TEST_DIR/.workflows/planning/completed-feature/plan.md" << 'EOF'
---
topic: completed-feature
status: concluded
date: 2024-02-01
format: local-markdown
specification: completed-feature/specification.md
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

echo -e "${YELLOW}Test: Environment setup file exists with setup required${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/test"

cat > "$TEST_DIR/.workflows/planning/test/plan.md" << 'EOF'
---
topic: test
status: in-progress
date: 2024-01-01
format: local-markdown
specification: test/specification.md
---

# Implementation Plan: Test
EOF

cat > "$TEST_DIR/.workflows/environment-setup.md" << 'EOF'
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
mkdir -p "$TEST_DIR/.workflows/planning/test"

cat > "$TEST_DIR/.workflows/planning/test/plan.md" << 'EOF'
---
topic: test
status: in-progress
date: 2024-01-01
format: local-markdown
specification: test/specification.md
---

# Implementation Plan: Test
EOF

cat > "$TEST_DIR/.workflows/environment-setup.md" << 'EOF'
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
mkdir -p "$TEST_DIR/.workflows/planning/test"

cat > "$TEST_DIR/.workflows/planning/test/plan.md" << 'EOF'
---
topic: test
status: in-progress
date: 2024-01-01
format: local-markdown
specification: test/specification.md
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

echo -e "${YELLOW}Test: Plan without frontmatter (legacy edge case)${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/no-frontmatter"

cat > "$TEST_DIR/.workflows/planning/no-frontmatter/plan.md" << 'EOF'
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
mkdir -p "$TEST_DIR/.workflows/planning/beads-plan"

cat > "$TEST_DIR/.workflows/planning/beads-plan/plan.md" << 'EOF'
---
topic: beads-plan
status: in-progress
date: 2024-04-01
format: beads
specification: beads-plan/specification.md
---

# Implementation Plan: Beads Plan
EOF

output=$(run_discovery)

assert_contains "$output" "format: \"beads\"" "Non-default format preserved"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with plan_id (beads format)${NC}"
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

echo -e "${YELLOW}Test: Plan without plan_id (local-markdown)${NC}"
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

# ============================================================================
# EXTERNAL DEPENDENCIES FROM FRONTMATTER
# ============================================================================

echo -e "${YELLOW}Test: Plan with empty external_dependencies${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/no-deps"

cat > "$TEST_DIR/.workflows/planning/no-deps/plan.md" << 'EOF'
---
topic: no-deps
status: concluded
format: local-markdown
specification: no-deps/specification.md
external_dependencies: []
---

# Plan: No Deps
EOF

output=$(run_discovery)

assert_contains "$output" "has_unresolved_deps: false" "No unresolved deps with empty array"
assert_contains "$output" "unresolved_dep_count: 0" "Unresolved dep count is 0"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with unresolved dependency${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/has-unresolved"

cat > "$TEST_DIR/.workflows/planning/has-unresolved/plan.md" << 'EOF'
---
topic: has-unresolved
status: concluded
format: local-markdown
specification: has-unresolved/specification.md
external_dependencies:
  - topic: billing-system
    description: Invoice generation for order completion
    state: unresolved
---

# Plan: Has Unresolved
EOF

output=$(run_discovery)

assert_contains "$output" "has_unresolved_deps: true" "Has unresolved deps"
assert_contains "$output" "unresolved_dep_count: 1" "Unresolved dep count is 1"
assert_contains "$output" 'topic: "billing-system"' "Unresolved dep topic extracted"
assert_contains "$output" 'state: "unresolved"' "Unresolved dep state extracted"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with resolved dependency${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/has-resolved"

cat > "$TEST_DIR/.workflows/planning/has-resolved/plan.md" << 'EOF'
---
topic: has-resolved
status: concluded
format: local-markdown
specification: has-resolved/specification.md
external_dependencies:
  - topic: authentication
    description: User context for permissions
    state: resolved
    task_id: auth-1-3
---

# Plan: Has Resolved
EOF

output=$(run_discovery)

assert_contains "$output" "has_unresolved_deps: false" "No unresolved deps"
assert_contains "$output" 'topic: "authentication"' "Resolved dep topic extracted"
assert_contains "$output" 'state: "resolved"' "Resolved dep state extracted"
assert_contains "$output" 'task_id: "auth-1-3"' "Resolved dep task_id extracted"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with satisfied_externally dependency${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/has-external"

cat > "$TEST_DIR/.workflows/planning/has-external/plan.md" << 'EOF'
---
topic: has-external
status: concluded
format: local-markdown
specification: has-external/specification.md
external_dependencies:
  - topic: payment-gateway
    description: Payment processing
    state: satisfied_externally
---

# Plan: Has External
EOF

output=$(run_discovery)

assert_contains "$output" "has_unresolved_deps: false" "No unresolved deps for externally satisfied"
assert_contains "$output" 'state: "satisfied_externally"' "Externally satisfied state extracted"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan with mixed dependencies${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/mixed-deps"

cat > "$TEST_DIR/.workflows/planning/mixed-deps/plan.md" << 'EOF'
---
topic: mixed-deps
status: concluded
format: local-markdown
specification: mixed-deps/specification.md
external_dependencies:
  - topic: billing-system
    description: Invoice generation
    state: unresolved
  - topic: authentication
    description: User context
    state: resolved
    task_id: auth-1-3
  - topic: payment-gateway
    description: Payment processing
    state: satisfied_externally
---

# Plan: Mixed Deps
EOF

output=$(run_discovery)

assert_contains "$output" "has_unresolved_deps: true" "Has unresolved deps in mixed"
assert_contains "$output" "unresolved_dep_count: 1" "Only 1 unresolved in mixed"
assert_contains "$output" 'topic: "billing-system"' "First dep topic"
assert_contains "$output" 'topic: "authentication"' "Second dep topic"
assert_contains "$output" 'topic: "payment-gateway"' "Third dep topic"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Plan without external_dependencies field (legacy)${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/legacy"

cat > "$TEST_DIR/.workflows/planning/legacy/plan.md" << 'EOF'
---
topic: legacy
status: concluded
format: local-markdown
specification: legacy/specification.md
---

# Plan: Legacy
EOF

output=$(run_discovery)

assert_contains "$output" "has_unresolved_deps: false" "No unresolved deps for legacy plan"
assert_contains "$output" "unresolved_dep_count: 0" "Zero unresolved for legacy plan"

echo ""

# ============================================================================
# IMPLEMENTATION TRACKING
# ============================================================================

echo -e "${YELLOW}Test: No implementation directory${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/test"

cat > "$TEST_DIR/.workflows/planning/test/plan.md" << 'EOF'
---
topic: test
status: concluded
format: local-markdown
specification: test/specification.md
external_dependencies: []
---

# Plan: Test
EOF

output=$(run_discovery)

assert_contains "$output" "implementation:" "Has implementation section"
assert_contains "$output" "exists: false" "Implementation does not exist"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Implementation tracking file - in-progress${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/core-features"
mkdir -p "$TEST_DIR/.workflows/implementation"

cat > "$TEST_DIR/.workflows/planning/core-features/plan.md" << 'EOF'
---
topic: core-features
status: concluded
format: local-markdown
specification: core-features/specification.md
external_dependencies: []
---

# Plan: Core Features
EOF

mkdir -p "$TEST_DIR/.workflows/implementation/core-features"
cat > "$TEST_DIR/.workflows/implementation/core-features/tracking.md" << 'EOF'
---
topic: core-features
plan: ../planning/core-features/plan.md
format: local-markdown
status: in-progress
current_phase: 2
current_task: 3
completed_phases:
  - 1
completed_tasks:
  - "core-1-1"
  - "core-1-2"
  - "core-1-3"
  - "core-2-1"
  - "core-2-2"
started: 2025-01-15
updated: 2025-01-20
completed: ~
---

# Implementation: Core Features

## Phase 1: Foundation
All tasks completed.

## Phase 2: Core Logic (current)
- Task 2.1: done
- Task 2.2: done
- Task 2.3: next
EOF

output=$(run_discovery)

assert_contains "$output" 'topic: "core-features"' "Tracking file topic extracted"
assert_contains "$output" 'status: "in-progress"' "Tracking file status extracted"
assert_contains "$output" "current_phase: 2" "Current phase extracted"
assert_contains "$output" "completed_phases: [1]" "Completed phases extracted"
assert_contains "$output" '"core-1-1"' "Completed task extracted"
assert_contains "$output" '"core-2-2"' "Last completed task extracted"
assert_contains "$output" "plans_in_progress_count: 1" "In-progress count is 1"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Implementation tracking file - completed${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/user-auth"
mkdir -p "$TEST_DIR/.workflows/implementation"

cat > "$TEST_DIR/.workflows/planning/user-auth/plan.md" << 'EOF'
---
topic: user-auth
status: concluded
format: local-markdown
specification: user-auth/specification.md
external_dependencies: []
---

# Plan: User Auth
EOF

mkdir -p "$TEST_DIR/.workflows/implementation/user-auth"
cat > "$TEST_DIR/.workflows/implementation/user-auth/tracking.md" << 'EOF'
---
topic: user-auth
plan: ../planning/user-auth/plan.md
format: local-markdown
status: completed
current_phase: 3
current_task: ~
completed_phases:
  - 1
  - 2
  - 3
completed_tasks:
  - "auth-1-1"
  - "auth-1-2"
  - "auth-1-3"
  - "auth-2-1"
started: 2025-01-10
updated: 2025-01-25
completed: 2025-01-25
---

# Implementation: User Auth

All phases completed.
EOF

output=$(run_discovery)

assert_contains "$output" 'status: "completed"' "Completed status extracted"
assert_contains "$output" "completed_phases: [1, 2, 3]" "All completed phases extracted"
assert_contains "$output" '"auth-1-3"' "Specific completed task in list"
assert_contains "$output" "plans_completed_count: 1" "Completed count is 1"

echo ""

# ============================================================================
# DEPENDENCY RESOLUTION
# ============================================================================

echo -e "${YELLOW}Test: Resolved dep with task in completed_tasks${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/billing"
mkdir -p "$TEST_DIR/.workflows/implementation"

cat > "$TEST_DIR/.workflows/planning/billing/plan.md" << 'EOF'
---
topic: billing
status: concluded
format: local-markdown
specification: billing/specification.md
external_dependencies:
  - topic: user-auth
    description: User context for permissions
    state: resolved
    task_id: auth-1-3
---

# Plan: Billing
EOF

mkdir -p "$TEST_DIR/.workflows/implementation/user-auth"
cat > "$TEST_DIR/.workflows/implementation/user-auth/tracking.md" << 'EOF'
---
topic: user-auth
plan: ../planning/user-auth/plan.md
format: local-markdown
status: completed
current_phase: 3
completed_phases:
  - 1
  - 2
  - 3
completed_tasks:
  - "auth-1-1"
  - "auth-1-2"
  - "auth-1-3"
started: 2025-01-10
updated: 2025-01-25
completed: 2025-01-25
---

# Implementation: User Auth
EOF

output=$(run_discovery)

assert_contains "$output" "deps_satisfied: true" "Deps satisfied when task completed"
assert_contains "$output" "plans_ready_count: 1" "Plan is ready"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Resolved dep with task NOT in completed_tasks${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/billing"
mkdir -p "$TEST_DIR/.workflows/implementation"

cat > "$TEST_DIR/.workflows/planning/billing/plan.md" << 'EOF'
---
topic: billing
status: concluded
format: local-markdown
specification: billing/specification.md
external_dependencies:
  - topic: core-features
    description: Core logic needed
    state: resolved
    task_id: core-2-3
---

# Plan: Billing
EOF

mkdir -p "$TEST_DIR/.workflows/implementation/core-features"
cat > "$TEST_DIR/.workflows/implementation/core-features/tracking.md" << 'EOF'
---
topic: core-features
plan: ../planning/core-features/plan.md
format: local-markdown
status: in-progress
current_phase: 2
completed_phases:
  - 1
completed_tasks:
  - "core-1-1"
  - "core-2-1"
  - "core-2-2"
started: 2025-01-15
updated: 2025-01-20
---

# Implementation: Core Features
EOF

output=$(run_discovery)

assert_contains "$output" "deps_satisfied: false" "Deps not satisfied when task incomplete"
assert_contains "$output" 'task_id: "core-2-3"' "Blocking task_id listed"
assert_contains "$output" "task not yet completed" "Blocking reason given"
assert_contains "$output" "plans_ready_count: 0" "Plan is not ready"

echo ""

# ============================================================================
# STATE SUMMARY COUNTS
# ============================================================================

echo -e "${YELLOW}Test: State summary counts with multiple plans${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.workflows/planning/feature-a"
mkdir -p "$TEST_DIR/.workflows/planning/feature-b"
mkdir -p "$TEST_DIR/.workflows/planning/feature-c"
mkdir -p "$TEST_DIR/.workflows/planning/feature-d"
mkdir -p "$TEST_DIR/.workflows/implementation"

# Concluded plan, no deps, no impl -> ready
cat > "$TEST_DIR/.workflows/planning/feature-a/plan.md" << 'EOF'
---
topic: feature-a
status: concluded
format: local-markdown
specification: feature-a/specification.md
external_dependencies: []
---

# Plan: Feature A
EOF

# Concluded plan with unresolved dep -> not ready
cat > "$TEST_DIR/.workflows/planning/feature-b/plan.md" << 'EOF'
---
topic: feature-b
status: concluded
format: local-markdown
specification: feature-b/specification.md
external_dependencies:
  - topic: feature-c
    description: Needs feature C
    state: unresolved
---

# Plan: Feature B
EOF

# Planning status -> not concluded
cat > "$TEST_DIR/.workflows/planning/feature-c/plan.md" << 'EOF'
---
topic: feature-c
status: planning
format: local-markdown
specification: feature-c/specification.md
external_dependencies: []
---

# Plan: Feature C
EOF

# Concluded with completed impl
cat > "$TEST_DIR/.workflows/planning/feature-d/plan.md" << 'EOF'
---
topic: feature-d
status: concluded
format: local-markdown
specification: feature-d/specification.md
external_dependencies: []
---

# Plan: Feature D
EOF

mkdir -p "$TEST_DIR/.workflows/implementation/feature-d"
cat > "$TEST_DIR/.workflows/implementation/feature-d/tracking.md" << 'EOF'
---
topic: feature-d
status: completed
completed_phases: [1, 2]
completed_tasks:
  - "d-1-1"
  - "d-2-1"
started: 2025-01-01
completed: 2025-01-10
---

# Implementation: Feature D
EOF

output=$(run_discovery)

assert_contains "$output" "plan_count: 4" "Total plan count is 4"
assert_contains "$output" "plans_concluded_count: 3" "Concluded count is 3"
assert_contains "$output" "plans_with_unresolved_deps: 1" "Plans with unresolved deps is 1"
assert_contains "$output" "plans_ready_count: 2" "Plans ready count is 2 (A and D)"
assert_contains "$output" "plans_completed_count: 1" "Plans completed count is 1"

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
