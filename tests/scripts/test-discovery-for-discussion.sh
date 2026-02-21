#!/bin/bash
#
# Tests the discovery-for-discussion.sh script against various workflow states.
# Creates temporary fixtures and validates YAML output.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERY_SCRIPT="$SCRIPT_DIR/../../skills/start-discussion/scripts/discovery.sh"

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
# Test: Fresh state (no research, no discussions)
#
test_fresh_state() {
    echo -e "${YELLOW}Test: Fresh state (no research, no discussions)${NC}"
    setup_fixture

    local output=$(run_discovery)

    assert_contains "$output" 'research:' "Has research section"
    assert_contains "$output" 'exists: false' "Research exists: false"
    assert_contains "$output" 'discussions:' "Has discussions section"
    assert_contains "$output" 'scenario: "fresh"' "Scenario is fresh"
    assert_contains "$output" 'status: "none"' "Cache status is none"

    echo ""
}

#
# Test: Research only (no discussions)
#
test_research_only() {
    echo -e "${YELLOW}Test: Research only (no discussions)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-21
---

# Research: Initial Exploration

Exploring ideas for the new feature.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'exists: true' "Research exists: true"
    assert_contains "$output" 'name: "exploration"' "Found exploration.md"
    assert_contains "$output" 'topic: "exploration"' "Extracted topic from frontmatter"
    assert_contains "$output" 'checksum:' "Has research checksum"
    assert_contains "$output" 'scenario: "research_only"' "Scenario is research_only"
    assert_contains "$output" 'has_research: true' "has_research is true"
    assert_contains "$output" 'has_discussions: false' "has_discussions is false"

    echo ""
}

#
# Test: Discussions only (no research)
#
test_discussions_only() {
    echo -e "${YELLOW}Test: Discussions only (no research)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"
    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: in-progress
date: 2026-01-20
---

# Discussion: Auth Flow

Discussing authentication flow.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'exists: false' "Research exists: false"
    assert_contains "$output" 'name: "auth-flow"' "Found auth-flow.md"
    assert_contains "$output" 'status: "in-progress"' "Status is in-progress"
    assert_contains "$output" 'date: "2026-01-20"' "Extracted date"
    assert_contains "$output" 'in_progress: 1' "in_progress count is 1"
    assert_contains "$output" 'concluded: 0' "concluded count is 0"
    assert_contains "$output" 'scenario: "discussions_only"' "Scenario is discussions_only"

    echo ""
}

#
# Test: Research and discussions
#
test_research_and_discussions() {
    echo -e "${YELLOW}Test: Research and discussions${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    mkdir -p "$TEST_DIR/.workflows/discussion"

    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-18
---

# Research: Exploration
EOF

    cat > "$TEST_DIR/.workflows/discussion/auth-flow.md" << 'EOF'
---
topic: auth-flow
status: concluded
date: 2026-01-19
---

# Discussion: Auth Flow
EOF

    cat > "$TEST_DIR/.workflows/discussion/data-model.md" << 'EOF'
---
topic: data-model
status: in-progress
date: 2026-01-20
---

# Discussion: Data Model
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'scenario: "research_and_discussions"' "Scenario is research_and_discussions"
    assert_contains "$output" 'has_research: true' "has_research is true"
    assert_contains "$output" 'has_discussions: true' "has_discussions is true"
    assert_contains "$output" 'in_progress: 1' "in_progress count is 1"
    assert_contains "$output" 'concluded: 1' "concluded count is 1"

    echo ""
}

#
# Test: Multiple discussions with mixed statuses
#
test_multiple_discussions() {
    echo -e "${YELLOW}Test: Multiple discussions with mixed statuses${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"

    cat > "$TEST_DIR/.workflows/discussion/topic-a.md" << 'EOF'
---
topic: topic-a
status: concluded
date: 2026-01-15
---
# Discussion: Topic A
EOF

    cat > "$TEST_DIR/.workflows/discussion/topic-b.md" << 'EOF'
---
topic: topic-b
status: concluded
date: 2026-01-16
---
# Discussion: Topic B
EOF

    cat > "$TEST_DIR/.workflows/discussion/topic-c.md" << 'EOF'
---
topic: topic-c
status: in-progress
date: 2026-01-17
---
# Discussion: Topic C
EOF

    cat > "$TEST_DIR/.workflows/discussion/topic-d.md" << 'EOF'
---
topic: topic-d
status: in-progress
date: 2026-01-18
---
# Discussion: Topic D
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'in_progress: 2' "in_progress count is 2"
    assert_contains "$output" 'concluded: 2' "concluded count is 2"
    assert_contains "$output" 'name: "topic-a"' "Found topic-a"
    assert_contains "$output" 'name: "topic-b"' "Found topic-b"
    assert_contains "$output" 'name: "topic-c"' "Found topic-c"
    assert_contains "$output" 'name: "topic-d"' "Found topic-d"

    echo ""
}

