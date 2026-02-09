# Invoke Synthesizer

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step invokes the synthesis agent to read analysis findings, synthesize them into tasks, and create those tasks in the plan.

---

## Invoke the Agent

**Agent path**: `../../../../agents/implementation-analysis-synthesizer.md`

Pass via the orchestrator's prompt:

1. **Findings file paths** — all analysis output files from `docs/workflow/implementation/`:
   - `{topic}-analysis-duplication.md`
   - `{topic}-analysis-standards.md`
   - `{topic}-analysis-architecture.md`
2. **Task normalization reference path** — `../task-normalisation.md`
3. **Topic name** — the implementation topic
4. **Cycle number** — the current analysis cycle number
5. **Specification path** — from the plan's frontmatter (if available)
6. **Plan path** — the implementation plan path
7. **Plan format reading adapter path** — `../../../technical-planning/references/output-formats/{format}/reading.md`
8. **Plan format authoring adapter path** — `../../../technical-planning/references/output-formats/{format}/authoring.md`

---

## Expected Result

The agent writes a report to `docs/workflow/implementation/{topic}-analysis-report.md` and creates tasks in the plan if actionable findings exist.

Returns a brief status:

```
STATUS: tasks_created | clean
TASKS_CREATED: {N}
PHASE: {phase number, if tasks created}
SUMMARY: {1-2 sentences}
```

- `tasks_created`: new tasks added to the plan — orchestrator should commit and route to task loop
- `clean`: no actionable findings — orchestrator should proceed to completion
