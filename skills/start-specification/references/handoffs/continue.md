# Handoff: Continue Specification

*Reference for **[confirm-continue.md](../confirm-continue.md)** and **[confirm-refine.md](../confirm-refine.md)***

---

This skill's purpose is now fulfilled. Invoke the [technical-specification](../../../technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed.

```
Specification session for: {Title Case Name}

Continuing existing: docs/workflow/specification/{kebab-case-name}.md

Sources for reference:
- docs/workflow/discussion/{discussion-name}.md
- docs/workflow/discussion/{discussion-name}.md

Context: This specification already exists. Review and refine it based on the source discussions.

---
Invoke the technical-specification skill.
```
