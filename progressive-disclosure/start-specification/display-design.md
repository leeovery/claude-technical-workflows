# Specification Display Design

Design decisions for the start-specification skill's display format, outputs, and step structure. This is the authoritative reference for what the skill should display in each scenario.

## Context

The original start-specification command displayed discussions and specifications in a confusing way:
- Discussions and specs shown as separate lists requiring mental cross-referencing
- Groupings hidden behind menu choices (not shown upfront)
- Inconsistent terminology (ready/incorporated/pending/spec: X)
- Unclear what statuses meant

## Agreed Display Format

### When Cache is Valid (Groupings Exist)

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. Authentication System
   └─ Spec: in-progress (2 of 3 sources extracted)
   └─ Discussions:
      ├─ auth-flow (extracted)
      ├─ user-sessions (extracted)
      └─ oauth-integration (pending)

2. API Design
   └─ Spec: none
   └─ Discussions:
      ├─ api-endpoints (ready)
      └─ error-handling (ready)

3. Logging Strategy
   └─ Spec: none
   └─ Discussions:
      └─ logging-strategy (ready)

4. Caching Layer
   └─ Spec: concluded
   └─ Discussions:
      └─ caching-layer (extracted)

---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · rate-limiting (in-progress)
  · webhook-design (in-progress)

---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification
    pending   — listed as source but content not yet extracted
    ready     — concluded and available to be specified

  Spec status:
    none        — no specification file exists yet
    in-progress — specification work is ongoing
    concluded   — specification is complete

---
What would you like to do?

1. Continue "Authentication System" — 1 source pending extraction
2. Start "API Design" — 2 ready discussions
3. Start "Logging Strategy" — 1 ready discussion
4. Refine "Caching Layer" — concluded spec
5. Re-analyze groupings

Enter choice (1-5):
```

## Key Design Decisions

### 1. Groupings Shown Immediately
When cache is valid, show groupings upfront. Don't hide them behind a menu choice.

### 2. All Items Are First-Class
Every work item (whether grouped or single-discussion) is a numbered entry in the main list. No "Standalone" or "Independent" sub-headings.

### 3. Title Case for All Items
Grouping/spec names use title case even when they correspond to a single discussion filename. "Logging Strategy" not "logging-strategy".

### 4. Nested Hierarchy
```
1. Item Name
   └─ Spec: {status}
   └─ Discussions:
      ├─ discussion-name (status)
      └─ discussion-name (status)
