# Execute Task

*Reference for **[technical-implementation](../../SKILL.md)***

---

Implements one task: extract context from the plan, invoke the executor agent, invoke the reviewer agent, handle the review gate, update tracking, and commit.

---

## Prepare Task Context

Extract the task details from the plan using the output format adapter's Reading section. Pass the task content **verbatim** — no summarisation, no rewriting.

---

## Invoke the Executor

Invoke `implementation-task-executor` (`.claude/agents/implementation-task-executor.md`) with:

1. **tdd-workflow.md**: `.claude/skills/technical-implementation/references/tdd-workflow.md`
2. **code-quality.md**: `.claude/skills/technical-implementation/references/code-quality.md`
3. **Specification path**: from the plan's frontmatter (if available)
4. **Project skill paths**: the paths confirmed by user during project skills discovery
5. **Task context**: the verbatim task content
6. **Phase context**: current phase number, phase name, and what's been built so far

---

## Handle Executor Result

#### If `complete`

→ Proceed to **Invoke the Reviewer**.

#### If `blocked` or `failed`

Present the executor's ISSUES to the user:

> **Task {id}: {Task Name} — {blocked/failed}**
>
> {executor's ISSUES content}
>
> **How would you like to proceed?**

**STOP.** Wait for user decision. Then either re-invoke the executor with the user's direction, or adjust plan as directed.

---

## Invoke the Reviewer

Invoke `implementation-task-reviewer` (`.claude/agents/implementation-task-reviewer.md`) with:

1. **Specification path**: same as executor
2. **Task context**: same verbatim content the executor received
3. **Files changed**: the FILES_CHANGED list from the executor's result
4. **Project skill paths**: same as executor

---

## Handle Review Result

#### If `approved`

→ Proceed to **Update Tracking and Commit**.

#### If `needs-changes`

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

#### Fix Round

After user approves or modifies the notes:

1. Re-invoke executor with original task context PLUS the user-approved review notes
2. Re-invoke reviewer with updated FILES_CHANGED
3. If `approved` → proceed to commit
4. If `needs-changes` → present to user again (same gate)
5. Repeat until approved or user skips

No iteration cap — the user controls every cycle.

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
