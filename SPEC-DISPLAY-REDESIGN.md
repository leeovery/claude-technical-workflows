# Specification Display Redesign - Design Decisions

Tracking file for the start-specification command display redesign. This captures decisions made during the design discussion so work can continue if context is lost.

## Context

The original issue was that the start-specification command displayed discussions and specifications in a confusing way:
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
Every work item (whether grouped or single-discussion) is a numbered entry in the main list. No "Standalone" or "Independent" sub-headings. Single-discussion items are just as valid as multi-discussion groupings.

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
Show "X of Y sources extracted" when a spec has pending sources, e.g., "Spec: in-progress (2 of 3 sources extracted)"

### 7. Key/Legend Included
Always show the key explaining what status terms mean. No room for misinterpretation.

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

- The discovery script outputs `anchored_names` in the cache section — an array of specification names that already exist as files
- During analysis (Step 5), Claude must use these exact names for any grouping that corresponds to an existing specification
- New groupings (discussions not covered by existing specs) get fresh names from analysis
- When the cache is saved, `anchored_names` is persisted so subsequent runs know which names to preserve
- On re-analysis, anchored names are re-derived from existing spec files during the next discovery run

### 11. Inline Menu Explanations
The "meta" menu options (Analyze, Unify, Re-analyze) include brief inline explanations. Individual spec picks (Start/Continue/Refine) are self-explanatory and have no explanation. Explanations vary by context (specs exist or not). See outputs for exact wording.

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

---

### Output 1: Block — No Discussions

**Condition:** `discussions: []` (empty array)

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns `discussions: []`, `concluded_count: 0`
3. Step 2 (Prerequisites): Blocked

**Output:**
```
Specification Phase

No discussions found.

The specification phase requires concluded discussions to work from.
Discussions capture the technical decisions, edge cases, and rationale
that specifications are built upon.

Run /start-discussion to begin documenting technical decisions.
```

**Action:** STOP. Wait for user acknowledgment.

---

### Output 2: Block — Discussions Exist But None Concluded

**Condition:** `discussions` has items but `concluded_count: 0`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns discussions with `status: "in-progress"`, `concluded_count: 0`
3. Step 2 (Prerequisites): Blocked

**Output:**
```
Specification Phase

No concluded discussions found.

The following discussions are still in progress:
  · rate-limiting (in-progress)
  · webhook-design (in-progress)

Specifications can only be created from concluded discussions.
Run /start-discussion to continue working on a discussion.
```

**Action:** STOP. Wait for user acknowledgment.

---

### Output 3: Auto-proceed — Single Concluded Discussion (No Spec)

**Condition:** `concluded_count: 1` and no spec exists for that discussion

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns one concluded discussion, `spec_count: 0`
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Single discussion path — auto-proceed

**Output:**
```
Specification Overview

Single concluded discussion found.

1. Auth Flow
   └─ Spec: none
   └─ Discussions:
      └─ auth-flow (ready)

---
Key:

  Discussion status:
    ready — concluded and available to be specified

  Spec status:
    none — no specification file exists yet

---
Automatically proceeding with "Auth Flow".
```

**Action:** Auto-proceed to Step 7 (confirm selection). Single-discussion paths skip the Step 3 confirmation since Step 7 immediately follows — two consecutive y/n prompts with nothing in between would be redundant. The user confirms once at Step 7.

**Note:** Uses same format as groupings view for consistency. Single-discussion items are first-class, not special-cased.

---

### Output 4: Auto-proceed — Single Concluded Discussion (Has Spec)

**Condition:** `concluded_count: 1` and spec exists for that discussion

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns one concluded discussion with `has_individual_spec: true`
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Single discussion with spec — auto-proceed to continue/refine

**Output:**
```
Specification Overview

Single concluded discussion found with existing specification.

1. Auth Flow
   └─ Spec: in-progress (1 of 1 sources extracted)
   └─ Discussions:
      └─ auth-flow (extracted)

---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification

  Spec status:
    in-progress — specification work is ongoing

---
Automatically proceeding with "Auth Flow".
```

