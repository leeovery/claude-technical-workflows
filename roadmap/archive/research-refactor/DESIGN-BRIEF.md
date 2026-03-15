# Research Refactor — Design Brief

## Problem

Research for epic work types needs to handle multiple topics, but the current system treats research as a single monolithic file (`exploration.md`). For a v1 project, research spans business, marketing, architecture, design, language choice, data modelling, and more — it can't all live in one file.

Additionally, the convergence awareness system — which detects when research themes are crystallising into distinct topics — isn't triggering in practice. It's loaded too late in the process and framed as a reactive detection step rather than an ongoing research posture.

## Current Behaviour

- Research always creates `exploration.md` as the starting file, regardless of work type
- No way to create named research files for specific topics
- No way to return to a specific research file from continue-epic or workflow-start
- Research status is tracked via manifest: flat status for feature/bugfix, per-topic items for epic
- Convergence awareness is loaded reactively via `convergence-awareness.md` when research-session detects convergence signals — but it's not triggering in practice
- The convergence reference file handles concluding the entire research phase, not individual files
- continue-epic discovery lists research items from the manifest but the menu already supports "Start new research" and "Continue {topic} — research" actions
- Discussion analysis (in `workflow-discussion-entry`) already handles multiple research files correctly — reads all `*.md` in the research directory and analyses them collectively
- Bugfix work type has no research phase (goes straight to investigation)

## Agreed Design

### Work-Type-Specific Behaviour

**Epic research** gets the full multi-file treatment:
- Two entry paths (specific topic or general exploration)
- Topic splitting from exploration as themes emerge
- Convergence awareness loaded as an ongoing research posture
- Per-topic manifest items for independent completion
- No limit on the number of research topics

**Feature research** stays single-file:
- Research file is named `{work_unit}.md` (not `exploration.md`) — consistent with how discussion, specification, planning, and implementation all use the work unit name as the topic for features
- No "specific topic or exploration?" question — implicitly scoped to the feature
- No convergence awareness — no splitting, no per-topic items
- Flat manifest status (as today, but file is renamed)
- The research session loop is the same conversational experience, just without the splitting/convergence overlay

**Bugfix** has no research phase. Unchanged.

### Entry Path (workflow-research-entry)

Add a question early in the bootstrap for epic work types: "Do you have a specific topic to research, or do you want to explore openly?"

- **Specific topic**: User names the topic. Create `.workflows/{work_unit}/research/{topic}.md` directly. Init manifest item for that topic. Research session is scoped to that topic.
- **General exploration**: Create `.workflows/{work_unit}/research/exploration.md`. Broad thinking, follow tangents, see where it goes.

For feature work types, this question is skipped. The file is always `.workflows/{work_unit}/research/{work_unit}.md`.

On return visits (resuming research), the entry skill shows existing research files and offers:
- Continue one of the existing files
- Start a new topic (specific or exploration)

Users can start in any order — specific topic first then exploration later, or vice versa. There's no constraint on the sequence.

### Topic Splitting During Research (technical-research — epic only)

As themes emerge during exploration, the research skill should actively offer to split them out. This is not a forced step in the session loop — it's a continuous background awareness.

**When to offer a split:**
- A thread gets pulled and the conversation starts going deep on one thing
- The conversation keeps circling back to the same topic
- Multiple distinct themes become obvious in the exploration
- The user explicitly mentions wanting to focus on something

**When NOT to interrupt:**
- If nothing is converging, say nothing and carry on
- Don't ask "any topics emerging?" as a checkpoint
- Don't force structure too early — early research is messy by design

**The split offer:**
- Can split one or multiple topics at once
- User picks which topic to continue with (or stays in exploration)
- Example: "I've noticed billing and auth-flow emerging as distinct themes. Want to split these into their own research files?"

**Split mechanics:**
- Content moves verbatim from `exploration.md` into new `{topic}.md` files
- Rewording only for flow and readability — no summarisation
- Reorganising slightly is acceptable to make the extracted content read as a standalone document
- The goal is as close to verbatim as possible while remaining legible
- The extracted content is removed from `exploration.md`
- New manifest items are initialised for each split topic
- Commit after the split

**Exploration persistence:**
- `exploration.md` always persists, even if most content has been extracted
- Some items are too small to warrant their own file — they stay in exploration
- Exploration is always available for general, open-ended research

### Convergence Awareness (technical-research — epic only)

The current convergence awareness system isn't working because it's loaded too late and framed as a detection checkpoint. The fix is to make it part of the research mindset, not a step in a process.

**Current state:**
- `convergence-awareness.md` is loaded reactively by `research-session.md` when convergence signals are detected
- It presents a conclude/keep menu
- It operates at the phase level — concluding research means concluding everything

**Desired state:**
- Convergence awareness instructions are loaded early — alongside or merged into the research guidelines (`research-guidelines.md`), which are loaded in Step 2 of the processing skill
- They become part of how Claude approaches the entire research session, like peripheral vision rather than a checkpoint
- Two distinct convergence behaviours:
  1. **Topic convergence** (splitting): A theme is crystallising into its own topic. Offer to split it out. This is about recognising emerging structure.
  2. **Research exhaustion** (completing): A specific topic file has been explored thoroughly. The tradeoffs are clear, options are understood, and it's approaching decision territory. Offer to mark it as completed and move on.
