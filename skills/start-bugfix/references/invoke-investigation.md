# Invoke Investigation

*Reference for **[start-bugfix](../SKILL.md)***

---

Invoke the technical-investigation skill for this bugfix.

## Handoff

Invoke the [technical-investigation](../../technical-investigation/SKILL.md) skill:

```
Investigation session for: {topic}
Work type: bugfix
Initial bug context:
- Problem: {problem description from gather-bug-context}
- Manifestation: {how it surfaces}
- Reproduction: {steps if provided, otherwise "unknown"}
- Initial hypothesis: {user's suspicion if any}

Create investigation file: .workflows/investigation/{topic}/investigation.md

The investigation frontmatter should include:
- topic: {topic}
- status: in-progress
- work_type: bugfix
- date: {today}

PIPELINE CONTINUATION — When this investigation concludes (status: concluded),
you MUST return to the start-bugfix skill and execute Step 4 (Phase Bridge).
Load: skills/start-bugfix/references/phase-bridge.md
Do not end the session after the investigation — the bugfix pipeline continues.

Invoke the technical-investigation skill.
```
