#!/bin/bash
#
# Tests the discovery-for-specification.sh script against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../scripts/discovery-for-specification.sh"

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
    assert_contains "$output" 'concluded_discussion_count: 0' "Concluded count is 0"

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
    assert_contains "$output" 'concluded_discussion_count: 1' "One concluded discussion"

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

    echo ""
}

#
# Test: Spec with sources array
#
test_spec_with_sources() {
    echo -e "${YELLOW}Test: Specification with sources array${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/docs/workflow/specification"
    cat > "$TEST_DIR/docs/workflow/specification/combined-feature.md" << 'EOF'
---
topic: combined-feature
status: in-progress
type: feature
date: 2026-01-20
sources:
  - auth-flow
  - api-design
  - error-handling
---

# Specification: Combined Feature
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "combined-feature"' "Found combined-feature spec"
    assert_contains "$output" 'sources:' "Has sources field"
    assert_contains "$output" '"auth-flow"' "Found auth-flow source"
    assert_contains "$output" '"api-design"' "Found api-design source"
    assert_contains "$output" '"error-handling"' "Found error-handling source"

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
test_spec_with_sources
test_spec_superseded
test_cache_none
test_cache_valid
test_cache_stale
test_anchored_names
test_current_state_checksum
test_spec_default_status
test_discussion_default_status

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
