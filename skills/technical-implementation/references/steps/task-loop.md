# Task Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Follow these stages sequentially, one task at a time: retrieve a task from the plan (delegating to the plan adapter for ordering and extraction), run it through execution, review, gating, and commit, then repeat until all tasks are done.

Every iteration must follow stages A through E fully — do not abbreviate, skip, or compress stages based on previous iterations.

```
A. Retrieve next task
B. Execute task → invoke-executor.md
   → Executor Blocked (conditional)
C. Review task → invoke-reviewer.md
   → Review Changes (conditional)
D. Task gate (gated → prompt user / auto → announce)
E. Update progress + commit
→ loop back to A until done
```

---

## A. Retrieve Next Task

1. Follow the plan adapter's Reading instructions to determine the next available task.
2. If no available tasks remain → skip to **When All Tasks Are Complete**.
3. Normalise the task content following **[task-normalisation.md](../task-normalisation.md)**.

---

## B. Execute Task

1. Load **[invoke-executor.md](invoke-executor.md)** and follow its instructions. Pass the normalised task content.
2. **STOP.** Do not proceed until the executor has returned its result.
3. On receipt of result, route on STATUS:
   - `blocked` or `failed` → follow **Executor Blocked** below
   - `complete` → proceed to **C. Review Task**

### Executor Blocked

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

→ Return to the top of **B. Execute Task** and re-invoke the executor with the user's comments added to the task context.

#### If `skip`

→ Proceed to **E. Update Progress and Commit** (mark task as skipped).

#### If `stop`

→ Return to the skill for **Step 6**.

---

## C. Review Task

1. Load **[invoke-reviewer.md](invoke-reviewer.md)** and follow its instructions. Pass the executor's result.
2. **STOP.** Do not proceed until the reviewer has returned its result.
3. On receipt of result, route on VERDICT:
   - `needs-changes` → follow **Review Changes** below
   - `approved` → proceed to **D. Task Gate**

### Review Changes

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

- **`y`/`yes`**: → Return to the top of **B. Execute Task** and re-invoke the executor with the reviewer's notes added.
- **`skip`**: → Proceed to **D. Task Gate**.
- **Comment**: → Return to the top of **B. Execute Task** and re-invoke the executor with the user's notes.

---

## D. Task Gate

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

- **`y`/`yes`**: → Proceed to **E. Update Progress and Commit**.
- **`auto`**: Note that `task_gate_mode` should be updated to `auto` during the commit step. → Proceed to **E. Update Progress and Commit**.
- **Comment**: → Return to the top of **B. Execute Task** and re-invoke the executor with the user's notes added.

### If `task_gate_mode: auto`

Announce the result (one line, no stop):

> **Task {id}: {Task Name} — approved** (phase {N}: {phase name}, {brief summary}). Committing.

→ Proceed to **E. Update Progress and Commit**.

---

## E. Update Progress and Commit

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

This is the end of this iteration.

→ Proceed to **A. Retrieve Next Task** and follow the instructions as written.

---

## When All Tasks Are Complete

> "All tasks complete. {M} tasks implemented."

→ Return to the skill for **Step 6**.
