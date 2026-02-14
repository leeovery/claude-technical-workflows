# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code skills package for structured technical discussion and planning workflows. Installed via npm as `@leeovery/claude-technical-workflows`.

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
  # Each entry-point skill with a discovery script has a scripts/ subdirectory
  migrate/                   # Keep workflow files in sync with system design
    scripts/migrate.sh       #   Migration orchestrator
    scripts/migrations/      #   Individual migration scripts (numbered)
  start-feature/             # Create spec directly from inline context
  link-dependencies/         # Link dependencies across topics
  start-research/            # Begin research exploration
  start-discussion/          # Begin technical discussions
    scripts/discovery.sh     #   Discovery script
  start-specification/       # Begin specification building
    scripts/discovery.sh     #   Discovery script
  start-planning/            # Begin implementation planning
    scripts/discovery.sh     #   Discovery script
  start-implementation/      # Begin implementing a plan
    scripts/discovery.sh     #   Discovery script
  start-review/              # Begin review
    scripts/discovery.sh     #   Discovery script
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
- `skills/migrate/scripts/migrate.sh` runs all migration scripts in `skills/migrate/scripts/migrations/` in numeric order
- Each migration is idempotent - safe to run multiple times
- Progress is tracked in `docs/workflow/.cache/migrations.log`
- Delete the log file to force re-running all migrations

**Adding new migrations:**
1. Create `skills/migrate/scripts/migrations/NNN-description.sh` (e.g., `002-spec-frontmatter.sh`)
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

## Display & Output Conventions (IMPORTANT)

All entry-point skills that present discovery state, menus, or interactive choices MUST follow these conventions. This ensures a consistent, scannable experience across all phases.

### Rendering Instructions

Every fenced block in skill files must be preceded by a rendering instruction:

```
> *Output the next fenced block as a code block:*
```

or:

```
> *Output the next fenced block as markdown (not a code block):*
```

Code blocks are used for informational displays (overviews, status, keys). Markdown is used for interactive elements (menus, prompts) where bold formatting is needed.

### Title Pattern

Always `{Phase} Overview` as the first line of the opening code block, followed by a blank line and a summary sentence.

```
Planning Overview

4 specifications found. 2 plans exist.
```

### Tree Structure

Every actionable item gets a numbered entry with `└─` branches showing its state. Depth varies by phase but structure is consistent. **Blank line between each numbered item.**

```
1. Auth Flow
   └─ Plan: none
   └─ Spec: concluded

2. Data Model
   └─ Plan: in-progress
   └─ Spec: concluded
```

For richer hierarchies (specification phase):

```
1. Auth Flow
   └─ Spec: in-progress (2 of 3 sources extracted)
   └─ Discussions:
      ├─ auth-tokens (extracted)
      └─ session-mgmt (pending)
```

### Status Terms

Always parenthetical `(term)`. Never brackets or dash-separated.

Core vocabulary: `none`, `in-progress`, `concluded`, `ready`, `completed`, `extracted`, `pending`, `reopened`. Phase-specific terms are fine but format is always `(term)`.

### "Not Ready" Blocks

Separate code block. Descriptive heading as `{Artifacts} not ready for {phase}:`, explanatory line, then `·` bullets with parenthetical status. **Blank line after the explanation, before the list.**

```
Specifications not ready for planning:
These specifications are either still in progress or cross-cutting
and cannot be planned directly.

  · caching-strategy (cross-cutting, concluded)
  · rate-limiting (cross-cutting, in-progress)
```

### Key / Legend

Separate code block. Categorized. Em dash (`—`) separators. **No `---` separator before the Key block.** Only show statuses that appear in the current display. **Blank line between categories.**

```
Key:

  Plan status:
    none        — no plan exists yet
    in-progress — planning work is ongoing
    concluded   — plan is complete

  Spec type:
    cross-cutting — architectural policy, not directly plannable
    feature       — plannable feature specification
```

### Menus / Interactive Prompts

Rendered as markdown (not code blocks). Framed with dot separators. Verb-based labels for selection menus. No single-character icons.

**Selection menu:**

```
· · · · · · · · · · · ·
1. Create "Auth Flow" — concluded spec, no plan
2. Continue "Data Model" — plan in-progress
3. Review "Billing" — plan concluded

Select an option (enter number):
· · · · · · · · · · · ·
```

**Yes/no prompt:**

```
· · · · · · · · · · · ·
Proceed?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

**Multi-choice prompt:**

```
· · · · · · · · · · · ·
What scope would you like to review?

- **`s`/`single`** — Review one plan's implementation
- **`m`/`multi`** — Review selected plans together
- **`a`/`all`** — Review all implemented plans
· · · · · · · · · · · ·
```

**Meta options** in selection menus get backtick-wrapped descriptions:

```
3. Unify all into single specification
   `All discussions combined into one specification.`
   `Existing specifications are incorporated and superseded.`
```

### Auto-Select

When only one actionable item exists:

```
Automatically proceeding with "Auth Flow".
```

### Block / Terminal Messages

When a phase can't proceed — use the phase title pattern, then explain:

```
Planning Overview

No specifications found in docs/workflow/specification/

The planning phase requires a concluded specification.
Run /start-specification first.
```

### Bullet Characters

- `•` — simple lists (sources, files, items)
- `·` — excluded / not-ready items in "not ready" blocks

### Spacing Rules

Inside code blocks, maintain **one blank line** between:
- Title/summary and first content
- Each numbered tree item
- Section headings and their content
- Key categories

Between code blocks (overview → not-ready → key → menu), no `---` separators — just the natural block separation.
