# Define Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

This step uses the `planning-task-designer` agent (`.claude/agents/planning-task-designer.md`) to break phases into task lists. You invoke the agent per phase, present its output, and handle the approval gate.

---

## Check for Existing Task Tables

Read the Plan Index File. Check the task table under each phase.

**For each phase with an existing task table:**
- If all tasks show `status: authored` → skip to next phase
- If task table exists but not all approved → present for review (deterministic replay)
- User can approve (`y`), amend, or navigate (`skip to {X}`)

Walk through each phase in order, presenting existing task tables for review before moving to phases that need fresh work.

**If all phases have approved task tables:** → Proceed to Step 6.

**If no task table for current phase:** Continue with fresh task design below.

---

## Fresh Task Design

Orient the user:

> "Taking Phase {N}: {Phase Name} and breaking it into tasks. I'll delegate this to a specialist agent that will read the full specification and propose a task list. Once we agree on the list, I'll write each task out in full detail."

### Invoke the Agent

Invoke `planning-task-designer` with these file paths:

1. **read-specification.md**: `.claude/skills/technical-planning/references/read-specification.md`
2. **Specification**: path from the Plan Index File's `specification:` field
3. **Cross-cutting specs**: paths from the Plan Index File's `cross_cutting_specs:` field (if any)
4. **task-design.md**: `.claude/skills/technical-planning/references/task-design.md`
5. **All approved phases**: the complete phase structure from the Plan Index File body
6. **Target phase number**: the phase being broken into tasks

### Present the Output

The agent returns a task overview and task table. Write the task table directly to the Plan Index File under the phase.

Update the frontmatter `planning:` block:
```yaml
planning:
  phase: {N}
  task: ~
```

Commit: `planning({topic}): draft Phase {N} task list`

Present the task overview to the user.

**STOP.** Ask:

> **To proceed:**
> - **`y`/`yes`** — Approved. I'll begin writing full task detail.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove tasks.

#### If the user provides feedback

Re-invoke `planning-task-designer` with all original inputs PLUS:
- **Previous output**: the current task list
- **User feedback**: what the user wants changed

Update the Plan Index File with the revised task table, re-present, and ask again. Repeat until approved.

#### If approved

1. Update the `planning:` block to note task authoring is starting
2. Commit: `planning({topic}): approve Phase {N} task list`

→ Proceed to **Step 6**.
