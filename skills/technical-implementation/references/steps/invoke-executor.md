# Invoke Executor

*Reference for **[technical-implementation](../../SKILL.md)***

---

How to invoke the `implementation-task-executor` agent (`.claude/agents/implementation-task-executor.md`) for one task.

---

## Prepare Task Context

Extract the task details from the plan using the output format adapter's Reading section. Pass the task content **verbatim** — no summarisation, no rewriting.

---

## Inputs

Invoke the agent with:

1. **tdd-workflow.md**: `.claude/skills/technical-implementation/references/tdd-workflow.md`
2. **code-quality.md**: `.claude/skills/technical-implementation/references/code-quality.md`
3. **Specification path**: from the plan's frontmatter (if available)
4. **Project skill paths**: the paths confirmed by user during project skills discovery
5. **Task context**: the verbatim task content
6. **Phase context**: current phase number, phase name, and what's been built so far

On **re-invocation after review feedback**, also include:
- **User-approved review notes**: verbatim or as modified by the user
- **Specific issues to address**: the ISSUES from the review

---

## Expected Result

The agent returns a structured report:

```
STATUS: complete | blocked | failed
TASK: {task name}
SUMMARY: {what was done}
FILES_CHANGED: {list of files created/modified}
TESTS_WRITTEN: {list of test files/methods}
TEST_RESULTS: {all passing | failures — details}
ISSUES: {any concerns, blockers, or deviations discovered}
```

- `complete`: all acceptance criteria met, all tests passing
- `blocked` or `failed`: ISSUES explains why and what decision is needed
