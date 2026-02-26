# Validate Investigation

*Reference for **[start-investigation](../SKILL.md)***

---

Check if investigation already exists for this topic.

```bash
ls .workflows/investigation/
```

#### If investigation exists for this topic

Read `.workflows/investigation/{topic}/investigation.md` frontmatter to check status.

#### If status is "in-progress"

> *Output the next fenced block as a code block:*

```
Resuming investigation: {topic:(titlecase)}
```

Set source="continue".

→ Return to **[the skill](../SKILL.md)** for **Step 8**.

#### If status is "concluded"

> *Output the next fenced block as a code block:*

```
Investigation Concluded

The investigation for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification {topic} bugfix` to continue to spec.

#### If no collision

Set source="fresh".

→ Return to **[the skill](../SKILL.md)**.
