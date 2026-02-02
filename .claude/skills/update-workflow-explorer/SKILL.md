---
name: update-workflow-explorer
description: Audit and update workflow-explorer.html flowcharts to match the current codebase logic. Reads all command, skill, and agent source files, compares against the 4 data structures in the HTML file, reports drift, and applies updates. Use when workflow logic has changed and the explorer needs syncing.
disable-model-invocation: true
---

# Update Workflow Explorer

Audit `workflow-explorer.html` and sync its flowchart data with the actual command/skill/agent source files.

## Step 0: Determine Scope

Check `$ARGUMENTS` for user-provided context about what changed.

- **Context given** (e.g. "I just updated the implementation skill") → narrow to affected flowchart keys using the source mapping below
- **No context** → full audit of all 17 flowchart keys
- **Ambiguous** → ASK user to confirm scope before proceeding

## Step 1: Read Source Files

For each in-scope flowchart key, read its source file(s) and extract the logical flow: steps, gates, decisions, loops, conditional branches, outputs.

### Source Mapping

| Key | Source Files |
|---|---|
| `research` | `commands/workflow/start-research.md` |
| `discussion` | `commands/workflow/start-discussion.md` |
| `specification` | `commands/workflow/start-specification.md` |
| `planning` | `commands/workflow/start-planning.md` |
| `implementation` | `commands/workflow/start-implementation.md` |
| `review` | `commands/workflow/start-review.md` |
| `skill-research` | `skills/technical-research/SKILL.md` |
| `skill-discussion` | `skills/technical-discussion/SKILL.md` |
| `skill-specification` | `skills/technical-specification/SKILL.md` + `skills/technical-specification/references/steps/*.md` |
| `skill-planning` | `skills/technical-planning/SKILL.md` + `skills/technical-planning/references/steps/*.md` |
| `skill-implementation` | `skills/technical-implementation/SKILL.md` + `skills/technical-implementation/references/steps/*.md` |
| `skill-review` | `skills/technical-review/SKILL.md` + `agents/chain-verifier.md` |
| `start-feature` | `commands/start-feature.md` |
| `link-deps` | `commands/link-dependencies.md` |
| `status` | `commands/workflow/status.md` |
| `view-plan` | `commands/workflow/view-plan.md` |
| `migrate` | `commands/migrate.md` |

Use parallel reads (Task tool with Explore agents or multiple Read calls) to gather sources efficiently.

## Step 2: Read Current Flowchart Data

Read `workflow-explorer.html` and extract the 4 data structures for each in-scope key:

1. **`phases[key]`** — metadata (steps, desc, scenarios, detailHTML)
2. **`FLOWCHARTS[key]`** — nodes + connections
3. **`FLOWCHART_DESCS[key]`** — summary, body, meta
4. **`OVERVIEW_*`** — only if phases were added/removed/renamed

## Step 3: Compare and Report

For each key, compare source logic against current flowchart data. Report per key:

- **MATCH** — no drift detected
- **DRIFT** — specific differences (added/removed steps, renamed concepts, changed gates, altered flow)
- **MISSING** — flowchart key exists in sources but not in explorer (or vice versa)

**Present findings to the user and STOP. Wait for confirmation of which changes to apply before proceeding.**

## Step 4: Apply Updates

For each confirmed change, update the following in `workflow-explorer.html`:

- `FLOWCHARTS[key].nodes` and `.connections`
- `FLOWCHART_DESCS[key]` summary, body, meta
- `phases[key]` desc, steps count, detailHTML (if affected)
- `OVERVIEW_*` (only if phases added/removed)

### Data Conventions

Follow the conventions documented in the file header (lines 1-41):

**Node shapes:**
- `pill` — start/end nodes (w:150, h:40)
- `diamond` — decision/gate nodes (w:110-130, h:110-130)
- rect (default) — action step nodes (w:180-200, h:44)

**Connection types:**
- `yes` — green (positive branch from diamond)
- `no` — red (negative branch from diamond)
- `transition` — orange dashed (phase/context transitions)
- `backloop` — gray dashed (retry/loop-back flows)

**Color conventions:**
- Phase color for primary nodes
- `var(--accent)` for start/migrate nodes
- `var(--text-dim)` for secondary/utility nodes
- `#a78bfa` for ASK/user-interaction nodes
- `#f43f5e` for gates/blocks
- `#fbbf24` for routing diamonds
- `#34d399` for discovery nodes

**Node properties:**
- `skillLink` — on nodes that should navigate to a skill flowchart on click
- `desc` — tooltip text describing what the node does

## Step 5: Validate and Verify

After applying updates:

1. Check all connection `from`/`to` values reference valid node IDs in the same flowchart
2. Check for orphaned nodes (not referenced by any connection as source or target, excluding `start` nodes)
3. Remind user to open `workflow-explorer.html` in browser for visual verification
