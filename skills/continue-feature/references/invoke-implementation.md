# Invoke Implementation

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-implementation bridge skill for this topic.

## Handoff

Invoke the [begin-implementation](../../begin-implementation/SKILL.md) skill:

```
Implementation pre-flight for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Work type: feature

Invoke the begin-implementation skill.
```

The bridge skill handles dependency checking, environment setup, and the handoff to technical-implementation.

When implementation completes, the processing skill will detect `work_type: feature` in the artifact and invoke workflow:bridge automatically.
