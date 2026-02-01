# Phase Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step executes all phases in the plan sequentially. Each phase contains tasks; each task is implemented by an executor agent and verified by a reviewer agent.

```
Determine starting position (from tracking file)
│
└─ For each phase:
    │
    ├─ Announce phase + acceptance criteria
    │
    ├─ For each task:
    │   ├─ Extract task details (verbatim from plan)
    │   ├─ Step A: Execute task
    │   │   ├─ Invoke executor (TDD: test → implement, no git)
    │   │   ├─ Invoke reviewer (spec, criteria, tests, conventions, architecture)
    │   │   └─ If needs-changes → user gate → fix round (loop)
    │   ├─ Update tracking
    │   └─ Commit: impl({topic}): P{N} T{id} — {description}
    │
    ├─ Phase completion checklist
    └─ PHASE GATE — STOP, wait for y/yes
```

---

## Determine Starting Position

Read the implementation tracking file (`docs/workflow/implementation/{topic}.md`). Check `current_phase`, `current_task`, `completed_phases`, and `completed_tasks`.

- **Completed phases**: skip entirely
- **Completed tasks within the current phase**: skip
- **Current task** (`current_task`): resume from here
- **If `current_task` is `~` and `completed_tasks` is empty**: fresh start — begin at Phase 1, Task 1

---

## Process Phases

Work through each phase in plan order, starting from the position determined above.

### For each phase:

#### If phase is already in `completed_phases`

Skip. Continue to the next phase.

#### Otherwise

Announce the phase to the user:

> **Starting Phase {N}: {Phase Name}**
>
> Acceptance criteria:
> {list acceptance criteria from the plan}

---

### For each task in phase:

#### If task is already in `completed_tasks`

Skip. Continue to the next task.

#### Otherwise

Extract task details from the plan using the output format adapter. Pass content **verbatim** — no summarisation, no rewriting.

#### Step A: Execute Task

Load **[execute-task.md](execute-task.md)** and follow it:
- Invoke `implementation-task-executor` — implements via TDD (writes code + tests, runs tests, no git)
- Invoke `implementation-task-reviewer` — independently verifies (spec, criteria, tests, conventions, architecture)
- If `needs-changes`: present to user (human-in-the-loop gate), then fix loop
- If `approved`: proceed to tracking update below

#### After task approved

**1. Update implementation tracking file** (`docs/workflow/implementation/{topic}.md`):
- Append the task ID to `completed_tasks`
- Update `current_task` to the next task (or `~` if phase done)
- Update `updated` to today's date
- Update the body progress section

**2. Update output format progress** — follow the output adapter's Implementation section to mark the task complete in the plan index file and any format-specific files.

**3. Commit all changes** in a single commit:

```
impl({topic}): P{N} T{task-id} — {brief description}
```

This includes code, tests, tracking file, and output format progress. Tasks are the atomic unit — one commit per approved task.

#### Then continue to the next task.

---

### When all tasks in a phase are complete

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

**STOP.** Wait for explicit user confirmation. Do not proceed to the next phase without `y`/`yes` or equivalent affirmative. A question, comment, or follow-up is NOT confirmation — address it and ask again.

---

## Loop Complete

When all phases have all tasks implemented and approved:

> "All phases complete. {N} phases, {M} tasks implemented."
