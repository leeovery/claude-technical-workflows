# Plan: Build start-specification Skill

Implementation plan for refactoring the monolithic `skills/start-specification/SKILL.md` (851 lines, old Steps 0-11) into a skill with progressive reference loading via conditional reference files. This also implements the display redesign — the current skill uses the old flat format; the new reference files use the nested tree format defined in the design documents.

**Source documents:**
- [display-design.md](display-design.md) — design decisions, all 10 outputs, step structure
- [flows/](flows/) — every path with exact prompts and user interactions

**Conventions:** [progressive-disclosure/conventions.md](../conventions.md)

---

## What We're Building

A skill directory at `skills/start-specification/` with:
- `SKILL.md` — the backbone. Always loaded. Contains Steps 0-3 (migrations, discovery, prerequisites, routing). Routes to one reference file based on discovery state.
- 7 reference files loaded conditionally — instructions enter context only when the path requires them.

### Why Progressive Disclosure Matters

1. **No context pollution.** If a step isn't needed, its instructions never enter context. Claude only sees what's relevant to the current path.
2. **No premature loading.** Downstream steps aren't loaded until the current step completes and routes to them. Claude works on one step at a time.

### What Must Not Change

The logic flow is final. All 10 outputs, all step transitions, all display formats, all menu options, all handoff variants — these are locked down in the design documents. The skill refactor reorganises _where_ instructions live, not _what_ they say.

---

## The Routing Table

This is the core of SKILL.md Step 3. Based on discovery output, load exactly one display reference:

| Condition | Outputs | Reference |
|-----------|---------|-----------|
| `concluded_count == 0` | 1, 2 | `display-blocks.md` |
| `concluded_count == 1` | 3, 4 | `display-single.md` |
| `concluded_count >= 2`, cache valid | 6, 9 | `display-groupings.md` |
| `concluded_count >= 2`, `spec_count == 0`, cache none/stale | 5, 7 | `display-analyze.md` |
| `concluded_count >= 2`, `spec_count >= 1`, cache none/stale | 8, 10 | `display-specs-menu.md` |

Notes:
- When cache is valid, specs don't affect which display loads — groupings display handles both cases (specs and no specs).
- When cache is none/stale, specs DO affect the display — `display-analyze.md` auto-proceeds to analysis while `display-specs-menu.md` offers a choice between existing specs and analysis.

---

## Reference File Chain

Each reference file is self-contained for its display + menu, then links forward to the next step:

```
SKILL.md (Steps 0-3: migrations, discovery, prerequisites, routing)
│
├── display-blocks.md ──── TERMINAL (Outputs 1-2)
│
├── display-single.md ──── confirm-and-handoff.md ──── TERMINAL (Outputs 3-4)
│
├── display-analyze.md ──── analysis-flow.md ──── display-groupings.md ──── confirm-and-handoff.md
│                                                        │
│                                                        └── analysis-flow.md (re-analyze loop)
│
├── display-groupings.md ──── confirm-and-handoff.md
│         │
│         ├── analysis-flow.md (re-analyze loop)
│         └── (unify → update cache → confirm-and-handoff.md)
│
└── display-specs-menu.md ──── confirm-and-handoff.md (continue existing)
          │
          └── analysis-flow.md ──── display-groupings.md ──── ...
```

Key observation: `analysis-flow.md` always feeds into `display-groupings.md`, and `display-groupings.md` always offers `confirm-and-handoff.md` and `analysis-flow.md` (re-analyze). This creates a clean loop.

---

## File-by-File Breakdown

### SKILL.md (~100-150 lines) — Always Loaded

**Frontmatter:**
```yaml
---
name: start-specification
description: "Start a specification session from concluded discussions. Discovers available discussions, offers consolidation assessment for multiple discussions, and invokes the technical-specification skill."
disable-model-invocation: true
allowed-tools: Bash(./scripts/discovery.sh), Bash(mkdir -p docs/workflow/.cache), Bash(rm docs/workflow/.cache/discussion-consolidation-analysis.md)
---
```

**Content:**
- Workflow context table (Phase 3 position)
- Critical instructions: STOP after interactions, don't skip steps, don't act until skill is loaded
- **Step 0**: Run migrations (invoke `/migrate`, stop if files updated)
- **Step 1**: Run discovery script, parse YAML output
- **Step 2**: Check prerequisites — if `concluded_count == 0`, load `display-blocks.md`
- **Step 3**: Routing logic — the table above, implemented as conditional instructions
- Navigation section: markdown links to all 7 reference files (so Claude knows they exist)

