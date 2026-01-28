# Define Phases

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[phase-design.md](../phase-design.md)** — the principles for structuring phases as independently valuable, testable increments built on a walking skeleton.

---

## Check for Existing Phases

Read the plan index file. Check if phases already exist in the body.

**If phases exist with `status: approved`:**
- Present them to the user for review (deterministic replay)
- User can approve (`y`), amend, or navigate (`skip to {X}`)
- If amended, flag downstream content for review
- Once approved (or skipped), proceed to Step 5

**If phases exist with `status: draft`:**
- Present the draft for review/approval
- Continue the approval flow below

**If no phases exist:**
- Continue with fresh phase design below

---

## Fresh Phase Design

Orient the user:

> "I've read the full specification. I'm going to propose a phase structure — how we break this into independently testable stages. Once we agree on the phases, we'll take each one and break it into tasks."

With the full specification understood, break it into logical phases. Understanding what tasks belong in each phase is necessary to determine the right ordering.

Present the proposed phase structure using this format:

```
Phase {N}: {Phase Name}
  Goal: {What this phase accomplishes}
  Why this order: {Why this phase comes at this position in the sequence}
  Acceptance criteria:
    - [ ] {First verifiable criterion}
    - [ ] {Second verifiable criterion}
```

Write the phases directly to the plan index file body:

```markdown
## Phases

### Phase 1: {Phase Name}
status: draft

**Goal**: {What this phase accomplishes}
**Why this order**: {Why this comes at this position}

**Acceptance**:
- [ ] {First verifiable criterion}
- [ ] {Second verifiable criterion}

### Phase 2: {Phase Name}
status: draft
...
```

Update the frontmatter `planning:` block:
```yaml
planning:
  phase: 1
  task: ~
```

Commit: `planning({topic}): draft phase structure`

Then present to the user.

**STOP.** Ask:

> **To proceed:**
> - **`y`/`yes`** — Approved. I'll proceed to task breakdown.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove phases.

#### If the user provides feedback

Incorporate feedback, update the phases in the plan index, re-present the updated phase structure, and ask again. Repeat until approved.

#### If approved

1. Update each phase in the plan index: set `status: approved` and `approved_at: YYYY-MM-DD` (use today's actual date)
2. Update `planning:` block in frontmatter to note current position
3. Commit: `planning({topic}): approve phase structure`

→ Proceed to **Step 5**.
