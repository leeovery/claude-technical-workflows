# Invoke Specification

*Reference for **[continue-feature](../SKILL.md)***

---

Invoke the specification skill for this topic.

## Check Source Material

The specification needs source material. Check what's available:

1. **Discussion document**: `docs/workflow/discussion/{topic}.md`
   - If exists and concluded → use as primary source
   - If exists and in-progress → this shouldn't happen (detect-phase would have routed to discussion)

2. If no discussion exists, this is an error — the pipeline expects a concluded discussion before specification. Report it and stop.

## Handoff

Invoke the [technical-specification](../../technical-specification/SKILL.md) skill:

```
Specification session for: {topic}

Source material:
- Discussion: docs/workflow/discussion/{topic}.md

Topic name: {topic}

PIPELINE CONTINUATION — When this specification concludes (status: concluded),
you MUST return to the continue-feature skill and execute Step 6 (Phase Bridge).
Load: skills/continue-feature/references/phase-bridge.md
Do not end the session after the specification — the feature pipeline continues.

Invoke the technical-specification skill.
```