**Does NOT contain:** Any display output, analysis logic, confirm format, handoff text.

### references/display-blocks.md (~25 lines)

**Covers:** Outputs 1-2 (terminal — no further steps)

**Content:**
- Output 1: No discussions found → block message with direction to `/start-discussion`
- Output 2: Discussions exist but none concluded → block message with in-progress list
- STOP instruction

**Links to:** Nothing. Terminal path.

### references/display-single.md (~50 lines)

**Covers:** Outputs 3-4 (single concluded discussion, auto-proceed)

**Content:**
- Display format: nested tree with spec status and discussion status
- Output 3 variant: spec = none, discussion = ready
- Output 4 variant: spec exists (in-progress or concluded), discussion = extracted
- Key/legend (only statuses relevant to this display)
- Auto-proceed text ("Automatically proceeding with...")
- Note: Skip to confirm — no intermediate menu since only one option exists

**Links to:** `confirm-and-handoff.md`

### references/display-analyze.md (~45 lines)

**Covers:** Outputs 5 and 7 (multiple discussions, no specs, cache none or stale)

**Content:**
- Summary line: "{N} concluded discussions found. No specifications exist yet."
- Concluded discussions list (bullet format)
- "Not ready" section with in-progress discussions
- Cache-aware intro text:
  - Output 5 (no cache): "These discussions will be analyzed for natural groupings..."
  - Output 7 (stale): "A previous grouping analysis exists but is outdated..."
- Confirm prompt: "Proceed with analysis? (y/n)"
- Decline path: graceful exit message
- If confirmed: proceed to analysis

**Links to:** `analysis-flow.md`

### references/display-groupings.md (~85 lines)

**Covers:** Outputs 6 and 9 (valid cache, show groupings). Also used after analysis complete.

This is the most content-rich display file because it handles the full groupings view with all possible statuses.

**Content:**
- Intro: "Recommended breakdown for specifications with their source discussions."
- Full nested tree display format (see [display-design.md](display-design.md) for exact format)
- Discussion status determination rules
- "Not ready" section
- Key/legend (all three discussion statuses + all three spec statuses)
- Tip about re-analyze
- Numbered menu with inline explanations
- Menu behaviour: pick → confirm, unify → update cache → confirm, re-analyze → delete cache → analysis

**Links to:** `confirm-and-handoff.md` and `analysis-flow.md`

### references/display-specs-menu.md (~65 lines)

**Covers:** Outputs 8 and 10 (specs exist, cache none or stale)

**Content:**
- Summary: "{N} concluded discussions found. {M} specifications exist."
- Existing specifications display (nested tree, from spec frontmatter — NOT from cache)
- Unassigned discussions list (concluded but not in any spec)
- "Not ready" section
- Key/legend (only statuses present in this display)
- Cache-aware message (no cache vs stale)
- Numbered menu: "Analyze for groupings (recommended)" + "Continue {spec}" for each existing spec

**Links to:** `analysis-flow.md` and `confirm-and-handoff.md`

### references/analysis-flow.md (~55 lines)

**Covers:** Context gathering, analysis, display results

**Content:**
- Gather analysis context (prompt + STOP)
- Analyze discussions (coupling analysis, grouping principles, preserve anchored names, save cache)
- After analysis, display results using groupings format

**Links to:** `display-groupings.md`

### references/confirm-and-handoff.md (~90 lines)

**Covers:** Confirm selection + invoke skill

**Content:**
- Confirm selection — all variants (see [display-design.md](display-design.md) Step 7 formats)
- Verb rule: no spec → "Creating", in-progress → "Continuing", concluded → "Refining"
- Decline path: return to previous display
- Invoke skill — all handoff variants
- Link to technical-specification skill

**Links to:** `technical-specification` skill (handoff)

---

## Shared Content Strategy

Duplicate small shared content rather than adding reference indirection.

| Content | Size | Appears in | Decision |
|---------|------|------------|----------|
| Key/legend | ~15 lines | display-single, display-analyze, display-groupings, display-specs-menu | Duplicate. Varies per context (different statuses shown). |
| "Not ready" section | ~4 lines | display-analyze, display-groupings, display-specs-menu | Duplicate. Identical text. |
| Graceful exit message | ~2 lines | display-single (decline), display-analyze (decline) | Duplicate. Identical text. |

---

