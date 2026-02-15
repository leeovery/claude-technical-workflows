# Plan Construction

*Reference for **[technical-planning](../SKILL.md)***

---

This step constructs the complete plan — defining phases, designing task lists, and authoring every task. It operates as a nested structure:

    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │  Phase Structure — define or review all phases      │
    │                                                     │
    │  ┌─────────────────────────────────────────────┐    │
    │  │  For each phase:                            │    │
    │  │                                             │    │
    │  │    Step A → Define tasks for the phase      │    │
    │  │                                             │    │
    │  │      ┌─────────────────────────────────┐    │    │
    │  │      │  For each task in the phase:    │    │    │
    │  │      │                                 │    │    │
    │  │      │    Step B → Author the task     │    │    │
    │  │      └─────────────────────────────────┘    │    │
    │  │                                             │    │
    │  └─────────────────────────────────────────────┘    │
    │                                                     │
    └─────────────────────────────────────────────────────┘

---

## Navigation

At any approval gate during plan construction, the user can navigate. They may describe where they want to go in their own words — a specific phase, a specific task, "the beginning", "the leading edge", or any point in the plan.

The **leading edge** is where new work begins — the first phase, task list, or task that hasn't been completed yet. It is tracked by the `planning:` block in the Plan Index File frontmatter (`phase` and `task`). To find the leading edge, read those values. If all phases and tasks are complete, the leading edge is the end of plan construction.

The `planning:` block always tracks the leading edge. It is only advanced when work is completed — never when the user navigates. Navigation moves the user's position, not the leading edge.

Navigation stays within plan construction. It cannot skip past the end of this step.

---

## Phase Structure

Load **[define-phases.md](define-phases.md)** and follow its instructions as written.

After the phase structure is approved, continue to **Process Phases** below.

---

## Process Phases

Work through each phase in order.

> *Output the next fenced block as a code block:*

```
I'll now work through each phase — presenting existing work for review
and designing or authoring anything still pending. You'll approve at
every stage.
```

### For each phase, check its state:

#### If the phase has no task table

This phase needs task design.

→ Go to **Step A** with this phase.

After Step A returns with an approved task table, continue to **Author Tasks for the Phase** below.

#### If the phase has a task table

> *Output the next fenced block as markdown (not a code block):*

```
**Phase {N}: {Phase Name}** — {M} tasks.

{task list from the phase's task table}
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**To proceed:**
- **`y`/`yes`** — Confirmed.
- **Or tell me what to change.**
- **Or navigate** — a different phase or task, or the leading edge.
· · · · · · · · · · · ·
```

**STOP.** Wait for the user's response.

#### If the user wants changes

→ Go to **Step A** with this phase for revision.

#### If confirmed

→ Continue to **Author Tasks for the Phase** below.

---

## Author Tasks for the Phase

Work through each task in the phase's task table, in order.

### Parallel authoring (optional optimization)

After the first `pending` task in a phase is approved, you may invoke multiple Step B agents concurrently for tasks you judge to be independent — where the authored detail of one would not inform the other. This is an invocation optimization only; the approval flow is unchanged:

- Present tasks one at a time, in order
- Each task still requires explicit user approval before logging
- If user feedback on a presented task changes context that could affect any already-authored task waiting to be presented, discard those results and re-invoke Step B
- When uncertain about independence, default to sequential — it is always safe

Never parallelize the first `pending` task in a phase. Never parallelize across phases.

#### If the task status is `authored`

Already written.

> *Output the next fenced block as a code block:*

```
Task {M} of {total}: {Task Name} — already authored.
```

Continue to the next task.

#### If the task status is `pending`

→ Go to **Step B** with this task.

After Step B returns, the task is authored. Continue to the next task.

#### When all tasks in the phase are authored

Advance the `planning:` block in frontmatter to the next phase. Commit: `planning({topic}): complete Phase {N} tasks`

> *Output the next fenced block as a code block:*

```
Phase {N}: {Phase Name} — complete ({M} tasks authored).
```

Continue to the next phase.

---

## Loop Complete

When all phases have all tasks authored:

> *Output the next fenced block as markdown (not a code block):*

```
All phases are complete. The plan has **{N} phases** with **{M} tasks** total.
```

---

## Step A: Define Tasks

Load **[define-tasks.md](define-tasks.md)** and follow its instructions as written. This step designs and approves a task list for **one phase**.

---

## Step B: Author Tasks

Load **[author-tasks.md](author-tasks.md)** and follow its instructions as written. This step authors **one task** and returns.
