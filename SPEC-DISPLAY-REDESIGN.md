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

See "Agreed Display Format" section above.

---

### Output 7: Prompt — Multiple Discussions, No Specs, Stale Cache

TODO

---

### Output 8: Prompt — Multiple Discussions, With Specs, No Cache

TODO

---

### Output 9: Show Groupings — Multiple Discussions, With Specs, Valid Cache

See "Agreed Display Format" section above.

---

### Output 10: Prompt — Multiple Discussions, With Specs, Stale Cache

TODO

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

## Still To Decide

- How this integrates with rest of the flow (Steps 4-11)
- Whether any changes needed to the skill handoff format

## Related Files

- `commands/workflow/start-specification.md` — the command to update
- `scripts/discovery-for-specification.sh` — discovery script
- `skills/technical-specification/references/specification-guide.md` — spec guide with sources format
- `scripts/migrations/004-sources-object-format.sh` — migration for sources tracking