**Action:** Auto-proceed to Step 7 (confirm selection). Single-discussion paths skip the Step 3 confirmation since Step 7 immediately follows — two consecutive y/n prompts with nothing in between would be redundant. The user confirms once at Step 7.

**Note:** Same format as Output 3, but shows existing spec progress. Both use auto-proceed to Step 7.

---

### Output 5: Auto-analyze — Multiple Discussions, No Specs, No Cache

**Condition:** `concluded_count >= 2`, `spec_count: 0`, `cache.status: "none"`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns multiple concluded discussions, no specs, no cache
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Multiple discussions, no cache — proceed to analysis

**Output:**
```
Specification Overview

3 concluded discussions found. No specifications exist yet.

Concluded discussions:
  • auth-flow
  • api-design
  • error-handling

---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · rate-limiting (in-progress)

---
These discussions will be analyzed for natural groupings to determine
how they should be organized into specifications. Results are cached
and reused until discussions change.

Proceed with analysis? (y/n)
```

**Action:** STOP. Wait for user confirmation.
- If **y**: Proceed to Step 4 (context gathering) → Step 5 (analyze) → Step 6 (show groupings)
- If **n**: Graceful exit — "Understood. You can run /start-discussion to continue working on discussions, or re-run this command when ready."

---

### Output 6: Show Groupings — Multiple Discussions, No Specs, Valid Cache

**Condition:** `concluded_count >= 2`, `spec_count: 0`, `cache.status: "valid"`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns multiple concluded discussions, no specs, valid cache
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Valid cache — show groupings directly

**Output:**
```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. Authentication System
   └─ Spec: none
   └─ Discussions:
      ├─ auth-flow (ready)
      └─ user-sessions (ready)

2. API Design
   └─ Spec: none
   └─ Discussions:
      ├─ api-endpoints (ready)
      └─ error-handling (ready)

3. Logging Strategy
   └─ Spec: none
   └─ Discussions:
      └─ logging-strategy (ready)

---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · rate-limiting (in-progress)

---
Key:

  Discussion status:
    ready — concluded and available to be specified

  Spec status:
    none — no specification file exists yet

---
Tip: To restructure groupings or pull a discussion into its own
specification, choose "Re-analyze" and provide guidance.

---
What would you like to do?

1. Start "Authentication System" — 2 ready discussions
2. Start "API Design" — 2 ready discussions
3. Start "Logging Strategy" — 1 ready discussion
4. Unify all into single specification
   All discussions are combined into one specification instead
   of following the recommended groupings.
5. Re-analyze groupings
   Current groupings are discarded and rebuilt. You can provide
   guidance on how to organize them in the next step.

Enter choice (1-5):
```

**Action:** STOP. Wait for user choice.
- If **1-3**: Proceed to Step 7 (confirm selection) → Step 8 (invoke skill)
- If **4 (Unify)**: Update cache to single unified grouping → proceed to Step 7 (confirm) with all discussions as sources
- If **5 (Re-analyze)**: Delete cache → loop back to context gathering step → analyze → show updated groupings

**Note:** "Unify" option only shown when there are 2+ groupings. If analysis produces a single grouping, it's already effectively unified.

---

### Output 7: Auto-analyze — Multiple Discussions, No Specs, Stale Cache

**Condition:** `concluded_count >= 2`, `spec_count: 0`, `cache.status: "stale"`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns multiple concluded discussions, no specs, stale cache
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Stale cache — must re-analyze

**Output:**
```
Specification Overview

3 concluded discussions found. No specifications exist yet.

Concluded discussions:
  • auth-flow
  • api-design
  • error-handling

---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · rate-limiting (in-progress)

---
A previous grouping analysis exists but is outdated — discussions
have changed since it was created.

These discussions will be re-analyzed for natural groupings. Results
are cached and reused until discussions change.

Proceed with analysis? (y/n)
```

**Action:** STOP. Wait for user confirmation.
- If **y**: Delete stale cache → Step 4 (context gathering) → Step 5 (analyze) → Step 6 (show groupings)
- If **n**: Graceful exit — "Understood. You can run /start-discussion to continue working on discussions, or re-run this command when ready."

**Note:** Essentially Output 5 with a stale cache explanation. Flow after confirming is identical.

