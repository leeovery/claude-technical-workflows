# Handoff: Continue Concluded Specification

*Reference for **[confirm-continue.md](../confirm-continue.md)***

---

Before invoking the skill, reset `finding_gate_mode` to `gated` in the specification frontmatter if present. Commit if changed: `spec({topic}): reset gate mode`

This skill's purpose is now fulfilled. Invoke the [technical-specification](../../../technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed.

```
Specification session for: {Title Case Name}

Continuing existing: docs/workflow/specification/{kebab-case-name}/specification.md (concluded)

New sources to extract:
- docs/workflow/discussion/{new-discussion-name}.md

Previously extracted (for reference):
- docs/workflow/discussion/{existing-discussion-name}.md

Context: This specification was previously concluded. New source discussions have been identified. Extract and incorporate their content while maintaining consistency with the existing specification.

---
Invoke the technical-specification skill.
```
