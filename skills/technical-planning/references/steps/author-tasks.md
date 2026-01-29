# Author Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[task-design.md](../task-design.md)** — the task design principles, template structure, and quality standards for writing task detail.

---

## Check for Existing Authored Tasks

Read the plan index file. Check the task table under the current phase.

**For each task:**
- If `status: authored` → skip (already written to output format)
- If `status: pending` → needs authoring

Walk through tasks in order. Already-authored tasks are presented for quick review (user can approve or amend). Pending tasks need full authoring.

**If all tasks in current phase are authored:** → Return to Step 5 for next phase, or Step 7 if all phases complete.

---

## Author Tasks

Orient the user:

> "Task list for Phase {N} is agreed. I'll work through each task one at a time — presenting the full detail, discussing if needed, and logging it to the plan once approved."

Work through the task list **one task at a time**.

#### Present

Write the complete task using the task template — Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Context.

Present it to the user **in the format it will be written to the output format**. The output format adapter determines the exact format. What the user sees is what gets logged — no changes between approval and writing.

After presenting, ask:

> **Task {M} of {total}: {Task Name}**
>
> **To proceed:**
> - **`y`/`yes`** — Approved. I'll log it to the plan verbatim.
> - **Or tell me what to change.**
> - **`skip to {X}`** — Navigate to different task/phase

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

1. Write the task to the output format (format-specific — see output adapter)
2. Update the task table in the plan index: set `status: authored`
3. Update the `planning:` block in frontmatter: note current phase and task
4. Commit: `planning({topic}): author task {task-id} ({task name})`

Confirm:

> "Task {M} of {total}: {Task Name} — authored."

#### Next task or phase complete

**If tasks remain in this phase:** → Return to the top with the next task. Present it, ask, wait.

**If all tasks in this phase are authored:**

Update `planning:` block and commit: `planning({topic}): complete Phase {N} tasks`

```
Phase {N}: {Phase Name} — complete ({M} tasks authored).
```

→ Return to **Step 5** for the next phase.

**If all phases are complete:** → Proceed to **Step 7**.