---

### Output 8: Prompt — Multiple Discussions, With Specs, No Cache

**Condition:** `concluded_count >= 2`, `spec_count >= 1`, `cache.status: "none"`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns multiple concluded discussions, specs exist, no cache
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Specs exist, no cache — show specs, offer options

**Output:**
```
Specification Overview

5 concluded discussions found. 2 specifications exist.

Existing specifications:

1. Authentication System
   └─ Spec: in-progress (2 of 2 sources extracted)
   └─ Discussions:
      ├─ auth-flow (extracted)
      └─ user-sessions (extracted)

2. Caching Layer
   └─ Spec: concluded (1 of 1 sources extracted)
   └─ Discussions:
      └─ caching-layer (extracted)

Concluded discussions not in a specification:
  • api-design
  • error-handling

---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · rate-limiting (in-progress)

---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification

  Spec status:
    in-progress — specification work is ongoing
    concluded   — specification is complete

---
No grouping analysis exists.

1. Analyze for groupings (recommended)
   All discussions are analyzed for natural groupings. Existing
   specification names are preserved. You can provide guidance
   in the next step.
2. Continue "Authentication System" — in-progress
3. Continue "Caching Layer" — concluded

Enter choice (1-3):
```

**Action:** STOP. Wait for user choice.
- If **1 (Analyze)**: Step 4 (context gathering) → Step 5 (analyze) → Step 6 (show groupings)
- If **2-3**: Proceed to Step 7 (confirm selection) → Step 8 (invoke skill)

**Note:** Existing specifications are shown using data from the spec files' `sources` frontmatter — no cache needed. The unassigned discussions are shown as a flat list because without a grouping analysis we can't recommend how they should be organized. This is why "Analyze for groupings" is the recommended first action — it will organize unassigned discussions and may suggest incorporating them into existing specs.

---

### Output 9: Show Groupings — Multiple Discussions, With Specs, Valid Cache

**Condition:** `concluded_count >= 2`, `spec_count >= 1`, `cache.status: "valid"`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns multiple concluded discussions, specs with sources, valid cache
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Valid cache + specs — show groupings with full status

**Output:**
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
   └─ Spec: concluded (1 of 1 sources extracted)
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
Tip: To restructure groupings or pull a discussion into its own
specification, choose "Re-analyze" and provide guidance.

---
What would you like to do?

1. Continue "Authentication System" — 1 source pending extraction
2. Start "API Design" — 2 ready discussions
3. Start "Logging Strategy" — 1 ready discussion
4. Refine "Caching Layer" — concluded spec
5. Unify all into single specification
   All discussions are combined into one specification. Existing
   specifications are incorporated and superseded.
6. Re-analyze groupings
   Current groupings are discarded and rebuilt. Existing
   specification names are preserved. You can provide guidance
   in the next step.

Enter choice (1-6):
```

**Action:** STOP. Wait for user choice.
- If **1-4**: Proceed to Step 7 (confirm selection) → Step 8 (invoke skill)
- If **5 (Unify)**: Update cache to single unified grouping → proceed to Step 7 (confirm) with all discussions as sources. Existing specs will be incorporated and superseded.
- If **6 (Re-analyze)**: Delete cache → loop back to context gathering step → analyze → show updated groupings

**Note:** Most complete variant — all three discussion statuses visible, mix of spec states, full key. Structurally identical to Output 6 but with real spec data. "Unify" option only shown when there are 2+ groupings.

---

### Output 10: Prompt — Multiple Discussions, With Specs, Stale Cache

**Condition:** `concluded_count >= 2`, `spec_count >= 1`, `cache.status: "stale"`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns multiple concluded discussions, specs exist, stale cache
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Specs exist, stale cache — show specs, recommend re-analysis

**Output:**
```
Specification Overview

5 concluded discussions found. 2 specifications exist.

Existing specifications:

1. Authentication System
   └─ Spec: in-progress (2 of 2 sources extracted)
   └─ Discussions:
      ├─ auth-flow (extracted)
      └─ user-sessions (extracted)

