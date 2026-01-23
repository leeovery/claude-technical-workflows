# NLP Skills Testing Framework

A testing framework for validating Claude Code skills and commands using deterministic structural checks combined with LLM-as-judge semantic validation.

## Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Validate setup (no API key needed)
npm test -- --dry-run

# 3. Run tests (requires API key)
export ANTHROPIC_API_KEY=your-key-here
npm test -- --suite contracts --verbose
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Test Execution Flow                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Load scenario YAML                                               │
│  2. Copy fixture to temp directory                                   │
│  3. Execute command via Claude Agent SDK                             │
│     ├─ Intercept AskUserQuestion → return scripted answers          │
│     └─ Capture all output and file changes                          │
│  4. Run assertions                                                   │
│     ├─ Structural checks (exists, frontmatter, sections)            │
│     └─ Semantic checks (LLM judge evaluates criteria)               │
│  5. Cleanup and report results                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
tests/
├── README.md                  # This file
├── fixtures/                  # World state snapshots
│   ├── minimal/               # Hand-crafted minimal fixtures
│   │   ├── empty/             # No workflow docs
│   │   ├── has-research/      # Only research exists
│   │   ├── has-discussion/    # Research + discussion exist
│   │   └── has-specification/ # Research + discussion + spec exist
│   └── generated/             # Auto-generated from seeds
│       └── auth-feature/
│           ├── post-research/
│           ├── post-discussion/
│           └── post-specification/
├── scenarios/                 # Test definitions
│   ├── contracts/             # Deterministic structural tests
│   └── integration/           # LLM-judged semantic tests
├── seeds/                     # Inputs for fixture generation
├── lib/                       # Framework implementation
├── scripts/                   # CLI tools
└── examples/                  # Usage examples
```

---

## Fixtures: How They Work

Fixtures represent "world states" - snapshots of the filesystem at different points in the workflow. Tests start from a fixture, run a command, and verify the result.

### Two Types of Fixtures

| Type | Location | Created By | When to Update |
|------|----------|------------|----------------|
| **Minimal** | `fixtures/minimal/` | Hand-crafted | Rarely (only structural changes) |
| **Generated** | `fixtures/generated/` | `generate-fixtures.ts` | When skills/commands change |

### Minimal Fixtures (Manual)

Small, focused fixtures for testing specific logic paths. They contain just enough to trigger the code path being tested.

```
fixtures/minimal/has-discussion/
├── docs/workflow/
│   ├── research/
│   │   └── test-topic.md      # Minimal research doc
│   └── discussion/
│       └── test-topic.md      # Minimal discussion doc
```

**When to create minimal fixtures:**
- Testing a specific logic branch
- Testing error handling (e.g., missing files)
- Contract tests that don't need realistic content

**How to create:**
1. Create the directory structure manually
2. Add minimal valid files (just frontmatter + required sections)
3. Commit to version control

### Generated Fixtures (Automatic)

Realistic fixtures created by actually running the workflow with canonical inputs. They capture real skill/command output.

**When to use generated fixtures:**
- Integration tests that need realistic content
- Testing semantic quality (LLM judge needs real content)
- Regression testing after skill updates

**How to create/update:**

```bash
# See what would be generated (no API calls)
npx tsx tests/scripts/generate-fixtures.ts --dry-run

# Generate all fixtures
export ANTHROPIC_API_KEY=your-key
npx tsx tests/scripts/generate-fixtures.ts

# Generate specific seed
npx tsx tests/scripts/generate-fixtures.ts --seed auth-feature

# Use cheaper model for development
npx tsx tests/scripts/generate-fixtures.ts --model sonnet --max-budget 1.0
```

**Seed file format:**

```yaml
# seeds/auth-feature.yml
name: auth-feature
description: "OAuth2 authentication feature"

