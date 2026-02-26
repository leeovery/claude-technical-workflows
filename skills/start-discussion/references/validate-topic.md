# Validate Topic

*Reference for **[start-discussion](../SKILL.md)***

---

Check if discussion already exists for this topic.

```bash
ls .workflows/discussion/
```

#### If discussion exists for this topic

Read `.workflows/discussion/{topic}.md` frontmatter to check status.

#### If status is "in-progress"

> *Output the next fenced block as a code block:*

```
Resuming discussion: {topic:(titlecase)}
```

Set source="continue".

→ Return to **[the skill](../SKILL.md)** for **Step 9**.

#### If status is "concluded"

> *Output the next fenced block as a code block:*

```
Discussion Concluded

The discussion for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` to continue to spec.

#### If no collision

Set source="bridge".

→ Return to **[the skill](../SKILL.md)**.
