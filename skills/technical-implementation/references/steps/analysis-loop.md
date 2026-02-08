# Analysis Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Run analysis cycles to discover cross-task issues in the completed implementation, synthesize findings into plan tasks, and re-enter the task loop to resolve them. Each cycle follows stages A through F sequentially. Always start at **A. Git Checkpoint**.

```
A. Git checkpoint
B. Dispatch analysis agents → invoke-analysis.md
C. Dispatch synthesis agent → invoke-synthesizer.md
D. Present findings (user gate)
E. Create tasks in plan
F. Re-enter task loop → task-loop.md
→ Cycle gate: loop back to A or exit
```

---

## A. Git Checkpoint

Ensure a clean working tree before analysis. Run `git status`.

If the working tree is clean → proceed to **B. Dispatch Analysis Agents**.

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

→ Proceed to **B. Dispatch Analysis Agents**.

---

## B. Dispatch Analysis Agents

Load **[invoke-analysis.md](invoke-analysis.md)** and follow its instructions. Dispatch all 3 analysis agents in parallel.

**STOP.** Do not proceed until all agents have returned.

→ Proceed to **C. Dispatch Synthesis Agent**.

---

## C. Dispatch Synthesis Agent

Load **[invoke-synthesizer.md](invoke-synthesizer.md)** and invoke the synthesizer. Pass the current `analysis_cycle + 1` as the cycle number.

**STOP.** Do not proceed until the synthesizer has returned.

→ Proceed to **D. Present Findings**.

---

## D. Present Findings

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
> - **Comment** — Feedback

**STOP.** Wait for user input.

#### If `none`

→ Return to the skill for **Step 8**.

#### If `all` or specific numbers

→ Proceed to **E. Create Tasks in Plan**.

---

## E. Create Tasks in Plan

For approved tasks:

1. Calculate the next phase number: read the plan via the reading adapter and find the max existing phase, then add 1.
2. Use the plan format's **authoring.md** adapter to create task files for the new phase.
3. Commit:

```
impl({topic}): add analysis phase {N} ({K} tasks)
```

→ Proceed to **F. Re-enter Task Loop**.

---

## F. Re-enter Task Loop

Load **[task-loop.md](task-loop.md)** and follow its instructions. The task loop picks up the new phase via the reading adapter.

After the loop completes, increment `analysis_cycle` in the tracking file.

→ Skip to **Cycle Gate**.

---

## Cycle Gate

If `analysis_cycle >= max_analysis_cycles` (default 3):

> "Max analysis cycles reached. Proceeding to completion."

→ Return to the skill for **Step 8**.

Otherwise → return to **A. Git Checkpoint** for the next cycle.
