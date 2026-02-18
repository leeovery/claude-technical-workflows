# Review Actions Loop

*Reference for **[technical-review](../SKILL.md)***

---

After a review is complete, this loop synthesizes findings into actionable tasks.

Stages A through E run sequentially. Always start at **A. Verdict Gate**.

```
A. Verdict gate (check verdicts, offer synthesis)
B. Dispatch review synthesizer → invoke-review-synthesizer.md
C. Approval gate (present tasks, approve/skip/comment)
D. Create tasks in plan → invoke-review-task-writer.md
E. Re-open implementation + plan mode handoff
```

---

## A. Verdict Gate

Check the verdict(s) from the review(s) being analyzed.

#### If all verdicts are "Approve" with no required changes

> *Output the next fenced block as a code block:*

```
No actionable findings. All reviews passed with no required changes.
```

**STOP.** Do not proceed — terminal condition.

#### If any verdict is "Request Changes"

Blocking issues exist. Synthesis is strongly recommended.

> *Output the next fenced block as a code block:*

```
The review found blocking issues that require changes.
Synthesizing findings into actionable tasks is recommended.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`y`/`yes`** — Synthesize findings into tasks *(recommended)*
- **`n`/`no`** — Skip synthesis

Proceed with synthesis?
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If yes

→ Proceed to **B. Dispatch Review Synthesizer**.

#### If no

**STOP.** Do not proceed — terminal condition.

#### If verdict is "Comments Only"

Non-blocking improvements only. Synthesis is optional.

> *Output the next fenced block as a code block:*

```
The review found non-blocking suggestions only.
You can synthesize these into tasks or skip.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`y`/`yes`** — Synthesize findings into tasks
- **`n`/`no`** — Skip synthesis *(default)*

Synthesize non-blocking findings?
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If yes

→ Proceed to **B. Dispatch Review Synthesizer**.

#### If no

**STOP.** Do not proceed — terminal condition.

---

## B. Dispatch Review Synthesizer

Load **[invoke-review-synthesizer.md](invoke-review-synthesizer.md)** and follow its instructions.

**STOP.** Do not proceed until the synthesizer has returned.

#### If STATUS is "clean"

> *Output the next fenced block as a code block:*

```
No actionable tasks synthesized.
```

**STOP.** Do not proceed — terminal condition.

#### If STATUS is "tasks_proposed"

→ Proceed to **C. Approval Gate**.

---

## C. Approval Gate

Read the staging file from `docs/workflow/implementation/{primary-topic}/review-tasks-c{cycle-number}.md`.

Check `gate_mode` in the staging file frontmatter (`gated` or `auto`).

Present an overview. For multi-plan reviews, group tasks by plan:

> *Output the next fenced block as a code block:*

```
Review synthesis cycle {N}: {K} proposed tasks

{plan-topic}:
  1. {title} ({severity})
  2. {title} ({severity})

{plan-topic-2}:
  3. {title} ({severity})
```

Then present each task with `status: pending` individually:

**Task {current}/{total}: {title}** ({severity}) — Plan: {plan-topic}
Sources: {sources}

**Problem**: {problem}
**Solution**: {solution}
**Outcome**: {outcome}

**Do**:
{steps}

**Acceptance Criteria**:
{criteria}

**Tests**:
{tests}

#### If gate_mode is "gated"

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`a`/`approve`** — Approve this task
- **`auto`** — Approve this and all remaining tasks automatically
- **`s`/`skip`** — Skip this task
- **Comment** — Revise based on feedback
· · · · · · · · · · · ·
```

**STOP.** Wait for user input.

#### If gate_mode is "auto"

> *Output the next fenced block as a code block:*

```
Task {current} of {total}: {title} — approved (auto).
```

→ Continue to next task without stopping.

---

Process user input:

#### If `approve`

Update `status: approved` in the staging file.

→ Present the next pending task, or proceed to routing below if all tasks processed.

#### If `auto`

Update `status: approved` in the staging file. Update `gate_mode: auto` in the staging file frontmatter.

→ Continue processing remaining tasks without stopping.

#### If `skip`

Update `status: skipped` in the staging file.

→ Present the next pending task, or proceed to routing below if all tasks processed.

#### If comment

Revise the task content in the staging file based on the user's feedback. Re-present this task.

---

After all tasks processed:

→ If any tasks have `status: approved`, proceed to **D. Create Tasks in Plan**.

→ If all tasks were skipped:

Commit the staging file updates:

```
review({scope}): synthesis cycle {N} — tasks skipped
```

**STOP.** Do not proceed — terminal condition.

---

## D. Create Tasks in Plan

For each plan that has approved tasks in the staging file, invoke the task writer.

Process plans sequentially — each writes to a different plan.

For each plan:

1. Filter staging file to tasks with `plan: {plan-topic}` and `status: approved`
2. Load **[invoke-review-task-writer.md](invoke-review-task-writer.md)** and follow its instructions
3. Wait for the task writer to return before processing the next plan

**STOP.** Do not proceed until all task writers have returned.

Commit all changes (staging file, plan tasks, Plan Index Files):

```
review({scope}): add review remediation ({K} tasks across {P} plans)
```

→ Proceed to **E. Re-open Implementation + Plan Mode Handoff**.

---

## E. Re-open Implementation + Plan Mode Handoff

For each plan that received new tasks:

1. Read the implementation tracking file at `docs/workflow/implementation/{topic}/tracking.md`
2. Update frontmatter:
   - `status: in-progress`
   - Remove `completed` field (if present)
   - `updated: {today's date}`
   - `analysis_cycle: 0`
3. Commit tracking changes:

```
review({scope}): re-open implementation tracking
```

Then enter plan mode and write the following plan:

```
# Review Actions Complete: {scope}

Review findings have been synthesized into {N} implementation tasks.

## Summary

{Per-plan summary, e.g., "tick-core: 3 tasks in Phase 9", "installation: 1 task in Phase 6"}

## Instructions

1. Invoke `/start-implementation`
2. The skill will detect the new tasks and start executing them

## Context

- Plans updated: {list of plan topics}
- Tasks created: {total count}
- Implementation tracking: re-opened for each plan

## How to proceed

Clear context and continue. Claude will start implementation
and pick up the new review remediation tasks automatically.
```

Exit plan mode. The user will approve and clear context, and the fresh session will pick up with `/start-implementation` routing to the new tasks.