2. Caching Layer
   └─ Spec: concluded (1 of 1 sources extracted)
   └─ Discussions:
      └─ caching-layer (extracted)

Concluded discussions not in a specification:
  • api-design
  • error-handling
  • oauth-integration

---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · rate-limiting (in-progress)

---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification

  Spec status:
    in-progress — specification work is ongoing
    concluded   — specification is complete

---
A previous grouping analysis exists but is outdated — discussions
have changed since it was created. Re-analysis is required.

1. Analyze for groupings (recommended)
   All discussions are analyzed for natural groupings. Existing
   specification names are preserved. You can provide guidance
   in the next step.
2. Continue "Authentication System" — in-progress
3. Continue "Caching Layer" — concluded

Enter choice (1-3):
```

**Action:** STOP. Wait for user choice.
- If **1 (Analyze)**: Delete stale cache → Step 4 (context gathering) → Step 5 (analyze) → Step 6 (show groupings)
- If **2-3**: Proceed to Step 7 (confirm selection) → Step 8 (invoke skill)

**Note:** Identical to Output 8 except for the stale cache message. Stale cache is not used for display — existing specs shown from spec files' frontmatter. Unassigned discussions shown as flat list.

---

## Discovery Script Improvements

**Task:** Update discovery script to provide explicit counts and states so the command doesn't need to check array lengths or derive states.

**Proposed `current_state` section:**
```yaml
current_state:
  discussions_checksum: "a1b2c3d4..."

  # Counts for easy conditionals
  discussion_count: 5
  concluded_count: 3
  in_progress_count: 2
  spec_count: 2
  active_spec_count: 1      # excludes superseded
  superseded_spec_count: 1

  # Derived states for routing
  has_discussions: true
  has_concluded: true
  has_specs: true
  has_active_specs: true
