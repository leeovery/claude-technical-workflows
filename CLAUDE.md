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
  start-feature/             # Start feature pipeline (discussion → spec → plan → impl)
    references/              #   Interview questions, handoffs, phase bridge
  continue-feature/          # Continue feature through next pipeline phase
    scripts/discovery.sh     #   Cross-phase discovery script
    references/              #   Phase detection, bridges, handoffs
  link-dependencies/         # Link dependencies across topics

  # Bridge skills (model-invocable — pre-flight + handoff for pipeline)
  begin-planning/            # Pre-flight for planning, invokes technical-planning
    references/              #   Cross-cutting context
  begin-implementation/      # Pre-flight for implementation, invokes technical-implementation
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
    scripts/discovery.sh     #   Discovery script
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
  planning-review-traceability.md  # Spec-to-plan traceability analysis
  planning-review-integrity.md     # Plan structural quality review

tests/
  scripts/                   # Shell script tests for discovery and migrations

hooks/
  workflows/
    system-check.sh      # Bootstrap: install hooks + run migrations
    session-env.sh       # Export CLAUDE_SESSION_ID on session start
    compact-recovery.sh  # Read session state, inject recovery context
    session-cleanup.sh   # Delete session state on session end
    write-session-state.sh # Helper: write session state YAML
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
- Specification: `docs/workflow/specification/{topic}/specification.md`
- Planning: `docs/workflow/planning/{topic}/plan.md` + format-specific task storage
- Implementation: `docs/workflow/implementation/{topic}/tracking.md`
- Review: `docs/workflow/review/{topic}.md`

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
- `README.md` - user-facing documentation where format options are presented

**Why this matters:** Listing formats elsewhere creates maintenance dependencies. If a format is added or removed, we should only need to update the planning references - not hunt through other skills or documentation.

**How other phases reference formats:**
- Plans include a `format:` field in their frontmatter
- Consumers load only the per-concern file they need (e.g., `{format}/reading.md` for implementation)

This keeps format knowledge centralized in the planning phase where it belongs.

## Migrations

The `/migrate` skill keeps workflow files in sync with the current system design. It runs automatically via the `system-check.sh` PreToolUse hook at the start of every workflow skill.

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

## Compaction Recovery

Processing skills run long and may hit context compaction. The hook system provides deterministic recovery.

**How it works:**
- Project-level hooks in `.claude/settings.json` are snapshotted at session startup and persist through compaction
- `SessionStart` (compact) hook reads session state from `docs/workflow/.cache/sessions/{session_id}.yaml` and injects recovery context as additionalContext
- Entry-point skills write session state (topic, skill, artifact) before invoking processing skills
- `SessionEnd` hook cleans up session state files

**Session state files:**
- Stored at `docs/workflow/.cache/sessions/{session_id}.yaml`
- Created by entry-point skills before invoking processing skills
- Contain: topic, skill path, artifact path, optional pipeline context
- Ephemeral — cleaned up on session end, gitignored

**First-run bootstrap:**
- Skill-level `PreToolUse` hook (`system-check.sh`) detects missing project hooks
- Installs hooks into `.claude/settings.json` and stops with restart message
- One-time cost; self-healing if hooks are removed

**Step 0 replacement:**
- The `system-check.sh` hook also runs migrations (previously Step 0 in entry-point skills)
- Step 0 has been removed from all entry-point skills — migrations now run deterministically via hooks

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

### Template Placeholders

Skill files use placeholders in fenced block templates. The syntax is:

```
{name}                                    — raw value, output as-is
{name:[option1|option2|option3]}          — enumerated options (pick one)
{name:(casing)}                           — with casing hint
{name:[option1|option2]:(casing)}         — options and casing
```

Casing hints: `titlecase`, `lowercase`, `kebabcase`. No hint means output the raw value.

Each part is optional — use only what's needed for clarity.

**Conditional directives** for branches that render differently based on state:

```
@if(condition) truthy content @else falsy content @endif
```

Example: `@if(has_discussion) {topic}.md ({status:[in-progress|concluded]}) @else (no discussion) @endif`

**When to use placeholders vs concrete examples:** Placeholders work well for structural templates (tree displays, status blocks) where each field has a clear source. Selection menus should use concrete examples instead — they encode conditional logic (which verb maps to which state) that placeholders obscure.

### Tree Structure

Every actionable item gets a numbered entry with `└─` branches showing its state. Depth varies by phase but structure is consistent. **Blank line between each numbered item.** Show one full entry, then `2. ...` to indicate repetition.

```
1. {topic:(titlecase)}
   └─ Plan: @if(has_plan) {plan_status:[in-progress|concluded]} @else (no plan) @endif
   └─ Spec: {spec_status:[in-progress|concluded]}

2. ...
```

For richer hierarchies (specification phase):

```
1. {topic:(titlecase)}
   └─ Spec: {spec_status:[in-progress|concluded]} ({extraction_summary})
   └─ Discussions:
      ├─ {discussion} ({status:[extracted|pending]})
      └─ ...
```

### Status Terms

Always parenthetical `(term)`. Never brackets or dash-separated.

Core vocabulary: `in-progress`, `concluded`, `ready`, `completed`, `extracted`, `pending`, `reopened`. Phase-specific terms are fine but format is always `(term)`.

### Cross-Plan References

Use colon notation to reference a task within a plan: `{plan}:{task-id}`.

```
  · advanced-features (blocked by core-features:core-2-3)
```

