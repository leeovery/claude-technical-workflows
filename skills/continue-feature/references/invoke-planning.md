# Invoke Planning

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-planning bridge skill for this topic.

## Handoff

Invoke the [begin-planning](../../begin-planning/SKILL.md) skill:

```
Planning pre-flight for: {topic}
Specification: docs/workflow/specification/{topic}/specification.md

Invoke the begin-planning skill.
```

The bridge skill handles cross-cutting context, additional context gathering, and the handoff to technical-planning.
