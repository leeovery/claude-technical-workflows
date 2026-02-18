#!/bin/bash
#
# Tests hooks/workflows/system-check.sh
# Validates hook installation and migration integration.
#

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/../../hooks/workflows/system-check.sh"

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
    rm -rf "$TEST_DIR/.claude" "$TEST_DIR/docs"
    mkdir -p "$TEST_DIR/.claude/skills/migrate/scripts"
}

run_hook() {
    CLAUDE_PROJECT_DIR="$TEST_DIR" bash "$HOOK_SCRIPT" < /dev/null 2>&1 || true
}

assert_contains() {
    local content="$1"
    local expected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if echo "$content" | grep -q -- "$expected"; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Expected to find: $expected"
        echo -e "    In: $content"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_not_contains() {
    local content="$1"
    local unexpected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if ! echo "$content" | grep -q -- "$unexpected"; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Did not expect to find: $unexpected"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_equals() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo -e "    Expected: $expected"
        echo -e "    Actual:   $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ============================================================================
# TEST CASES
# ============================================================================

echo -e "${YELLOW}Test: No settings.json — creates with hooks, outputs continue:false${NC}"
setup_fixture
# Create a no-op migrate script
cat > "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh" << 'EOF'
#!/bin/bash
echo "[SKIP] No changes needed"
EOF
chmod +x "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh"

output=$(run_hook)

assert_contains "$output" '"continue": false' "Output contains continue:false"
assert_contains "$output" "Restart Claude Code" "Output contains restart message"
# Verify settings.json was created with hooks
assert_contains "$(cat "$TEST_DIR/.claude/settings.json" 2>/dev/null)" "SessionStart" "settings.json contains SessionStart hooks"
assert_contains "$(cat "$TEST_DIR/.claude/settings.json" 2>/dev/null)" "SessionEnd" "settings.json contains SessionEnd hooks"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: settings.json without hooks — merges hooks, outputs continue:false${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.claude"
cat > "$TEST_DIR/.claude/settings.json" << 'EOF'
{
  "permissions": {
    "allow": ["Read", "Write"]
  }
}
EOF
cat > "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh" << 'EOF'
#!/bin/bash
echo "[SKIP] No changes needed"
EOF
chmod +x "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh"

output=$(run_hook)

assert_contains "$output" '"continue": false' "Output contains continue:false"
settings_content=$(cat "$TEST_DIR/.claude/settings.json")
assert_contains "$settings_content" "SessionStart" "Hooks merged into settings"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: settings.json with hooks already — silent exit, no output${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.claude"
# Create settings with hooks already present
cat > "$TEST_DIR/.claude/settings.json" << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [{ "type": "command", "command": "echo test" }]
      }
    ]
  }
}
EOF
# Create no-op migrate script that outputs only skips
cat > "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh" << 'EOF'
#!/bin/bash
echo "[SKIP] No changes needed"
EOF
chmod +x "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh"

output=$(run_hook)

assert_equals "$output" "" "No output when hooks already configured and no migrations"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Migrations needed — outputs additionalContext${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.claude"
# Create settings with hooks present (so hook install is skipped)
cat > "$TEST_DIR/.claude/settings.json" << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [{ "type": "command", "command": "echo test" }]
      }
    ]
  }
}
EOF
# Create migrate script that reports actual migrations
cat > "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh" << 'EOF'
#!/bin/bash
echo "[UPDATE] auth-flow.md: migrated to frontmatter format"
echo "[UPDATE] caching.md: migrated to frontmatter format"
EOF
chmod +x "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh"

output=$(run_hook)

assert_contains "$output" "additionalContext" "Output contains additionalContext"
assert_contains "$output" "migrated" "Output contains migration report"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: No migrations needed — silent exit${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.claude"
cat > "$TEST_DIR/.claude/settings.json" << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [{ "type": "command", "command": "echo test" }]
      }
    ]
  }
}
EOF
cat > "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh" << 'EOF'
#!/bin/bash
echo "[SKIP] No changes needed"
EOF
chmod +x "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh"

output=$(run_hook)

assert_equals "$output" "" "No output when no migrations needed"

echo ""

# ----------------------------------------------------------------------------

echo -e "${YELLOW}Test: Existing permissions in settings.json — preserved after merge${NC}"
setup_fixture
mkdir -p "$TEST_DIR/.claude"
cat > "$TEST_DIR/.claude/settings.json" << 'EOF'
{
  "permissions": {
    "allow": ["Read", "Write", "Bash(git *)"]
  },
  "customSetting": "keep-me"
}
EOF
cat > "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh" << 'EOF'
#!/bin/bash
echo "[SKIP] No changes needed"
EOF
chmod +x "$TEST_DIR/.claude/skills/migrate/scripts/migrate.sh"

output=$(run_hook)

settings_content=$(cat "$TEST_DIR/.claude/settings.json")
assert_contains "$settings_content" '"allow"' "Permissions preserved"
assert_contains "$settings_content" 'Bash(git' "Specific permission preserved"
assert_contains "$settings_content" "keep-me" "Custom settings preserved"
assert_contains "$settings_content" "SessionStart" "Hooks added"

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