phases:
  research:
    command: /workflow/start-research
    inputs:
      topic: "OAuth2 authentication for API"
      context: |
        Building a REST API that needs user authentication.
        Requirements: secure, standard protocols, mobile-friendly.
    choices:
      - match: "focus area"
        answer: "technical feasibility"

  discussion:
    command: /workflow/start-discussion
    choices:
      - match: "topic"
        answer: "authentication"

  specification:
    command: /workflow/start-specification
    choices:
      - match: "topic"
        answer: "authentication"
```

**The generator:**
1. Creates a temp workspace
2. Runs each phase command sequentially
3. Captures the workspace state after each phase
4. Saves snapshots as `post-{phase}/` directories

---

## Running Tests

### Basic Commands

```bash
# Run all tests
npm test

# Run only contract tests (fast, deterministic validation)
npm test -- --suite contracts

# Run only integration tests (slower, uses LLM judge)
npm test -- --suite integration

# Run specific scenario file
npm test -- --file contracts/start-specification.yml

# Run specific scenario by name
npm test -- --scenario "creates spec from discussion"

# Verbose output (see Claude's responses)
npm test -- --verbose

# Dry run (validate scenarios without executing)
npm test -- --dry-run
```

### Cost Control

```bash
# Use cheaper model (faster, less accurate)
npm test -- --model haiku

# Limit budget per test
npm test -- --max-budget 0.50

# Limit turns per test
npm test -- --max-turns 20
```

### Test Output

```
Found 4 scenario file(s)
Model: opus
Max budget per test: $2.00

Running: scenarios/contracts/start-specification.yml
  ✓ creates spec from discussion (45023ms)
  ✓ spec has required frontmatter (38291ms)
  ✗ handles missing discussion gracefully (52104ms)
    → File not found: docs/workflow/specification/new-topic.md

============================================================
Test Summary
============================================================

Total: 3 tests
  ✓ Passed: 2
  ✗ Failed: 1
```

---

## Writing Tests

### Test Scenario Format

```yaml
name: "start-specification contracts"
description: "Tests for the specification command"
type: contract  # or "integration"

