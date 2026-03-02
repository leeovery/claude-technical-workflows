# Invoke Processing Skill

*Reference for **[start-epic](../SKILL.md)***

---

Save a session bookmark for compaction recovery, then invoke the appropriate processing skill.

> *Output the next fenced block as a code block:*

```
Saving session state for compaction recovery.
```

#### If `phase` is `research`

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{work_unit}" \
  "skills/technical-research/SKILL.md" \
  ".workflows/{work_unit}/research/{work_unit}.md"
```

→ Load **[invoke-research.md](invoke-research.md)** and follow its instructions.

#### If `phase` is `discussion`

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{work_unit}" \
  "skills/technical-discussion/SKILL.md" \
  ".workflows/{work_unit}/discussion/discussion.md"
```

→ Load **[invoke-discussion.md](invoke-discussion.md)** and follow its instructions.
