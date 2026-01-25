# NLP Skills Testing Framework

A testing framework for validating Claude Code skills and commands using deterministic structural checks combined with LLM-as-judge semantic validation.

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture Overview](#architecture-overview)
- [Directory Structure](#directory-structure)
- [How Testing Works](#how-testing-works)
- [Fixtures: World State Snapshots](#fixtures-world-state-snapshots)
- [Scenarios: Test Definitions](#scenarios-test-definitions)
- [Testing Complex Commands](#testing-complex-commands)
- [Catching Regressions](#catching-regressions)
- [Running Tests](#running-tests)
- [CI/CD Integration](#cicd-integration)
- [Cost Management](#cost-management)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Validate setup (no API key needed)
npm run test:dry-run

# 3. Run tests (requires API key or Claude Max auth)
export ANTHROPIC_API_KEY=your-key-here
npm test -- --suite contracts --verbose
```

---

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

**Key Components:**

| Component | Purpose |
|-----------|---------|
| **Runner** (`lib/runner.ts`) | Orchestrates test execution, manages lifecycle |
| **Executor** (`lib/executor.ts`) | Runs commands via Claude Agent SDK, intercepts tools |
| **Validators** (`lib/validators.ts`) | Implements all assertion types |
| **FixtureManager** (`lib/fixture-manager.ts`) | Copies fixtures, captures state, cleans up |
| **ChoiceInterceptor** (`lib/choice-interceptor.ts`) | Scripts answers to AskUserQuestion |
| **LLMJudge** (`lib/llm-judge.ts`) | Semantic evaluation using Claude |

---

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
├── scenarios/                 # Test definitions
│   ├── contracts/             # Deterministic structural tests
│   └── integration/           # LLM-judged semantic tests
├── seeds/                     # Inputs for fixture generation
├── lib/                       # Framework implementation
├── scripts/                   # CLI tools
└── examples/                  # Usage examples
```

---

## How Testing Works

### The Test Loop

1. **Scenario defines the test**: What fixture to use, what command to run, what answers to give, what to verify
2. **Fixture provides starting state**: Files copied to a temp directory
3. **Command executes**: Claude Agent SDK runs the command, intercepting questions
4. **Assertions verify results**: Structural checks first (free), semantic checks if needed (costs tokens)
5. **Cleanup**: Temp directory deleted

### Two Types of Tests

| Type | Location | Purpose | Cost |
|------|----------|---------|------|
| **Contract** | `scenarios/contracts/` | Verify structure, files, sections | Free (no LLM) |
| **Integration** | `scenarios/integration/` | Verify semantic quality | LLM tokens |

**Run contract tests first** - they catch most issues without API costs.

---

## Fixtures: World State Snapshots

Fixtures represent the filesystem state BEFORE a command runs. They're just directories with pre-made files.

### Minimal Fixtures (Hand-Crafted)

Located in `fixtures/minimal/`. These are simple, focused fixtures for testing specific paths.

```
fixtures/minimal/has-discussion/
├── docs/workflow/
│   ├── research/
│   │   └── test-topic.md      # Minimal research doc
│   └── discussion/
│       └── test-topic.md      # Minimal discussion doc
```

**When to create manually:**
- Testing a specific code path (e.g., "what happens with no discussion?")
- Testing error handling
- Contract tests that don't need realistic content

**How to create:**
1. Create the directory structure
2. Add minimal valid files (basic frontmatter + required sections)
3. Keep content generic - tests should work with any topic

### Generated Fixtures (Automatic)

Located in `fixtures/generated/`. Created by actually running the workflow.

**When to use:**
- Integration tests that need realistic content
- Testing semantic quality
- Regression testing

**How to regenerate:**

```bash
# See what would be generated
npx tsx tests/scripts/generate-fixtures.ts --dry-run

# Generate all fixtures
npx tsx tests/scripts/generate-fixtures.ts

# Generate specific seed
npx tsx tests/scripts/generate-fixtures.ts --seed auth-feature
```

---

## Scenarios: Test Definitions

Scenarios are YAML files that define individual tests.

### Anatomy of a Scenario

```yaml
name: "start-specification contracts"
description: "Tests for the specification command"
type: contract  # or "integration"

scenarios:
  - name: "creates spec from discussion"
    description: "When discussion exists, creates specification file"

    # 1. START STATE: Which fixture to copy
    fixture: minimal/has-discussion

    # 2. COMMAND: What to run
    command: /workflow/start-specification

    # 3. CHOICES: Answers to questions (fuzzy match)
    choices:
      - match: "topic"        # If question contains "topic"
        answer: "test-topic"  # Answer with this
      - match: "approve"
        answer: "yes"

    # 4. ASSERTIONS: What to verify after
    assertions:
      - exists: docs/workflow/specification/test-topic.md
      - has_sections:
          path: docs/workflow/specification/test-topic.md
          sections:
            - "# Specification"
            - "## Dependencies"

    # 5. INVARIANTS: Files that must NOT change
    invariants:
      - docs/workflow/discussion/*
```

### Assertion Types

| Assertion | Description | Example |
|-----------|-------------|---------|
| `exists` | File/pattern exists | `exists: docs/spec/*.md` |
| `not_exists` | File doesn't exist | `not_exists: docs/spec/foo.md` |
| `unchanged` | Files unchanged from fixture | `unchanged: docs/discussion/*` |
| `has_frontmatter` | YAML frontmatter has fields | See below |
| `has_sections` | Markdown has headings | See below |
| `content_matches` | Regex matches content | `pattern: "OAuth2"` |
| `output_contains` | Claude output has text | `output_contains: "Created"` |
| `file_count` | Number of matching files | `min: 1, max: 3` |
| `semantic` | LLM evaluates criteria | See below |

### Scripted Choices

When a command asks questions (AskUserQuestion), you script the answers:

```yaml
choices:
  - match: "which topic"     # Fuzzy match (case-insensitive)
    answer: "authentication"
  - match: "include all"
    answer: "yes"
  - match: "format"
    answer: ["json", "yaml"]  # Multi-select
```

The `match` field is matched case-insensitively against the question text. First match wins.

---

## Testing Complex Commands

Commands like `start-specification` have complex logic with multiple paths:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     start-specification Paths                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────┐                                                │
│  │ No discussions? │──→ STOP: "Run /start-discussion first"        │
│  └────────┬────────┘                                                │
│           ↓                                                         │
│  ┌─────────────────┐                                                │
│  │ One discussion? │──→ Simple path: specify that one              │
│  └────────┬────────┘                                                │
│           ↓                                                         │
│  ┌─────────────────┐                                                │
│  │ Multiple?       │──→ Ask: "Continue existing?" or "Assess?"     │
│  └────────┬────────┘                                                │
│           ↓                                                         │
│  ┌─────────────────┐                                                │
│  │ Has cache?      │──→ Use cached groupings or re-analyze         │
│  └────────┬────────┘                                                │
│           ↓                                                         │
│  Present grouping options → User picks → Create spec                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Strategy: Test Each Path Separately

Create a scenario for EACH path:

```yaml
scenarios:
  # Path 1: No discussions → error
  - name: "handles missing discussion"
    fixture: minimal/empty
    command: /workflow/start-specification
    assertions:
      - file_count:
          pattern: docs/workflow/specification/*.md
          count: 0

  # Path 2: Single discussion → simple path
  - name: "creates spec from single discussion"
    fixture: minimal/has-discussion  # Only one discussion
    command: /workflow/start-specification
    choices:
      - match: "topic"
        answer: "test-topic"
    assertions:
      - exists: docs/workflow/specification/test-topic.md

  # Path 3: Multiple discussions → grouping analysis
  - name: "offers grouping for multiple discussions"
    fixture: minimal/has-multiple-discussions
    command: /workflow/start-specification
    choices:
      - match: "continue"
        answer: "assess"  # Choose to analyze groupings
      - match: "proceed"
        answer: "1"       # Pick first grouping
    assertions:
      - exists: docs/workflow/specification/*.md

  # Path 4: Existing spec → continue or overwrite
  - name: "respects existing specification"
    fixture: minimal/has-specification
    command: /workflow/start-specification
    choices:
      - match: "overwrite"
        answer: "no"
    assertions:
      - unchanged: docs/workflow/specification/test-topic.md
```

### Testing Logic Forks

For each decision point in the command:

1. **Identify the fork**: "What question does it ask?"
2. **Create two scenarios**: One for each answer
3. **Verify different outcomes**: Each path should produce different results

```yaml
# Fork: "Overwrite existing spec?"
scenarios:
  - name: "overwrites spec when user agrees"
    choices:
      - match: "overwrite"
        answer: "yes"
    assertions:
      - content_matches:
          path: docs/workflow/specification/test-topic.md
          pattern: "Updated content"  # New content present

  - name: "preserves spec when user declines"
    choices:
      - match: "overwrite"
        answer: "no"
    assertions:
      - unchanged: docs/workflow/specification/test-topic.md
```

---

## Catching Regressions

### What Causes Regressions?

1. **Logic bugs**: Command takes wrong path, skips steps, produces wrong output
2. **Missing questions**: Command no longer asks expected questions
3. **Changed structure**: Output files missing sections, wrong format
4. **Broken integration**: Skill invocation fails, handoff incomplete

### How Tests Catch Them

| Regression Type | How Tests Catch It |
|-----------------|-------------------|
| Wrong file created | `exists` assertion fails |
| Missing section | `has_sections` assertion fails |
| Frontmatter malformed | `has_frontmatter` assertion fails |
| Question not asked | Scripted choice unused (warning in verbose mode) |
| Unexpected question | `[ChoiceInterceptor] No scripted answer` warning |
| Source files modified | `invariants` or `unchanged` assertion fails |
| Content quality dropped | `semantic` assertion fails |

### The Golden Rule: Test Behavior, Not Content

**WRONG** (brittle, breaks when wording changes):
```yaml
assertions:
  - content_matches:
      path: docs/workflow/specification/test-topic.md
      pattern: "OAuth2 with PKCE flow"  # Specific content!
```

**RIGHT** (behavioral, resilient to wording changes):
```yaml
assertions:
  - has_sections:
      path: docs/workflow/specification/test-topic.md
      sections:
        - "# Specification"
        - "## Dependencies"
  - semantic:
      criteria:
        - "Contains validated technical decisions"
        - "Is structured as a standalone document"
```

### Avoiding False Positives (Baking Bugs into Tests)

**The danger**: If you write tests that match buggy behavior, you'll never catch the bug.

**Prevention strategies:**

1. **Write tests BEFORE you know the output**
   - Define what SHOULD happen based on the skill spec
   - Don't peek at actual output then write tests to match

2. **Use semantic criteria, not exact content**
   - "Contains decisions with rationale" ✓
   - "Contains 'We decided to use OAuth2'" ✗

3. **Test invariants explicitly**
   - If discussion shouldn't change, add `unchanged: docs/workflow/discussion/*`
   - If exactly one file should be created, add `file_count: 1`

4. **Review fixture content carefully**
   - Fixtures should contain VALID input, not buggy output
   - If a fixture contains malformed data, fix the fixture

5. **Regenerate fixtures periodically**
   - When skills change, regenerate and REVIEW the diff
   - Don't blindly commit regenerated fixtures

### The Regression Testing Workflow

```bash
# 1. Make your skill/command change
vim commands/workflow/start-specification.md

# 2. Run contract tests (fast feedback)
npm test -- --suite contracts

# 3. If tests fail, decide:
#    - Is the test wrong? → Update the test
#    - Is the code wrong? → Fix the code

# 4. Regenerate fixtures and review
npx tsx tests/scripts/generate-fixtures.ts
git diff tests/fixtures/generated/

# 5. If fixture changes look correct, commit
git add tests/fixtures/generated/
git commit -m "chore: update fixtures for skill changes"

# 6. Run full integration tests
npm test -- --suite integration
```

---

## Running Tests

### Basic Commands

```bash
# Run all tests
npm test

# Run only contract tests (fast, free)
npm test -- --suite contracts

# Run only integration tests (slower, uses LLM)
npm test -- --suite integration

# Run specific scenario file
npm test -- --file contracts/start-specification.yml

# Run specific scenario by name
npm test -- --scenario "creates spec from discussion"

# Verbose output
npm test -- --verbose

# Dry run (validate scenarios without executing)
npm test -- --dry-run
```

### Cost Control

```bash
# Use cheaper model
npm test -- --model haiku

# Limit budget per test
npm test -- --max-budget 0.50

# Limit turns per test
npm test -- --max-turns 20
```

### Example Output

```
Found 4 scenario file(s)
Model: opus
Max budget per test: $2.00

Running: scenarios/contracts/start-specification.yml
  ✓ creates spec from discussion (45023ms)
  ✓ spec has required sections (38291ms)
  ✗ handles missing discussion (52104ms)
    → File count 1 does not satisfy count=0

============================================================
Test Summary
============================================================

Total: 3 tests
  ✓ Passed: 2
  ✗ Failed: 1
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/test-skills.yml
name: Test Skills

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

jobs:
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

  integration-tests:
    if: github.event_name == 'pull_request'
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
```

### Pre-Release Checklist

```bash
# 1. Run contract tests
npm test -- --suite contracts

# 2. Regenerate fixtures
npx tsx tests/scripts/generate-fixtures.ts

# 3. Review changes
git diff tests/fixtures/generated/

# 4. Run integration tests
npm test -- --suite integration --model opus

# 5. Commit and release
git add tests/fixtures/generated/
git commit -m "chore: update fixtures for release"
```

---

## Cost Management

### Estimated Costs

| Operation | Model | Est. Cost |
|-----------|-------|-----------|
| Contract test | N/A | $0.00 |
| Integration test (1 command) | Haiku | ~$0.01-0.03 |
| Integration test (1 command) | Opus | ~$0.10-0.30 |
| Semantic assertion | Haiku | ~$0.001 |
| Fixture generation (4 phases) | Opus | ~$0.50-1.00 |

### Tips

1. **Run contract tests first** - Free and catch most issues
2. **Use Haiku for CI** - 10x cheaper than Opus
3. **Use Opus sparingly** - Only for release validation
4. **Set budget limits** - `--max-budget 1.0` prevents runaway costs
5. **Cache fixtures** - Commit generated fixtures

---

## Troubleshooting

### "No scripted answer for..."

The command asked a question not in your `choices` list.

**Fix**: Add the choice:
```yaml
choices:
  - match: "the question text"
    answer: "your answer"
```

### Test times out

**Fix**: Increase timeout or reduce complexity:
```bash
npm test -- --timeout 300000 --max-turns 30
```

### Semantic check fails unexpectedly

1. Run with `--verbose` to see content
2. Check if criteria are too strict
3. Lower the threshold
4. Consider if criteria match actual skill output

### Fixtures different after skill update

This is expected! Review the changes:

```bash
git diff tests/fixtures/generated/
```

If changes look correct, commit them. If not, the skill regressed.

### Tests pass but skill is broken

Your tests may be too weak. Add:
- More structural checks (`has_sections`, `has_frontmatter`)
- Semantic criteria for quality
- Invariants for files that shouldn't change
