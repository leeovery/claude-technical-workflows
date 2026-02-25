# Check Existing Specification

*Reference for **[start-specification](../SKILL.md)***

---

Check if a specification already exists for this topic.

Read `.workflows/specification/{topic}/specification.md` if it exists.

**If specification doesn't exist:**

Control returns to the main skill with verb="Creating".

**If specification exists with status "in-progress":**

> *Output the next fenced block as a code block:*

```
Specification In Progress

A specification for "{topic:(titlecase)}" already exists and is in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`resume`** — Resume the existing specification
- **`s`/`start-fresh`** — Archive and start fresh
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resume → control returns to the main skill with verb="Continuing".
If start-fresh → archive the existing spec, control returns to the main skill with verb="Creating".

**If specification exists with status "concluded":**

> *Output the next fenced block as a code block:*

```
Specification Concluded

The specification for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic to continue to planning.
