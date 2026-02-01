# Invoke Reviewer

*Reference for **[technical-implementation](../../SKILL.md)***

---

How to invoke the `implementation-task-reviewer` agent (`.claude/agents/implementation-task-reviewer.md`) after the executor completes a task.

---

## Inputs

Invoke the agent with:

1. **Specification path**: same path given to the executor
2. **Task context**: same verbatim content the executor received
3. **Files changed**: the FILES_CHANGED list from the executor's result
4. **Project skill paths**: same paths given to the executor

---

## Expected Result

The agent returns a structured finding:

```
TASK: {task name}
VERDICT: approved | needs-changes
SPEC_CONFORMANCE: {conformant | drift detected — details}
ACCEPTANCE_CRITERIA: {all met | gaps — list}
TEST_COVERAGE: {adequate | gaps — list}
CONVENTIONS: {followed | violations — list}
ARCHITECTURE: {sound | concerns — details}
ISSUES:
- {specific issue with file:line reference}
NOTES:
- {non-blocking observations}
```

- `approved`: task passes all five review dimensions
- `needs-changes`: ISSUES contains specific, actionable items
