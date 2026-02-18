# Invoke Implementation

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-implementation bridge skill for this topic.

## Handoff

Invoke the [begin-implementation](../../begin-implementation/SKILL.md) skill:

```
Implementation pre-flight for: {topic}
Plan: docs/workflow/planning/{topic}/plan.md

PIPELINE CONTINUATION — When implementation completes (tracking status: completed),
you MUST return to the continue-feature skill and execute Step 6 (Phase Bridge).
Load: skills/continue-feature/references/phase-bridge.md
Do not end the session after implementation — the feature pipeline continues.

Invoke the begin-implementation skill.
```

The bridge skill handles dependency checking, environment setup, and the handoff to technical-implementation.
