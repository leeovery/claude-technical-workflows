# Validate Plan and Implementation

*Reference for **[start-review](../SKILL.md)***

---

Check if plan and implementation exist and are ready.

```bash
ls .workflows/planning/
ls .workflows/implementation/
```

Read `.workflows/planning/{topic}/plan.md` frontmatter.

**If plan doesn't exist:**

> *Output the next fenced block as a code block:*

```
Plan Missing

No plan found for "{topic:(titlecase)}".

A concluded plan and implementation are required for review.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic.

Read `.workflows/implementation/{topic}/tracking.md` frontmatter.

**If implementation tracking doesn't exist:**

> *Output the next fenced block as a code block:*

```
Implementation Missing

No implementation found for "{topic:(titlecase)}".

A completed implementation is required for review.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-implementation` with topic.

**If implementation status is not "completed":**

> *Output the next fenced block as a code block:*

```
Implementation Not Complete

The implementation for "{topic:(titlecase)}" is not yet completed.
Complete the implementation first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-implementation` with topic to continue.

**If plan and implementation are both ready:**

Control returns to the main skill.
