# Validate Source Material

*Reference for **[start-specification](../SKILL.md)***

---

Check if source material exists and is ready.

#### For greenfield or feature work_type

Check if discussion exists and is concluded:

```bash
ls .workflows/discussion/
```

Read `.workflows/discussion/{topic}.md` frontmatter.

**If discussion doesn't exist:**

> *Output the next fenced block as a code block:*

```
Source Material Missing

No discussion found for "{topic:(titlecase)}".

A concluded discussion is required before specification.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-discussion` with topic.

**If discussion exists but status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Discussion In Progress

The discussion for "{topic:(titlecase)}" is not yet concluded.
Complete the discussion first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-discussion` with topic to continue.

**If discussion exists and status is "concluded":**

Control returns to the main skill.

#### For bugfix work_type

Check if investigation exists and is concluded:

```bash
ls .workflows/investigation/
```

Read `.workflows/investigation/{topic}/investigation.md` frontmatter.

**If investigation doesn't exist:**

> *Output the next fenced block as a code block:*

```
Source Material Missing

No investigation found for "{topic:(titlecase)}".

A concluded investigation is required before specification.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-investigation` with topic.

**If investigation exists but status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Investigation In Progress

The investigation for "{topic:(titlecase)}" is not yet concluded.
Complete the investigation first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-investigation` with topic to continue.

**If investigation exists and status is "concluded":**

Control returns to the main skill.
