# Validate Specification

*Reference for **[start-planning](../SKILL.md)***

---

Check if specification exists and is ready.

```bash
ls .workflows/specification/
```

Read `.workflows/specification/{topic}/specification.md` frontmatter.

**If specification doesn't exist:**

> *Output the next fenced block as a code block:*

```
Specification Missing

No specification found for "{topic:(titlecase)}".

A concluded specification is required for planning.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` with topic.

**If specification exists but status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Specification In Progress

The specification for "{topic:(titlecase)}" is not yet concluded.
Complete the specification first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` with topic to continue.

**If specification exists and status is "concluded":**

Parse cross-cutting specs from `specifications.crosscutting` in the discovery output.

Control returns to the main skill.
