# Task Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Follow stages A through E sequentially for each task. Do not abbreviate, skip, or compress stages based on previous iterations.

```
A. Retrieve next task
B. Execute task → invoke-executor.md
   → Executor Blocked (conditional)
C. Review task → invoke-reviewer.md
   → Review Changes with fix analysis (conditional, fix_gate_mode)
D. Task gate (gated → prompt user / auto → announce)
E. Update progress + commit
→ loop back to A until done
```

---

## A. Retrieve Next Task

1. Follow the format's **reading.md** instructions to determine the next available task.
2. If no available tasks remain → skip to **When All Tasks Are Complete**.
3. Normalise the task content following **[task-normalisation.md](../task-normalisation.md)**.
4. Reset `fix_attempts` to `0` in the implementation tracking file.

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
> · · · · · · · · · · · ·
> - **`r`/`retry`** — Re-invoke the executor with your comments (provide below)
> - **`s`/`skip`** — Skip this task and move to the next
> - **`t`/`stop`** — Stop implementation entirely
> · · · · · · · · · · · ·

**STOP.** Wait for user choice.

#### If `retry`

→ Return to the top of **B. Execute Task** and re-invoke the executor with the full task content and the user's comments.

#### If `skip`

→ Proceed to **E. Update Progress and Commit** (mark task as skipped).

#### If `stop`

→ Return to the skill for **Step 7**.

---

## C. Review Task

1. Load **[invoke-reviewer.md](invoke-reviewer.md)** and follow its instructions. Pass the executor's result.
2. **STOP.** Do not proceed until the reviewer has returned its result.
3. On receipt of result, route on VERDICT:
   - `needs-changes` → follow **Review Changes** below
   - `approved` → proceed to **D. Task Gate**

### Review Changes

Increment `fix_attempts` in the implementation tracking file.

#### If `fix_gate_mode: auto` and `fix_attempts < 3`

Announce the fix round (one line, no stop):

> **Review for Task {id}: {Task Name} — needs changes** (attempt {N}/{max 3}, fix analysis included). Re-invoking executor.

→ Return to the top of **B. Execute Task** and re-invoke the executor with the full task content and the reviewer's notes (including fix analysis).

#### If `fix_gate_mode: gated`, or `fix_attempts >= 3`

If `fix_attempts >= 3`, the executor and reviewer have failed to converge. Prepend:

> The executor and reviewer have not converged after {N} attempts. Escalating for human review.

Present the reviewer's findings and fix analysis to the user:

> **Review for Task {id}: {Task Name} — needs changes** (attempt {N})
>
> {ISSUES from reviewer, including FIX, ALTERNATIVE, and CONFIDENCE for each}
>
> Notes (non-blocking):
> {NOTES from reviewer}
>
> · · · · · · · · · · · ·
> - **`y`/`yes`** — Accept the review and fix analysis, pass to executor
> - **`a`/`auto`** — Accept and auto-approve future fix analyses
> - **`s`/`skip`** — Override the reviewer and proceed as-is
> - **Comment** — Any commentary, adjustments, alternative approaches, or questions before passing to executor
> · · · · · · · · · · · ·

**STOP.** Wait for user choice.

- **`y`/`yes`**: → Return to the top of **B. Execute Task** and re-invoke the executor with the full task content and the reviewer's notes (including fix analysis).
- **`auto`**: Note that `fix_gate_mode` should be updated to `auto` during the next commit step. → Return to the top of **B. Execute Task** and re-invoke the executor with the full task content and the reviewer's notes (including fix analysis).
- **`skip`**: → Proceed to **D. Task Gate**.
- **Comment**: → Return to the top of **B. Execute Task** and re-invoke the executor with the full task content, the reviewer's notes, and the user's commentary.

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
> · · · · · · · · · · · ·
> **Options:**
> - **`y`/`yes`** — Approve, commit, continue to next task
> - **`a`/`auto`** — Approve this and all future reviewer-approved tasks automatically
> - **Comment** — Feedback the reviewer missed (triggers a fix round)
> · · · · · · · · · · · ·

**STOP.** Wait for user input.

- **`y`/`yes`**: → Proceed to **E. Update Progress and Commit**.
- **`auto`**: Note that `task_gate_mode` should be updated to `auto` during the commit step. → Proceed to **E. Update Progress and Commit**.
- **Comment**: → Return to the top of **B. Execute Task** and re-invoke the executor with the full task content and the user's notes.

### If `task_gate_mode: auto`

Announce the result (one line, no stop):

> **Task {id}: {Task Name} — approved** (phase {N}: {phase name}, {brief summary}). Committing.

→ Proceed to **E. Update Progress and Commit**.

---

## E. Update Progress and Commit

**Update task progress in the plan** — follow the format's **updating.md** instructions to mark the task complete.

**Mirror to implementation tracking file** (`docs/workflow/implementation/{topic}/tracking.md`):
- Append the task ID to `completed_tasks`
- Update `current_phase` if phase changed
- Update `current_task` to the next task (or `~` if done)
- Update `updated` to today's date
- If user chose `auto` at the task gate this turn: update `task_gate_mode: auto`
- If user chose `auto` at the fix gate this turn: update `fix_gate_mode: auto`

The tracking file is a derived view for discovery scripts and cross-topic dependency resolution — not a decision-making input during implementation (except `task_gate_mode` and `fix_gate_mode`).

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

→ Return to the skill for **Step 7**.
