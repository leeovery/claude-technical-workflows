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

## Handoff

Invoke the [technical-specification](../../technical-specification/SKILL.md) skill:

```
Specification session for: {topic}
Work type: bugfix

Source material:
- Investigation: .workflows/investigation/{topic}/investigation.md

Topic name: {topic}

The specification frontmatter should include:
- topic: {topic}
- status: in-progress
- type: feature
- work_type: bugfix
- date: {today}

Note: This is a bugfix specification. The investigation contains root cause analysis
and reproduction details. The specification should focus on the fix approach.

Invoke the technical-specification skill.
```

When the specification concludes, the processing skill will detect `work_type: bugfix` in the artifact and invoke workflow:bridge automatically.
