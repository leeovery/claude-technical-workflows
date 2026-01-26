# Flow: Multiple Discussions, No Specs, No Cache (Output 5)

First time running specification with multiple discussions and no prior analysis. Auto-proceeds to analysis.

**Entry state:** 3 concluded discussions, 1 in-progress, 0 specs, no cache

---

## Scenario A: User Confirms Analysis → Picks Grouping

**Steps:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

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
  status: "none"
  reason: "No cache file exists"
```

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 5)

Multiple concluded, no specs, no cache → auto-proceed to analysis.

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

**STOP.** Wait for user.

#### User responds: y

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

#### User responds: auth-flow and api-design are closely related — the API uses the auth system. error-handling is cross-cutting.

### Step 5: Analyze Discussions + Cache

Claude reads all 3 concluded discussion files, considers the user's context, and forms groupings.

```
Analyzing discussions...
```

Analysis result — writes to `docs/workflow/.cache/discussion-consolidation-analysis.md`:
```markdown
---
checksum: abc123...
generated: 2026-01-26T14:30:00Z
discussion_files:
  - auth-flow.md
  - api-design.md
  - error-handling.md
---

# Discussion Consolidation Analysis

## Recommended Groupings

### API Authentication
- **auth-flow**: Defines authentication mechanisms used by the API layer
- **api-design**: Defines API structure, endpoints, and request/response patterns

**Coupling**: auth-flow defines the security model that api-design depends on. Both define aspects of the public API surface.

## Independent Discussions
- **error-handling**: Cross-cutting concern that applies across all systems. No strong coupling to a specific group.

## Analysis Notes
User noted auth-flow and api-design are closely related. error-handling is cross-cutting — stands alone.
```

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
3. Unify all into single specification
4. Re-analyze groupings

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

## Scenario B: User Chooses "Unify All" from Step 6

**Steps:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → (unify) → 7 → 8

Steps 0-6 are identical to Scenario A.

#### User responds: 3 (Unify all into single specification)

Claude updates the cache to reflect a single unified grouping containing all concluded discussions.

### Step 7: Confirm Selection

```
Creating specification: Unified

Sources:
  • auth-flow
  • api-design
  • error-handling

Output: docs/workflow/specification/unified.md

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: Unified

Sources:
- docs/workflow/discussion/auth-flow.md
- docs/workflow/discussion/api-design.md
- docs/workflow/discussion/error-handling.md

Output: docs/workflow/specification/unified.md

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

**On re-entry:** Cache shows single unified grouping. Display will show:
```
1. Unified
   └─ Spec: in-progress (0 of 3 sources extracted)
   └─ Discussions:
      ├─ auth-flow (pending)
      ├─ api-design (pending)
      └─ error-handling (pending)
```
Since there's only 1 grouping, "Unify" option is not shown in the menu.

---

## Scenario C: User Chooses "Re-analyze" from Step 6

**Steps:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → (re-analyze) → 4 → 5 → 6

Steps 0-6 are identical to Scenario A.

#### User responds: 4 (Re-analyze)

Claude deletes the cache:
```bash
rm docs/workflow/.cache/discussion-consolidation-analysis.md
```

Loops back to Step 4:

### Step 4: Gather Analysis Context (again)

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

#### User responds: Actually, keep all three together as one API specification.

### Step 5: Analyze Discussions + Cache

Claude re-reads discussions with new guidance. Produces updated groupings.

### Step 6: Display Groupings

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. API Platform
   └─ Spec: none
   └─ Discussions:
      ├─ auth-flow (ready)
      ├─ api-design (ready)
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
What would you like to do?

1. Start "API Platform" — 3 ready discussions
2. Re-analyze groupings

Enter choice (1-2):
```

**Note:** Only 1 grouping exists, so "Unify" option is not shown. No tip about restructuring either since re-analyze is already visible.

Flow continues to Steps 7 → 8 as normal.

---

## Scenario D: User Declines Analysis at Step 3

**Steps:** 0 → 1 → 2 → 3 (STOP)

Steps 0-3 identical to Scenario A up to the confirmation.

#### User responds: n

```
Understood. You can run /start-discussion to continue working on
discussions, or re-run this command when ready.
```

**Command ends.** Control returns to the user.
