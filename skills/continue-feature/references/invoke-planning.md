# Invoke Planning

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-planning bridge skill for this topic.

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
