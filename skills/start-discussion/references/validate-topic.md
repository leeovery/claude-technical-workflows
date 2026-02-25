# Validate Topic

*Reference for **[start-discussion](../SKILL.md)***

---

Check if discussion already exists for this topic.

```bash
ls .workflows/discussion/
```

#### If discussion exists for this topic

Read `.workflows/discussion/{topic}.md` frontmatter to check status.

**If status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Discussion In Progress

A discussion for "{topic:(titlecase)}" already exists and is in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`resume`** — Resume the existing discussion
- **`n`/`new`** — Start a new topic with a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resume → set path="continue", control returns to the main skill for **Step 9**.
If new → ask for a new topic name, re-run validation with the new topic.

**If status is "concluded":**

> *Output the next fenced block as a code block:*

```
Discussion Concluded

The discussion for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` to continue to spec.

#### If no collision

Control returns to the main skill.
