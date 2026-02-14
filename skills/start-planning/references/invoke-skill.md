# Invoke the Skill

*Reference for **[start-planning](../SKILL.md)***

---

After completing the steps above, this skill's purpose is fulfilled.

Invoke the [technical-planning](../../technical-planning/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (fresh plan):**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Additional context: {summary of user's answers from Step 5}
Cross-cutting references: {list of applicable cross-cutting specs with brief summaries, or "none"}
Recommended output format: {common_format from discovery if non-empty, otherwise "none"}

Invoke the technical-planning skill.
```

**Example handoff (continue/review existing plan):**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Existing plan: docs/workflow/planning/{topic}.md

Invoke the technical-planning skill.
```
