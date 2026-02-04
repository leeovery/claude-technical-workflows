# Invoke Polish

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step invokes the `implementation-polish` agent (`.claude/agents/implementation-polish.md`) to perform holistic quality analysis and orchestrate fixes after all tasks are complete.

---

## Invoke the Agent

**Every invocation** includes these file paths:

1. **code-quality.md**: `.claude/skills/technical-implementation/references/code-quality.md`
2. **tdd-workflow.md**: `.claude/skills/technical-implementation/references/tdd-workflow.md`
3. **Specification path**: from the plan's frontmatter (if available)
4. **Plan file path**: the implementation plan
5. **Plan format reading.md**: `.claude/skills/technical-planning/references/output-formats/{format}/reading.md` (format from plan frontmatter)
6. **Integration context file**: `docs/workflow/implementation/{topic}-context.md`
7. **Project skill paths**: from `project_skills` in the implementation tracking file

**Re-invocation after user feedback** additionally includes:

8. **User feedback**: the user's comments on what to change or focus on

The polish agent is stateless — each invocation starts fresh. Always pass all inputs.

---

## Expected Result

The agent returns a structured report:

```
STATUS: complete | blocked
SUMMARY: {overview — what was analyzed, key findings, what was fixed}
CYCLES: {number of discovery-fix cycles completed}
DISCOVERY:
- {findings from analysis passes, organized by category}
FIXES_APPLIED:
- {what was changed and why, with file:line references}
TESTS_ADDED:
- {integration tests written, what workflows they exercise}
SKIPPED:
- {issues found but not addressed — too risky, needs design decision, or low impact}
TEST_RESULTS: {all passing | failures — details}
```

- `complete`: all applied fixes have passing tests, discovery-fix loop finished
- `blocked`: SUMMARY explains what decision is needed
