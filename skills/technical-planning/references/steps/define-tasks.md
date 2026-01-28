# Define Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[task-design.md](../task-design.md)** — the principles for breaking phases into well-scoped, vertically-sliced tasks.

---

## Check for Existing Task Tables

Read the plan index file. Check the task table under each phase.

**For each phase with an existing task table:**
- If all tasks show `status: authored` → skip to next phase
- If task table exists but not all approved → present for review (deterministic replay)
- User can approve (`y`), amend, or navigate (`skip to {X}`)

**If resuming:** Use the `planning:` block to determine which phase to continue with.

**If all phases have approved task tables:** → Proceed to Step 6.

**If no task table for current phase:** Continue with fresh task design below.

---

## Fresh Task Design

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

Write the task table directly to the plan index, under the phase:

```markdown
#### Tasks
| ID | Name | Edge Cases | Status |
|----|------|------------|--------|
| {id} | {Task Name} | {list} | pending |
| {id} | {Task Name} | {list} | pending |
```

The ID format depends on the output format:
- **local-markdown**: `{topic}-{phase}-{seq}` (e.g., `auth-1-1`, `auth-1-2`)
- **linear/beads/backlog-md**: Will be assigned when task is authored to external system

Update the frontmatter `planning:` block:
```yaml
planning:
  phase: {N}
  task: ~
```

Commit: `planning({topic}): draft Phase {N} task list`

Then present to the user.

**STOP.** Ask:

> **To proceed:**
> - **`y`/`yes`** — Approved. I'll begin writing full task detail.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove tasks.

#### If the user provides feedback

Incorporate feedback, update the task table in the plan index, re-present the updated overview, and ask again. Repeat until approved.

#### If approved

1. Update the `planning:` block to note task authoring is starting
2. Commit: `planning({topic}): approve Phase {N} task list`

→ Proceed to **Step 6**.
