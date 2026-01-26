# Flow: Multiple Discussions, With Specs, No Cache (Output 8)

Specs exist but no grouping analysis has been done. Show existing specs, offer analysis.

**Entry state:** 5 concluded discussions, 1 in-progress, 2 specs, no cache

---

## Scenario A: User Chooses "Analyze for Groupings"

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
    has_individual_spec: true
    spec_status: in-progress
  - name: user-sessions
    status: concluded
    has_individual_spec: true
    spec_status: in-progress
  - name: caching-layer
    status: concluded
    has_individual_spec: true
    spec_status: concluded
  - name: api-design
    status: concluded
    has_individual_spec: false
  - name: error-handling
    status: concluded
    has_individual_spec: false
  - name: rate-limiting
    status: in-progress
    has_individual_spec: false
concluded_count: 5
spec_count: 2
specifications:
  - name: authentication-system
    status: in-progress
    sources:
      - name: auth-flow
        status: incorporated
      - name: user-sessions
        status: incorporated
  - name: caching-layer
    status: concluded
    sources:
      - name: caching-layer
        status: incorporated
cache:
  status: "none"
  reason: "No cache file exists"
```

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 8)

Specs exist, no cache → show specs, recommend analysis.

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

Enter choice (1-3):
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

#### User responds: api-design and error-handling go together. The auth and caching specs are fine as they are.

### Step 5: Analyze Discussions + Cache

Claude reads all 5 concluded discussions. Considers existing specs and user context. Forms groupings preserving existing spec names (anchored names will apply on subsequent runs).

Cache written to `docs/workflow/.cache/discussion-consolidation-analysis.md`:
```markdown
---
checksum: def456...
generated: 2026-01-26T15:00:00Z
discussion_files:
  - auth-flow.md
  - user-sessions.md
  - caching-layer.md
  - api-design.md
  - error-handling.md
---

# Discussion Consolidation Analysis

## Recommended Groupings

### Authentication System
- **auth-flow**: Core authentication mechanisms
- **user-sessions**: Session management tied to auth

**Coupling**: Existing spec covers both. User confirmed this grouping is correct.

### API Design
- **api-design**: API structure and endpoints
- **error-handling**: Error handling patterns for the API

**Coupling**: User requested these be combined.

### Caching Layer
- **caching-layer**: Caching strategies and invalidation

**Coupling**: Standalone topic with completed spec. User confirmed this is correct.

## Analysis Notes
User confirmed existing specs (Authentication System, Caching Layer) are correctly scoped. api-design and error-handling grouped per user guidance.
```

### Step 6: Display Groupings (Output 9 format)

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. Authentication System
   └─ Spec: in-progress (2 of 2 sources extracted)
   └─ Discussions:
      ├─ auth-flow (extracted)
      └─ user-sessions (extracted)

2. API Design
   └─ Spec: none
   └─ Discussions:
      ├─ api-design (ready)
      └─ error-handling (ready)

3. Caching Layer
   └─ Spec: concluded (1 of 1 sources extracted)
   └─ Discussions:
      └─ caching-layer (extracted)

---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · rate-limiting (in-progress)

---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification
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

1. Continue "Authentication System" — all sources extracted
2. Start "API Design" — 2 ready discussions
3. Refine "Caching Layer" — concluded spec
4. Unify all into single specification
5. Re-analyze groupings

Enter choice (1-5):
```

**STOP.** Wait for user.

#### User responds: 2

### Step 7: Confirm Selection

```
Creating specification: API Design

Sources:
  • api-design
  • error-handling

Output: docs/workflow/specification/api-design.md

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: API Design

Sources:
- docs/workflow/discussion/api-design.md
- docs/workflow/discussion/error-handling.md

Output: docs/workflow/specification/api-design.md

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario B: User Chooses "Continue Existing Spec"

**Steps:** 0 → 1 → 2 → 3 → 7 → 8

Steps 0-3 identical to Scenario A.

#### User responds: 2 (Continue "Authentication System")

### Step 7: Confirm Selection

```
Continuing specification: Authentication System

Existing: docs/workflow/specification/authentication-system.md (in-progress)

All sources extracted:
  • auth-flow
  • user-sessions

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: Authentication System

Continuing existing: docs/workflow/specification/authentication-system.md

Sources for reference:
- docs/workflow/discussion/auth-flow.md
- docs/workflow/discussion/user-sessions.md

Context: This specification already exists. Review and refine it based on the source discussions.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario C: User Declines at Confirm

**Steps:** 0 → 1 → 2 → 3 → 7 → (decline) → back to 3

Steps 0-3 identical. User picks option 2 (Continue "Authentication System").

### Step 7: Confirm Selection

```
Continuing specification: Authentication System

Existing: docs/workflow/specification/authentication-system.md (in-progress)

All sources extracted:
  • auth-flow
  • user-sessions

Proceed? (y/n)
```

#### User responds: n

Returns to Step 3 display (same output as before). User can make a different choice.

```
Specification Overview

5 concluded discussions found. 2 specifications exist.

...same Output 8 display...

Enter choice (1-3):
```

**STOP.** Wait for user to make a different selection.
