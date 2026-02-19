# Invoke Review

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-review bridge skill for this topic.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the feature pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-review/SKILL.md" \
  "docs/workflow/review/{topic}/r{N}/review.md" \
  --pipeline "This session is part of the feature pipeline. After the review concludes, return to the continue-feature skill and execute Step 7 (Phase Bridge). Load: skills/continue-feature/references/phase-bridge.md"
```

## Handoff

Invoke the [begin-review](../../begin-review/SKILL.md) skill:

```
Review pre-flight for: {topic}
Plan: docs/workflow/planning/{topic}/plan.md

PIPELINE CONTINUATION — When review concludes,
you MUST return to the continue-feature skill and execute Step 7 (Phase Bridge).
Load: skills/continue-feature/references/phase-bridge.md
Do not end the session after review — the feature pipeline continues.

Invoke the begin-review skill.
```

The bridge skill handles discovery, validation, version detection, and the handoff to technical-review.
