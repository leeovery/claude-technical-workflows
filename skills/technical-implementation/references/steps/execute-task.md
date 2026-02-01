# Execute Task

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step uses the `implementation-task-executor` agent (`.claude/agents/implementation-task-executor.md`) to implement one task via TDD, then the `implementation-task-reviewer` agent (`.claude/agents/implementation-task-reviewer.md`) to independently verify it. You invoke both agents, handle review gates, and commit on approval.

---

## Prepare Task Context

Extract the full task details from the plan using the loaded output format adapter. Pass the task content **verbatim** — no summarisation, no rewriting. What the plan says is what the agent receives.

The adapter determines how to read task fields (title, goal/problem, solution, implementation steps, acceptance criteria, test cases, context/constraints, dependencies). Follow the adapter's Implementation (Reading) section.

---

## Invoke the Executor

Invoke `implementation-task-executor` with:

1. **tdd-workflow.md**: `.claude/skills/technical-implementation/references/tdd-workflow.md`
2. **code-quality.md**: `.claude/skills/technical-implementation/references/code-quality.md`
3. **Specification path**: from the plan's frontmatter (if available)
4. **Project skill paths**: the paths confirmed by user during project skills discovery
5. **Task context**: verbatim task content extracted from the plan
6. **Phase context**: brief note on current phase number, phase name, and what's been built so far in this phase

The agent implements the task (writes code, writes tests, runs tests). Code is left on disk — the agent does NOT commit.

---

## Handle Executor Result

### If `complete`

Proceed to invoke the reviewer.

### If `blocked` or `failed`

Present the issue to the user with full context from the executor's ISSUES field:

> **Task {id}: {Task Name} — {blocked/failed}**
>
> {executor's ISSUES content}
>
> **How would you like to proceed?**

**STOP.** Wait for user decision.

After receiving direction:
- Re-invoke executor with original task context PLUS the user's decision/feedback, OR
- Adjust plan as directed by user

---

## Invoke the Reviewer

After the executor returns `complete`, invoke `implementation-task-reviewer` with:

1. **Specification path**: same path given to executor
2. **Task context**: verbatim task content — same content the executor received
3. **Files changed**: the FILES_CHANGED list from the executor's result
4. **Project skill paths**: same paths given to executor

The reviewer evaluates spec conformance, acceptance criteria, test adequacy, convention adherence, and architectural quality. It does not modify any files.

---

## Handle Review Result

### If `approved`

Proceed to commit (see below). No user gate needed — the reviewer approved, and the user has phase-level gates.

### If `needs-changes`

Present the reviewer's full findings to the user:

> **Review for Task {id}: {Task Name}**
>
> The reviewer found issues:
>
> {ISSUES from reviewer — full content}
>
> Notes (non-blocking):
> {NOTES from reviewer — full content}
>
> **How would you like to proceed?**
> - **`y`/`yes`** — Accept these review notes. I'll pass them to the executor to fix.
> - **Modify** — Edit or add to the review notes before passing to executor.
> - **`skip`** — Override the reviewer and proceed as-is.

**STOP.** Wait for user direction.

This ensures the user is always in the loop on review decisions. No auto-looping on potentially bad reviewer judgement.

---

## Fix Round

After user approves or modifies the review notes:

1. Re-invoke `implementation-task-executor` with original task context PLUS:
   - **User-approved review notes**: the notes the user approved (verbatim or as modified)
   - **Specific issues to address**: the ISSUES from the review
2. After executor completes, re-invoke `implementation-task-reviewer` (same inputs as before, updated FILES_CHANGED)
3. If reviewer says `approved` → proceed to commit
4. If reviewer says `needs-changes` → present findings to user again (same human-in-the-loop gate)
5. Repeat until reviewer approves OR user skips

There is no iteration cap — the user controls every cycle.

---

## Commit

After reviewer approval (or user skip):

Stage and commit all changes — code, tests, output format progress updates, and tracking file updates — in a single commit:

```
impl({topic}): P{phase} T{task-id} — {brief description}
```

Example: `impl(auth): P2 T2.3 — implement password hashing with bcrypt`

Tasks are the atomic unit — one meaningful commit per approved task.