#
# Test: Cache status "none" (no cache file)
#
test_cache_none() {
    echo -e "${YELLOW}Test: Cache status none (no cache file)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-21
---
# Research
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "none"' "Cache status is none"
    assert_contains "$output" 'reason: "no cache exists"' "Reason is no cache exists"
    assert_contains "$output" 'checksum: null' "Cache checksum is null"
    assert_contains "$output" 'generated: null' "Cache generated is null"

    echo ""
}

#
# Test: Cache status "valid" (cache matches current research)
#
test_cache_valid() {
    echo -e "${YELLOW}Test: Cache status valid (checksums match)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    mkdir -p "$TEST_DIR/.workflows/.state"

    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-21
---
# Research: Exploration
EOF

    # Compute the checksum of the research file
    local checksum=$(cat "$TEST_DIR/.workflows/research"/*.md | md5sum | cut -d' ' -f1)

    # Create cache with matching checksum
    cat > "$TEST_DIR/.workflows/.state/research-analysis.md" << EOF
---
checksum: $checksum
generated: 2026-01-21T10:00:00
research_files:
  - exploration.md
---

# Research Analysis Cache

## Topics

### Feature Ideas
- **Source**: exploration.md (lines 1-10)
- **Summary**: Initial exploration of feature ideas
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "valid"' "Cache status is valid"
    assert_contains "$output" 'reason: "checksums match"' "Reason is checksums match"
    assert_contains "$output" "checksum: \"$checksum\"" "Cache checksum matches"
    assert_contains "$output" 'generated: "2026-01-21T10:00:00"' "Cache generated date present"
    assert_contains "$output" '"exploration.md"' "Cache research_files contains exploration.md"

    echo ""
}

#
# Test: Cache status "stale" (research has changed)
#
test_cache_stale() {
    echo -e "${YELLOW}Test: Cache status stale (research changed)${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"
    mkdir -p "$TEST_DIR/.workflows/.state"

    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-21
---
# Research: Exploration

This content is different from when cache was created.
EOF

    # Create cache with OLD checksum (doesn't match current)
    cat > "$TEST_DIR/.workflows/.state/research-analysis.md" << 'EOF'
---
checksum: old_checksum_that_doesnt_match
generated: 2026-01-20T10:00:00
research_files:
  - exploration.md
---

# Research Analysis Cache
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'status: "stale"' "Cache status is stale"
    assert_contains "$output" 'reason: "research has changed since cache was generated"' "Reason explains research changed"

    echo ""
}

#
# Test: Research files without frontmatter (fallback to filename)
#
test_research_no_frontmatter() {
    echo -e "${YELLOW}Test: Research files without frontmatter${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"

    # Create research file WITHOUT frontmatter
    cat > "$TEST_DIR/.workflows/research/market-analysis.md" << 'EOF'
# Market Analysis

No frontmatter here, just content.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "market-analysis"' "Found market-analysis.md"
    assert_contains "$output" 'topic: "market-analysis"' "Topic falls back to filename"

    echo ""
}

#
# Test: Discussion without status field (defaults to unknown)
#
test_discussion_no_status() {
    echo -e "${YELLOW}Test: Discussion without status field${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/discussion"

    cat > "$TEST_DIR/.workflows/discussion/legacy-topic.md" << 'EOF'
---
topic: legacy-topic
date: 2026-01-15
---
# Discussion: Legacy Topic

No status field.
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "legacy-topic"' "Found legacy-topic.md"
    assert_contains "$output" 'status: "unknown"' "Status defaults to unknown"

    echo ""
}

#
# Test: Multiple research files
#
test_multiple_research_files() {
    echo -e "${YELLOW}Test: Multiple research files${NC}"
    setup_fixture

    mkdir -p "$TEST_DIR/.workflows/research"

    cat > "$TEST_DIR/.workflows/research/exploration.md" << 'EOF'
---
topic: exploration
date: 2026-01-18
---
# Exploration
EOF

    cat > "$TEST_DIR/.workflows/research/market-landscape.md" << 'EOF'
---
topic: market-landscape
date: 2026-01-19
---
# Market Landscape
EOF

    cat > "$TEST_DIR/.workflows/research/technical-feasibility.md" << 'EOF'
---
topic: technical-feasibility
date: 2026-01-20
---
# Technical Feasibility
EOF

    local output=$(run_discovery)

    assert_contains "$output" 'name: "exploration"' "Found exploration.md"
    assert_contains "$output" 'name: "market-landscape"' "Found market-landscape.md"
    assert_contains "$output" 'name: "technical-feasibility"' "Found technical-feasibility.md"
    assert_contains "$output" 'topic: "market-landscape"' "Extracted market-landscape topic"
    assert_contains "$output" 'topic: "technical-feasibility"' "Extracted technical-feasibility topic"

    echo ""
}

#
# Run all tests
#
echo "=========================================="
echo "Running discovery-for-discussion.sh tests"
echo "=========================================="
echo ""

test_fresh_state
test_research_only
test_discussions_only
test_research_and_discussions
test_multiple_discussions
test_cache_none
test_cache_valid
test_cache_stale
test_research_no_frontmatter
test_discussion_no_status
test_multiple_research_files

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
