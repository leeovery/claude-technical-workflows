# Analysis Loop

*Reference for **[technical-implementation](../../SKILL.md)***

---

Run one analysis cycle: check the cycle gate, checkpoint, analyze the implementation, and synthesize findings into plan tasks. Each cycle follows stages A through D sequentially. Always start at **A. Cycle Gate**.

After this loop completes with new tasks, the skill returns to Step 6 (task loop) to execute them, then re-enters this loop for the next cycle.

```
A. Cycle gate (check analysis_cycle, warn if over limit)
B. Git checkpoint
C. Dispatch analysis agents → invoke-analysis.md
D. Dispatch synthesis agent → invoke-synthesizer.md
→ Route on result
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

Load **[invoke-analysis.md](invoke-analysis.md)** and follow its instructions.

**STOP.** Do not proceed until all agents have returned.

→ Proceed to **D. Dispatch Synthesis Agent**.

---

## D. Dispatch Synthesis Agent

Load **[invoke-synthesizer.md](invoke-synthesizer.md)** and follow its instructions.

**STOP.** Do not proceed until the synthesizer has returned.

→ If `STATUS: clean`, return to the skill for **Step 8**.

→ If `STATUS: tasks_created`, commit and return to the skill:

```
impl({topic}): add analysis phase {N} ({K} tasks)
```

→ Return to the skill. New tasks are now in the plan.
