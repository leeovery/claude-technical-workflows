# Determine Review Version

*Reference for **[start-review](../SKILL.md)***

---

Check if reviews already exist for this topic from the discovery output.

**If no reviews exist:**

Set review_version = 1.

**If reviews exist:**

Find the latest review version for this topic.
Set review_version = latest_version + 1.

> *Output the next fenced block as a code block:*

```
Starting review r{review_version} for "{topic:(titlecase)}".
```

→ Return to **[the skill](../SKILL.md)**.
