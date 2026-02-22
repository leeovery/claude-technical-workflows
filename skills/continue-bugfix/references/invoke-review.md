# Invoke Review

*Reference for **[continue-bugfix](../SKILL.md)***

---

Invoke the begin-review bridge skill for this bugfix topic.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the bugfix pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-review/SKILL.md" \
  ".workflows/review/{topic}/r{N}/review.md" \
  --pipeline "This session is part of the bugfix pipeline. After the review concludes, return to the continue-bugfix skill and execute Step 7 (Phase Bridge). Load: skills/continue-bugfix/references/phase-bridge.md"
```

## Handoff

Invoke the [begin-review](../../begin-review/SKILL.md) skill:

```
Review pre-flight for bugfix: {topic}
Plan: .workflows/planning/{topic}/plan.md
Work type: bugfix

PIPELINE CONTINUATION — When review concludes,
you MUST return to the continue-bugfix skill and execute Step 7 (Phase Bridge).
Load: skills/continue-bugfix/references/phase-bridge.md
Do not end the session after review — the bugfix pipeline continues.

Invoke the begin-review skill.
```

The bridge skill handles discovery, validation, version detection, and the handoff to technical-review.
