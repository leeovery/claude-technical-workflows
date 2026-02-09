# Analysis Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Each cycle follows stages A through F sequentially. Always start at **A. Cycle Gate**.

```
A. Cycle gate (check analysis_cycle, warn if over limit)
B. Git checkpoint
C. Dispatch analysis agents → invoke-analysis.md
D. Dispatch synthesis agent → invoke-synthesizer.md
E. Approval gate (present tasks, approve/skip/comment)
F. Create tasks in plan → invoke-task-writer.md
→ Route on result
```

---

## A. Cycle Gate

Increment `analysis_cycle` in the implementation tracking file.

If `analysis_cycle > 3`:

> **Analysis cycle {N} — this is beyond the standard 3 cycles.**
>
> · · ·
>
> - **`s`/`skip`** — Skip analysis, proceed to completion
> - **`p`/`proceed`** — Run analysis anyway

**STOP.** Wait for user choice.

- **`skip`**: → Return to the skill for **Step 8**.
- **`proceed`**: → Continue to **B. Git Checkpoint**.

→ If `analysis_cycle <= 3`, proceed to **B. Git Checkpoint**.

---

## B. Git Checkpoint

Ensure a clean working tree before analysis. Run `git status`.

→ If the working tree is clean, proceed to **C. Dispatch Analysis Agents**.

If there are unstaged changes or untracked files, categorize them:

- **Implementation files** (files touched by `impl({topic}):` commits) — stage these automatically.
- **Unexpected files** (files not touched during implementation) — present to the user:

> **Pre-analysis checkpoint — unexpected files detected:**
> - `{file}` ({status: modified/untracked})
> - ...
>
> · · ·
>
> - **`y`/`yes`** — Include all in the checkpoint commit
> - **`s`/`skip`** — Exclude unexpected files, commit only implementation files
> - **Comment** — Specify which to include

**STOP.** Wait for user choice.

Commit included files:

```
impl({topic}): pre-analysis checkpoint
```

→ Proceed to **C. Dispatch Analysis Agents**.

---

## C. Dispatch Analysis Agents

Load **[invoke-analysis.md](invoke-analysis.md)** and follow its instructions.

**STOP.** Do not proceed until all agents have returned.

Commit the analysis findings:

```
impl({topic}): analysis cycle {N} — findings
```

→ Proceed to **D. Dispatch Synthesis Agent**.

---

## D. Dispatch Synthesis Agent

Load **[invoke-synthesizer.md](invoke-synthesizer.md)** and follow its instructions.

**STOP.** Do not proceed until the synthesizer has returned.

Commit the synthesis output:

```
impl({topic}): analysis cycle {N} — synthesis
```

→ If `STATUS: clean`, return to the skill for **Step 8**.

→ If `STATUS: tasks_proposed`, proceed to **E. Approval Gate**.

---

## E. Approval Gate

Read the staging file from `docs/workflow/implementation/{topic}/analysis-tasks-c{N}.md`.

Present an overview:

> **Analysis cycle {N}: {K} proposed tasks**
>
> 1. {title} ({severity})
> 2. {title} ({severity})
> ...

Then present each task with `status: pending` individually:

> **Task {current}/{total}: {title}** ({severity})
> Sources: {sources}
>
> **Problem**: {problem}
> **Solution**: {solution}
> **Outcome**: {outcome}
>
> **Do**:
> {steps}
>
> **Acceptance Criteria**:
> {criteria}
>
> **Tests**:
> {tests}
>
> · · ·
>
> - **`a`/`approve`** — Approve this task
> - **`s`/`skip`** — Skip this task
> - **Comment** — Revise based on feedback

**STOP.** Wait for user input.

#### If `approve`

Update `status: approved` in the staging file.

→ Present the next pending task, or proceed to routing below if all tasks processed.

#### If `skip`

Update `status: skipped` in the staging file.

→ Present the next pending task, or proceed to routing below if all tasks processed.

#### If comment

Revise the task content in the staging file based on the user's feedback. Re-present this task.

---

After all tasks processed:

→ If any tasks have `status: approved`, proceed to **F. Create Tasks in Plan**.

→ If all tasks were skipped:

Commit the staging file updates:

```
impl({topic}): analysis cycle {N} — tasks skipped
```

Return to the skill for **Step 8**.

---

## F. Create Tasks in Plan

Load **[invoke-task-writer.md](invoke-task-writer.md)** and follow its instructions.

**STOP.** Do not proceed until the task writer has returned.

Commit all analysis and plan changes (staging file, plan tasks, Plan Index File):

```
impl({topic}): add analysis phase {N} ({K} tasks)
```

→ Return to the skill. New tasks are now in the plan.
