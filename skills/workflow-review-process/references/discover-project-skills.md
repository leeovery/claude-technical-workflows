# Load Project Skills

*Reference for **[workflow-review-process](../SKILL.md)***

---

Read the project skills used during implementation via manifest CLI:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit}.implementation.{topic} project_skills
```

#### If populated

These are the same skills the implementation phase used. Pass the skill paths to the QA agent so it applies the same conventions.

→ Return to **[the skill](../SKILL.md)**.

#### If empty

No project skills were used during implementation. Proceed without project-specific conventions.

→ Return to **[the skill](../SKILL.md)**.
