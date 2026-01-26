# Flow: Multiple Discussions, With Specs, Valid Cache (Output 9)

The richest scenario — specs exist and groupings are cached and current. Full display with all statuses visible.

**Entry state:** 6 concluded discussions, 2 in-progress, 2 specs, valid cache with groupings

---

## Scenario A: User Picks a Grouping With Pending Sources

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
    has_individual_spec: true
    spec_status: in-progress
  - name: user-sessions
    status: concluded
    has_individual_spec: true
    spec_status: in-progress
  - name: oauth-integration
    status: concluded
    has_individual_spec: false
  - name: api-endpoints
    status: concluded
    has_individual_spec: false
  - name: error-handling
    status: concluded
    has_individual_spec: false
  - name: logging-strategy
    status: concluded
    has_individual_spec: false
  - name: caching-layer
    status: concluded
    has_individual_spec: true
    spec_status: concluded
  - name: rate-limiting
    status: in-progress
    has_individual_spec: false
  - name: webhook-design
    status: in-progress
    has_individual_spec: false
concluded_count: 7
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
  status: "valid"
  reason: "Cache exists and checksums match"
  generated: "2026-01-25T10:00:00Z"
  anchored_names:
    - authentication-system
    - caching-layer
```

Cache file contains groupings:
- **Authentication System**: auth-flow, user-sessions, oauth-integration
- **API Design**: api-endpoints, error-handling
- **Logging Strategy**: logging-strategy
- **Caching Layer**: caching-layer

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 9)

Valid cache + specs → show groupings with full status.

Claude cross-references the cache groupings with spec `sources` arrays:
- Authentication System grouping has 3 discussions, but spec only has auth-flow and user-sessions as sources (both incorporated). oauth-integration is in the grouping but not in the spec's sources → status: pending. Effective spec status: "needs update" but we show the count format instead.

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
6. Re-analyze groupings

Enter choice (1-6):
```

**STOP.** Wait for user.

#### User responds: 1

### Step 7: Confirm Selection

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

**STOP.** Wait for user.

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: Authentication System

Continuing existing: docs/workflow/specification/authentication-system.md

Sources for reference:
- docs/workflow/discussion/auth-flow.md
- docs/workflow/discussion/user-sessions.md
- docs/workflow/discussion/oauth-integration.md

Context: This specification already exists. Review and refine it based on the source discussions.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario B: User Starts a New Spec From Grouping

**Steps:** 0 → 1 → 2 → 3 → 7 → 8

Steps 0-3 identical to Scenario A.

#### User responds: 2 (Start "API Design")

### Step 7: Confirm Selection

```
Creating specification: API Design

Sources:
  • api-endpoints
  • error-handling

Output: docs/workflow/specification/api-design.md

Proceed? (y/n)
```

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: API Design

Sources:
- docs/workflow/discussion/api-endpoints.md
- docs/workflow/discussion/error-handling.md

Output: docs/workflow/specification/api-design.md

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario C: User Refines a Concluded Spec

**Steps:** 0 → 1 → 2 → 3 → 7 → 8

Steps 0-3 identical to Scenario A.

#### User responds: 4 (Refine "Caching Layer")

### Step 7: Confirm Selection

```
Refining specification: Caching Layer

Existing: docs/workflow/specification/caching-layer.md (concluded)

All sources extracted:
  • caching-layer

Proceed? (y/n)
```

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: Caching Layer

Continuing existing: docs/workflow/specification/caching-layer.md

Sources for reference:
- docs/workflow/discussion/caching-layer.md

Context: This specification already exists. Review and refine it based on the source discussions.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario D: User Re-analyzes

**Steps:** 0 → 1 → 2 → 3 → (re-analyze) → 4 → 5 → 6 → 7 → 8

Steps 0-3 identical to Scenario A.

#### User responds: 6 (Re-analyze)

Claude deletes the cache:
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

#### User responds: I'd like to combine api-endpoints, error-handling, and logging-strategy into one "API Infrastructure" group. Auth and caching can stay as they are.

### Step 5: Analyze Discussions + Cache

Claude re-reads discussions with guidance. Preserves anchored names (authentication-system, caching-layer). Creates new grouping for API Infrastructure. Saves updated cache.

