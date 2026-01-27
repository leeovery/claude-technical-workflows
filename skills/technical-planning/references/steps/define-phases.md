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

> **To proceed, choose one:**
> - **"Approve"** — Phase structure is confirmed. I'll proceed to task breakdown.
> - **"Adjust"** — Tell me what to change: reorder, split, merge, add, or remove phases.

#### If Approved

→ Proceed to **Step 5**.

#### If Adjust

Incorporate feedback, re-present the updated phase structure, and ask again. Repeat until approved.
