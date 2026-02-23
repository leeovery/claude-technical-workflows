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

Invoke the technical-research skill.
```

When research concludes, the processing skill will detect `work_type: feature` in the artifact and invoke workflow:bridge automatically.
