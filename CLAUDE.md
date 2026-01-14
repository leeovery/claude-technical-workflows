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
  # Workflow commands (sequential, expect previous phase files)
  workflow:start-research.md       # Begin research exploration
  workflow:start-discussion.md     # Begin technical discussions
  workflow:start-specification.md  # Begin specification building
  workflow:start-planning.md       # Begin implementation planning
  workflow:start-implementation.md # Begin implementing a plan
  workflow:start-review.md         # Begin review
  workflow:link-dependencies.md    # Link dependencies across topics
  workflow:interview.md            # Focused questioning mode

  # Standalone commands (flexible input)
  start-feature.md                 # Create spec directly from inline context

agents/
  chain-verifier.md          # Parallel chain verification for review phase
```

## Command Architecture

**Workflow commands** (`workflow:*`) are part of the sequential workflow system. They expect files from previous phases and pass content to skills.

**Standalone commands** (no prefix) can be used independently. They gather inputs flexibly (inline, files, or prompts) and pass to skills.

**Skills are input-agnostic** - they receive inputs and process them without knowing where the inputs came from. Commands are responsible for gathering inputs.

## Key Conventions

Phase-first directory structure:
- Research: `docs/workflow/research/` (flat, semantically named files)
- Discussion: `docs/workflow/discussion/{topic}.md`
- Specification: `docs/workflow/specification/{topic}.md`
- Planning: `docs/workflow/planning/{topic}.md`

Commit docs frequently (natural breaks, before context refresh). Skills capture context, don't implement.

## Adding New Output Formats

To add a new planning output format:

1. Create `skills/technical-planning/references/output-{format}.md`
2. Include sections: About, Setup, Benefits, Output Process, Implementation (Reading/Updating)
3. Add to the list in `skills/technical-planning/references/output-formats.md`
