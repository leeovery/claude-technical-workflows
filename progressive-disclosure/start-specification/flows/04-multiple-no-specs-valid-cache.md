# Flow: Multiple Discussions, No Specs, Valid Cache (Output 6)

Groupings have been analyzed previously and discussions haven't changed. Show groupings immediately.

**Entry state:** 3 concluded discussions, 1 in-progress, 0 specs, valid cache with groupings

---

## Scenario A: User Picks a Grouping

**Steps:** 0 → 1 → 2 → 3 → 7 → 8

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
  status: "valid"
  reason: "Cache exists and checksums match"
  generated: "2026-01-25T10:00:00Z"
  anchored_names: []
```

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 6)

Valid cache, no specs → show groupings directly from cache.

Claude loads `docs/workflow/.state/discussion-consolidation-analysis.md` and presents:

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
3. Unify all into single specification
   All discussions are combined into one specification instead
   of following the recommended groupings.
4. Re-analyze groupings
   Current groupings are discarded and rebuilt. You can provide
   guidance on how to organize them in the next step.

Enter choice (1-4):
```

**STOP.** Wait for user.

#### User responds: 1

### Step 7: Confirm Selection

```
Creating specification: API Authentication

Sources:
  • auth-flow
  • api-design

Output: docs/workflow/specification/api-authentication.md

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: API Authentication

Sources:
- docs/workflow/discussion/auth-flow.md
- docs/workflow/discussion/api-design.md

Output: docs/workflow/specification/api-authentication.md

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario B: User Chooses "Re-analyze"

**Steps:** 0 → 1 → 2 → 3 → (re-analyze) → 4 → 5 → 6 → 7 → 8

Steps 0-3 are identical to Scenario A.

#### User responds: 4 (Re-analyze)

Claude deletes the cache:
```bash
rm docs/workflow/.state/discussion-consolidation-analysis.md
```

### Step 4: Gather Analysis Context

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

#### User responds: I'd like error-handling grouped with api-design instead, and auth-flow on its own.

### Step 5: Analyze Discussions + Cache

Claude re-reads discussions with new guidance. Saves updated cache.

### Step 6: Display Groupings

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. API Layer
   └─ Spec: none
   └─ Discussions:
      ├─ api-design (ready)
      └─ error-handling (ready)

2. Auth Flow
   └─ Spec: none
   └─ Discussions:
      └─ auth-flow (ready)

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

1. Start "API Layer" — 2 ready discussions
2. Start "Auth Flow" — 1 ready discussion
3. Unify all into single specification
   All discussions are combined into one specification instead
   of following the recommended groupings.
4. Re-analyze groupings
   Current groupings are discarded and rebuilt. You can provide
   guidance on how to organize them in the next step.

Enter choice (1-4):
```

Flow continues to Steps 7 → 8 as normal.
