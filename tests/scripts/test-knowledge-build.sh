#!/bin/bash
# Tests for the knowledge CLI build pipeline (knowledge-base phase 1, task 1-1).
# Run: bash tests/scripts/test-knowledge-build.sh

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUNDLE="$REPO_DIR/skills/workflow-knowledge/scripts/knowledge.cjs"
MAX_BUNDLE_BYTES=153600  # 150 KB
LOG_DIR="${TMPDIR:-/tmp}"

PASS=0
FAIL=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $label"
    echo "  expected: $expected"
    echo "  actual:   $actual"
  fi
}

# --- Test 1: npm run build exits 0 ---
test_build_exits_clean() {
  cd "$REPO_DIR"
  if npm run build > "$LOG_DIR/knowledge-build.log" 2>&1; then
    build_status=0
  else
    build_status=$?
  fi
  assert_eq "npm run build exits with code 0" "0" "$build_status"
}

# --- Test 2: bundle exists ---
test_bundle_exists() {
  assert_eq "bundle file exists at expected path" \
    "true" \
    "$([ -f "$BUNDLE" ] && echo true || echo false)"
}

# --- Test 3: bundle under 150KB ---
test_bundle_under_threshold() {
  local size
  size=$(/usr/bin/stat -f '%z' "$BUNDLE" 2>/dev/null || stat -c '%s' "$BUNDLE")
  if [ "$size" -lt "$MAX_BUNDLE_BYTES" ]; then
    under=true
  else
    under=false
    echo "  bundle size: $size bytes (threshold: $MAX_BUNDLE_BYTES)"
  fi
  assert_eq "bundle size under 150KB" "true" "$under"
}

# --- Test 4: bundle runs and exits 0 ---
test_bundle_runs_clean() {
  if node "$BUNDLE" > "$LOG_DIR/knowledge-run.log" 2>&1; then
    run_status=0
  else
    run_status=$?
  fi
  assert_eq "bundle runs and exits with code 0" "0" "$run_status"
}

# --- Test 5: __dirname resolves to the script directory, not the source ---
test_dirname_resolves_to_script_dir() {
  local stdout
  stdout=$(node "$BUNDLE" 2>/dev/null)
  assert_eq "stdout contains skills/workflow-knowledge/scripts path" \
    "true" \
    "$(echo "$stdout" | grep -q 'skills/workflow-knowledge/scripts' && echo true || echo false)"
  assert_eq "stdout does NOT contain src/knowledge path" \
    "true" \
    "$(echo "$stdout" | grep -q 'src/knowledge' && echo false || echo true)"
}

# --- Run all tests ---
echo "Running knowledge build tests..."
echo ""

test_build_exits_clean
test_bundle_exists
test_bundle_under_threshold
test_bundle_runs_clean
test_dirname_resolves_to_script_dir

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
