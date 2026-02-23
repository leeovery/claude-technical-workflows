# Invoke Research

*Reference for **[start-feature](../SKILL.md)***

---

Invoke the [technical-research](../../technical-research/SKILL.md) skill for feature research.

```
Research session for: {topic}
Work type: feature

Initial context from feature interview:
{compiled feature context from gather-feature-context}

Uncertainties to explore:
{list of uncertainties identified in research-gating}

Create research file: .workflows/research/{topic}.md

The research frontmatter should include:
- topic: {topic}
- status: in-progress
- work_type: feature
- date: {today}

PIPELINE CONTINUATION — When this research concludes (status: concluded),
you MUST return to the start-feature skill and execute Step 5 (Phase Bridge).
Load: skills/start-feature/references/phase-bridge.md
Do not end the session after research — the feature pipeline continues.

Invoke the technical-research skill.
```
