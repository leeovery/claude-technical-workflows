# Define Phases

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[phase-design.md](../phase-design.md)** — the principles for structuring phases as independently valuable, testable increments built on a walking skeleton.

---

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

**STOP.** Present your proposed phase structure and ask:

> **To proceed:**
> - **`y`/`yes`** — Approved. I'll proceed to task breakdown.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove phases.

#### If the user provides feedback

Incorporate feedback, re-present the updated phase structure, and ask again. Repeat until approved.

#### If approved

Update progress files and commit:

1. Update `phases.md`: set `status: approved` and `approved_at: {today}`
2. Update `progress.md`: mark Step 4 complete
3. Commit: `planning({topic}): approve phase structure`

→ Proceed to **Step 5**.

---

## Progress Tracking

**On first entry to Step 4**, create the progress directory and files:

1. Create `docs/workflow/planning/.progress/{topic}/`
2. Write `progress.md` with current state (step 4, status in-progress)
3. Write `phases.md` with `status: draft` containing your proposed phases
4. Commit: `planning({topic}): initialize progress tracking`

**On adjustment** (user requests changes):

1. Update `phases.md` with the revised proposal (keep `status: draft`)
2. Commit if significant changes: `planning({topic}): revise phase structure`
