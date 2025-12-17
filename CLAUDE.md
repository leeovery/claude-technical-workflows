# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code skills package for structured technical discussion and planning workflows. Distributed via Composer as `leeovery/claude-technical-workflows`.

## Six-Phase Workflow

1. **Research** (`technical-research` skill): EXPLORE - feasibility, market, viability, early ideas
2. **Discussion** (`technical-discussion` skill): Capture WHAT and WHY - decisions, architecture, edge cases, debates
3. **Specification** (`technical-specification` skill): Validate and refine into standalone spec
4. **Planning** (`technical-planning` skill): Define HOW - phases, tasks, acceptance criteria
5. **Implementation** (`technical-implementation` skill): Execute plan via strict TDD
6. **Review** (`technical-review` skill): Validate work against discussion, specification, and plan

## Structure

```
skills/
  technical-research/        # Phase 1: Explore and validate ideas
  technical-discussion/      # Phase 2: Document discussions
  technical-specification/   # Phase 3: Build validated specifications
  technical-planning/        # Phase 4: Create implementation plans
  technical-implementation/  # Phase 5: Execute via TDD
  technical-review/          # Phase 6: Validate against artifacts
commands/
  start-research.md          # Slash command to begin research
  start-discussion.md        # Slash command to begin discussions
  start-specification.md     # Slash command to begin specifications
  start-planning.md          # Slash command to begin planning
```

## Key Conventions

Phase-first directory structure:
- Research: `docs/workflow/research/` (flat, semantically named files)
- Discussion: `docs/workflow/discussion/{topic}.md`
- Specification: `docs/workflow/specification/{topic}.md`
- Planning: `docs/workflow/planning/{topic}.md`

Commit docs frequently (natural breaks, before context refresh). Skills capture context, don't implement.
