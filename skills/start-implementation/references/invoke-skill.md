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

This skill's purpose is now fulfilled.

Invoke the [technical-implementation](../../technical-implementation/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

---

## Handoff

Construct the handoff based on the implementation state.

#### If starting fresh implementation

```
Implementation session for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Format: {format from plan frontmatter}

Invoke the technical-implementation skill.
```

#### If continuing in-progress implementation

```
Implementation session for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Tracking: .workflows/implementation/{topic}/tracking.md
Format: {format from plan frontmatter}

Invoke the technical-implementation skill.
```

#### If re-implementing completed topic

```
Implementation session for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Tracking: .workflows/implementation/{topic}/tracking.md (completed)
Format: {format from plan frontmatter}

Re-implementation requested.

Invoke the technical-implementation skill.
```
