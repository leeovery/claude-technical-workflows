# Author Tasks

*Reference for **[technical-planning](../SKILL.md)***

---

This step uses the `planning-task-author` agent (`../../../agents/planning-task-author.md`) to write full detail for a single task. You invoke the agent, present its output, and handle the approval gate.

---

## Author the Task

### Invoke the Agent

Invoke `planning-task-author` with these file paths:

1. **read-specification.md**: `read-specification.md`
2. **Specification**: path from the Plan Index File's `specification:` field
3. **Cross-cutting specs**: paths from the Plan Index File's `cross_cutting_specs:` field (if any)
4. **task-design.md**: `task-design.md`
5. **All approved phases**: the complete phase structure from the Plan Index File body
6. **Task list for current phase**: the approved task table
7. **Target task**: the task name, edge cases, and ID from the table
8. **Output format authoring reference**: path to the format's `authoring.md` (e.g., `output-formats/{format}/authoring.md`)

### Check Gate Mode

The agent returns complete task detail following the task template from task-design.md. What the user sees is what gets logged.

> *Output the next fenced block as markdown (not a code block):*

```
{task detail from planning-task-author agent}
```

Check `author_gate_mode` in the Plan Index File frontmatter.

#### If `author_gate_mode: auto`

**Auto mode removes the approval pause — not the sequential process.** Each task is still invoked, authored, and logged one at a time, in order. Do not batch, skip ahead, or create multiple tasks concurrently.

> *Output the next fenced block as a code block:*

```
Task {M} of {total}: {Task Name} — authored. Logging to plan.
```

→ Skip to **If approved** below.

#### If `author_gate_mode: gated`

**Task {M} of {total}: {Task Name}**

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**To proceed:**
- **`y`/`yes`** — Approved. I'll log it to the plan.
- **`a`/`auto`** — Approve this and all remaining tasks automatically
- **Or tell me what to change.**
- **Or navigate** — a different phase or task, or the leading edge.
· · · · · · · · · · · ·
```

**STOP.** Wait for the user's response.

#### If the user provides feedback

Re-invoke `planning-task-author` with all original inputs PLUS:
- **Previous output**: the current task detail
- **User feedback**: what the user wants changed

Present the revised task in full. Ask the same choice again. Repeat until approved.

#### If the user navigates

→ Return to **Plan Construction**.

#### If `auto`

Note that `author_gate_mode` should be updated to `auto` during the commit step below.

→ Proceed to **If approved** below.

#### If approved (`y`/`yes` or `auto`)

> **CHECKPOINT**: If `author_gate_mode: gated`, verify before logging: (1) You presented this exact content, (2) The user explicitly approved with `y`/`yes` or equivalent — not a question, comment, or "okay" in passing, (3) You are writing exactly what was approved with no modifications.

See **[plan-index-schema.md](plan-index-schema.md)** for field definitions and lifecycle.

1. Write the task to the output format (format-specific — see authoring.md)
2. If the Plan Index File frontmatter `ext_id` is empty, set it to the external identifier for the plan as exposed by the output format.
3. If the current phase's `ext_id` is empty, set it to the external identifier for the phase as exposed by the output format.
4. Update the task table in the Plan Index File: set `status: authored` and set `Ext ID` to the external identifier for the task as exposed by the output format.
5. Advance the `planning:` block in frontmatter to the next pending task (or next phase if this was the last task)
6. If user chose `auto` at this gate: update `author_gate_mode: auto` in the Plan Index File frontmatter
7. Commit: `planning({topic}): author task {task-id} ({task name})`

> *Output the next fenced block as a code block:*

```
Task {M} of {total}: {Task Name} — authored.
```

→ Return to **Plan Construction**.