## Discovery Script Changes

The script currently outputs `concluded_discussion_count`. Add explicit counts to `current_state` for cleaner routing:

```yaml
current_state:
  discussions_checksum: "a1b2c3d4..."
  discussion_count: 5
  concluded_count: 3        # renamed from concluded_discussion_count
  in_progress_count: 2
  spec_count: 2
  has_discussions: true
  has_concluded: true
  has_specs: true
```

**Timing:** Implement alongside the skill refactor. The routing logic in SKILL.md is written against these fields.

---

## Implementation Sequence

### 1. Update Discovery Script

Add the explicit counts and boolean helpers to `current_state`.

**Files:** `skills/start-specification/scripts/discovery.sh`

### 2. Create Skill Directory Structure

```
skills/start-specification/
  SKILL.md
  references/
    display-blocks.md
    display-single.md
    display-analyze.md
    display-groupings.md
    display-specs-menu.md
    analysis-flow.md
    confirm-and-handoff.md
```

### 3. Write SKILL.md (Backbone)

Must contain accurate frontmatter, Steps 0-3, precise routing conditionals, links to all reference files.

**Source material:** [display-design.md](display-design.md) Steps 0-3 + routing table above.

### 4. Write Display Reference Files

In dependency order:
1. `display-blocks.md` — simplest, terminal
2. `display-single.md` — auto-proceed, links to confirm
3. `display-analyze.md` — prompt for analysis, links to analysis-flow
4. `display-specs-menu.md` — specs exist menu
5. `display-groupings.md` — most complex display

**Source material:** Extract exact display text from [display-design.md](display-design.md) outputs.

### 5. Write Analysis Flow

**Source material:** [display-design.md](display-design.md) Steps 4-6 + analysis logic from current monolithic SKILL.md Steps 4-6 (coupling types, grouping principles, cache format, anchored names).

### 6. Write Confirm and Handoff

**Source material:** [display-design.md](display-design.md) Step 7 confirm formats + [flows/](flows/) handoff texts.

### 7. Replace Monolithic SKILL.md

Replace with the new backbone + reference file structure.

### 8. Verify All 10 Outputs

Walk through each output path using the [flows/](flows/) documents as test cases. Also verify secondary paths (unify, re-analyze, decline at confirm, decline at analysis prompt).

---

## Critical Things to Get Right

### 1. Reference Loading Chain Must Work

The architecture depends on Claude following markdown links from one reference file to another. Example chain: `display-analyze.md` → `analysis-flow.md` → `display-groupings.md` → `confirm-and-handoff.md`. **Verify this early.**

### 2. Display Format Fidelity

The display formats are precisely defined in the design documents. The reference files must reproduce these exactly.

### 3. Conditional Text Within Files

Several files handle multiple variants. Each must clearly delineate which variant applies when using explicit conditionals.

### 4. Menu Option Dynamics

Some menu options are conditional (Unify only with 2+ groupings, verb changes based on spec status, etc.).

### 5. Decline Paths

Two types: graceful exit (at analysis prompt) and return to menu (at confirm).

### 6. The Unify Flow

Update cache → use "unified" name → proceed to confirm → handle superseded specs.

---

## Open Questions

1. **Reference loading depth**: Can a reference file link to another reference file? Needs verification — the architecture depends on this.

2. **Allowed-tools inheritance**: When a reference file is loaded, does it inherit `allowed-tools` from the skill's frontmatter? Expected yes (tools are scoped to the skill).

3. **Context budget**: Skills load into a context budget (default 15,000 chars). With many skills installed, check we don't exceed this.

---

## Out of Scope

- **Planning skill superseded display** — `discovery-for-planning.sh` doesn't extract `superseded_by`. Separate task.

---

## Verification Checklist

- [ ] `skills/start-specification/SKILL.md` exists with correct frontmatter
- [ ] All 7 reference files exist in `skills/start-specification/references/`
- [ ] Discovery script outputs explicit counts in `current_state`
- [ ] Routing table in SKILL.md covers all 10 outputs
- [ ] Each display file matches its output format from design docs exactly
- [ ] analysis-flow.md preserves anchored names logic
- [ ] confirm-and-handoff.md covers all 5+ confirm variants
- [ ] Handoff format matches all variants from flows/
- [ ] Reference-to-reference linking verified (chain works)
- [ ] Monolithic SKILL.md replaced with backbone + reference files
- [ ] All 10 output paths manually walked through against flows/
