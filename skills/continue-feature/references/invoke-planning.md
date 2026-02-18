# Invoke Planning

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-planning bridge skill for this topic.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the feature pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-planning/SKILL.md" \
  "docs/workflow/planning/{topic}/plan.md" \
  --pipeline "This session is part of the feature pipeline. After the plan concludes, return to the continue-feature skill and execute Step 6 (Phase Bridge). Load: skills/continue-feature/references/phase-bridge.md"
```

## Handoff

Invoke the [begin-planning](../../begin-planning/SKILL.md) skill:

```
Planning pre-flight for: {topic}
Specification: docs/workflow/specification/{topic}/specification.md

PIPELINE CONTINUATION — When planning concludes (plan status: concluded),
you MUST return to the continue-feature skill and execute Step 6 (Phase Bridge).
Load: skills/continue-feature/references/phase-bridge.md
Do not end the session after planning — the feature pipeline continues.

Invoke the begin-planning skill.
```

The bridge skill handles cross-cutting context, additional context gathering, and the handoff to technical-planning.
