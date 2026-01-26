# Flow: Multiple Discussions, No Specs, Stale Cache (Output 7)

Cache exists but discussions have changed since analysis. Must re-analyze.

**Entry state:** 3 concluded discussions, 1 in-progress, 0 specs, stale cache

---

## Scenario A: User Chooses "Analyze for Groupings"

**Steps:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9

### Step 0: Run Migrations

```
[SKIP] No changes needed
```

### Step 1: Run Discovery

Discovery returns:
```yaml
discussions:
  - name: auth-flow
    status: concluded
    has_individual_spec: false
  - name: api-design
    status: concluded
    has_individual_spec: false
  - name: error-handling
    status: concluded
    has_individual_spec: false
  - name: rate-limiting
    status: in-progress
    has_individual_spec: false
concluded_count: 3
spec_count: 0
cache:
  status: "stale"
  reason: "Cache exists but checksums differ — discussions have changed"
  generated: "2026-01-20T10:00:00Z"
  anchored_names: []
```

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 7)

Stale cache, no specs → prompt for analysis with stale note.

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

**STOP.** Wait for user.

#### User responds: 1

### Step 4: Gather Analysis Context

Claude deletes the stale cache:
```bash
rm docs/workflow/.cache/discussion-consolidation-analysis.md
```

```
Before analyzing, is there anything about how these discussions relate
that would help me group them appropriately?

For example:
- Topics that are part of the same feature
- Dependencies between topics
- Topics that must stay separate

Your context (or 'none'):
```

**STOP.** Wait for user.

#### User responds: none

### Step 5: Analyze Discussions + Cache

Claude reads all 3 concluded discussions and forms groupings. Saves to cache.

### Step 6: Display Groupings (Output 6 format)

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. API Authentication
   └─ Spec: none
   └─ Discussions:
      ├─ auth-flow (ready)
      └─ api-design (ready)

2. Error Handling
   └─ Spec: none
   └─ Discussions:
      └─ error-handling (ready)

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

1. Start "API Authentication" — 2 ready discussions
2. Start "Error Handling" — 1 ready discussion
3. Re-analyze groupings

Enter choice (1-3):
```

Flow continues to Steps 7 → 8 → 9 as normal.

---

## Scenario B: User Chooses "Pick a Discussion Individually"

**Steps:** 0 → 1 → 2 → 3 → (pick) → 7 → 8 → 9

Steps 0-3 are identical to Scenario A.

#### User responds: 2 (Pick individually)

```
Which discussion would you like to specify?

1. auth-flow
2. api-design
3. error-handling

Enter choice (1-3):
```

**STOP.** Wait for user.

#### User responds: 3

### Step 7: Confirm Selection

```
Creating specification: Error Handling

Sources:
  • error-handling

Output: docs/workflow/specification/error-handling.md

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Gather Additional Context

(Standard prompt)

#### User responds: none

### Step 9: Invoke Skill

```
Specification session for: Error Handling

Sources:
- docs/workflow/discussion/error-handling.md

Output: docs/workflow/specification/error-handling.md

Additional context: None provided.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Note

This flow is functionally identical to Output 5 (no cache). The only difference is the initial message in Step 3 — it mentions the stale cache and that re-analysis is required, rather than describing what grouping analysis does. The user's choices and subsequent steps are the same.
