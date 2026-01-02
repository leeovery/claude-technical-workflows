---
description: Start an implementation session from an existing plan. Discovers available plans, checks environment setup, and invokes the technical-implementation skill.
---

Invoke the **technical-implementation** skill for this conversation.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

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
   - Note the `format:` field
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
  {topic-1}
  {topic-2}

Which plan would you like to implement?
```

## Step 4: Check Environment Setup

After the user selects a plan:

1. Check if `docs/workflow/environment-setup.md` exists
2. If it exists, follow the setup instructions
3. If missing, ask: "Are there any environment setup instructions I should follow?"

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
Format: {format}
Scope: All phases

Environment setup: Completed (or: Not needed)

Begin implementation using the technical-implementation skill.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- Execute environment setup before starting implementation
