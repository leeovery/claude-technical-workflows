# Flow: Multiple Discussions, No Specs, No Cache (Output 5)

First time running specification with multiple discussions and no prior analysis.

**Entry state:** 3 concluded discussions, 1 in-progress, 0 specs, no cache

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
  status: "none"
  reason: "No cache file exists"
```

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 5)

Multiple concluded, no specs, no cache → prompt for analysis.

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

**STOP.** Wait for user.

#### User responds: 1

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
3. Re-analyze groupings

Enter choice (1-3):
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

### Step 8: Gather Additional Context

```
Before invoking the specification skill:

1. Any additional context or priorities to consider?
2. Any constraints or changes since the discussion(s) concluded?
3. Are there existing partial implementations or related documentation I should review?

(Say 'none' or 'continue' if nothing to add)
```

**STOP.** Wait for user.

#### User responds: none

### Step 9: Invoke Skill

```
Specification session for: API Authentication

Sources:
- docs/workflow/discussion/auth-flow.md
- docs/workflow/discussion/api-design.md

Output: docs/workflow/specification/api-authentication.md

Additional context: None provided.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

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

#### User responds: 2

### Step 7: Confirm Selection

```
Creating specification: Api Design

Sources:
  • api-design

Output: docs/workflow/specification/api-design.md

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Gather Additional Context

(Same prompt as Scenario A)

#### User responds: none

### Step 9: Invoke Skill

```
Specification session for: Api Design

Sources:
- docs/workflow/discussion/api-design.md

Output: docs/workflow/specification/api-design.md

Additional context: None provided.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario C: User Chooses "Re-analyze" from Step 6

**Steps:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → (re-analyze) → 4 → 5 → 6

Steps 0-6 are identical to Scenario A.

#### User responds: 3 (Re-analyze)

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

#### User responds: Actually, keep all three together as one unified API specification.

### Step 5: Analyze Discussions + Cache

Claude re-reads discussions with new guidance. Produces updated groupings:

```markdown
### Unified API
- **auth-flow**: Authentication mechanisms
- **api-design**: API structure and endpoints
- **error-handling**: Error handling across the API

**Coupling**: User requested all three combined into a single API specification.
```

### Step 6: Display Groupings

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. Unified API
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
Tip: To restructure groupings or pull a discussion into its own
specification, choose "Re-analyze" and provide guidance.

---
What would you like to do?

1. Start "Unified API" — 3 ready discussions
2. Re-analyze groupings

Enter choice (1-2):
```

Flow continues to Steps 7 → 8 → 9 as normal.
