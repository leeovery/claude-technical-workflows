# Author Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

This step uses the `planning-task-author` agent (`.claude/agents/planning-task-author.md`) to write full detail for a single task. You invoke the agent, present its output, and handle the approval gate.

---

## Author the Task

### Invoke the Agent

Invoke `planning-task-author` with these file paths:

1. **read-specification.md**: `.claude/skills/technical-planning/references/read-specification.md`
2. **Specification**: path from the Plan Index File's `specification:` field
3. **Cross-cutting specs**: paths from the Plan Index File's `cross_cutting_specs:` field (if any)
4. **task-design.md**: `.claude/skills/technical-planning/references/task-design.md`
5. **All approved phases**: the complete phase structure from the Plan Index File body
6. **Task list for current phase**: the approved task table
7. **Target task**: the task name, edge cases, and ID from the table
8. **Output format authoring reference**: path to the format's `authoring.md` (e.g., `.claude/skills/technical-planning/references/output-formats/{format}/authoring.md`)

### Present the Output

The agent returns complete task detail following the task template from task-design.md. Present it to the user **exactly as it will be written** — what the user sees is what gets logged.

After presenting, ask:

> **Task {M} of {total}: {Task Name}**
>
> · · ·
>
> **To proceed:**
> - **`y`/`yes`** — Approved. I'll log it to the plan.
> - **Or tell me what to change.**
> - **Or navigate** — a different phase or task, or the leading edge.

**STOP.** Wait for the user's response.

#### If the user provides feedback

Re-invoke `planning-task-author` with all original inputs PLUS:
- **Previous output**: the current task detail
- **User feedback**: what the user wants changed

Present the revised task in full. Ask the same choice again. Repeat until approved.

#### If the user navigates

→ Return to **Plan Construction**.

#### If approved (`y`/`yes`)

> **CHECKPOINT**: Before logging, verify: (1) You presented this exact content, (2) The user explicitly approved with `y`/`yes` or equivalent — not a question, comment, or "okay" in passing, (3) You are writing exactly what was approved with no modifications.

1. Write the task to the output format (format-specific — see authoring.md)
2. Update the task table in the Plan Index File: set `status: authored`
3. Advance the `planning:` block in frontmatter to the next pending task (or next phase if this was the last task)
4. Commit: `planning({topic}): author task {task-id} ({task name})`

Confirm:

> "Task {M} of {total}: {Task Name} — authored."

→ Return to **Plan Construction**.
