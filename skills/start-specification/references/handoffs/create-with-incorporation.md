# Handoff: Create With Incorporation

*Reference for **[confirm-create.md](../confirm-create.md)***

---

This skill's purpose is now fulfilled. Invoke the [technical-specification](../../../technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed.

```
Specification session for: {Title Case Name}

Source discussions:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md

Existing specifications to incorporate:
- docs/workflow/specification/{spec-name}/specification.md (covers: {discussion-name} discussion)

Output: docs/workflow/specification/{kebab-case-name}/specification.md

Context: This consolidates multiple sources. The existing {spec-name}.md specification should be incorporated - extract and adapt its content alongside the discussion material. The result should be a unified specification, not a simple merge.

After the {kebab-case-name} specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: {kebab-case-name}

---
Invoke the technical-specification skill.
```
