# Flow: Block Scenarios (Outputs 1–2)

These are terminal paths — the command stops and cannot proceed.

---

## Scenario A: No Discussions Exist

**Entry state:** No discussion files in `.workflows/discussion/`

**Steps:** 0 → 1 → 2 (STOP)

### Step 0: Run Migrations

```
[SKIP] No changes needed
```

### Step 1: Run Discovery

Discovery returns:
```yaml
discussions: []
concluded_count: 0
spec_count: 0
cache:
  status: "none"
```

### Step 2: Check Prerequisites — BLOCKED

```
Specification Phase

No discussions found.

The specification phase requires concluded discussions to work from.
Discussions capture the technical decisions, edge cases, and rationale
that specifications are built upon.

Run /start-discussion to begin documenting technical decisions.
```

**STOP.** Wait for user acknowledgment. Command ends here.

---

## Scenario B: Discussions Exist But None Concluded

**Entry state:** 2 discussions, both in-progress

**Steps:** 0 → 1 → 2 (STOP)

### Step 0: Run Migrations

```
[SKIP] No changes needed
```

### Step 1: Run Discovery

Discovery returns:
```yaml
discussions:
  - name: rate-limiting
    status: in-progress
    has_individual_spec: false
  - name: webhook-design
    status: in-progress
    has_individual_spec: false
concluded_count: 0
spec_count: 0
cache:
  status: "none"
```

### Step 2: Check Prerequisites — BLOCKED

```
Specification Phase

No concluded discussions found.

The following discussions are still in progress:
  · rate-limiting (in-progress)
  · webhook-design (in-progress)

Specifications can only be created from concluded discussions.
Run /start-discussion to continue working on a discussion.
```

**STOP.** Wait for user acknowledgment. Command ends here.
