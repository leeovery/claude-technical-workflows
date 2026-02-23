# Invoke Planning

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-planning bridge skill for this topic.

## Handoff

Invoke the [begin-planning](../../begin-planning/SKILL.md) skill:

```
Planning pre-flight for: {topic}
Specification: .workflows/specification/{topic}/specification.md
Work type: feature

Invoke the begin-planning skill.
```

The bridge skill handles cross-cutting context, additional context gathering, and the handoff to technical-planning.

When the plan concludes, the processing skill will detect `work_type: feature` in the artifact and invoke workflow:bridge automatically.
