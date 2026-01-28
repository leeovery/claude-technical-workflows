# Author Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[task-design.md](../task-design.md)** — the task design principles, template structure, and quality standards for writing task detail.

---

Orient the user:

> "Task list for Phase {N} is agreed. I'll work through each task one at a time — presenting the full detail, discussing if needed, and logging it to the plan once approved."

Check `tasks.md` for transfer status. Skip tasks already marked `transfer: transferred`. Start with the first `transfer: pending` task.

Work through the task list **one task at a time**.

#### Present

Write the complete task using the task template — Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Context.

Present it to the user **in the format it will be written to the plan**. The output format adapter determines the exact format. What the user sees is what gets logged — no changes between approval and writing.

After presenting, ask:

> **Task {M} of {total}: {Task Name}**
>
> **To proceed:**
> - **`y`/`yes`** — Approved. I'll log it to the plan verbatim.
> - **Or tell me what to change.**

**STOP.** Wait for the user's response.

#### If the user provides feedback

The user may:
- Request changes to the task content
- Ask questions about scope, granularity, or approach
- Flag that something doesn't match the specification
- Identify missing edge cases or acceptance criteria

Incorporate feedback and re-present the updated task **in full**. Then ask the same choice again. Repeat until approved.

#### If approved (`y`/`yes`)

> **CHECKPOINT**: Before logging, verify: (1) You presented this exact content, (2) The user explicitly approved with `y`/`yes` or equivalent — not a question, comment, or "okay" in passing, (3) You are writing exactly what was approved with no modifications.

1. Log the task to the plan — verbatim, as presented
2. Update `tasks.md`: set `transfer: transferred` for this task
3. Update `progress.md`: note current phase and task
4. Commit: `planning({topic}): transfer task {N.M} ({task name})`

Confirm:

> "Task {M} of {total}: {Task Name} — logged."

#### Next task or phase complete

**If tasks remain in this phase:** → Return to the top with the next task. Present it, ask, wait.

**If all tasks in this phase are logged:**

1. Update `progress.md`: note phase complete
2. Commit: `planning({topic}): complete Phase {N}`

```
Phase {N}: {Phase Name} — complete ({M} tasks logged).
```

→ Return to **Step 6** for the next phase.

**If all phases are complete:** → Proceed to **Step 8**.
