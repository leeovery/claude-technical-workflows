#!/bin/bash
#
# Fixture Generator
#
# Generates test fixtures by running workflow commands with canonical seed inputs.
# This creates realistic fixtures that reflect actual skill/command behavior.
#
# Usage:
#   ./generate-fixtures.sh              # Generate all fixtures
#   ./generate-fixtures.sh --seed NAME  # Generate specific seed
#   ./generate-fixtures.sh --dry-run    # Show what would be generated

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(dirname "$SCRIPT_DIR")"
ROOT_DIR="$(dirname "$TESTS_DIR")"
SEEDS_DIR="$TESTS_DIR/seeds"
FIXTURES_DIR="$TESTS_DIR/fixtures/generated"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
SPECIFIC_SEED=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --seed)
      SPECIFIC_SEED="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "Usage: $0 [--seed NAME] [--dry-run]"
      echo ""
      echo "Options:"
      echo "  --seed NAME   Generate fixtures for specific seed only"
      echo "  --dry-run     Show what would be generated without executing"
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Find seed files
if [[ -n "$SPECIFIC_SEED" ]]; then
  SEED_FILES=("$SEEDS_DIR/$SPECIFIC_SEED.yml")
  if [[ ! -f "${SEED_FILES[0]}" ]]; then
    log_error "Seed not found: $SPECIFIC_SEED"
    exit 1
  fi
else
  SEED_FILES=("$SEEDS_DIR"/*.yml)
fi

log_info "Found ${#SEED_FILES[@]} seed file(s)"

# Process each seed
for seed_file in "${SEED_FILES[@]}"; do
  seed_name=$(basename "$seed_file" .yml)
  log_info "Processing seed: $seed_name"

  if $DRY_RUN; then
    echo "  Would generate fixtures in: $FIXTURES_DIR/$seed_name/"
    echo "  Phases: research, discussion, specification, planning"
    continue
  fi

  # Create output directory
  output_dir="$FIXTURES_DIR/$seed_name"
  rm -rf "$output_dir"
  mkdir -p "$output_dir"

  # Create workspace for generation
  workspace=$(mktemp -d)
  trap "rm -rf $workspace" EXIT

  log_info "  Workspace: $workspace"

  # Initialize workspace with project structure
  mkdir -p "$workspace/docs/workflow/"{research,discussion,specification,planning}

  # Read seed phases using yq (if available) or basic parsing
  # For now, we'll create a placeholder that documents the process

  cat > "$output_dir/README.md" << EOF
# Generated Fixtures: $seed_name

These fixtures were generated from \`tests/seeds/$seed_name.yml\`.

## Generation Process

Fixtures are created by running workflow commands sequentially:

1. **post-research/**: After running \`/workflow/start-research\`
2. **post-discussion/**: After running \`/workflow/start-discussion\`
3. **post-specification/**: After running \`/workflow/start-specification\`
4. **post-planning/**: After running \`/workflow/start-planning\`

## Regeneration

To regenerate these fixtures:

\`\`\`bash
./tests/scripts/generate-fixtures.sh --seed $seed_name
\`\`\`

## Note

Full fixture generation requires programmatic Claude interaction.
See \`tests/lib/fixture-generator.ts\` for the implementation.

For now, this script creates placeholder structure.
EOF

  # Create placeholder directories for each phase
  for phase in post-research post-discussion post-specification post-planning; do
    mkdir -p "$output_dir/$phase/docs/workflow/"{research,discussion,specification,planning}
    echo "# Placeholder - regenerate with Claude Agent SDK" > "$output_dir/$phase/.generated"
  done

  log_success "  Created fixture structure: $output_dir"
done

log_info ""
log_info "Fixture generation complete."
log_info ""
log_warn "Note: Full generation requires Claude Agent SDK integration."
log_info "The test runner (tests/lib/runner.ts) handles actual command execution."
