# Invoke Synthesizer

*Reference for **[technical-implementation](../../SKILL.md)***

---

This step invokes the synthesis agent to deduplicate, group, and normalize analysis findings into proposed plan tasks.

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

**Re-invocation after user feedback** additionally includes:
6. **User feedback** — the user's comments on proposed tasks
7. **Previous report path** — the report from the previous synthesis

---

## Expected Result

The agent writes a consolidated report to:

```
docs/workflow/implementation/{topic}-analysis-report.md
```

Report structure:

```yaml
---
topic: {topic}
cycle: {N}
total_findings: {N}
deduplicated_findings: {N}
proposed_tasks: {N}
---
```

Followed by:
- **Proposed Tasks** — each with full task content (Problem/Solution/Outcome/Do/AC/Tests), source agents, and severity
- **Discarded Findings** — each with reason for discarding

The orchestrator reads this report after the synthesizer returns to present findings to the user.
