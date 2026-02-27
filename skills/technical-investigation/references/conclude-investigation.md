# Conclude Investigation

*Reference for **[technical-investigation](../SKILL.md)***

---

When the root cause is identified and documented:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Root cause identified. Ready to conclude?

- **`y`/`yes`** — Conclude investigation and proceed to specification
- **`m`/`more`** — Continue investigating (more analysis needed)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If more

Continue investigation. Ask what aspects need more analysis.

→ Return to **[the skill](../SKILL.md)** for **Step 3**.

#### If yes

1. Update frontmatter `status: concluded`
2. Final commit
3. Display conclusion:

> *Output the next fenced block as a code block:*

```
Investigation concluded: {topic}

Root cause: {brief summary}
Fix direction: {proposed approach}

The investigation is ready for specification. The specification will
detail the exact fix approach, acceptance criteria, and testing plan.
```

4. Check the investigation frontmatter for `work_type`

**If work_type is set** (bugfix):

This investigation is part of a pipeline. Invoke the `/workflow:bridge` skill:

```
Pipeline bridge for: {topic}
Work type: bugfix
Completed phase: investigation

Invoke the workflow:bridge skill to enter plan mode with continuation instructions.
```

**If work_type is not set:**

The session ends here. The investigation document can be used as input to `/start-specification`.
