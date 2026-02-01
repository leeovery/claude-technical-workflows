# Task Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Work through the plan task by task. The output format adapter provides instructions suited to the plan's format — use them to query and retrieve tasks in the correct order. Each task passes through executor and reviewer agents, then a per-task approval gate.

```
Retrieve next task
│
└─ Loop:
    ├─ Invoke executor → invoke-executor.md
    ├─ Invoke reviewer → invoke-reviewer.md
    ├─ Handle review (approved / needs-changes / fix round)
    ├─ Task gate check (gated → prompt user / auto → announce)
    ├─ Update progress + mirror to tracking file + commit
    └─ Retrieve next task → repeat until done
```

---

## Retrieving the Next Task

The output format adapter is authoritative for determining which task to work on next. Follow the adapter's Reading section to retrieve the next available task.

If the adapter defines a mechanism for task selection (e.g., dependency-aware querying, priority ordering), use it. If not, read tasks from the plan in sequence, checking each task's completion state via the adapter, and take the first incomplete task.

The orchestrator does not maintain its own skip logic — the adapter's state determines what's done and what's next.

---

## For Each Task

**1.** Load **[invoke-executor.md](invoke-executor.md)** — prepare task context and invoke the executor agent.

#### If executor returns `blocked` or `failed`

Present the executor's ISSUES to the user:

> **Task {id}: {Task Name} — {blocked/failed}**
>
> {executor's ISSUES content}
>
> **How would you like to proceed?**

**STOP.** Wait for user decision. Re-invoke the executor with the user's direction, or adjust plan as directed.

#### If executor returns `complete`

**2.** Load **[invoke-reviewer.md](invoke-reviewer.md)** — invoke the reviewer agent with the executor's results.

#### If reviewer returns `needs-changes`

Present the reviewer's findings to the user:

> **Review for Task {id}: {Task Name}**
>
> {ISSUES from reviewer}
>
> Notes (non-blocking):
> {NOTES from reviewer}
>
> **How would you like to proceed?**
> - **`y`/`yes`** — Accept these notes. I'll pass them to the executor to fix.
> - **Modify** — Edit or add to the notes before passing to executor.
> - **`skip`** — Override the reviewer and proceed as-is.

**STOP.** Wait for user direction.

**Fix round:** After user approves or modifies the notes, re-invoke executor (with review notes added), then re-invoke reviewer. If `approved`, proceed to task gate. If `needs-changes`, present to user again. No iteration cap — the user controls every cycle.

#### If reviewer returns `approved`

→ Proceed to **Task Gate**.

---

## Task Gate

After the reviewer approves a task, check the `task_gate_mode` field in the implementation tracking file.

### If `task_gate_mode: gated`

Present a summary and wait for user input:

> **Task {id}: {Task Name} — approved**
>
> Phase: {phase number} — {phase name}
> Built: {brief summary of what was implemented}
> Files: {list of files changed}
>
> **Options:**
> - **`y`/`yes`** — Approve, commit, continue to next task
> - **`auto`** — Approve this and all future reviewer-approved tasks automatically
> - **Comment** — Feedback the reviewer missed (triggers a fix round)

**STOP.** Wait for user input.

- **`y`/`yes`**: → Proceed to **Update Progress and Commit**.
- **`auto`**: Note that `task_gate_mode` should be updated to `auto` during the commit step. → Proceed to **Update Progress and Commit**.
- **Comment**: Treat as a fix round — re-invoke executor with the user's notes, then re-invoke reviewer. Return to **Task Gate** after reviewer approves.

### If `task_gate_mode: auto`

Announce the result (one line, no stop):

> **Task {id}: {Task Name} — approved** (phase {N}: {phase name}, {brief summary}). Committing.

→ Proceed to **Update Progress and Commit**.

---

## Update Progress and Commit

**Update output format progress** — follow the adapter's Implementation section to mark the task complete. The adapter is the source of truth for task progress.

**Mirror to implementation tracking file** (`docs/workflow/implementation/{topic}.md`):
- Append the task ID to `completed_tasks`
- Update `current_phase` if phase changed
- Update `current_task` to the next task (or `~` if done)
- Update `updated` to today's date
- If user chose `auto` this turn: update `task_gate_mode: auto`

The tracking file is a derived view for discovery scripts and cross-topic dependency resolution — not a decision-making input during implementation (except `task_gate_mode`).

**Commit all changes** in a single commit:

```
impl({topic}): T{task-id} — {brief description}
```

Code, tests, output format progress, and tracking file — one commit per approved task.

→ Retrieve the next task.

---

## When All Tasks Are Complete

> "All tasks complete. {M} tasks implemented."

→ Return to the skill for **Step 6**.
