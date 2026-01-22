# NLP Skills Testing Framework

A testing framework for validating Claude Code skills and commands using deterministic structural checks combined with LLM-as-judge semantic validation.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Test Execution                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐    ┌─────────────┐    ┌──────────────────┐        │
│  │  Fixtures   │    │  Scenarios  │    │   Test Runner    │        │
│  │  (state)    │ +  │  (config)   │ →  │   (executor)     │        │
│  └─────────────┘    └─────────────┘    └──────────────────┘        │
│        │                  │                     │                   │
│        │                  │                     ▼                   │
│        │                  │            ┌──────────────────┐        │
│        │                  │            │  Claude Session  │        │
│        │                  │            │  (Agent SDK)     │        │
│        │                  │            └──────────────────┘        │
│        │                  │                     │                   │
│        │                  │                     ▼                   │
│        │                  │            ┌──────────────────┐        │
│        │                  │            │   Validators     │        │
│        │                  │            │   (assertions)   │        │
│        │                  │            └──────────────────┘        │
│        │                  │                     │                   │
│        ▼                  ▼                     ▼                   │
│  tests/fixtures/    tests/scenarios/     tests/results/            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
tests/
├── README.md              # This file
├── fixtures/              # World state snapshots
│   ├── minimal/           # Minimal fixtures for contract tests
│   │   ├── empty/
│   │   ├── has-research/
│   │   ├── has-discussion/
│   │   └── has-specification/
│   └── generated/         # Full fixtures from seeds (auto-generated)
│       └── auth-feature/
│           ├── post-research/
│           ├── post-discussion/
│           └── post-specification/
├── scenarios/             # Test scenario definitions
│   ├── contracts/         # Structural/logic tests (deterministic)
│   │   ├── start-specification.yml
│   │   └── start-planning.yml
│   └── integration/       # Full workflow tests (uses LLM judge)
│       └── full-workflow.yml
├── seeds/                 # Canonical inputs for fixture generation
│   └── auth-feature.yml
├── lib/                   # Test framework implementation
│   ├── runner.ts          # Main test runner
│   ├── validators.ts      # Assertion implementations
│   ├── fixture-manager.ts # Fixture setup/teardown
│   ├── choice-interceptor.ts  # Script user choices
│   └── llm-judge.ts       # Semantic validation via LLM
├── results/               # Test output (gitignored)
└── scripts/
    ├── run-tests.sh       # Main test entry point
    └── generate-fixtures.sh  # Regenerate fixtures from seeds
```

## Test Types

### 1. Contract Tests (Deterministic)

Test logic paths, file creation, structure. No LLM calls needed for validation.

```yaml
# scenarios/contracts/start-specification.yml
name: "start-specification contracts"
type: contract

scenarios:
  - name: "creates spec from discussion"
    fixture: minimal/has-discussion
    command: /workflow/start-specification
    choices:
      - match: "topic"
        answer: "test-topic"
    assertions:
      - exists: docs/workflow/specification/test-topic.md
      - has_frontmatter:
          path: docs/workflow/specification/test-topic.md
          required: [topic, status]
      - has_sections:
          path: docs/workflow/specification/test-topic.md
          sections: ["## Summary", "## Validated Decisions"]
      - unchanged: docs/workflow/discussion/*
```

### 2. Integration Tests (LLM-Judged)

Test full workflow behavior with semantic validation.

```yaml
# scenarios/integration/full-workflow.yml
name: "full workflow integration"
type: integration

scenarios:
  - name: "research to specification"
    fixture: generated/auth-feature/post-research
    command: /workflow/start-discussion
    choices:
      - match: "topic"
        answer: "authentication"
    assertions:
      - exists: docs/workflow/discussion/authentication.md
      - semantic:
          judge_model: haiku
          criteria:
            - "Captures key decisions about OAuth2"
            - "Documents rationale for each decision"
            - "Identifies open questions or edge cases"
```

## Running Tests

```bash
# Run all contract tests (fast, deterministic)
./tests/scripts/run-tests.sh --suite contracts

# Run integration tests (slower, uses LLM)
./tests/scripts/run-tests.sh --suite integration

# Run specific scenario file
./tests/scripts/run-tests.sh --file scenarios/contracts/start-specification.yml

# Regenerate fixtures from seeds
./tests/scripts/generate-fixtures.sh

# Regenerate specific fixture
./tests/scripts/generate-fixtures.sh --seed auth-feature
```

## Fixture Management

### Minimal Fixtures (Manual)

Small, focused fixtures for testing specific logic paths. Rarely need updating.

```
fixtures/minimal/has-discussion/
└── docs/workflow/discussion/
    └── test-topic.md    # Minimal valid discussion file
```

### Generated Fixtures (Automatic)

Full realistic fixtures created by running the workflow with canonical seed inputs.

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
    # Continues from post-research state
```

## Assertion Types

| Assertion | Description | Deterministic |
|-----------|-------------|---------------|
| `exists` | File/directory exists | ✅ |
| `not_exists` | File/directory does not exist | ✅ |
| `unchanged` | Files match pre-test state (glob) | ✅ |
| `has_frontmatter` | YAML frontmatter contains fields | ✅ |
| `has_sections` | Markdown contains headings | ✅ |
| `content_matches` | Regex match on file content | ✅ |
| `output_contains` | Claude output contains text | ✅ |
| `file_count` | Number of files matching glob | ✅ |
| `semantic` | LLM judge evaluates criteria | ⚠️ |

## CI Integration

```yaml
# .github/workflows/test-skills.yml
name: Test Skills

on: [push, pull_request]

jobs:
  contract-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: ./tests/scripts/run-tests.sh --suite contracts

  integration-tests:
    needs: contract-tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: ./tests/scripts/generate-fixtures.sh
      - run: ./tests/scripts/run-tests.sh --suite integration
      - name: Check fixture changes
        run: |
          if ! git diff --quiet tests/fixtures/generated/; then
            echo "::warning::Generated fixtures changed"
            git diff tests/fixtures/generated/
          fi
```

## Writing New Tests

1. **Identify what you're testing**: Logic path? Structure? Content quality?
2. **Choose test type**: Contract (deterministic) or Integration (semantic)
3. **Create/select fixture**: Minimal for contracts, generated for integration
4. **Define choices**: Script any interactive prompts
5. **Write assertions**: Structural first, semantic only if needed

See `scenarios/contracts/` for examples.
