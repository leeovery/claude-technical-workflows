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
3. **Plan format authoring adapter path** — `../../../technical-planning/references/output-formats/{format}/authoring.md` (format from plan frontmatter)
4. **Plan path** — the implementation plan path
5. **Topic name** — the implementation topic
6. **Next phase number** — calculated by orchestrator: max existing phase + 1 (read from plan via reading adapter)
7. **Specification path** — from the plan's frontmatter (if available)

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
