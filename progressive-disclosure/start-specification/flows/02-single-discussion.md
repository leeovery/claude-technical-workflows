# Flow: Single Concluded Discussion (Outputs 3–4)

Auto-proceed paths — only one concluded discussion exists, so no selection menu is needed.

---

## Scenario A: Single Discussion, No Spec

**Entry state:** 1 concluded discussion (auth-flow), 1 in-progress, no specs

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
Automatically proceeding with "Auth Flow".
```

Step 3 auto-proceeds — no prompt needed since Step 7 immediately follows.

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

### Step 8: Invoke Skill

Handoff to technical-specification skill:
```
Specification session for: Auth Flow

Sources:
- docs/workflow/discussion/auth-flow.md

Output: docs/workflow/specification/auth-flow.md

---
Invoke the technical-specification skill.
```

**Command complete.** Skill takes over.

---

#### Alternate: User declines at Step 7

**User responds: n**

```
Understood. You can run /start-discussion to continue working on
discussions, or re-run this command when ready.
```

**Command ends.** Control returns to the user.

---

## Scenario B: Single Discussion, Has Spec (In-Progress)

**Entry state:** 1 concluded discussion (auth-flow), spec exists (in-progress)

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
Automatically proceeding with "Auth Flow".
```

Step 3 auto-proceeds — no prompt needed since Step 7 immediately follows.

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

### Step 8: Invoke Skill

Handoff to technical-specification skill:
```
Specification session for: Auth Flow

Continuing existing: docs/workflow/specification/auth-flow.md

Sources for reference:
- docs/workflow/discussion/auth-flow.md

Context: This specification already exists. Review and refine it based on the source discussions.

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
Automatically proceeding with "Auth Flow".
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
