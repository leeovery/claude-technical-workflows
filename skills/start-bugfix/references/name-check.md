# Bugfix Name and Conflict Check

*Reference for **[start-bugfix](../SKILL.md)***

---

Based on the bug description, suggest a name in kebab-case. Once confirmed, this becomes both `{work_unit}` and `{topic}` — for bugfix, they are always the same value.

> *Output the next fenced block as a code block:*

```
Suggested bugfix name: {work_unit}
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Is this name okay?

- **`y`/`yes`** — Use this name
- **something else** — Suggest a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

Once the name is confirmed, check for naming conflicts:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit} work_type
```

#### If a work unit with the same name exists

Read the `work_type` from the command output to identify what already exists.

**If the existing work unit is a bugfix:**

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
A bugfix named "{work_unit}" already exists.

- **`r`/`resume`** — Resume the existing investigation
- **`n`/`new`** — Choose a different name
· · · · · · · · · · · ·
```

**If the existing work unit is a different type (feature or epic):**

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
A {work_type} named "{work_unit}" already exists.
Work unit names must be unique across all work types.

- **`n`/`new`** — Choose a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If `resuming`

Check the investigation status via manifest CLI:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js get {work_unit} --phase investigation --topic {topic} status
```

**If in-progress:**

→ Return to **[the skill](../SKILL.md)** for **Step 3**.

**Otherwise:**

> *Output the next fenced block as a code block:*

```
"{work_unit:(titlecase)}" already exists and is past the investigation phase.

Run /workflow-start to continue from where you left off.
```

**STOP.** Do not proceed — terminal condition.

#### If no conflict

Create the work unit manifest:

```bash
node .claude/skills/workflow-manifest/scripts/manifest.js init {work_unit} --work-type bugfix --description "{description}"
```

Where `{description}` is a concise one-line summary compiled from the bug context gathered in Step 1.

→ Return to **[the skill](../SKILL.md)**.
