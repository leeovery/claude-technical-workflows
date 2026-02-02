# Invoke Executor

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step invokes the `implementation-task-executor` agent (`.claude/agents/implementation-task-executor.md`) to implement one task via strict TDD.

---

## Invoke the Agent

Invoke `implementation-task-executor` with these file paths:

1. **tdd-workflow.md**: `.claude/skills/technical-implementation/references/tdd-workflow.md`
2. **code-quality.md**: `.claude/skills/technical-implementation/references/code-quality.md`
3. **Specification path**: from the plan's frontmatter (if available)
4. **Project skill paths**: from `project_skills` in the implementation tracking file
5. **Task content**: verbatim — no summarisation, no rewriting
6. **Phase context** (informational): which phase this task belongs to (e.g., Phase 2: Authentication) and what's been built so far — not a workflow state, just context for the executor to understand where this task fits

On **re-invocation after review feedback**, also include:
- **User-approved review notes**: verbatim or as modified by the user
- **Specific issues to address**: the ISSUES from the review

---

## Expected Result

The agent returns a structured report:

```
STATUS: complete | blocked | failed
TASK: {task name}
SUMMARY: {2-5 lines — commentary, decisions made, anything off-script}
TEST_RESULTS: {all passing | failures — details}
ISSUES: {any concerns, blockers, or deviations discovered}
```

- `complete`: all acceptance criteria met, all tests passing
- `blocked` or `failed`: ISSUES explains why and what decision is needed
