# Handoff: Create With Incorporation

*Reference for **[confirm-create.md](../confirm-create.md)***

---

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-specification/SKILL.md" \
  ".workflows/specification/{topic}/specification.md"
```

This skill's purpose is now fulfilled. Invoke the [technical-specification](../../../technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed.

Determine work_type: use the value from Step 2 if available. Otherwise, read work_type from the source discussion(s) frontmatter.

```
Specification session for: {Title Case Name}
Work type: {work_type}

Source discussions:
- .workflows/discussion/{discussion-name}.md
- .workflows/discussion/{discussion-name}.md

Existing specifications to incorporate:
- .workflows/specification/{spec-name}/specification.md (covers: {discussion-name} discussion)

Output: .workflows/specification/{kebab-case-name}/specification.md

Context: This consolidates multiple sources. The existing {spec-name}.md specification should be incorporated - extract and adapt its content alongside the discussion material. The result should be a unified specification, not a simple merge.

After the {kebab-case-name} specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: {kebab-case-name}

---
Invoke the technical-specification skill.
```
