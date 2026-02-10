#!/bin/bash
#
# Tests the discovery-for-specification.sh script against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/start-specification/scripts/discovery.sh"

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
# Test: Fresh state (no discussions or specs)
#
test_fresh_state() {
    echo -e "${YELLOW}Test: Fresh state (no discussions or specs)${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'discussions:' "Has discussions section"
    assert_contains "$output" '\[\]  # No discussions found' "Discussions empty"
    assert_contains "$output" 'specifications:' "Has specifications section"
    assert_contains "$output" '\[\]  # No specifications found' "Specifications empty"
    assert_contains "$output" 'status: "none"' "Cache status is none"
    assert_contains "$output" 'concluded_count: 0' "Concluded count is 0"
    assert_contains "$output" 'discussion_count: 0' "Discussion count is 0"
    assert_contains "$output" 'in_progress_count: 0' "In-progress count is 0"
    assert_contains "$output" 'spec_count: 0' "Spec count is 0"
    assert_contains "$output" 'has_discussions: false' "has_discussions is false"
    assert_contains "$output" 'has_concluded: false' "has_concluded is false"
    assert_contains "$output" 'has_specs: false' "has_specs is false"

    echo ""
}

#
# Test: Discussions only
#
test_discussions_only() {
    echo -e "${YELLOW}Test: Discussions only (no specs)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: in-progress
date: 2026-01-20
---

# Discussion: Auth Flow
EOF

    cat > "$TEST_DIR/docs/workflow/discussion/api-design.md" << 'EOF'
---
topic: api-design
status: concluded
date: 2026-01-19
---

# Discussion: API Design
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow discussion"
    assert_contains "$output" 'name: "api-design"' "Found api-design discussion"
    assert_contains "$output" 'status: "in-progress"' "Found in-progress status"
    assert_contains "$output" 'status: "concluded"' "Found concluded status"
    assert_contains "$output" 'has_individual_spec: false' "No individual spec exists"
    assert_contains "$output" 'concluded_count: 1' "One concluded discussion"
    assert_contains "$output" 'discussion_count: 2' "Two total discussions"
    assert_contains "$output" 'in_progress_count: 1' "One in-progress discussion"
    assert_contains "$output" 'spec_count: 0' "No specs"
    assert_contains "$output" 'has_discussions: true' "has_discussions is true"
    assert_contains "$output" 'has_concluded: true' "has_concluded is true"
    assert_contains "$output" 'has_specs: false' "has_specs is false"

    echo ""
}

#
# Test: Specifications only
#
test_specifications_only() {
    echo -e "${YELLOW}Test: Specifications only (no discussions)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: in-progress
type: feature
date: 2026-01-20
---

# Specification: Auth System
EOF

    local output=$(run_discovery)

    assert_contains "$output" '\[\]  # No discussions found' "Discussions empty"
    assert_contains "$output" 'name: "auth-system"' "Found auth-system spec"
    assert_contains "$output" 'status: "in-progress"' "Status is in-progress"

    echo ""
}

#
# Test: Discussion with corresponding spec
#
test_discussion_with_spec() {
    echo -e "${YELLOW}Test: Discussion with corresponding spec${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
date: 2026-01-20
---

# Discussion: Auth Flow
EOF

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: in-progress
type: feature
date: 2026-01-21
---

# Specification: Auth Flow
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'has_individual_spec: true' "Discussion has corresponding spec"
    assert_contains "$output" 'spec_status: "in-progress"' "Spec status is in-progress"

    echo ""
}

#
# Test: Discussion with corresponding concluded spec
#
test_discussion_with_concluded_spec() {
    echo -e "${YELLOW}Test: Discussion with corresponding concluded spec${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/discussion/billing.md" << 'EOF'
---
topic: billing
status: concluded
date: 2026-01-20
---

# Discussion: Billing
EOF

    cat > "$TEST_DIR/docs/workflow/specification/billing.md" << 'EOF'
---
topic: billing
status: concluded
type: feature
date: 2026-01-21
---

# Specification: Billing
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'has_individual_spec: true' "Discussion has corresponding spec"
    assert_contains "$output" 'spec_status: "concluded"' "Spec status is concluded"

    echo ""
}

