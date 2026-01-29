# Author Tasks

*Reference for **[technical-planning](../../SKILL.md)***

---

This step uses the `planning-task-author` agent to write full task detail. You (the orchestrator) invoke the agent per task, present its output, and handle the approval gate.

---

## Check for Existing Authored Tasks

Read the Plan Index File. Check the task table under the current phase.

**For each task:**
- If `status: authored` → skip (already written to output format)
- If `status: pending` → needs authoring

Walk through tasks in order. Already-authored tasks are presented for quick review (user can approve or amend). Pending tasks need full authoring.

**If all tasks in current phase are authored:** → Return to Step 5 for next phase, or Step 7 if all phases complete.

---

## Author Tasks

Orient the user:

> "Task list for Phase {N} is agreed. I'll work through each task one at a time — delegating to a specialist agent that will read the full specification and write the complete task detail. You'll review each one before it's logged."

Work through the task list **one task at a time**.

### Invoke the Agent

For each pending task, invoke `planning-task-author` with these file paths:

1. **read-specification.md**: `references/steps/read-specification.md`
2. **Specification**: path from the Plan Index File's `specification:` field
3. **Cross-cutting specs**: paths from the Plan Index File's `cross_cutting_specs:` field (if any)
4. **task-design.md**: `references/task-design.md`
5. **All approved phases**: the complete phase structure from the Plan Index File body
6. **Task list for current phase**: the approved task table
7. **Target task**: the task name, edge cases, and ID from the table
8. **Output format adapter**: path to the loaded output format adapter

### Present the Output

The agent returns complete task detail in the output format's structure. Present it to the user **exactly as it will be written** — what the user sees is what gets logged.

After presenting, ask:

> **Task {M} of {total}: {Task Name}**
>
> **To proceed:**
> - **`y`/`yes`** — Approved. I'll log it to the plan verbatim.
> - **Or tell me what to change.**
> - **`skip to {X}`** — Navigate to different task/phase

**STOP.** Wait for the user's response.

#### If the user provides feedback

Re-invoke `planning-task-author` with all original inputs PLUS:
- **Previous output**: the current task detail
- **User feedback**: what the user wants changed

Present the revised task in full. Ask the same choice again. Repeat until approved.

#### If approved (`y`/`yes`)

> **CHECKPOINT**: Before logging, verify: (1) You presented this exact content, (2) The user explicitly approved with `y`/`yes` or equivalent — not a question, comment, or "okay" in passing, (3) You are writing exactly what was approved with no modifications.

1. Write the task to the output format (format-specific — see output adapter)
2. Update the task table in the Plan Index File: set `status: authored`
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
