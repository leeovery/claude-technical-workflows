#!/usr/bin/env bash
# CLI dispatch tests for the knowledge base bundle.
# Tests against the built bundle (knowledge.cjs).

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE="$SCRIPT_DIR/../../skills/workflow-knowledge/scripts/knowledge.cjs"

PASS=0
FAIL=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "    expected: $expected"
    echo "    actual:   $actual"
    FAIL=$((FAIL + 1))
  fi
}

# --- Test 1: No command prints usage and exits 1 ---
echo "Test 1: No command prints usage"
output=$(node "$BUNDLE" 2>&1 || true)
exit_code=0
node "$BUNDLE" 2>/dev/null || exit_code=$?
assert_eq "exits with code 1" "1" "$exit_code"
assert_eq "prints usage" "true" "$(echo "$output" | grep -q 'Usage:' && echo true || echo false)"

# --- Test 2: Unknown command prints error and exits 1 ---
echo "Test 2: Unknown command"
output=$(node "$BUNDLE" foobar 2>&1 || true)
exit_code=0
node "$BUNDLE" foobar 2>/dev/null || exit_code=$?
assert_eq "exits with code 1" "1" "$exit_code"
assert_eq "mentions unknown command" "true" "$(echo "$output" | grep -q 'Unknown command' && echo true || echo false)"

# --- Test 3: Not-yet-implemented commands exit 1 ---
echo "Test 3: Not-yet-implemented commands"
for cmd in status remove compact rebuild setup; do
  exit_code=0
  output=$(node "$BUNDLE" "$cmd" 2>&1 || true)
  node "$BUNDLE" "$cmd" 2>/dev/null || exit_code=$?
  assert_eq "$cmd exits with code 1" "1" "$exit_code"
  assert_eq "$cmd mentions not yet implemented" "true" "$(echo "$output" | grep -q 'not yet implemented' && echo true || echo false)"
done

# --- Test 4: Known Phase 3 commands dispatch without unknown-command error ---
# Note: index/query/check are stubbed to "not yet implemented" in Task 3-1,
# but they should NOT print "Unknown command". They dispatch to the correct
# handler. Once Task 3-3/3-4/3-5 land, these tests will be updated.
echo "Test 4: Phase 3 commands dispatch correctly"
for cmd in index query check; do
  output=$(node "$BUNDLE" "$cmd" 2>&1 || true)
  assert_eq "$cmd does not say unknown command" "false" "$(echo "$output" | grep -q 'Unknown command' && echo true || echo false)"
done

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
