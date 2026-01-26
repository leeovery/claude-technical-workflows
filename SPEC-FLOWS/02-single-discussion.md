# Flow: Single Concluded Discussion (Outputs 3–4)

Auto-proceed paths — only one concluded discussion exists, so no selection menu is needed.

---

## Scenario A: Single Discussion, No Spec

**Entry state:** 1 concluded discussion (auth-flow), 1 in-progress, no specs

**Steps:** 0 → 1 → 2 → 3 → 7 → 8 → 9

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
  - name: rate-limiting
    status: in-progress
    has_individual_spec: false
concluded_count: 1
spec_count: 0
cache:
  status: "none"
```

### Step 2: Check Prerequisites — Passes

At least one concluded discussion exists.

### Step 3: Route and Display (Output 3)

Single concluded discussion, no spec → auto-proceed.

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

**STOP.** Wait for user.

#### User responds: y

### Step 7: Confirm Selection

```
Creating specification: Auth Flow

Sources:
  • auth-flow

Output: docs/workflow/specification/auth-flow.md

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

Handoff to technical-specification skill:
```
Specification session for: Auth Flow

Sources:
- docs/workflow/discussion/auth-flow.md

Output: docs/workflow/specification/auth-flow.md

Additional context: None provided.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

#### Alternate: User declines at Step 3

**User responds: n**

```
What would you like to do instead?
```

**STOP.** Wait for user. They may exit or provide alternative direction.

---

## Scenario B: Single Discussion, Has Spec (In-Progress)

**Entry state:** 1 concluded discussion (auth-flow), spec exists (in-progress)

**Steps:** 0 → 1 → 2 → 3 → 7 → 8 → 9

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
concluded_count: 1
spec_count: 1
specifications:
  - name: auth-flow
    status: in-progress
    sources:
      - name: auth-flow
        status: incorporated
cache:
  status: "none"
```

### Step 2: Check Prerequisites — Passes

### Step 3: Route and Display (Output 4)

Single concluded discussion with existing spec → auto-proceed to continue.

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

**STOP.** Wait for user.

#### User responds: y

### Step 7: Confirm Selection

```
Continuing specification: Auth Flow

Existing: docs/workflow/specification/auth-flow.md (in-progress)

All sources extracted:
  • auth-flow

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

#### User responds: Focus on the edge cases around token expiry.

### Step 9: Invoke Skill

Handoff to technical-specification skill:
```
Specification session for: Auth Flow

Continuing existing: docs/workflow/specification/auth-flow.md

Sources for reference:
- docs/workflow/discussion/auth-flow.md

Context: This specification already exists. Review and refine it based on the source discussions and any new context provided.

Additional context: Focus on the edge cases around token expiry.

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

## Scenario C: Single Discussion, Has Spec (Concluded)

**Entry state:** 1 concluded discussion (auth-flow), spec exists (concluded)

**Steps:** Same as Scenario B but spec status is concluded.

### Step 3: Route and Display (Output 4 variant)

```
Specification Overview

Single concluded discussion found with existing specification.

1. Auth Flow
   └─ Spec: concluded (1 of 1 sources extracted)
   └─ Discussions:
      └─ auth-flow (extracted)

---
Key:

  Discussion status:
    extracted — content has been incorporated into the specification

  Spec status:
    concluded — specification is complete

---
Proceeding with "Auth Flow".

Continue refining this specification? (y/n)
```

### Step 7: Confirm Selection

```
Refining specification: Auth Flow

Existing: docs/workflow/specification/auth-flow.md (concluded)

All sources extracted:
  • auth-flow

Proceed? (y/n)
```

Rest of flow identical to Scenario B.