- Per-file completion: individual research topics can be completed independently. "This topic is ready for discussion" → complete just that file. Other files remain in-progress.
- Phase-level status is derived: all items completed → phase completed, or the user explicitly decides the phase is done.
- The convergence reference file is only loaded for epic work types (progressive disclosure). Feature research doesn't need it.

### Per-File Convergence (manifest)

Individual research topics can be completed independently via manifest items (already supported for epic):

```bash
# Complete a single research topic
node .claude/skills/workflow-manifest/scripts/manifest.js set {work_unit} --phase research --topic {topic} status completed
```

Phase-level status derivation:
- All items completed → phase completed (or the user explicitly decides)
- Some items completed, others in-progress → phase remains in-progress
- This mirrors how discussion items already work

### Continue / Resume (workflow-research-entry + continue-epic)

**workflow-research-entry** — when called with an existing work unit that has research:
- Show existing research files with their status
- Offer to continue any existing file, or start a new one (specific topic or exploration)
- This is the "on return" experience

**continue-epic** — the epic state display and menu already handles research:
- State display shows research items with status (from manifest items)
- Menu includes "Continue {topic} — research (in-progress)" for in-progress items
- Menu includes "Start new research" as a standing option
- Soft gate warns if some research is in-progress when user tries to start discussion

No changes needed to the continue-epic display structure — it already renders research items from discovery. The change is that there will now be more items to display (multiple research topics instead of just one).

### Display in continue-epic

The discovery script already lists research items from the manifest. With multiple research files, the state display shows:

```
Research
  └─ Exploration (in-progress)
  └─ Architecture (completed)
  └─ Data Modelling (in-progress)
```

This is already supported by the display template's `@foreach(item in phase.items)` loop. No structural change needed — just more items flowing through.

### Discussion Integration

Unchanged. The discussion entry skill (`workflow-discussion-entry`) already:
- Reads all `*.md` files in the research directory
- Computes a checksum across all files for cache validation
- Analyses them collectively to extract discussion topics
- Caches the analysis in the manifest and `.state/research-analysis.md`

Whether there's 1 file or 10, the analysis groups them into discussion topics. This works today and doesn't need modification.

### File Naming

- Epic exploration: `exploration.md` (special name for open exploration)
- Epic named topics: `{topic}.md` in kebab-case (e.g., `billing.md`, `data-modelling.md`)
- Feature: `{work_unit}.md` (topic = work_unit for features, consistent with all other phases)

### Session State (workflow-research-entry)

The session state bookmark in Step 4 of `workflow-research-entry` currently hardcodes `exploration.md` as the artifact path:

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-research/SKILL.md" \
  ".workflows/{work_unit}/research/exploration.md"
```

This needs to use the actual research file path — `{topic}.md` for named topics, `exploration.md` for exploration, `{work_unit}.md` for features.

### Handoff (workflow-research-entry → technical-research)

The invoke-skill reference currently hardcodes `exploration.md` in the handoff output path. This needs to use the resolved file path based on entry mode:

```
Research session for: {topic}
Work unit: {work_unit}

Output: .workflows/{work_unit}/research/{resolved_filename}.md

Context:
- Prompted by: {problem, opportunity, or curiosity}
...
```

### Migration

A migration is needed for existing feature research files that are currently named `exploration.md`. The migration should rename `.workflows/{work_unit}/research/exploration.md` to `.workflows/{work_unit}/research/{work_unit}.md` for feature work units only. Epic exploration files keep their `exploration.md` name.

## Files Affected

### Processing skill changes
- `skills/technical-research/SKILL.md` — work-type-aware resume detection, conditional convergence loading
- `skills/technical-research/references/research-guidelines.md` — merge convergence awareness into the research mindset (epic only via progressive disclosure)
- `skills/technical-research/references/research-session.md` — topic splitting offer during session loop (epic only)
- `skills/technical-research/references/convergence-awareness.md` — rework for per-file convergence and topic splitting (epic only)

### Entry skill changes
- `skills/workflow-research-entry/SKILL.md` — work-type branching, resolve file path for session state
- `skills/workflow-research-entry/references/gather-context.md` — add "specific topic or exploration?" question for epic; skip for feature
- `skills/workflow-research-entry/references/invoke-skill.md` — use resolved file path in handoff, not hardcoded `exploration.md`
- `skills/workflow-research-entry/references/validate-phase.md` — handle per-file status for epic

### No changes expected
- `skills/workflow-discussion-entry/` — already reads all research files collectively
- `skills/continue-epic/` — already renders research items from manifest, menu already has research actions
- `skills/workflow-bridge/` — already routes based on phase completion
- `skills/start-epic/references/route-first-phase.md` — research/discussion choice unchanged
- `skills/workflow-start/` — shows work units, not phase internals

### Migration
- `skills/migrate/scripts/migrations/` — new migration to rename feature `exploration.md` to `{work_unit}.md`

## Relationship to Prior Work

Originally identified during Round 8 audit of `feat/work-type-architecture-v2`. The immediate gaps (missing `research` row in routing tables, research files not surfaced in epic discovery) were patched minimally in that audit. This PR implements the full design.

The terminology change from "concluded" to "completed" (PR9) is already in place — this design uses "completed" throughout.
