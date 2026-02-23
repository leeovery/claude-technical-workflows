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

## Handoff

Invoke the [technical-specification](../../technical-specification/SKILL.md) skill:

```
Specification session for: {topic}
Work type: feature

Source material:
- Discussion: .workflows/discussion/{topic}.md

Topic name: {topic}

The specification frontmatter should include:
- topic: {topic}
- status: in-progress
- type: feature
- work_type: feature
- date: {today}

Invoke the technical-specification skill.
```

When the specification concludes, the processing skill will detect `work_type: feature` in the artifact and invoke workflow:bridge automatically.