```

### 5. Status Vocabulary

**Discussion status (relative to a specification):**
- `extracted` — content has been incorporated into the specification
- `pending` — listed as source but content not yet extracted
- `ready` — concluded and available to be specified

**Spec status:**
- `none` — no specification file exists yet
- `in-progress` — specification work is ongoing
- `in-progress (X of Y sources extracted)` — when has pending sources
- `concluded` — specification is complete

### 6. Extraction Count
Show "X of Y sources extracted" when a spec has pending sources.

### 7. Key/Legend Included
Always show the key explaining what status terms mean.

### 8. Not Ready Section Explained
The "not ready" section explains that these discussions are still in progress and must be concluded before specification.

### 9. Numbered Menu
Menu choices are numbered with descriptive context:
```
1. Continue "Authentication System" — 1 source pending extraction
2. Start "API Design" — 2 ready discussions
```

### 10. Anchored Names
When grouping analysis runs (or re-runs), existing specification names must be preserved. This prevents analysis from renaming a specification that already has work done against it.

- The discovery script outputs `anchored_names` in the cache section
- During analysis, Claude must use these exact names for any grouping that corresponds to an existing specification
- New groupings get fresh names from analysis
- On re-analysis, anchored names are re-derived from existing spec files during the next discovery run

### 11. Inline Menu Explanations
The "meta" menu options (Analyze, Unify, Re-analyze) include brief inline explanations. Individual spec picks (Start/Continue/Refine) are self-explanatory. Explanations vary by context.

### 12. "Pick individually" Removed
Grouping analysis is part of the specification process. If the user wants a single discussion as its own spec, they can provide that guidance during analysis.

### 13. "Unified specification" Option
After analysis, the user can combine all discussions into a single specification:
- Only offered when 2+ groupings exist
- Uses "unified" as the specification name
- On re-entry: cache shows one unified group, "Unify" not shown again
- If existing specs exist, the confirm step lists them as being superseded

### 14. Verb Logic
- No spec exists → **"Creating"** / "Start" in menu
- Spec is `in-progress` → **"Continuing"** / "Continue" in menu
- Spec is `concluded` → **"Refining"** / "Refine" in menu

### 15. Title Case from Filenames
Single-discussion specs get names from filename via kebab-to-title conversion (`auth-flow` → `Auth Flow`). Grouped specs get proper names from analysis. Consistent within each context.

### 16. Single-Discussion Decline
Graceful exit: "Understood. You can run /start-discussion to continue working on discussions, or re-run this command when ready."

## Pathway Outputs

### Entry Conditions Table

| #  | Discussions | Concluded | Specs Exist | Cache Status | Pathway                                 |
|----|-------------|-----------|-------------|--------------|-----------------------------------------|
| 1  | None        | —         | —           | —            | Block: no discussions                   |
| 2  | Some        | None      | —           | —            | Block: none concluded                   |
| 3  | Some        | 1         | No          | —            | Auto-proceed: single discussion         |
| 4  | Some        | 1         | Yes         | —            | Auto-proceed: single with existing spec |
| 5  | Some        | 2+        | No          | None         | Prompt: analyze?                        |
| 6  | Some        | 2+        | No          | Valid        | Show groupings directly                 |
| 7  | Some        | 2+        | No          | Stale        | Prompt: analyze (note stale)            |
| 8  | Some        | 2+        | Yes         | None         | Prompt: continue spec or analyze?       |
| 9  | Some        | 2+        | Yes         | Valid        | Show groupings directly                 |
| 10 | Some        | 2+        | Yes         | Stale        | Prompt: continue spec or analyze?       |

Exact output for each pathway is documented in [flows/](flows/).

## Step Structure

The flow uses Steps 0-8:

| Step | Purpose | Notes |
|------|---------|-------|
| 0 | Run migrations | Unchanged |
| 1 | Run discovery | Unchanged |
| 2 | Check prerequisites | Outputs 1-2 (block paths) |
| 3 | Route and display | Outputs 3-10 (includes menu, stops for input) |
| 4 | Gather analysis context | Only if user chose "Analyze" |
| 5 | Analyze discussions + cache | Read discussions, form groupings, save cache |
| 6 | Display groupings | Shows Output 6 or 9 format, stops for input |
| 7 | Confirm selection | After user picks a grouping/discussion |
| 8 | Invoke skill | Handoff to technical-specification skill |

### Flows Through Steps

- **Single discussion (Outputs 3-4):** 0 → 1 → 2 → 3 → 7 → 8
- **Multiple, no specs, analyze (Outputs 5/7):** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8
- **Multiple, with specs, analyze (Outputs 8/10):** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8
- **Multiple, with specs, continue (Outputs 8/10):** 0 → 1 → 2 → 3 → 7 → 8
- **Multiple, valid cache (Outputs 6/9):** 0 → 1 → 2 → 3 → 7 → 8 (Step 3 shows groupings directly)
- **Multiple, valid cache, unify (Outputs 6/9):** 0 → 1 → 2 → 3 → (update cache) → 7 → 8
- **Re-analyze:** from Step 3 or 6 → delete cache → 4 → 5 → 6
- **Decline at confirm:** Step 7 → back to Step 3 or 6 (whichever displayed the menu)

### Confirm Selection Formats

**Creating a new spec:**
```
Creating specification: Authentication System

Sources:
  • auth-flow
  • user-sessions

Output: docs/workflow/specification/authentication-system.md

Proceed? (y/n)
```

**Continuing a spec with pending sources:**
```
Continuing specification: Authentication System

Existing: docs/workflow/specification/authentication-system.md (in-progress)

Sources to extract:
  • oauth-integration (pending)

Previously extracted (for reference):
  • auth-flow
  • user-sessions

Proceed? (y/n)
```

**Refining a concluded spec:**
```
Refining specification: Caching Layer

Existing: docs/workflow/specification/caching-layer.md (concluded)

All sources extracted:
  • caching-layer

Proceed? (y/n)
```

**Creating a grouped spec that supersedes individual specs:**
```
Creating specification: Authentication System

Sources:
  • auth-flow (has individual spec — will be incorporated)
  • user-sessions

Output: docs/workflow/specification/authentication-system.md

After completion:
  specification/auth-flow.md → marked as superseded

Proceed? (y/n)
```

### Invoke Skill

Skills are workflow-agnostic. The handoff passes sources and output path to the technical-specification skill. No additional context gathering — discussion files contain everything needed.

## Discovery Script Improvements

**Task:** Update discovery script to provide explicit counts so routing uses clean conditionals.

**Proposed `current_state` additions:**
```yaml
current_state:
  discussions_checksum: "a1b2c3d4..."
  discussion_count: 5
  concluded_count: 3
  in_progress_count: 2
  spec_count: 2
  active_spec_count: 1
  superseded_spec_count: 1
  has_discussions: true
  has_concluded: true
  has_specs: true
  has_active_specs: true
```

## Related Files

- `skills/start-specification/SKILL.md` — the skill to refactor
- `skills/start-specification/scripts/discovery.sh` — discovery script
- `skills/technical-specification/references/specification-guide.md` — spec guide with sources format
- `skills/migrate/scripts/migrations/004-sources-object-format.sh` — migration for sources tracking
