---
name: status
description: "Show workflow status - what exists, where you are, and what to do next."
disable-model-invocation: true
---

Show the current state of the workflow for this project.

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Scan Directories

Check for files in each workflow directory:

```
docs/workflow/research/
docs/workflow/discussion/
docs/workflow/specification/
docs/workflow/planning/
docs/workflow/implementation/
```

For implementation, check `docs/workflow/implementation/{topic}/tracking.md` files and extract frontmatter fields: `status`, `current_phase`, `current_task`, `completed_tasks`, `completed_phases`.

## Step 2: Present Status

Research is project-wide exploration. From discussion onwards, work is organised by **topic** - different topics may be at different stages.

> *Output the next fenced block as a code block:*

```
Workflow Overview

Research: {count} files ({filenames})

Topics:

  Topic          Discussion   Spec         Plan         Implemented
  {topic}        {discussion_status}   {spec_status}   {plan_status}   {impl_status}
  ...
```

Adapt based on what exists:
- If a directory is empty or missing, show `-`
- For planning, note the output format if specified in frontmatter
- Match topics across phases by filename
- For implementation, derive the Implemented column from tracking file data:
  - No tracking file → `-`
  - `status: not-started` → `not started`
  - `status: in-progress` → `phase {current_phase} ({n}/{total} tasks done)` — count `completed_tasks` for n; use total task count from `completed_tasks` + remaining if available, otherwise just show completed count
  - `status: completed` → `completed`

## Step 3: Suggest Next Steps

Based on what exists, offer relevant options. Don't assume linear progression - topics may have dependencies on each other.

**If nothing exists:**
- "Start with `/start-research` to explore ideas, or `/start-discussion` if you already know what you're building."

**If topics exist at various stages**, summarise options without being prescriptive:
- Topics in discussion can move to specification
- Topics with specs can move to planning
- Topics with plans can move to implementation
- Completed implementations can be reviewed

Example: "auth-system has a plan ready. payment-flow needs a spec before planning. You might want to complete planning for related topics before implementing if there are dependencies."

Keep suggestions brief - the user knows their project's dependencies better than we do.

## Step 4: Mention Plan Viewing

If planning files exist, let the user know they can view plan details:

> *Output the next fenced block as a code block:*

```
To view a plan's tasks and progress, use /view-plan
```

## Notes

- Keep output concise - this is a quick status check
- Use tables for scannable information
