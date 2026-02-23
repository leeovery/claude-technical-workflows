# Invoke Review

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-review bridge skill for this topic.

## Handoff

Invoke the [begin-review](../../begin-review/SKILL.md) skill:

```
Review pre-flight for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Work type: feature

Invoke the begin-review skill.
```

The bridge skill handles discovery, validation, version detection, and the handoff to technical-review.

When review concludes, the processing skill will detect `work_type: feature` in the artifact and invoke workflow:bridge automatically.