Reads as: "advanced-features is blocked by task core-2-3 in the core-features plan."

### "Not Ready" Blocks

Separate code block. Descriptive heading as `{Artifacts} not ready for {phase}:`, explanatory line, then `•` bullets with parenthetical status. **Blank line after the explanation, before the list.**

```
Specifications not ready for planning:
These specifications are either still in progress or cross-cutting
and cannot be planned directly.

  • caching-strategy (cross-cutting, concluded)
  • rate-limiting (cross-cutting, in-progress)
```

### Key / Legend

Separate code block. Categorized. Em dash (`—`) separators. **No `---` separator before the Key block.** Only show statuses that appear in the current display. **Blank line between categories.**

```
Key:

  Plan status:
    in-progress — planning work is ongoing
    concluded   — plan is complete

  Spec type:
    cross-cutting — architectural policy, not directly plannable
    feature       — plannable feature specification
```

### Menus / Interactive Prompts

Rendered as markdown (not code blocks). Framed with dot separators. Verb-based labels for selection menus. No single-character icons.

**Selection menu** — use concrete examples showing verb-to-state mapping:

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
Automatically proceeding with "{topic:(titlecase)}".
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

Use `•` for all bulleted lists (sources, files, not-ready items, etc.).

### Spacing Rules

Inside code blocks, maintain **one blank line** between:
- Title/summary and first content
- Each numbered tree item
- Section headings and their content
- Key categories

Between code blocks (overview → not-ready → key → menu), no `---` separators — just the natural block separation.

## Structural Conventions (IMPORTANT)

All skill files (entry-point and processing) MUST follow these structural conventions for consistency.

### Stop Gates

Use `**STOP.**` (bold, period). This is the only pattern for user interaction boundaries.

Two categories:

**Interaction stop** — waiting for real user input to continue:
```
**STOP.** Wait for user response.
**STOP.** Wait for user response before proceeding.
```

**Terminal stop** — skill is done, nothing to process:
```
**STOP.** Do not proceed — terminal condition.
```

Never use `Stop here.`, `Command ends.`, `Wait for user to acknowledge before ending.`, or other variations.

### Heading Hierarchy

- **H1** (`#`): File title only — one per file, at the top
- **H2** (`##`): Steps and major sections (`## Step N: {Name}`, `## Notes`, `## Instructions`)
- **H3** (`###`): Subsections within steps (`### 6a: Warn about in-progress specs`)
- **H4** (`####`): Conditional routing only (`#### If {condition}`, `#### Otherwise`)

### Step Numbering

Sequential: `## Step 0`, `## Step 1`, `## Step 2`, etc.

- **Step 0** has been replaced by the `system-check.sh` PreToolUse hook (runs migrations automatically)
- Steps are separated by `---` horizontal rules
- Each step completes fully before the next begins

### Conditional Routing

Use H4 headings for if/else branches within a step:

```
#### If scenario is "no_specs"
{content}

#### If scenario is "has_options"
{content}
```

Never use else-if chains. Each condition gets its own `#### If` heading.

### Navigation Arrows

Use `→` for flow control between steps or to external files:

```
→ Proceed to **Step 4**.
→ Go directly to **Step 7** to invoke the skill.
→ Load **[file.md](file.md)** and follow its instructions.
```

### Reference File Headers

Reference files loaded by skills use this header pattern:

```
# Title

*Reference for **[parent-skill](../SKILL.md)***

---
```

### Critical / Important Markers

Use bold labels with colons for emphasis levels:

```
**CRITICAL**: This guidance is mandatory.
**IMPORTANT**: Use ONLY this script for discovery.
**CHECKPOINT**: Summarize progress before continuing.
```

### Zero Output Rule

Entry-point skills that invoke processing skills use this exact blockquote to prevent narration:

```
> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.
```

### Auto-Mode Gates

Per-item approval gates can offer `a`/`auto` to let the user bypass repeated STOP gates. This pattern is used in implementation (task + fix gates), planning (task authoring + review findings), and specification (review findings).

**Frontmatter tracking**: Gate modes are stored in the relevant frontmatter file (`gated` or `auto`). This ensures they survive context refresh.

**Behavior when `auto`**: Content is always rendered above the gate check (so both modes see identical output). Auto mode proceeds without a STOP gate. Use a rendering instruction + code block for the one-line announcement:

```
> *Output the next fenced block as a code block:*

\```
Task {M} of {total}: {Task Name} — authored. Logging to plan.
\```
```

**Lifecycle**:
- Default: `gated` (set in frontmatter template on creation)
- Opt-in: user chooses `a`/`auto` at any per-item gate → frontmatter updated before next commit
- Reset: entry-point skills reset gates to `gated` on fresh invocation (not on `continue`)
- Context refresh: read gate modes from frontmatter and preserve

**Menu option format**: Add between the primary action and secondary options:
```
- **`a`/`auto`** — Approve this and all remaining {items} automatically
```

**Re-loop safety cap**: When auto-mode enables automatic re-analysis loops, cap at 5 cycles before escalating to the user. This prevents infinite cascading.

### Rendering Instructions for Ask Blocks

When a step asks the user a question, wrap it in a rendering instruction and code block — don't use bare `Ask:` labels:

```
> *Output the next fenced block as a code block:*

\```
What's on your mind?

- What idea or topic do you want to explore?
- What prompted this - a problem, opportunity, curiosity?
\```

**STOP.** Wait for user response before proceeding.
```
