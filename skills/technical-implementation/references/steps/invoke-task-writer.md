# Invoke Task Writer

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step invokes the `implementation-analysis-task-writer` agent (`../../../../agents/implementation-analysis-task-writer.md`) to create plan tasks from approved analysis findings.

---

## Invoke the Agent

Pass via the orchestrator's prompt:

1. **Approved task content** — the full task descriptions the user approved from the analysis report
2. **Plan path** — the implementation plan path
3. **Topic name** — the implementation topic
4. **Phase number** — next phase number (calculated by orchestrator: max existing phase + 1, read from plan via reading adapter)
5. **Plan format authoring adapter path** — `../../../technical-planning/references/output-formats/{format}/authoring.md` (format from plan frontmatter)

---

## Expected Result

The agent returns a structured report:

```
STATUS: complete | failed
PHASE: {phase number}
TASKS_CREATED: {count}
FILES: {list of files created/modified}
ISSUES: {any problems encountered — omit if none}
```

- `complete`: all tasks created in the plan
- `failed`: ISSUES explains what went wrong