### Step 6: Display Groupings

```
Specification Overview

Recommended breakdown for specifications with their source discussions.

1. Authentication System
   └─ Spec: in-progress (2 of 3 sources extracted)
   └─ Discussions:
      ├─ auth-flow (extracted)
      ├─ user-sessions (extracted)
      └─ oauth-integration (pending)

2. API Infrastructure
   └─ Spec: none
   └─ Discussions:
      ├─ api-endpoints (ready)
      ├─ error-handling (ready)
      └─ logging-strategy (ready)

3. Caching Layer
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
2. Start "API Infrastructure" — 3 ready discussions
3. Refine "Caching Layer" — concluded spec
4. Unify all into single specification
5. Re-analyze groupings

Enter choice (1-5):
```

Flow continues to Steps 7 → 8 as normal.

---

## Scenario E: User Chooses "Unify All"

**Steps:** 0 → 1 → 2 → 3 → (unify) → 7 → 8

Steps 0-3 identical to Scenario A.

#### User responds: 5 (Unify all into single specification)

Claude updates the cache to reflect a single unified grouping containing all concluded discussions.

### Step 7: Confirm Selection

```
Creating specification: Unified

Sources:
  • auth-flow
  • user-sessions
  • oauth-integration
  • api-endpoints
  • error-handling
  • logging-strategy
  • caching-layer

Existing specifications to incorporate:
  • authentication-system.md → will be superseded
  • caching-layer.md → will be superseded

Output: docs/workflow/specification/unified.md

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: Unified

Source discussions:
- docs/workflow/discussion/auth-flow.md
- docs/workflow/discussion/user-sessions.md
- docs/workflow/discussion/oauth-integration.md
- docs/workflow/discussion/api-endpoints.md
- docs/workflow/discussion/error-handling.md
- docs/workflow/discussion/logging-strategy.md
- docs/workflow/discussion/caching-layer.md

Existing specifications to incorporate:
- docs/workflow/specification/authentication-system.md
- docs/workflow/specification/caching-layer.md

Output: docs/workflow/specification/unified.md

Context: This consolidates all discussions into a single unified specification. The existing specifications should be incorporated - extract and adapt their content alongside the discussion material.

After the unified specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: unified

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario F: User Re-analyzes From Step 6

**Steps:** ... → 6 → (re-analyze) → 4 → 5 → 6

This shows that re-analyze is also available from Step 6 (post-analysis display), not just Step 3. The flow is identical: delete cache → Step 4 → Step 5 → Step 6.

If the user sees the groupings in Step 6 after a fresh analysis and wants to restructure further, they choose "Re-analyze" again and the cycle repeats.

---

## Scenario G: New Grouped Spec Supersedes Individual Spec

**Steps:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

This shows what happens when a grouping includes a discussion that already has its own individual spec.

**Entry state:** Suppose the discovery reveals auth-flow has an individual spec `auth-flow.md` (not the grouped `authentication-system.md`). The grouping analysis recommends combining auth-flow with api-design.

After analysis, Step 6 shows:

```
1. API Authentication
   └─ Spec: none
   └─ Discussions:
      ├─ auth-flow (ready)
      └─ api-design (ready)
```

#### User responds: 1 (Start "API Authentication")

### Step 7: Confirm Selection

```
Creating specification: API Authentication

Sources:
  • auth-flow (has individual spec — will be incorporated)
  • api-design

Output: docs/workflow/specification/api-authentication.md

After completion:
  specification/auth-flow.md → marked as superseded

Proceed? (y/n)
```

**STOP.** Wait for user.

#### User responds: y

### Step 8: Invoke Skill

```
Specification session for: API Authentication

Source discussions:
- docs/workflow/discussion/auth-flow.md
- docs/workflow/discussion/api-design.md

Existing specifications to incorporate:
- docs/workflow/specification/auth-flow.md (covers: auth-flow discussion)

Output: docs/workflow/specification/api-authentication.md

Context: This consolidates multiple sources. The existing auth-flow.md specification should be incorporated - extract and adapt its content alongside the discussion material. The result should be a unified specification, not a simple merge.

After the api-authentication specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: api-authentication

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.