#
# Test: Discussion without spec has no spec_status
#
test_discussion_without_spec_no_status() {
    echo -e "${YELLOW}Test: Discussion without spec has no spec_status${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"

    cat > "$TEST_DIR/docs/workflow/discussion/standalone.md" << 'EOF'
---
topic: standalone
status: concluded
date: 2026-01-20
---

# Discussion: Standalone
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'has_individual_spec: false' "Discussion has no spec"
    assert_not_contains "$output" 'spec_status:' "No spec_status field when no spec exists"

    echo ""
}

#
# Test: Spec with sources in object format
#
test_spec_with_sources() {
    echo -e "${YELLOW}Test: Specification with sources in object format${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/combined-feature.md" << 'EOF'
---
topic: combined-feature
status: in-progress
type: feature
date: 2026-01-20
sources:
  - name: auth-flow
    status: incorporated
  - name: api-design
    status: incorporated
  - name: error-handling
    status: pending
---

# Specification: Combined Feature
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "combined-feature"' "Found combined-feature spec"
    assert_contains "$output" 'sources:' "Has sources field"
    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow source name"
    assert_contains "$output" 'name: "api-design"' "Found api-design source name"
    assert_contains "$output" 'name: "error-handling"' "Found error-handling source name"
    assert_contains "$output" 'status: "incorporated"' "Found incorporated status"
    assert_contains "$output" 'status: "pending"' "Found pending status"

    echo ""
}


#
# Test: Spec with superseded_by
#
test_spec_superseded() {
    echo -e "${YELLOW}Test: Specification with superseded_by${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/old-auth.md" << 'EOF'
---
topic: old-auth
status: superseded
type: feature
date: 2026-01-15
superseded_by: new-auth
---

# Specification: Old Auth
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "superseded"' "Status is superseded"
    assert_contains "$output" 'superseded_by: "new-auth"' "Has superseded_by field"

    echo ""
}

#
# Test: Cache status none
#
test_cache_none() {
    echo -e "${YELLOW}Test: Cache status none${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/test.md" << 'EOF'
---
topic: test
status: in-progress
date: 2026-01-20
---

# Discussion: Test
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "none"' "Cache status is none"
    assert_contains "$output" 'reason: "no cache exists"' "Reason is no cache exists"
    assert_contains "$output" 'checksum: null' "Checksum is null"
    assert_contains "$output" 'anchored_names: \[\]' "No anchored names"

    echo ""
}

