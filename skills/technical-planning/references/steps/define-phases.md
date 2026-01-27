# Define Phases

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[phase-design.md](../phase-design.md)** — the principles for structuring phases as independently valuable, testable increments built on a walking skeleton.

---

Orient the user:

> "I've read the full specification. I'm going to propose a phase structure — how we break this into independently testable stages. Once we agree on the phases, we'll take each one and break it into tasks."

With the full specification understood, break it into logical phases. Understanding what tasks belong in each phase is necessary to determine the right ordering. Consider the natural dependencies between areas of functionality — what must exist before something else can be built. This informs both phase boundaries and phase sequence.

Present the proposed phase structure using this format:

```
Phase {N}: {Phase Name}
  Goal: {What this phase accomplishes}
  Why this order: {Why this phase comes at this position in the sequence}
  Acceptance criteria:
    - [ ] {First verifiable criterion}
    - [ ] {Second verifiable criterion}
```

**Example:**

```
Phase 1: Foundation — Event Model and Storage
  Goal: Establish the core data model and persistence layer for calendar events
  Why this order: All subsequent phases depend on events being storable and retrievable
  Acceptance criteria:
    - [ ] Events can be created with required fields (title, start, end)
    - [ ] Events persist to the database and can be retrieved by ID
    - [ ] Validation rejects events with missing required fields

Phase 2: Core — Recurring Events
  Goal: Support recurring event patterns (daily, weekly, monthly)
  Why this order: Recurrence extends the event model from Phase 1
  Acceptance criteria:
    - [ ] Events can be created with a recurrence rule
    - [ ] Recurring instances are generated correctly for a given date range
    - [ ] Editing a single instance does not affect other instances
```

**STOP.** Present your proposed phase structure and ask:

> **To proceed, choose one:**
> - **"Approve"** — Phase structure is confirmed. I'll proceed to task breakdown.
> - **"Adjust"** — Tell me what to change: reorder, split, merge, add, or remove phases.

#### If Approved

→ Proceed to **Step 5**.

#### If Adjust

Incorporate feedback, re-present the updated phase structure, and ask again. Repeat until approved.
