# Invoke Specification

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the specification skill for this topic.

## Check Source Material

The specification needs source material. Check what's available:

1. **Discussion document**: `.workflows/discussion/{topic}.md`
   - If exists and concluded → use as primary source
   - If exists and in-progress → this shouldn't happen (detect-phase would have routed to discussion)

2. If no discussion exists, this is an error — the pipeline expects a concluded discussion before specification. Report it and stop.

## Save Session State

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off and continue the feature pipeline if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-specification/SKILL.md" \
  ".workflows/specification/{topic}/specification.md" \
  --pipeline "This session is part of the feature pipeline. After the specification concludes, return to the continue-feature skill and execute Step 7 (Phase Bridge). Load: skills/continue-feature/references/phase-bridge.md"
```

## Handoff

Invoke the [technical-specification](../../technical-specification/SKILL.md) skill:

```
Specification session for: {topic}

Source material:
- Discussion: .workflows/discussion/{topic}.md

Topic name: {topic}

PIPELINE CONTINUATION — When this specification concludes (status: concluded),
you MUST return to the continue-feature skill and execute Step 7 (Phase Bridge).
Load: skills/continue-feature/references/phase-bridge.md
Do not end the session after the specification — the feature pipeline continues.

Invoke the technical-specification skill.
```
