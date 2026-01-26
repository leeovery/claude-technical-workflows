# Flow: Multiple Discussions, With Specs, Stale Cache (Output 10)

Specs exist and cache exists but is outdated. Show existing specs from frontmatter, recommend re-analysis.

**Entry state:** 5 concluded discussions, 1 in-progress, 2 specs, stale cache

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
  status: "stale"
  reason: "Cache exists but checksums differ — discussions have changed"
  generated: "2026-01-20T10:00:00Z"
  anchored_names:
    - authentication-system
    - caching-layer
```

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 10)

Specs exist, stale cache → show specs from frontmatter, recommend re-analysis. Stale cache is NOT used for display.

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
A previous grouping analysis exists but is outdated — discussions
have changed since it was created. Re-analysis is required.

1. Analyze for groupings (recommended)
2. Continue "Authentication System" — in-progress
3. Continue "Caching Layer" — concluded

Enter choice (1-3):
```

**STOP.** Wait for user.

#### User responds: 1

Claude deletes the stale cache:
```bash
rm docs/workflow/.cache/discussion-consolidation-analysis.md
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

#### User responds: none

### Step 5: Analyze Discussions + Cache

Claude reads all 5 concluded discussions. Preserves anchored names (authentication-system, caching-layer). Forms groupings. Saves new cache.

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

Flow continues to Steps 7 → 8 as normal.

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

## Note

This flow is functionally identical to Output 8 (no cache). The only difference is Step 3's message about the stale cache. In both cases, existing specs are shown from frontmatter data (not cache), unassigned discussions are listed flat, and the same menu options are offered. The stale cache is never used for display.
