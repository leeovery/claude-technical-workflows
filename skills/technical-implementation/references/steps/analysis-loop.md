# Analysis Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Run one analysis cycle: check the cycle gate, analyze the implementation, synthesize findings, present to user, and create plan tasks if approved. Each cycle follows stages A through F sequentially. Always start at **A. Cycle Gate**.

After this loop completes with new tasks, the skill returns to Step 6 (task loop) to execute them, then re-enters this loop for the next cycle.

```
A. Cycle gate (check analysis_cycle, warn if over limit)
B. Git checkpoint
C. Dispatch analysis agents → invoke-analysis.md
D. Dispatch synthesis agent → invoke-synthesizer.md
E. Present findings (user gate)
F. Create tasks in plan → invoke-task-writer.md
→ Return to skill
```

---

## A. Cycle Gate

Increment `analysis_cycle` in the implementation tracking file.

If `analysis_cycle > max_analysis_cycles` (default 3):

> **Analysis cycle {N} — exceeds configured maximum ({max_analysis_cycles}).**
>
> · · ·
>
> - **`s`/`skip`** — Skip analysis, proceed to completion
> - **`p`/`proceed`** — Run analysis anyway

**STOP.** Wait for user choice.

- **`skip`**: → Return to the skill for **Step 8**.
- **`proceed`**: → Continue to **B. Git Checkpoint**.

→ If `analysis_cycle <= max_analysis_cycles`, proceed to **B. Git Checkpoint**.

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

Load **[invoke-analysis.md](invoke-analysis.md)** and follow its instructions. Dispatch all 3 analysis agents in parallel.

**STOP.** Do not proceed until all agents have returned.

→ Proceed to **D. Dispatch Synthesis Agent**.

---

## D. Dispatch Synthesis Agent

Load **[invoke-synthesizer.md](invoke-synthesizer.md)** and invoke the synthesizer.

**STOP.** Do not proceed until the synthesizer has returned.

→ Proceed to **E. Present Findings**.

---

## E. Present Findings

Read the report from `docs/workflow/implementation/{topic}-analysis-report.md`.

If zero proposed tasks:

> "Analysis cycle {N}: no issues found."

→ Return to the skill for **Step 8**.

Otherwise, present grouped findings conversationally:

> **Analysis cycle {N}: {K} proposed tasks**
>
> {For each proposed task:}
> **{number}. {title}** ({severity})
> Sources: {agents}
> {Problem summary}
> {Solution summary}
>
> · · ·
>
> - **`a`/`all`** — Approve all, add to plan
> - **`1,3,5`** — Approve specific tasks by number
> - **`n`/`none`** — Skip, mark complete as-is
> - **Comment** — Feedback (re-invokes synthesizer with your notes)

**STOP.** Wait for user input.

#### If `none`

→ Return to the skill for **Step 8**.

#### If comment

Re-invoke the synthesizer with the user's feedback and the previous report. Return to the top of **E. Present Findings** when the synthesizer returns.

#### If `all` or specific numbers

→ Proceed to **F. Create Tasks in Plan**.

---

## F. Create Tasks in Plan

1. Calculate the next phase number: read the plan via the reading adapter and find the max existing phase, then add 1.
2. Load **[invoke-task-writer.md](invoke-task-writer.md)** and follow its instructions. Pass the approved task content from the report.
3. **STOP.** Do not proceed until the task writer has returned.
4. Commit:

```
impl({topic}): add analysis phase {N} ({K} tasks)
```

→ Return to the skill. New tasks are now in the plan.
