# Define Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[task-design.md](../task-design.md)** — the principles for breaking phases into well-scoped, vertically-sliced tasks.

---

Orient the user:

> "Taking Phase {N}: {Phase Name} and breaking it into tasks. Here's the overview — once we agree on the list, I'll write each task out in full detail."

Take the first (or next) phase and break it into tasks. Present a high-level overview so the user can see the shape of the phase before committing to the detail of each task.

Present the task overview using this format:

```
Phase {N}: {Phase Name}

  1. {Task Name} — {One-line summary}
     Edge cases: {comma-separated list, or "none"}

  2. {Task Name} — {One-line summary}
     Edge cases: {comma-separated list, or "none"}
```

This overview establishes the scope and ordering. The user should be able to see whether the phase is well-structured, whether tasks are in the right order, and whether anything is missing or unnecessary — before investing time in writing out full task detail.

**STOP.** Present the phase task overview and ask:

> **To proceed:**
> - **`y`/`yes`** — Approved. I'll begin writing full task detail.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove tasks.

#### If the user provides feedback

Incorporate feedback, re-present the updated task overview, and ask again. Repeat until approved.

#### If approved

Update progress files and commit:

1. Update `tasks.md`: set `overview_status: approved` for this phase
2. Update `progress.md`: note Phase N tasks approved
3. Commit: `planning({topic}): approve Phase {N} task overview`

→ Proceed to **Step 6**.

---

## Progress Tracking

**On first entry for a phase**, add the phase section to `tasks.md`:

1. Add phase header with `overview_status: pending`
2. Add task list with each task showing `transfer: pending`
3. Commit: `planning({topic}): propose Phase {N} tasks`

**On adjustment** (user requests changes):

1. Update the task list in `tasks.md` (keep `overview_status: pending`)
2. Commit if significant changes: `planning({topic}): revise Phase {N} tasks`

**On approval** (user approves with `y`/`yes`):

1. Update `tasks.md`: set `overview_status: approved` for this phase
2. Update `progress.md`: note which phases have approved overviews
3. Commit: `planning({topic}): approve Phase {N} task overview`
