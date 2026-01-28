# Author Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[task-design.md](../task-design.md)** — the task design principles, template structure, and quality standards for writing task detail.

---

Orient the user:

> "Task list for Phase {N} is agreed. I'll work through each task one at a time — presenting the full detail, discussing if needed, and logging it to the plan once approved."

Work through the agreed task list **one task at a time**.

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

Log the task to the plan — verbatim, as presented. Do not modify content between approval and writing. The output format adapter determines how tasks are written (appending markdown, creating issues, etc.).

After logging, confirm:

> "Task {M} of {total}: {Task Name} — logged."

#### Next task or phase complete

**If tasks remain in this phase:** → Return to the top of **Step 6** with the next task. Present it, ask, wait.

**If all tasks in this phase are logged:**

```
Phase {N}: {Phase Name} — complete ({M} tasks logged).
```

→ Return to **Step 5** for the next phase.

**If all phases are complete:** → Proceed to **Step 7**.

---

## Progress Tracking

**Before authoring**, check `tasks.md` for transfer status:

1. Read the transfer status for each task in the current phase
2. Skip tasks already marked `transfer: transferred`
3. Start with the first `transfer: pending` task

**After writing to the output format** (task approved and logged):

1. Update `tasks.md`: set `transfer: transferred` for this task
2. Update `progress.md`: note current phase and task position
3. Commit progress files alongside plan files: `planning({topic}): transfer task {N.M} ({task name})`

**On phase complete**:

1. Verify all tasks in phase show `transfer: transferred`
2. Update `progress.md`: note phase complete
3. Commit: `planning({topic}): complete Phase {N}`
