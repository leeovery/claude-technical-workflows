---
description: View a plan's tasks and progress, regardless of output format.
---

Display a readable summary of a plan's phases, tasks, and status.

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the [/migrate](../migrate.md) command and assess its output before proceeding to Step 1.

---

## Step 1: Identify the Plan

If no topic is specified, list available plans:

```bash
ls docs/workflow/planning/
```

Ask the user which plan to view.

## Step 2: Read the Plan Index

Read the plan file from `docs/workflow/planning/{topic}.md` and check the `format:` field in the frontmatter.

## Step 3: Load Format Reference

Load the corresponding output format reference:

```
skills/technical-planning/references/output-{format}.md
```

This reference contains instructions for reading plans in that format.

## Step 4: Read Plan Content

Follow the "Reading" or "Implementation" section in the format reference to locate and read the actual plan content.

## Step 5: Present Summary

Display a readable summary:

```
## Plan: {topic}

**Format:** {format}

### Phase 1: {phase name}
- [ ] Task 1.1: {description}
- [x] Task 1.2: {description}

### Phase 2: {phase name}
- [ ] Task 2.1: {description}
...
```

Show:
- Phase names and acceptance criteria
- Task descriptions and status (if trackable)
- Any blocked or dependent tasks

Keep it scannable - this is for quick reference, not full detail.

## Notes

- Some formats (like external issue trackers) may not be fully readable without API access - note this if applicable
- If status tracking isn't available in the format, just show the task structure
