# Invoke the Skill

*Reference for **[start-review](../SKILL.md)***

---

After completing the steps above, this skill's purpose is fulfilled.

Invoke the [technical-review](../../technical-review/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (single):**
```
Review session for: {topic}
Review scope: single
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Plan ID: {plan_id} (if applicable)
Specification: {specification} (exists: {true|false})

Invoke the technical-review skill.
```

**Example handoff (multi/all):**
```
Review session for: {scope description}
Review scope: {multi | all}
Plans:
  - docs/workflow/planning/{topic-1}.md (format: {format}, spec: {spec})
  - docs/workflow/planning/{topic-2}.md (format: {format}, spec: {spec})

Invoke the technical-review skill.
```
