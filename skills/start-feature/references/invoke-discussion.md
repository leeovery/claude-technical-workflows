# Invoke Discussion

*Reference for **[start-feature](../SKILL.md)***

---

Invoke the discussion skill with the gathered feature context.

## Handoff

Invoke the [technical-discussion](../../technical-discussion/SKILL.md) skill:

```
Technical discussion for: {topic}

## Feature Context

{compiled feature context from gather-feature-context}

---

This is a feature pipeline discussion — the goal is to capture architecture
decisions, edge cases, and rationale for this feature so they can be
transformed into a specification.

Focus on:
- Key architectural decisions and their rationale
- Edge cases and error handling strategies
- Integration concerns
- Anything that needs to be validated before specification

PIPELINE CONTINUATION — When this discussion concludes (status: concluded),
you MUST return to the start-feature skill and execute Step 4 (Phase Bridge).
Load: skills/start-feature/references/phase-bridge.md
Do not end the session after the discussion — the feature pipeline continues.

Begin the technical discussion using the technical-discussion skill.
```
