# Invoke Discussion

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-discussion bridge skill for this topic.

This is reached when research has concluded and the feature is ready for discussion.

## Handoff

Invoke the [begin-discussion](../../begin-discussion/SKILL.md) skill:

```
Discussion pre-flight for: {topic}
Work type: feature

Research completed: .workflows/research/{topic}.md
(The research findings should inform the discussion)

Invoke the begin-discussion skill.
```

The bridge skill handles the handoff to technical-discussion.

When the discussion concludes, the processing skill will detect `work_type: feature` in the artifact and invoke workflow:bridge automatically.