```

**Benefits:**
- Command can check `concluded_count: 0` instead of iterating arrays
- Routing logic becomes simple conditionals: `if concluded_count == 1 && spec_count == 0`
- Reduces cognitive overhead when reading/maintaining the command
- Single source of truth for counts (discovery calculates once)

**Additional counts to consider:**
- `grouped_spec_count` — specs with multiple sources
- `pending_source_count` — total sources pending extraction across all specs
- `specs_needing_work_count` — specs with at least one pending source

## Reorganized Step Structure

The original command had Steps 0-11. With the redesign, the flow simplifies to Steps 0-8.

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

### Removed / Merged Steps

- **Old Step 5 (Check Cache Status)**: Removed — cache status is already checked during routing in Step 3. By the time we reach the analysis flow, we know the cache is stale or absent.
- **Old Step 7 (Present Grouping Options)**: Replaced by new Step 6. The old format used tables and different vocabulary. Now uses nested tree format.
- **Old Step 8 (Select Grouping)**: Eliminated as a separate step. The old 4-option menu (Proceed as recommended / Combine differently / Single specification / Individual specifications) is gone. Selection is now built into the numbered menu shown in Steps 3 and 6. Restructuring is handled via "Re-analyze with guidance." "Pick individually" has been removed — grouping analysis is part of the specification process. "Unify all" option added to groupings display for when user wants a single specification.
- **Old Step 10 (Gather Additional Context)**: Removed. By this point, the discussion files contain everything needed. If context has changed since the discussion concluded, the user should reopen the discussion phase. Injecting ephemeral context here creates undocumented decisions that break the artifact chain.

### Flows Through Steps

- **Single discussion (Outputs 3-4):** 0 → 1 → 2 → 3 → 7 → 8
- **Multiple, no specs, analyze (Outputs 5/7):** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 (auto-proceed to analysis)
- **Multiple, with specs, analyze (Outputs 8/10):** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8
- **Multiple, with specs, continue (Outputs 8/10):** 0 → 1 → 2 → 3 → 7 → 8
- **Multiple, valid cache (Outputs 6/9):** 0 → 1 → 2 → 3 → 7 → 8 (Step 3 shows groupings directly)
- **Multiple, valid cache, unify (Outputs 6/9):** 0 → 1 → 2 → 3 → (update cache) → 7 → 8
- **Re-analyze:** from Step 3 or 6 → delete cache → 4 → 5 → 6
- **Decline at confirm:** Step 7 → back to Step 3 or 6 (whichever displayed the menu)

### Step 7: Confirm Selection Formats

**Verb rule:** The heading verb is determined by the spec's status:
- No spec exists → **"Creating"** / "Start" in menu
- Spec is `in-progress` → **"Continuing"** / "Continue" in menu
- Spec is `concluded` → **"Refining"** / "Refine" in menu

**Creating a new spec (from grouping or individual pick):**
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

**Creating a new grouped spec that supersedes individual specs:**
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

### Step 8: Invoke Skill

Skills are workflow-agnostic. The handoff passes sources and output path to the technical-specification skill. No additional context gathering step — by this point, the discussion files contain everything needed. If context has changed since the discussion concluded, the user should go back to the discussion phase.

## Still To Decide

- Discovery script improvements (explicit counts) — design agreed, implementation pending
- Planning command: `discovery-for-planning.sh` does not extract `superseded_by` and `start-planning.md` does not display superseded specs differently. A superseded spec won't be accidentally planned (it lacks `status: concluded`), but it shows as `(superseded) - not ready` with no indication of what replaced it. Should show something like `× auth-flow (superseded → authentication-system)` and the discovery script should output `superseded_by` so the command can display the replacement.
- Remove this tracking file when implementation is complete

## Pending Questions

### Resolved

1. **"Pick individually" removed.** Grouping analysis is part of the specification process. If the user wants a single discussion as its own spec, they can provide that guidance during analysis. This simplifies the flow:
   - **Outputs 5/7 (no specs):** No menu needed — auto-proceed to analysis with confirmation.
   - **Outputs 8/10 (with specs):** Menu becomes "Analyze for groupings" + "Continue {spec}" only.
   - **Even with just 2 discussions**, still analyze — they might belong together or apart. The context gathering step handles this naturally.

2. **"Unified specification" option added to groupings display.** After analysis, the user can choose to combine all discussions into a single specification instead of following the recommended groupings.
   - Only offered when there are **2+ groupings** (if there's already one group, it's effectively unified).
   - Appears in the Step 6 menu (and Step 3 when showing cached groupings) alongside individual groupings and re-analyze.
   - When chosen: update cache to reflect a single unified grouping, then proceed to confirm.
   - On re-entry: cache shows one unified group. Since there's only 1 grouping, "Unify" is not shown again.
   - Uses "unified" as the specification name (consistent with existing convention).
   - If existing specs exist, the confirm step lists them as being superseded.

### Resolved (continued)

3. **Confirm step wording for "all sources extracted" — no change needed.** "All sources extracted" is informational context (here's where you are), not a description of the action. The handoff correctly says "review and refine." The user is refining what's already there — revisiting decisions, improving clarity, adding detail. No wording change required.

4. **"Continue" vs "Refine" verb logic — document explicitly in the command.** Rule: `in-progress` spec → "Continue", `concluded` spec → "Refine." This applies to both the menu labels and the confirm step heading. Must be stated as an explicit rule in the command so Claude applies it consistently.

5. **Title case from filenames — acceptable inconsistency.** With "Pick individually" removed, this only affects Outputs 3-4 (single discussion auto-proceed). Single-discussion specs get their name from the filename via kebab-to-title conversion (`auth-flow` → `Auth Flow`). Grouped specs get proper names from analysis (`API Design`). This is consistent within each context — single discussions don't have analysis-assigned names, so filename-derived titles are the correct behaviour.

6. **Single-discussion decline — graceful exit.** If the user says "n" to the single-discussion auto-proceed (Outputs 3-4), there's nothing else to offer. Show a graceful exit message:
   ```
   Understood. You can run /start-discussion to continue working on
   discussions, or re-run this command when ready.
   ```
   This ends the command's job and passes control back to the user. We don't exit their Claude session — we just stop the command flow.

## Related Files

- `commands/workflow/start-specification.md` — the command to update
- `scripts/discovery-for-specification.sh` — discovery script
- `skills/technical-specification/references/specification-guide.md` — spec guide with sources format
- `scripts/migrations/004-sources-object-format.sh` — migration for sources tracking
