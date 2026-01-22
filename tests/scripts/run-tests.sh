#!/bin/bash
#
# NLP Skills Test Runner
#
# Runs test scenarios against skills and commands.
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

# Check dependencies
check_dependencies() {
  if ! command -v npx &> /dev/null; then
    log_error "npx not found. Install Node.js first."
    exit 1
  fi

  # Check if ts-node is available
  if ! npx ts-node --version &> /dev/null; then
    log_warn "ts-node not found. Installing..."
    npm install --save-dev ts-node typescript @types/node
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

  # Check if test dependencies are installed
  if [[ ! -f "tests/node_modules/.bin/ts-node" ]] && [[ ! -f "node_modules/.bin/ts-node" ]]; then
    log_info "Installing test dependencies..."
    npm install --save-dev ts-node typescript @types/node yaml glob
  fi

  log_info "Running tests..."
  echo ""

  # Run the TypeScript test runner
  npx ts-node "$TESTS_DIR/lib/runner.ts" "$@"
}

main "$@"
