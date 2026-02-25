# Validate Plan

*Reference for **[start-implementation](../SKILL.md)***

---

Check if plan exists and is ready.

```bash
ls .workflows/planning/
```

Read `.workflows/planning/{topic}/plan.md` frontmatter.

**If plan doesn't exist:**

> *Output the next fenced block as a code block:*

```
Plan Missing

No plan found for "{topic:(titlecase)}".

A concluded plan is required for implementation.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic.

**If plan exists but status is not "concluded":**

> *Output the next fenced block as a code block:*

```
Plan Not Concluded

The plan for "{topic:(titlecase)}" is not yet concluded.
Complete the plan first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic to continue.

**If plan exists and status is "concluded":**

Control returns to the main skill.
