# Phase Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Work through all phases in the plan. For each phase, tasks are executed and reviewed via **[execute-task.md](execute-task.md)**, then a mandatory phase gate controls progression.

```
Determine starting position (from tracking file)
│
└─ For each phase:
    ├─ Announce phase + acceptance criteria
    ├─ Determine next task (adapter or sequential)
    │   └─ For each task → load execute-task.md
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

## Process Phases

### For each phase:

#### If phase is already in `completed_phases`

Skip. Continue to the next phase.

#### Otherwise

Announce the phase:

> **Starting Phase {N}: {Phase Name}**
>
> Acceptance criteria:
> {list acceptance criteria from the plan}

---

### For each task in phase:

Check whether the output format adapter's Reading section defines a mechanism for determining the next task (e.g., dependency-aware querying, priority ordering). If so, use it — filtering out tasks already in `completed_tasks`. If not, process tasks sequentially as listed in the plan.

#### If task is already in `completed_tasks`

Skip. Continue to the next task.

#### Otherwise

Load **[execute-task.md](execute-task.md)** and follow its instructions.

Continue to the next task.

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
