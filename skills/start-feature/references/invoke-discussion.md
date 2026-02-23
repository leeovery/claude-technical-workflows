# Invoke Discussion

*Reference for **[start-feature](../SKILL.md)***

---

Invoke the discussion skill with the gathered feature context.

## Handoff

Invoke the [technical-discussion](../../technical-discussion/SKILL.md) skill:

```
Technical discussion for: {topic}
Work type: feature

{compiled feature context from gather-feature-context}

The discussion frontmatter should include:
- topic: {topic}
- status: in-progress
- work_type: feature
- date: {today}

Invoke the technical-discussion skill.
```

When the discussion concludes, the processing skill will detect `work_type: feature` in the artifact and invoke workflow:bridge automatically.
