# Invoke Investigation

*Reference for **[start-bugfix](../SKILL.md)***

---

Save a session bookmark for compaction recovery, then invoke the processing skill.

> *Output the next fenced block as a code block:*

```
Saving session state for compaction recovery.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-investigation/SKILL.md" \
  ".workflows/investigation/{topic}/investigation.md"
```

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

Invoke the technical-investigation skill.
```

When the investigation concludes, the processing skill will detect `work_type: bugfix` in the artifact and invoke workflow:bridge automatically.
