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
  # Standalone commands (flexible input)
  start-feature.md                 # Create spec directly from inline context
  link-dependencies.md             # Link dependencies across topics

  # Workflow commands (sequential, expect previous phase files)
  workflow/
    start-research.md              # Begin research exploration
    start-discussion.md            # Begin technical discussions
    start-specification.md         # Begin specification building
    start-planning.md              # Begin implementation planning
    start-implementation.md        # Begin implementing a plan
    start-review.md                # Begin review
    status.md                      # Show workflow status and next steps
    view-plan.md                   # View plan tasks and progress

agents/
  chain-verifier.md          # Parallel chain verification for review phase

scripts/
  specification-discovery.sh # Discovery script for specification command
```

## Command Architecture

**Workflow commands** (in `commands/workflow/`) are part of the sequential workflow system. They expect files from previous phases and pass content to skills.

**Standalone commands** (no prefix) can be used independently. They gather inputs flexibly (inline, files, or prompts) and pass to skills.

**Skills are input-agnostic** - they receive inputs and process them without knowing where the inputs came from. Commands are responsible for gathering inputs.

### Keeping Skills Workflow-Agnostic (IMPORTANT)

Skills should **never hardcode references** to specific workflow phases (e.g., "the research phase", "after discussion"). This allows skills to be invoked from different entry points - whether via the six-phase workflow commands or standalone commands like `/start-feature`.

**In skills, avoid:**
- "The research, discussion, and specification phases..."
- "After completing discussion, you should..."
- "Proceed to the planning phase..."

**In skills, prefer:**
- "The specification contains validated decisions..."
- "Planning is complete when..."
- Reference inputs generically (specification, plan) not how they were created

**Commands set context; skills process inputs.** If workflow-specific language is needed, it belongs in the command that invokes the skill, not in the skill itself.

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

## Output Format References (IMPORTANT)

**NEVER list output format names (beads, linear, local-markdown, etc.) anywhere except:**
- `skills/technical-planning/references/output-formats.md` - the authoritative list
- `skills/technical-planning/references/output-{format}.md` - individual format definitions

**Why this matters:** Listing formats elsewhere creates maintenance dependencies. If a format is added or removed, we should only need to update the planning references - not hunt through skills, commands, or documentation.

**How other phases reference formats:**
- Plans include a `format:` field in their frontmatter
- Implementation/review skills read the format from the plan
- They then load the appropriate `output-{format}.md` reference file

This keeps format knowledge centralized in the planning phase where it belongs.
