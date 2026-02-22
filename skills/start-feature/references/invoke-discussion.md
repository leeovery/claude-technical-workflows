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

PIPELINE CONTINUATION — When this discussion concludes (status: concluded),
you MUST return to the start-feature skill and execute Step 4 (Phase Bridge).
Load: skills/start-feature/references/phase-bridge.md
Do not end the session after the discussion — the feature pipeline continues.

Invoke the technical-discussion skill.
```
