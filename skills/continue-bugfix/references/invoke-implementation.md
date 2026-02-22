# Invoke Implementation

*Reference for **[continue-bugfix](../SKILL.md)***

---

Invoke the begin-implementation bridge skill for this bugfix topic.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the bugfix pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-implementation/SKILL.md" \
  ".workflows/implementation/{topic}/tracking.md" \
  --pipeline "This session is part of the bugfix pipeline. After implementation completes, return to the continue-bugfix skill and execute Step 7 (Phase Bridge). Load: skills/continue-bugfix/references/phase-bridge.md"
```

## Handoff

Invoke the [begin-implementation](../../begin-implementation/SKILL.md) skill:

```
Implementation pre-flight for bugfix: {topic}
Plan: .workflows/planning/{topic}/plan.md
Work type: bugfix

PIPELINE CONTINUATION — When implementation completes (tracking status: completed),
you MUST return to the continue-bugfix skill and execute Step 7 (Phase Bridge).
Load: skills/continue-bugfix/references/phase-bridge.md
Do not end the session after implementation — the bugfix pipeline continues.

Invoke the begin-implementation skill.
```

The bridge skill handles dependency checking, environment setup, and the handoff to technical-implementation.
