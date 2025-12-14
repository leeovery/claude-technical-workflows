# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code skills package for structured technical discussion and planning workflows. Distributed via Composer as `leeovery/claude-technical-workflows`.

## Five-Phase Workflow

1. **Discussion** (`technical-discussion` skill): Capture WHAT and WHY - decisions, architecture, edge cases, debates
2. **Specification** (`technical-specification` skill): Validate and refine into standalone spec
3. **Planning** (`technical-planning` skill): Define HOW - phases, tasks, acceptance criteria
4. **Implementation** (`technical-implementation` skill): Execute plan via strict TDD
5. **Review** (`technical-review` skill): Validate work against discussion, specification, and plan

## Structure

```
skills/
  technical-discussion/      # Phase 1: Document discussions
  technical-specification/   # Phase 2: Build validated specifications
  technical-planning/        # Phase 3: Create implementation plans
  technical-implementation/  # Phase 4: Execute via TDD
  technical-review/          # Phase 5: Validate against artifacts
commands/
  start-discussion.md        # Slash command to begin discussions
```

## Key Conventions

- Discussion docs: `docs/specs/discussions/<topic-name>/discussion.md`
- Specification docs: `docs/specs/specifications/<topic-name>/specification.md`
- Plan docs: `docs/specs/plans/<topic-name>/`
- Commit docs frequently (natural breaks, before context refresh)
- Skills capture context, don't implement
