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

## Pathway Outputs

### Entry Conditions Table

| # | Discussions | Concluded | Specs Exist | Cache Status | Pathway |
|---|-------------|-----------|-------------|--------------|---------|
| 1 | None | — | — | — | Block: no discussions |
| 2 | Some | None | — | — | Block: none concluded |
| 3 | Some | 1 | No | — | Auto-proceed: single discussion |
| 4 | Some | 1 | Yes | — | Auto-proceed: single with existing spec |
| 5 | Some | 2+ | No | None | Prompt: analyze? |
| 6 | Some | 2+ | No | Valid | Show groupings directly |
| 7 | Some | 2+ | No | Stale | Prompt: analyze (note stale) |
| 8 | Some | 2+ | Yes | None | Prompt: continue spec or analyze? |
| 9 | Some | 2+ | Yes | Valid | Show groupings directly |
| 10 | Some | 2+ | Yes | Stale | Prompt: continue spec or analyze? |

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
Proceeding with "Auth Flow".

Create specification from this discussion? (y/n)
```

**Action:** STOP. Wait for user confirmation.
- If **y**: Proceed to gather additional context, then invoke skill
- If **n**: "What would you like to do instead?" (offer alternatives or exit)

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
Proceeding with "Auth Flow".

Continue refining this specification? (y/n)
```

**Action:** STOP. Wait for user confirmation.
- If **y**: Proceed to gather additional context, then invoke skill
- If **n**: "What would you like to do instead?"

**Note:** Same format as Output 3, but shows existing spec progress and uses "Continue refining" prompt.

---

### Output 5: Prompt — Multiple Discussions, No Specs, No Cache

**Condition:** `concluded_count >= 2`, `spec_count: 0`, `cache.status: "none"`

**Sequence:**
1. Step 0 (Migrations): `[SKIP] No changes needed`
2. Step 1 (Discovery): Returns multiple concluded discussions, no specs, no cache
3. Step 2 (Prerequisites): Passes
4. Step 3 (Route): Multiple discussions, no cache — prompt for analysis

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
Would you like me to analyze these discussions for natural groupings? (recommended)

Grouping analysis identifies discussions that should become a single
specification versus those that should stand alone. Results are cached
and reused until discussions change.

1. Analyze for groupings
2. Pick a discussion individually

Enter choice (1-2):
```

**Action:** STOP. Wait for user choice.

- If **1 (Analyze)**:
  ```
  Before analyzing, is there anything about how these discussions relate
  that would help me group them appropriately?

  For example:
  - Topics that are part of the same feature
  - Dependencies between topics
  - Topics that must stay separate

  Your context (or 'none'):
  ```
  Then: analyze with context → cache results → show groupings (Output 6)

- If **2 (Pick individually)**: Show numbered discussion list to pick from, skip analysis entirely

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
4. Re-analyze groupings

Enter choice (1-4):
```

