# Invoke Review

*Reference for **[continue-bugfix](../SKILL.md)***

---

Invoke the begin-review bridge skill for this bugfix topic.

## Handoff

Invoke the [begin-review](../../begin-review/SKILL.md) skill:

```
Review pre-flight for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Work type: bugfix

Invoke the begin-review skill.
```

The bridge skill handles discovery, validation, version detection, and the handoff to technical-review.

When review concludes, the processing skill will detect `work_type: bugfix` in the artifact and invoke workflow:bridge automatically.
