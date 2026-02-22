# Invoke Specification

*Reference for **[continue-bugfix](../SKILL.md)***

---

Invoke the specification skill for this bugfix topic.

## Check Source Material

The specification needs source material. For bugfixes, the investigation serves as the source:

1. **Investigation document**: `.workflows/investigation/{topic}/investigation.md`
   - If exists and concluded → use as primary source
   - If exists and in-progress → this shouldn't happen (detect-phase would have routed to investigation)

2. If no investigation exists, this is an error — the bugfix pipeline expects a concluded investigation before specification. Report it and stop.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the bugfix pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-specification/SKILL.md" \
  ".workflows/specification/{topic}/specification.md" \
  --pipeline "This session is part of the bugfix pipeline. After the specification concludes, return to the continue-bugfix skill and execute Step 7 (Phase Bridge). Load: skills/continue-bugfix/references/phase-bridge.md"
```

## Handoff

Invoke the [technical-specification](../../technical-specification/SKILL.md) skill:

```
Specification session for bugfix: {topic}

Source material:
- Investigation: .workflows/investigation/{topic}/investigation.md

Topic name: {topic}
Work type: bugfix

Note: This is a bugfix specification. The investigation contains root cause analysis
and reproduction details. The specification should focus on the fix approach.

PIPELINE CONTINUATION — When this specification concludes (status: concluded),
you MUST return to the continue-bugfix skill and execute Step 7 (Phase Bridge).
Load: skills/continue-bugfix/references/phase-bridge.md
Do not end the session after the specification — the bugfix pipeline continues.

Invoke the technical-specification skill.
```