scenarios:
  - name: "creates spec from discussion"
    description: "When discussion exists, spec is created"
    fixture: minimal/has-discussion
    command: /workflow/start-specification
    choices:
      - match: "topic"          # Fuzzy match on question text
        answer: "test-topic"
    assertions:
      - exists: docs/workflow/specification/test-topic.md
      - has_frontmatter:
          path: docs/workflow/specification/test-topic.md
          required: [topic, status]
      - has_sections:
          path: docs/workflow/specification/test-topic.md
          sections: ["## Summary", "## Validated Decisions"]
    invariants:
      - docs/workflow/discussion/*  # These files must not change
```

### Assertion Types

| Assertion | Description | Example |
|-----------|-------------|---------|
| `exists` | File/directory exists | `exists: docs/workflow/spec/topic.md` |
| `not_exists` | File doesn't exist | `not_exists: docs/workflow/spec/*.md` |
| `unchanged` | Files unchanged from fixture | `unchanged: docs/workflow/discussion/*` |
| `has_frontmatter` | YAML frontmatter has fields | See below |
| `has_sections` | Markdown has headings | See below |
| `content_matches` | Regex matches content | `pattern: "OAuth2"` |
| `output_contains` | Claude output has text | `output_contains: "Created specification"` |
| `file_count` | Number of matching files | `min: 1, max: 3` |
| `semantic` | LLM evaluates criteria | See below |

**Frontmatter assertion:**
```yaml
has_frontmatter:
  path: docs/workflow/specification/topic.md
  required: [topic, status, date]
  values:
    topic: "authentication"
    status: "draft"
```

**Sections assertion:**
```yaml
has_sections:
  path: docs/workflow/specification/topic.md
  sections:
    - "## Summary"
    - "## Validated Decisions"
    - "## Requirements"
```

**Semantic assertion (LLM judge):**
```yaml
semantic:
  judge_model: haiku  # haiku (cheap), sonnet, or opus
  path: docs/workflow/specification/topic.md
  criteria:
    - "Contains specific technical decisions"
    - "Includes implementation requirements"
    - "Identifies scope boundaries"
  threshold: 0.66  # 2 of 3 criteria must pass
```

### Scripting User Choices

When a command uses `AskUserQuestion`, script the responses:

```yaml
choices:
  - match: "which topic"     # Fuzzy match (case-insensitive)
    answer: "authentication"
  - match: "include all"
    answer: "yes"
  - match: "format"
    answer: ["json", "yaml"]  # Multi-select
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test-skills.yml
name: Test Skills

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  release:
    types: [published]

env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

jobs:
  # Fast structural tests (every push)
  contract-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --suite contracts

  # Slower semantic tests (PRs and releases)
  integration-tests:
    if: github.event_name == 'pull_request' || github.event_name == 'release'
    needs: contract-tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --suite integration --model haiku

  # Full validation before release
  release-validation:
    if: github.event_name == 'release'
    needs: [contract-tests, integration-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci

      # Regenerate fixtures and check for drift
      - name: Regenerate fixtures
        run: npx tsx tests/scripts/generate-fixtures.ts --model sonnet

      - name: Check for fixture changes
        run: |
          if ! git diff --quiet tests/fixtures/generated/; then
            echo "::warning::Generated fixtures changed!"
            echo "This may indicate skill behavior has changed."
            git diff tests/fixtures/generated/
          fi

      # Run full test suite with opus
      - name: Full test suite
        run: npm test -- --model opus --verbose
```

### Testing Strategy by Stage

| Stage | Tests Run | Model | Purpose |
|-------|-----------|-------|---------|
| Every push | Contract tests | N/A (structural) | Catch obvious breakage |
| Pull request | + Integration tests | Haiku | Verify semantic correctness |
| Release | + Fixture regen | Sonnet/Opus | Full validation |

### Pre-release Checklist

```bash
# 1. Run contract tests locally
npm test -- --suite contracts

# 2. Regenerate fixtures (detects behavior changes)
npx tsx tests/scripts/generate-fixtures.ts --model opus

# 3. Review fixture changes
git diff tests/fixtures/generated/

# 4. Run full integration tests
npm test -- --suite integration --model opus --verbose

# 5. If all pass, commit fixtures and create release
git add tests/fixtures/generated/
git commit -m "chore: update generated fixtures for release"
```

---

## Cost Management

### Estimated Costs

| Operation | Model | Est. Cost |
|-----------|-------|-----------|
| Contract test | N/A (structural only) | $0.00 |
| Integration test (1 command) | Haiku | ~$0.01-0.03 |
| Integration test (1 command) | Opus | ~$0.10-0.30 |
| Semantic assertion (LLM judge) | Haiku | ~$0.001 |
| Fixture generation (4 phases) | Opus | ~$0.50-1.00 |

### Cost Control Tips

1. **Run contract tests first** - They're free and catch most issues
2. **Use Haiku for CI** - 10x cheaper than Opus, good enough for validation
3. **Use Opus sparingly** - Only for release validation or debugging
4. **Set budget limits** - `--max-budget 1.0` prevents runaway costs
5. **Cache fixtures** - Commit generated fixtures, only regenerate on changes

---

## Troubleshooting

### Test fails with "No scripted answer for..."

The command asked a question that wasn't in the `choices` list. Add it:

```yaml
choices:
  - match: "the question text"
    answer: "your answer"
```

### Test times out

Increase timeout or reduce max turns:

```bash
npm test -- --timeout 300000 --max-turns 30
```

### Semantic check fails unexpectedly

1. Run with `--verbose` to see the content
2. Check if criteria are too strict
3. Try lowering the threshold
4. Consider if the criteria match what the skill actually produces

### Generated fixtures are different after skill update

This is expected! Review the changes:

```bash
git diff tests/fixtures/generated/
```

If the changes look correct, commit them. If not, the skill may have regressed.
