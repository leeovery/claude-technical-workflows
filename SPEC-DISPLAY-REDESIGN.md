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

## Still To Decide

- Display format when cache is stale/none
- Display format for first run (no specs, no cache)
- How this integrates with rest of the flow (Steps 4-11)
- Whether any changes needed to discovery script output
- Whether any changes needed to the skill handoff format

## Related Files

- `commands/workflow/start-specification.md` — the command to update
- `scripts/discovery-for-specification.sh` — discovery script
- `skills/technical-specification/references/specification-guide.md` — spec guide with sources format
- `scripts/migrations/004-sources-object-format.sh` — migration for sources tracking
