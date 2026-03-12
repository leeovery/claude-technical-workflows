# Invoke the Skill

*Reference for **[workflow-review-entry](../SKILL.md)***

---

## Initialize Review Phase

Only initialize if the review phase doesn't already exist:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js exists {work_unit} --phase review --topic {topic}
```

#### If `false`

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js init-phase {work_unit} --phase review --topic {topic}
```

#### If `true`

Phase already exists (validate-phase.md already handled status). Skip init-phase.

---

## Invoke the Skill

Invoke the [technical-review](../../technical-review/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

Query format from manifest:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit} --phase planning --topic {topic} format
```

**Handoff:**
```
Review session
Work unit: {work_unit}

Plans to review:
  - work_unit: {work_unit}
    plan: .workflows/{work_unit}/planning/{topic}/planning.md
    format: {format}
    specification: .workflows/{work_unit}/specification/{topic}/specification.md (exists: {true|false})
    review_mode: {review_mode:[full|incremental]}
    unreviewed_tasks: {unreviewed_tasks or "all"}

Invoke the technical-review skill.
```
