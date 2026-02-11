# Invoke the Skill

*Reference for **[start-discussion](../SKILL.md)***

---

This skill's purpose is now fulfilled.

Invoke the [technical-discussion](../../technical-discussion/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (from research):**
```
Discussion session for: {topic}
Output: docs/workflow/discussion/{topic}.md

Research reference:
Source: docs/workflow/research/{filename}.md (lines {start}-{end})
Summary: {the 1-2 sentence summary from the research analysis}

Invoke the technical-discussion skill.
```

**Example handoff (continuing or fresh):**
```
Discussion session for: {topic}
Source: {existing discussion | fresh}
Output: docs/workflow/discussion/{topic}.md

Invoke the technical-discussion skill.
```
