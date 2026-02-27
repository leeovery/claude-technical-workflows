# Handoff: Unify With Incorporation

*Reference for **[confirm-unify.md](../confirm-unify.md)***

---

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "unified" \
  "skills/technical-specification/SKILL.md" \
  ".workflows/specification/unified/specification.md"
```

This skill's purpose is now fulfilled. Invoke the [technical-specification](../../../technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed.

Determine work_type: use the value from Step 2 if available. Otherwise, read work_type from the source discussion(s) frontmatter.

```
Specification session for: Unified
Work type: {work_type}

Source discussions:
- .workflows/discussion/{discussion-name}.md
- .workflows/discussion/{discussion-name}.md
...

Existing specifications to incorporate:
- .workflows/specification/{spec-name}/specification.md
- .workflows/specification/{spec-name}/specification.md

Output: .workflows/specification/unified/specification.md

Context: This consolidates all discussions into a single unified specification. The existing specifications should be incorporated - extract and adapt their content alongside the discussion material.

After the unified specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: unified

---
Invoke the technical-specification skill.
```
