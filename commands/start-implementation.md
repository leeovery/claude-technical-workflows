---
description: Start an implementation session from an existing plan. Discovers available plans, checks environment setup, and invokes the technical-implementation skill.
---

## IMPORTANT: Follow these steps EXACTLY. Do not skip steps.

- Ask each question and WAIT for a response before proceeding
- Do NOT install anything or invoke tools until Step 5
- Even if the user's initial prompt seems to answer a question, still confirm with them at the appropriate step
- Do NOT make assumptions about what the user wants
- Complete each step fully before moving to the next

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

## Step 2: Present Options to User

Show what you found.

> **Note:** If no plans exist, inform the user that this workflow is designed to be executed in sequence. They need to create plans from specifications prior to implementation using `/start-planning`.

> **Auto-select:** If exactly one plan exists, automatically select it and proceed to Step 3. Inform the user which plan was selected. Do not ask for confirmation.

```
Plans found:
  {topic-1}
  {topic-2}

Which plan would you like to implement?
```

## Step 3: Check Environment Setup

> **IMPORTANT**: This step is for **information gathering only**. Do NOT execute any setup commands at this stage. The technical-implementation skill will handle execution when invoked.

After the user selects a plan:

1. Check if `docs/workflow/environment-setup.md` exists
2. If it exists, note the file location for the skill handoff
3. If missing, ask: "Are there any environment setup instructions I should follow?"
   - If the user provides instructions, save them to `docs/workflow/environment-setup.md`, commit and push to Git
   - If the user says no, create `docs/workflow/environment-setup.md` with "No special setup required." and commit. This prevents asking again in future sessions.
   - See `skills/technical-implementation/references/environment-setup.md` for format guidance

## Step 4: Ask About Scope

Ask the user about implementation scope:

```
How would you like to proceed?

1. **Implement all phases** - Work through the entire plan sequentially
2. **Implement specific phase** - Focus on one phase (e.g., "Phase 1")
3. **Implement specific task** - Focus on a single task

Which approach?
```

If they choose a specific phase or task, ask them to specify which one.

> **Note:** Do NOT verify that the phase or task exists. Accept the user's answer and pass it to the skill. Validation happens during the implementation phase.

## Step 5: Invoke Implementation Skill

Invoke the **technical-implementation** skill for this conversation.

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
