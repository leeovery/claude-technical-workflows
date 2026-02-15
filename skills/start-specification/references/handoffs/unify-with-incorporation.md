# Handoff: Unify With Incorporation

*Reference for **[confirm-unify.md](../confirm-unify.md)***

---

This skill's purpose is now fulfilled. Invoke the [technical-specification](../../../technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed.

```
Specification session for: Unified

Source discussions:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md
...

Existing specifications to incorporate:
- docs/workflow/specification/{spec-name}/specification.md
- docs/workflow/specification/{spec-name}/specification.md

Output: docs/workflow/specification/unified/specification.md

Context: This consolidates all discussions into a single unified specification. The existing specifications should be incorporated - extract and adapt their content alongside the discussion material.

After the unified specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: unified

---
Invoke the technical-specification skill.
```
