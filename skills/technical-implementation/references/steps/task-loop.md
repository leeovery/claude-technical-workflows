# Task Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Flat loop over tasks. The plan adapter (loaded in Step 2) provides instructions for reading tasks from and writing progress to the plan.

```
Retrieve next task
│
└─ Loop:
    ├─ Execute task → invoke-executor.md
    ├─ Review task → invoke-reviewer.md
    ├─ Task gate (gated → prompt user / auto → announce)
    ├─ Update progress + commit
    └─ Retrieve next task → repeat until done
```

---

## Retrieve Next Task

1. Follow the plan adapter's Reading instructions to determine the next incomplete task.
2. Extract the task content verbatim from the plan.
3. If no incomplete tasks remain → skip to **When All Tasks Are Complete**.

---

## Execute Task

1. Load **[invoke-executor.md](invoke-executor.md)** and follow its instructions. Pass the task content verbatim.
2. **STOP.** Do not proceed until the executor has returned its result.
3. Route on STATUS:
   - `blocked` or `failed` → **Executor Blocked**
   - `complete` → **Review Task**

---

## Executor Blocked

Present the executor's ISSUES to the user:

> **Task {id}: {Task Name} — {blocked/failed}**
>
> {executor's ISSUES content}
>
> - **`retry`** — Re-invoke the executor with your comments (provide below)
> - **`skip`** — Skip this task and move to the next
> - **`stop`** — Stop implementation entirely

**STOP.** Wait for user choice.

#### If `retry`

Re-invoke the executor with the user's comments added to the task context. Return to **Execute Task** with the new result.

#### If `skip`

→ Proceed to **Update Progress and Commit** (mark task as skipped).

#### If `stop`

→ Return to the skill for **Step 6**.

---

## Review Task

1. Load **[invoke-reviewer.md](invoke-reviewer.md)** and follow its instructions. Pass the executor's result.
2. **STOP.** Do not proceed until the reviewer has returned its result.
3. Route on VERDICT:
   - `needs-changes` → **Review Changes**
   - `approved` → **Task Gate**

---

## Review Changes

Present the reviewer's findings to the user:

> **Review for Task {id}: {Task Name} — needs changes**
>
> {ISSUES from reviewer}
>
> Notes (non-blocking):
> {NOTES from reviewer}
>
> - **`y`/`yes`** — Accept these notes and pass them to the executor to fix
> - **`skip`** — Override the reviewer and proceed as-is
> - **Comment** — Modify or add to the notes before passing to the executor

**STOP.** Wait for user choice.

- **`y`/`yes`**: Re-invoke executor with the reviewer's notes added, then return to **Execute Task** and follow the instructions as written.
- **`skip`**: → Proceed to **Task Gate**.
- **Comment**: Re-invoke executor with the user's notes, then return to **Execute Task** and follow the instructions as written.

---

## Task Gate

After the reviewer approves a task, check the `task_gate_mode` field in the implementation tracking file.

### If `task_gate_mode: gated`

Present a summary and wait for user input:

> **Task {id}: {Task Name} — approved**
>
> Phase: {phase number} — {phase name}
> {executor's SUMMARY — brief commentary, decisions, implementation notes}
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

**Update task progress in the plan** — follow the plan adapter's Implementation section for instructions on how to mark the task complete.

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

Code, tests, plan progress, and tracking file — one commit per approved task.

→ Retrieve the next task.

---

## When All Tasks Are Complete

> "All tasks complete. {M} tasks implemented."

→ Return to the skill for **Step 6**.
