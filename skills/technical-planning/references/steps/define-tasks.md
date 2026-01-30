# Define Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

This step uses the `planning-task-designer` agent (`.claude/agents/planning-task-designer.md`) to design a task list for a single phase. You invoke the agent, present its output, and handle the approval gate.

---

## Design the Task List

Orient the user:

> "Taking Phase {N}: {Phase Name} and breaking it into tasks. I'll delegate this to a specialist agent that will read the full specification and propose a task list."

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
> - **`y`/`yes`** — Approved.
> - **Or tell me what to change** — reorder, split, merge, add, edit, or remove tasks.
> - **Or navigate** — describe where you want to go.

#### If the user provides feedback

Re-invoke `planning-task-designer` with all original inputs PLUS:
- **Previous output**: the current task list
- **User feedback**: what the user wants changed

Update the Plan Index File with the revised task table, re-present, and ask again. Repeat until approved.

#### If approved

**If the task list is new or was amended:**

1. Advance the `planning:` block to the first task in this phase
2. Commit: `planning({topic}): approve Phase {N} task list`

**If the task list was already approved and unchanged:** No updates needed.

→ Return to **Plan Construction**.
