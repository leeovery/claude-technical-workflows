# Invoke Review Synthesizer

*Reference for **[technical-review](../SKILL.md)***

---

This step dispatches a `review-findings-synthesizer` agent to read review findings, deduplicate, group, and normalize them into proposed tasks.

---

## Determine Cycle Number

Count existing `review-tasks-c*.md` files in `.workflows/implementation/{primary-topic}/` and add 1.

```bash
ls .workflows/implementation/{primary-topic}/review-tasks-c*.md 2>/dev/null | wc -l
```

---

## Invoke the Agent

**Agent path**: `../../../agents/review-findings-synthesizer.md`

Dispatch **one agent** via the Task tool.

The synthesizer receives:

1. **Plan topic** — the plan being synthesized
2. **Review path** — path to `r{N}/` directory (review summary + QA files)
3. **Specification path** — from the plan's frontmatter
4. **Cycle number** — the review remediation cycle number

---

## Wait for Completion

**STOP.** Do not proceed until the synthesizer has returned.

If the agent fails (error, timeout), record the failure and report "synthesis failed" to the user.

---

## Commit Findings

Commit the report and staging file (if created):

```
review({scope}): synthesis cycle {N} — findings
```

---

## Expected Result

The synthesizer returns:

```
STATUS: tasks_proposed | clean
TASKS_PROPOSED: {N}
SUMMARY: {1-2 sentences}
```

The full report is at `.workflows/implementation/{primary-topic}/review-report-c{N}.md`. If tasks were proposed, the staging file is at `.workflows/implementation/{primary-topic}/review-tasks-c{N}.md`.
