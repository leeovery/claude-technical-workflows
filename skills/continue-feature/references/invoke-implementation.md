# Invoke Implementation

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the begin-implementation bridge skill for this topic.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the feature pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-implementation/SKILL.md" \
  "docs/workflow/implementation/{topic}/tracking.md" \
  --pipeline "This session is part of the feature pipeline. After implementation completes, return to the continue-feature skill and execute Step 7 (Phase Bridge). Load: skills/continue-feature/references/phase-bridge.md"
```

## Handoff

Invoke the [begin-implementation](../../begin-implementation/SKILL.md) skill:

```
Implementation pre-flight for: {topic}
Plan: docs/workflow/planning/{topic}/plan.md

PIPELINE CONTINUATION — When implementation completes (tracking status: completed),
you MUST return to the continue-feature skill and execute Step 7 (Phase Bridge).
Load: skills/continue-feature/references/phase-bridge.md
Do not end the session after implementation — the feature pipeline continues.

Invoke the begin-implementation skill.
```

The bridge skill handles dependency checking, environment setup, and the handoff to technical-implementation.
