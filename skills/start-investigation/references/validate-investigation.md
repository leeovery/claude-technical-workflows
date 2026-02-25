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
Investigation In Progress

An investigation for "{topic:(titlecase)}" already exists and is in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`resume`** — Resume the existing investigation
- **`n`/`new`** — Start a new topic with a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If resume

→ Return to **[the skill](../SKILL.md)** for **Step 8**.

#### If new

Ask for a new topic name, re-run validation with the new topic.

#### If status is "concluded"

> *Output the next fenced block as a code block:*

```
Investigation Concluded

The investigation for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification {topic} bugfix` to continue to spec.

#### If no collision

→ Return to **[the skill](../SKILL.md)**.
