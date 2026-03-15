# Invoke the Skill

*Reference for **[workflow-investigation-entry](../SKILL.md)***

---

This skill's purpose is now fulfilled. Construct the handoff and invoke the processing skill.

---

## Handoff

#### If source is `new`

```
Investigation session for: {work_unit}

Output: .workflows/{work_unit}/investigation/{topic}.md

Bug context:
- Expected behavior: {from user's description}
- Actual behavior: {from user's description}
- Initial context: {error messages, reproduction steps, etc.}

Invoke the workflow-investigation-process skill.
```

Invoke the [workflow-investigation-process](../../workflow-investigation-process/SKILL.md) skill. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed. Terminal.

#### If source is `continue`

```
Investigation session for: {work_unit}

Source: existing investigation
Output: .workflows/{work_unit}/investigation/{topic}.md

Invoke the workflow-investigation-process skill.
```

Invoke the [workflow-investigation-process](../../workflow-investigation-process/SKILL.md) skill. Do not act on the gathered information until the skill is loaded — it contains the instructions for how to proceed. Terminal.
