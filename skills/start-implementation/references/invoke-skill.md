# Invoke the Skill

*Reference for **[start-implementation](../SKILL.md)***

---

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-implementation/SKILL.md" \
  ".workflows/implementation/{topic}/tracking.md"
```

After completing the steps above, this skill's purpose is fulfilled.

Invoke the [technical-implementation](../../technical-implementation/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

---

## Handoff

```
Implementation session for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Format: {format}
Plan ID: {plan_id} (if applicable)
Specification: {specification} (exists: {true|false})
Implementation tracking: {exists | new} (status: {in-progress | not-started | completed})

Dependencies: {All satisfied | List any notes}
Environment: {Setup required | No special setup required}

Invoke the technical-implementation skill.
```
