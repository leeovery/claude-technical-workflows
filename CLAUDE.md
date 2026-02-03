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
  # Processing skills (model-invocable — do the work)
  technical-research/        # Phase 1: Explore and validate ideas
  technical-discussion/      # Phase 2: Document discussions
  technical-specification/   # Phase 3: Build validated specifications
  technical-planning/        # Phase 4: Create implementation plans
  technical-implementation/  # Phase 5: Execute via TDD
  technical-review/          # Phase 6: Validate against artifacts

  # Entry-point skills (user-invocable — gather context, invoke processing skills)
  migrate/                   # Keep workflow files in sync with system design
  start-feature/             # Create spec directly from inline context
  link-dependencies/         # Link dependencies across topics
  start-research/            # Begin research exploration
  start-discussion/          # Begin technical discussions
  start-specification/       # Begin specification building
  start-planning/            # Begin implementation planning
  start-implementation/      # Begin implementing a plan
  start-review/              # Begin review
  status/                    # Show workflow status and next steps
  view-plan/                 # View plan tasks and progress

.claude/skills/
  create-output-format/      # Dev-time skill: scaffold new output format adapters
  skill-creator/             # Dev-time skill: guide for creating effective skills
  update-workflow-explorer/  # Dev-time skill: sync workflow-explorer.html with source

agents/
  review-task-verifier.md           # Verifies single task implementation for review
  implementation-task-executor.md  # TDD executor for single plan tasks
  implementation-task-reviewer.md  # Post-task review for spec conformance
  planning-phase-designer.md       # Design phases from specification
  planning-task-designer.md        # Break phases into task lists
  planning-task-author.md          # Write full task detail
  planning-dependency-grapher.md   # Analyze task dependencies and priorities

scripts/
  migrate.sh                              # Migration orchestrator
  discovery-for-discussion.sh             # Discovery script for discussion skill
  discovery-for-specification.sh          # Discovery script for specification skill
  discovery-for-planning.sh              # Discovery script for planning skill
  discovery-for-implementation-and-review.sh  # Discovery script for implementation/review
  migrations/                             # Individual migration scripts (numbered)

tests/
  scripts/                   # Shell script tests for discovery and migrations
```

## Skill Architecture

Skills are organised in two tiers:

**Entry-point skills** (`/start-*`, `/status`, `/migrate`, etc.) are user-invocable. They gather context from files, prompts, or inline input, then invoke a processing skill. They have `disable-model-invocation: true` in their frontmatter (except `/migrate`, which other skills invoke).

**Processing skills** (`technical-*`) are model-invocable. They receive inputs and process them without knowing where the inputs came from. Entry-point skills are responsible for gathering inputs.

**Standalone entry points** (e.g., `/start-feature`) can invoke processing skills directly without requiring previous phase files.

### Keeping Processing Skills Workflow-Agnostic (IMPORTANT)

Processing skills should **never hardcode references** to specific workflow phases (e.g., "the research phase", "after discussion"). This allows them to be invoked from different entry points — whether via workflow skills or standalone skills like `/start-feature`.

**In processing skills, avoid:**
- "The research, discussion, and specification phases..."
- "After completing discussion, you should..."
- "Proceed to the planning phase..."

**In processing skills, prefer:**
- "The specification contains validated decisions..."
- "Planning is complete when..."
- Reference inputs generically (specification, plan) not how they were created

**Entry-point skills set context; processing skills process inputs.** If workflow-specific language is needed, it belongs in the entry-point skill, not in the processing skill.

## Key Conventions

Phase-first directory structure:
- Research: `docs/workflow/research/` (flat, semantically named files)
- Discussion: `docs/workflow/discussion/{topic}.md`
- Specification: `docs/workflow/specification/{topic}.md`
- Planning: `docs/workflow/planning/{topic}.md`

Commit docs frequently (natural breaks, before context refresh). Skills capture context, don't implement.

## Adding New Output Formats

Use the `/create-output-format` skill to scaffold a new format adapter. Each format is a directory of 5 files:

```
skills/technical-planning/references/output-formats/{format}/
├── about.md        # Benefits, setup, output location
├── authoring.md    # Task storage, flagging, cleanup
├── reading.md      # Extracting tasks, next available task
├── updating.md     # Marking complete/skipped
└── graph.md        # Task graph — priority + dependencies
```

The contract and scaffolding templates live in `.claude/skills/create-output-format/references/`.

## Output Format References (IMPORTANT)

**NEVER list output format names (linear, local-markdown, etc.) anywhere except:**
- `skills/technical-planning/references/output-formats.md` - the authoritative list
- `skills/technical-planning/references/output-formats/{format}/` - individual format directories

**Why this matters:** Listing formats elsewhere creates maintenance dependencies. If a format is added or removed, we should only need to update the planning references - not hunt through other skills or documentation.

**How other phases reference formats:**
- Plans include a `format:` field in their frontmatter
- Consumers load only the per-concern file they need (e.g., `{format}/reading.md` for implementation)

This keeps format knowledge centralized in the planning phase where it belongs.

## Migrations

The `/migrate` skill keeps workflow files in sync with the current system design. It runs automatically at the start of every workflow skill (Step 0).

**How it works:**
- `scripts/migrate.sh` runs all migration scripts in `scripts/migrations/` in numeric order
- Each migration is idempotent - safe to run multiple times
- Progress is tracked in `docs/workflow/.cache/migrations.log`
- Delete the log file to force re-running all migrations

**Adding new migrations:**
1. Create `scripts/migrations/NNN-description.sh` (e.g., `002-spec-frontmatter.sh`)
2. The script will be run automatically in numeric order
3. Use helper functions: `is_migrated`, `record_migration`, `report_update`, `report_skip`

**Critical: Frontmatter extraction in bash scripts**

Workflow documents may contain `---` horizontal rules in body content. NEVER use `sed -n '/^---$/,/^---$/p'` to extract frontmatter — it matches ALL `---` pairs, not just the first frontmatter block, causing body content to leak into extraction results and potential content loss during file rewrites.

Always use this awk pattern for safe frontmatter extraction:
```bash
awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1{print}' "$file"
```

For content after frontmatter (preserving all body `---`):
```bash
awk '/^---$/ && c<2 {c++; next} c>=2 {print}' "$file"
```

Also avoid BSD sed incompatibilities: `sed '/range/{cmd1;cmd2}'` syntax fails on macOS. Use awk or separate `sed -e` expressions instead.
