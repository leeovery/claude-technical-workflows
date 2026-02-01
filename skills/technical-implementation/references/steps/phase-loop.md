# Phase Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Work through the plan by retrieving tasks from the output format adapter, executing them via executor and reviewer agents, and gating phase transitions on user approval.

```
Retrieve next task (via adapter)
│
└─ Loop:
    ├─ Phase transition? → checklist + phase gate
    ├─ Announce new phase if needed
    ├─ Invoke executor → invoke-executor.md
    ├─ Invoke reviewer → invoke-reviewer.md
    ├─ Handle review (approved / needs-changes / fix round)
    ├─ Update progress + mirror to tracking file + commit
    └─ Retrieve next task → repeat until done
```

---

## Retrieving the Next Task

The output format adapter is authoritative for determining which task to work on next. Follow the adapter's Reading section to retrieve the next available task.

If the adapter defines a mechanism for task selection (e.g., dependency-aware querying, priority ordering), use it. If not, read tasks from the plan in sequence, checking each task's completion state via the adapter, and take the first incomplete task.

The orchestrator does not maintain its own skip logic — the adapter's state determines what's done and what's next.

---

## Phase Transitions

Tasks belong to phases as defined in the plan. Track which phase the current task belongs to.

#### When starting the first task

Announce the phase:

> **Starting Phase {N}: {Phase Name}**
>
> Acceptance criteria:
> {list acceptance criteria from the plan}

#### When a task belongs to a different phase than the previous task

The previous phase is complete. Before starting the new phase:

1. Run the **phase completion checklist** (below)
2. Run the **phase gate** (below)
3. Announce the new phase (as above)

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

#### If reviewer returns `approved`

→ Proceed to **Update Progress and Commit**.

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

**Fix round:** After user approves or modifies the notes, re-invoke executor (with review notes added), then re-invoke reviewer. If `approved`, proceed to commit. If `needs-changes`, present to user again. No iteration cap — the user controls every cycle.

---

## Update Progress and Commit

**Update output format progress** — follow the adapter's Implementation section to mark the task complete. The adapter is the source of truth for task progress.

**Mirror to implementation tracking file** (`docs/workflow/implementation/{topic}.md`):
- Append the task ID to `completed_tasks`
- Update `current_phase` if phase changed
- Update `updated` to today's date

The tracking file is a derived view for discovery scripts and cross-topic dependency resolution — not a decision-making input during implementation.

**Commit all changes** in a single commit:

```
impl({topic}): P{N} T{task-id} — {brief description}
```

Code, tests, output format progress, and tracking file — one commit per approved task.

→ Retrieve the next task.

---

## Phase Completion Checklist

Run when all tasks in a phase are complete (detected when the next task belongs to a new phase, or no tasks remain):

- [ ] All phase tasks implemented and reviewer-approved
- [ ] All tests passing
- [ ] Tests cover task acceptance criteria
- [ ] No skipped edge cases from plan
- [ ] All changes committed
- [ ] Manual verification steps completed (if specified in plan)

**Update implementation tracking file:**
- Append the phase number to `completed_phases`

---

## Phase Gate — MANDATORY

> **Phase {N}: {Phase Name} — complete.**
>
> {Summary of what was built in this phase}
>
> **To proceed to Phase {N+1}: {Next Phase Name}:**
> - **`y`/`yes`** — Proceed.
> - **Or raise concerns** — anything to address before moving on.

**STOP.** Wait for explicit user confirmation. Do not proceed without `y`/`yes` or equivalent affirmative. A question, comment, or follow-up is NOT confirmation — address it and ask again.

---

## When All Tasks Are Complete

Run the phase completion checklist and phase gate for the final phase, then:

> "All phases complete. {N} phases, {M} tasks implemented."

→ Return to the skill for **Step 6**.
