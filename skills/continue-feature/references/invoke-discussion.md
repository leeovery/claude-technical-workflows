# Invoke Discussion

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-discussion bridge skill for this topic.

This is reached when research has concluded and the feature is ready for discussion.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the feature pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-discussion/SKILL.md" \
  ".workflows/discussion/{topic}.md" \
  --pipeline "This session is part of the feature pipeline. After the discussion concludes, return to the continue-feature skill and execute Step 7 (Phase Bridge). Load: skills/continue-feature/references/phase-bridge.md"
```

## Handoff

Invoke the [begin-discussion](../../begin-discussion/SKILL.md) skill:

```
Discussion pre-flight for: {topic}
Work type: feature

Research completed: .workflows/research/{topic}.md
(The research findings should inform the discussion)

PIPELINE CONTINUATION — When discussion concludes (status: concluded),
you MUST return to the continue-feature skill and execute Step 7 (Phase Bridge).
Load: skills/continue-feature/references/phase-bridge.md
Do not end the session after discussion — the feature pipeline continues.

Invoke the begin-discussion skill.
```

The bridge skill handles the handoff to technical-discussion.