**Action:** STOP. Wait for user choice.
- If **1-3**: Proceed to confirm selection → gather additional context → invoke skill
- If **4 (Re-analyze)**: Delete cache → loop back to context gathering step (same as Output 5's analyze flow) → analyze → show updated groupings

---

### Output 7: Prompt — Multiple Discussions, No Specs, Stale Cache

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
have changed since it was created. Re-analysis is required.

1. Analyze for groupings (recommended)
2. Pick a discussion individually

Enter choice (1-2):
```

**Action:** STOP. Wait for user choice.
- If **1 (Analyze)**: Delete stale cache → context gathering step → analyze → cache → show groupings (Output 6)
- If **2 (Pick individually)**: Show numbered discussion list to pick from, skip analysis entirely

**Note:** Essentially Output 5 with a stale cache explanation. Flow after choosing is identical.

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
2. Continue "Authentication System" — in-progress
3. Continue "Caching Layer" — concluded
4. Pick a discussion individually

Enter choice (1-4):
```

**Action:** STOP. Wait for user choice.
- If **1 (Analyze)**: Context gathering step → analyze → cache → show groupings (Output 9)
- If **2-3**: Proceed to confirm selection → gather additional context → invoke skill
- If **4 (Pick individually)**: Show numbered discussion list to pick from

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
5. Re-analyze groupings

Enter choice (1-5):
```

**Action:** STOP. Wait for user choice.
- If **1-4**: Proceed to confirm selection → gather additional context → invoke skill
- If **5 (Re-analyze)**: Delete cache → loop back to context gathering step → analyze → show updated groupings

**Note:** Most complete variant — all three discussion statuses visible, mix of spec states, full key. Structurally identical to Output 6 but with real spec data.

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
2. Continue "Authentication System" — in-progress
3. Continue "Caching Layer" — concluded
4. Pick a discussion individually

Enter choice (1-4):
```

**Action:** STOP. Wait for user choice.
- If **1 (Analyze)**: Delete stale cache → context gathering step → analyze → cache → show groupings (Output 9)
- If **2-3**: Proceed to confirm selection → gather additional context → invoke skill
- If **4 (Pick individually)**: Show numbered discussion list to pick from

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

The original command had Steps 0-11. With the redesign, the flow simplifies to Steps 0-9.

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
| 8 | Gather additional context | "Any constraints or changes?" |
| 9 | Invoke skill | Handoff to technical-specification skill |

### Removed / Merged Steps

- **Old Step 5 (Check Cache Status)**: Removed — cache status is already checked during routing in Step 3. By the time we reach the analysis flow, we know the cache is stale or absent.
- **Old Step 7 (Present Grouping Options)**: Replaced by new Step 6. The old format used tables and different vocabulary. Now uses nested tree format.
- **Old Step 8 (Select Grouping)**: Eliminated as a separate step. The old 4-option menu (Proceed as recommended / Combine differently / Single specification / Individual specifications) is gone. Selection is now built into the numbered menu shown in Steps 3 and 6. Restructuring is handled via "Re-analyze with guidance." Picking a single discussion is always available in the menu where relevant.

### Flows Through Steps

- **Single discussion (Outputs 3-4):** 0 → 1 → 2 → 3 → 7 → 8 → 9
- **Multiple, pick individually:** 0 → 1 → 2 → 3 → (pick) → 7 → 8 → 9
- **Multiple, analyze:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9
- **Multiple, valid cache (Outputs 6/9):** 0 → 1 → 2 → 3 → 7 → 8 → 9 (Step 3 shows groupings directly)
- **Re-analyze:** from Step 3 or 6 → delete cache → 4 → 5 → 6
- **Decline at confirm:** Step 7 → back to Step 3 or 6 (whichever displayed the menu)

### Step 7: Confirm Selection Formats

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

### Step 8: Gather Additional Context (Unchanged)

```
Before invoking the specification skill:

1. Any additional context or priorities to consider?
2. Any constraints or changes since the discussion(s) concluded?
3. Are there existing partial implementations or related documentation I should review?

(Say 'none' or 'continue' if nothing to add)
```

### Step 9: Skill Handoff (Unchanged)

Skills are workflow-agnostic. The handoff simply passes sources and output path to the technical-specification skill. No changes needed — the skill doesn't need to know about groupings, caches, or source statuses.

## Still To Decide

- Discovery script improvements (explicit counts) — design agreed, implementation pending
- Remove this tracking file when implementation is complete

## Pending Questions

### Active Discussion

1. **Should "Pick individually" be removed?** The option may be redundant. If specs exist, the menu already offers "Continue" for each. The remaining unassigned discussions would be better served by going through grouping analysis first — that's arguably the point of the specification phase. Counter-argument: sometimes a user just wants to quickly specify one discussion without analyzing everything.

2. **Should we offer a "Unified specification" option?** Allow the user to ignore groupings and consolidate all discussions into a single spec. If chosen, update the cache to reflect this so subsequent runs display the unified group. Needs design for: where the option appears in the menu, how the cache is updated, and what the display looks like on re-entry.

### Parked (circle back after active items resolved)

3. **Confirm step wording for "all sources extracted"** — When continuing a spec where everything is already extracted, the confirm says "All sources extracted" but the handoff says "review and refine." Could be clearer about what the user is actually doing (refinement, not extraction).

4. **"Continue" vs "Refine" verb logic** — In-progress specs use "Continue", concluded specs use "Refine." Rule is implied but never explicitly stated. Should be documented in the command.

5. **Title case inconsistency on individual picks** — Mechanical kebab-to-title conversion (`api-design` → `Api Design`) can differ from proper names chosen during analysis (`API Design`). Minor but visible.

6. **Single-discussion decline has no fallback** — Outputs 3-4 ask y/n. If user says no, there's nothing to fall back to. Should be a graceful exit rather than an open-ended "What would you like to do instead?"

## Related Files

- `commands/workflow/start-specification.md` — the command to update
- `scripts/discovery-for-specification.sh` — discovery script
- `skills/technical-specification/references/specification-guide.md` — spec guide with sources format
- `scripts/migrations/004-sources-object-format.sh` — migration for sources tracking
