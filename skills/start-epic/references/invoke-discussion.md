# Invoke Discussion

*Reference for **[start-epic](../SKILL.md)***

---

Invoke the discussion skill with the gathered epic context.

## Handoff

Invoke the [technical-discussion](../../technical-discussion/SKILL.md) skill:

```
Technical discussion for: {work_unit}
Work type: epic

{compiled epic context from gather-epic-context}

Invoke the technical-discussion skill.
```

When the discussion concludes, the processing skill will read `work_type` from the manifest and invoke workflow-bridge automatically.
