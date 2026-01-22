#!/bin/bash
#
# NLP Skills Test Runner
#
# Runs test scenarios against skills and commands using Claude Agent SDK.
#
# Usage:
#   ./run-tests.sh                    # Run all tests
#   ./run-tests.sh --suite contracts  # Run only contract tests
#   ./run-tests.sh --suite integration # Run only integration tests
#   ./run-tests.sh --dry-run          # Validate scenarios without executing
#   ./run-tests.sh --help             # Show help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(dirname "$SCRIPT_DIR")"
ROOT_DIR="$(dirname "$TESTS_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if --dry-run is in arguments
is_dry_run() {
  for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
      return 0
    fi
  done
  return 1
}

# Check dependencies
check_dependencies() {
  if ! command -v npx &> /dev/null; then
    log_error "npx not found. Install Node.js first."
    exit 1
  fi
}

# Parse arguments and pass to TypeScript runner
main() {
  check_dependencies

  cd "$ROOT_DIR"

  # Install dependencies if node_modules doesn't exist
  if [[ ! -d "node_modules" ]]; then
    log_info "Installing dependencies..."
    npm install
  fi

  # Check for API key (unless dry run)
  if ! is_dry_run "$@" && [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    log_error "ANTHROPIC_API_KEY environment variable is required"
    echo ""
    echo "Set it with: export ANTHROPIC_API_KEY=your-key-here"
    echo ""
    echo "Or run with --dry-run to validate scenarios without executing:"
    echo "  $0 --dry-run"
    exit 1
  fi

  log_info "Running tests..."
  echo ""

  # Run the TypeScript test runner with tsx (faster than ts-node, native ESM)
  npx tsx "$TESTS_DIR/lib/runner.ts" "$@"
}

main "$@"
