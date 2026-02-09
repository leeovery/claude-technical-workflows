# Invoke Synthesizer

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step invokes the synthesis agent to read analysis findings, deduplicate, and write normalized tasks to a staging file for user approval.

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
6. **Staging file path** — `docs/workflow/implementation/{topic}-analysis-tasks.md`

---

## Expected Result

The agent writes:
- A report to `docs/workflow/implementation/{topic}-analysis-report.md` (audit trail)
- A staging file to `docs/workflow/implementation/{topic}-analysis-tasks.md` (if actionable tasks exist)

Returns a brief status:

```
STATUS: tasks_proposed | clean
TASKS_PROPOSED: {N}
SUMMARY: {1-2 sentences}
```

- `tasks_proposed`: tasks written to staging file — orchestrator should present for approval
- `clean`: no actionable findings — orchestrator should proceed to completion
