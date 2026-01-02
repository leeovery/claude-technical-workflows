---
description: Start an implementation session from an existing plan. Discovers available plans, checks environment setup, and invokes the technical-implementation skill.
---

Invoke the **technical-implementation** skill for this conversation.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples.

Before beginning, discover existing work and gather necessary information.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover Existing Plans

Scan the codebase for plans:

1. **Find plans**: Look in `docs/workflow/planning/`
   - Run `ls docs/workflow/planning/` to list plan files
   - Each file is named `{topic}.md`

2. **Check plan format**: For each plan file
   - Run `head -10 docs/workflow/planning/{topic}.md` to read the frontmatter
   - Extract the `format:` field (local-markdown, linear, backlog-md, beads)
   - Do NOT use bash loops - run separate `head` commands for each topic

## Step 2: Check Prerequisites

**If no plans exist:**

```
No plans found in docs/workflow/planning/

The implementation phase requires a completed plan. Please run /start-planning first to create an implementation plan from your specification.
```

Stop here and wait for the user to acknowledge.

## Step 3: Present Options to User

Show what you found:

```
Plans found:
  {topic-1} (format: local-markdown)
  {topic-2} (format: beads)
  {topic-3} (format: linear)

Which plan would you like to implement?
```

## Step 4: Check Environment Setup

After the user selects a plan, handle environment setup.

**Read the environment setup reference**: Load `skills/technical-implementation/references/environment-setup.md` and follow its instructions for:

1. Checking for `docs/workflow/environment-setup.md` (project-specific setup)
2. Prompting the user if no setup document exists
3. Setting up format-specific requirements (the reference links to the appropriate planning output file for each format)

## Step 5: Ask About Scope

Ask the user about implementation scope:

```
How would you like to proceed?

1. **Implement all phases** - Work through the entire plan sequentially
2. **Implement specific phase** - Focus on one phase (e.g., "Phase 1")
3. **Implement specific task** - Focus on a single task

Which approach?
```

If they choose a specific phase or task, ask them to specify which one.

## Step 6: Invoke Implementation Skill

Pass to the technical-implementation skill:
- Plan: `docs/workflow/planning/{topic}.md`
- Format: (from frontmatter)
- Scope: (all phases | specific phase | specific task)
- Environment setup: (completed | not needed)

**Example handoff:**
```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: local-markdown
Scope: All phases

Environment setup: Completed (or: Not needed)

Begin implementation using the technical-implementation skill.
Reference: plan-sources.md for reading the plan, tdd-workflow.md for execution.
```

**Example handoff for beads:**
```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: beads
Epic: bd-{epic_id}
Scope: Phase 1 only

Environment setup: Completed

Begin implementation using the technical-implementation skill.
Reference: plan-sources.md for reading beads tasks, tdd-workflow.md for execution.
Use `bd ready` to identify unblocked tasks. Close tasks with `bd close bd-{id} "reason"`.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- Execute environment setup before starting implementation
- For beads format, remember to run `bd sync` at session end
- Commit frequently after each passing test
