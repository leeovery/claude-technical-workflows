# Topic Name and Conflict Check

*Reference for **[start-investigation](../SKILL.md)***

---

If the user didn't provide a clear topic name, suggest one based on the bug description:

> *Output the next fenced block as a code block:*

```
Suggested topic name: {suggested-topic:(kebabcase)}

This will create: .workflows/investigation/{suggested-topic}/investigation.md
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Is this name okay?

- **`y`/`yes`** — Use this name
- **`s`/`something else`** — Suggest a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

Once the topic name is confirmed, check for naming conflicts in the discovery output.

If an investigation with the same name exists, inform the user:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
An investigation named "{topic}" already exists.

- **`r`/`resume`** — Resume the existing investigation
- **`n`/`new`** — Choose a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If resuming

Check the investigation status. If concluded → suggest `/start-specification {topic} bugfix`. If in-progress:

→ Return to **[the skill](../SKILL.md)** for **Step 8**.

#### If no conflict

→ Return to **[the skill](../SKILL.md)**.
