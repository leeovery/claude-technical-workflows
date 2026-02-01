# Phase Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Work through all phases in the plan. For each phase, implement tasks via executor and reviewer agents, then gate progression on user approval.

```
Determine starting position (from tracking file)
│
└─ For each phase:
    ├─ Announce phase + acceptance criteria
    ├─ Determine next task (adapter or sequential)
    │   └─ For each task:
    │       ├─ Invoke executor → invoke-executor.md
    │       ├─ Invoke reviewer → invoke-reviewer.md
    │       ├─ Handle review (approved / needs-changes / fix round)
    │       └─ Update tracking + commit
    ├─ Phase completion checklist
    ├─ Update phase tracking
    └─ PHASE GATE — STOP, wait for y/yes
```

---

## Determine Starting Position

Read the implementation tracking file (`docs/workflow/implementation/{topic}.md`). Check `completed_phases` and `completed_tasks` to identify completed work.

- **Completed phases**: skip entirely
- **Completed tasks**: skip
- **Fresh start** (`completed_tasks` empty, `current_task` is `~`): begin at Phase 1

---

## For Each Phase

#### If phase is already in `completed_phases`

Skip. Continue to the next phase.

#### Otherwise

Announce the phase:

> **Starting Phase {N}: {Phase Name}**
>
> Acceptance criteria:
> {list acceptance criteria from the plan}

---

## For Each Task in Phase

Check whether the output format adapter's Reading section defines a mechanism for determining the next task (e.g., dependency-aware querying, priority ordering). If so, use it — filtering out tasks already in `completed_tasks`. If not, process tasks as listed in the plan.

#### If task is already in `completed_tasks`

Skip. Continue to the next task.

#### Otherwise

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

→ Proceed to **Update Tracking and Commit**.

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

## Update Tracking and Commit

**Update implementation tracking file** (`docs/workflow/implementation/{topic}.md`):
- Append the task ID to `completed_tasks`
- Update `current_task` to the next task (or `~` if phase done)
- Update `updated` to today's date
- Update the body progress section

**Update output format progress** — follow the adapter's Implementation section to mark the task complete.

**Commit all changes** in a single commit:

```
impl({topic}): P{N} T{task-id} — {brief description}
```

Code, tests, tracking file, and output format progress — one commit per approved task.

→ Continue to the next task in the phase.

---

## When All Tasks in a Phase Are Complete

**Phase completion checklist:**
- [ ] All phase tasks implemented and reviewer-approved
- [ ] All tests passing
- [ ] Tests cover task acceptance criteria
- [ ] No skipped edge cases from plan
- [ ] All changes committed
- [ ] Manual verification steps completed (if specified in plan)

**Update implementation tracking file:**
- Append the phase number to `completed_phases`
- Update `current_phase` to the next phase (or leave as last)
- Update the body progress section

**Phase gate — MANDATORY:**

> **Phase {N}: {Phase Name} — complete.**
>
> {Summary of what was built in this phase}
>
> **To proceed to Phase {N+1}: {Next Phase Name}:**
> - **`y`/`yes`** — Proceed.
> - **Or raise concerns** — anything to address before moving on.

**STOP.** Wait for explicit user confirmation. Do not proceed without `y`/`yes` or equivalent affirmative. A question, comment, or follow-up is NOT confirmation — address it and ask again.

#### If more phases remain

→ Return to **For Each Phase** above.

#### If all phases are complete

> "All phases complete. {N} phases, {M} tasks implemented."

→ Return to the skill for **Step 6**.