#
# Test: Cache status valid
#
test_cache_valid() {
    echo -e "${YELLOW}Test: Cache status valid${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/.cache"

    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
date: 2026-01-20
---

# Discussion: Auth Flow
EOF

    # Compute the checksum that the cache should have
    local checksum=$(cat "$TEST_DIR/docs/workflow/discussion"/*.md | md5sum | cut -d' ' -f1)

    cat > "$TEST_DIR/docs/workflow/.cache/discussion-consolidation-analysis.md" << EOF
---
checksum: $checksum
generated: 2026-01-20T10:00:00
research_files:
  - auth-flow.md
---

# Discussion Consolidation Analysis
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "valid"' "Cache status is valid"
    assert_contains "$output" 'reason: "checksums match"' "Reason is checksums match"

    echo ""
}

#
# Test: Cache status stale
#
test_cache_stale() {
    echo -e "${YELLOW}Test: Cache status stale${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/.cache"

    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
date: 2026-01-20
---

# Discussion: Auth Flow
EOF

    # Use a different checksum to make cache stale
    cat > "$TEST_DIR/docs/workflow/.cache/discussion-consolidation-analysis.md" << 'EOF'
---
checksum: oldchecksum123
generated: 2026-01-19T10:00:00
research_files:
  - auth-flow.md
---

# Discussion Consolidation Analysis
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "stale"' "Cache status is stale"
    assert_contains "$output" 'reason: "discussions have changed' "Reason mentions discussions changed"

    echo ""
}

#
# Test: Anchored names in cache
#
test_anchored_names() {
    echo -e "${YELLOW}Test: Anchored names in cache${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/specification"
    mkdir -p "$TEST_DIR/docs/workflow/.cache"

    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
date: 2026-01-20
---

# Discussion: Auth Flow
EOF

    # Create a spec that matches a grouping name in the cache
    cat > "$TEST_DIR/docs/workflow/specification/authentication.md" << 'EOF'
---
topic: authentication
status: in-progress
type: feature
date: 2026-01-21
---

# Specification: Authentication
EOF

    local checksum=$(cat "$TEST_DIR/docs/workflow/discussion"/*.md | md5sum | cut -d' ' -f1)

    # Cache with grouping names
    cat > "$TEST_DIR/docs/workflow/.cache/discussion-consolidation-analysis.md" << EOF
---
checksum: $checksum
generated: 2026-01-20T10:00:00
research_files:
  - auth-flow.md
---

# Discussion Consolidation Analysis

## Topics

### Authentication
Related to auth-flow discussion

### API Design
Not yet specified
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'anchored_names:' "Has anchored_names section"
    assert_contains "$output" '"authentication"' "Found authentication as anchored name"

    echo ""
}

#
# Test: Current state with discussions checksum
#
test_current_state_checksum() {
    echo -e "${YELLOW}Test: Current state with discussions checksum${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"

    cat > "$TEST_DIR/docs/workflow/discussion/test.md" << 'EOF'
---
topic: test
status: concluded
date: 2026-01-20
---

# Discussion: Test
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'current_state:' "Has current_state section"
    assert_contains "$output" 'discussions_checksum:' "Has discussions_checksum"
    assert_not_contains "$output" 'discussions_checksum: null' "Checksum is not null"

    echo ""
}

#
# Test: Spec without status defaults to active
#
test_spec_default_status() {
    echo -e "${YELLOW}Test: Spec without status defaults to active${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/legacy.md" << 'EOF'
---
topic: legacy
type: feature
date: 2026-01-20
---

# Specification: Legacy

No status field.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "active"' "Defaults to active status"

    echo ""
}

#
# Test: Discussion without status defaults to unknown
#
test_discussion_default_status() {
    echo -e "${YELLOW}Test: Discussion without status defaults to unknown${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/legacy.md" << 'EOF'
---
topic: legacy
date: 2026-01-20
---

# Discussion: Legacy

No status field.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "unknown"' "Defaults to unknown status"

    echo ""
}

#
# Test: Spec with many sources (8, tick-core pattern)
#
test_spec_many_sources() {
    echo -e "${YELLOW}Test: Specification with many sources (8)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/tick-core.md" << 'EOF'
---
topic: tick-core
status: in-progress
type: feature
date: 2026-01-20
sources:
  - name: tick-engine
    status: incorporated
  - name: tick-scheduler
    status: incorporated
  - name: tick-renderer
    status: pending
  - name: tick-storage
    status: incorporated
  - name: tick-api
    status: pending
  - name: tick-auth
    status: incorporated
  - name: tick-notifications
    status: pending
  - name: tick-analytics
    status: incorporated
---

# Specification: Tick Core
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "tick-core"' "Found tick-core spec"
    assert_contains "$output" 'name: "tick-engine"' "Found tick-engine source"
    assert_contains "$output" 'name: "tick-scheduler"' "Found tick-scheduler source"
    assert_contains "$output" 'name: "tick-renderer"' "Found tick-renderer source"
    assert_contains "$output" 'name: "tick-storage"' "Found tick-storage source"
    assert_contains "$output" 'name: "tick-api"' "Found tick-api source"
    assert_contains "$output" 'name: "tick-auth"' "Found tick-auth source"
    assert_contains "$output" 'name: "tick-notifications"' "Found tick-notifications source"
    assert_contains "$output" 'name: "tick-analytics"' "Found tick-analytics source"

    echo ""
}

#
# Test: Spec with --- horizontal rules in body
#
test_spec_with_hr_in_body() {
    echo -e "${YELLOW}Test: Specification with --- in body content${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/tricky-spec.md" << 'EOF'
---
topic: tricky-spec
status: in-progress
type: feature
date: 2026-01-20
sources:
  - name: design-doc
    status: incorporated
  - name: api-review
    status: pending
---

# Specification: Tricky Spec

Some introductory content here.

---

## Section After HR

More content below a horizontal rule.

---

## Another Section

Even more content with another horizontal rule.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "tricky-spec"' "Found tricky-spec"
    assert_contains "$output" 'status: "in-progress"' "Status is in-progress"
    assert_contains "$output" 'name: "design-doc"' "Found design-doc source"
    assert_contains "$output" 'name: "api-review"' "Found api-review source"
    assert_not_contains "$output" 'Section After HR' "No body content leaks into output"
    assert_not_contains "$output" 'introductory content' "No body text leaks into output"

    echo ""
}

#
# Test: Spec with empty sources array
#
test_spec_empty_sources() {
    echo -e "${YELLOW}Test: Specification with empty sources${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/empty-sources.md" << 'EOF'
---
topic: empty-sources
status: in-progress
type: feature
date: 2026-01-20
sources: []
---

# Specification: Empty Sources
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "empty-sources"' "Found empty-sources spec"
    assert_contains "$output" 'status: "in-progress"' "Status is in-progress"

    # Count how many "sources:" lines appear - spec entry should not have sources section
    local sources_count=$(echo "$output" | grep -c "sources:" || true)
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$sources_count" -le 1 ]; then
        echo -e "  ${GREEN}✓${NC} No sources section emitted for empty sources array"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} No sources section emitted for empty sources array"
        echo -e "    Expected at most 1 sources: line, found: $sources_count"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    echo ""
}

#
# Test: Discussion with --- horizontal rules in body
#
test_discussion_with_hr_in_body() {
    echo -e "${YELLOW}Test: Discussion with --- in body content${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    cat > "$TEST_DIR/docs/workflow/discussion/tricky-discussion.md" << 'EOF'
---
topic: tricky-discussion
status: concluded
date: 2026-01-20
---

# Discussion: Tricky Discussion

Some discussion content.

---

## Decision Log

We decided to use approach A.

---

## Open Questions

None remaining.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "tricky-discussion"' "Found tricky-discussion"
    assert_contains "$output" 'status: "concluded"' "Status is concluded"
    assert_not_contains "$output" 'Decision Log' "No body content leaks into output"
    assert_not_contains "$output" 'Open Questions' "No body text leaks into output"
    assert_contains "$output" 'concluded_count: 1' "Concluded count is 1"

    echo ""
}

#
# Test: Spec count excludes superseded
#
test_spec_count_excludes_superseded() {
    echo -e "${YELLOW}Test: Spec count excludes superseded${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/discussion"
    mkdir -p "$TEST_DIR/docs/workflow/specification"

    cat > "$TEST_DIR/docs/workflow/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
date: 2026-01-20
---

# Discussion: Auth Flow
EOF

    cat > "$TEST_DIR/docs/workflow/specification/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: superseded
type: feature
date: 2026-01-20
superseded_by: auth-system
---

# Specification: Auth Flow (superseded)
EOF

    cat > "$TEST_DIR/docs/workflow/specification/auth-system.md" << 'EOF'
---
topic: auth-system
status: in-progress
type: feature
date: 2026-01-21
sources:
  - name: auth-flow
    status: incorporated
---

# Specification: Auth System
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'spec_count: 1' "Spec count excludes superseded (1 active, 1 superseded)"
    assert_contains "$output" 'has_specs: true' "has_specs is true (active spec exists)"

    echo ""
}

#
# Run all tests
#
echo "=========================================="
echo "Running discovery-for-specification.sh tests"
echo "=========================================="
echo ""

test_fresh_state
test_discussions_only
test_specifications_only
test_discussion_with_spec
test_discussion_with_concluded_spec
test_discussion_without_spec_no_status
test_spec_with_sources
test_spec_superseded
test_cache_none
test_cache_valid
test_cache_stale
test_anchored_names
test_current_state_checksum
test_spec_default_status
test_discussion_default_status
test_spec_many_sources
test_spec_with_hr_in_body
test_spec_empty_sources
test_discussion_with_hr_in_body
test_spec_count_excludes_superseded

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
