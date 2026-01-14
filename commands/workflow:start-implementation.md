---
description: Start an implementation session from an existing plan. Discovers available plans, checks environment setup, and invokes the technical-implementation skill.
---

## IMPORTANT: Follow these steps EXACTLY. Do not skip steps.

- Ask each question and WAIT for a response before proceeding
- Do NOT install anything or invoke tools until Step 6
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

> **Note:** If no plans exist, inform the user that this workflow is designed to be executed in sequence. They need to create plans from specifications prior to implementation using `/workflow:start-planning`.

> **Auto-select:** If exactly one plan exists, automatically select it and proceed to Step 3. Inform the user which plan was selected. Do not ask for confirmation.

```
Plans found:
  {topic-1}
  {topic-2}

Which plan would you like to implement?
```

## Step 3: Check External Dependencies

**This step is a gate.** Implementation cannot proceed if dependencies are not satisfied.

See **[dependencies.md](../skills/technical-planning/references/dependencies.md)** for dependency format and states.

After the user selects a plan:

1. **Read the External Dependencies section** from the plan index file
2. **Check each dependency** according to its state:
   - **Unresolved**: Block
   - **Resolved**: Check if task is complete (load output format reference, follow "Querying Dependencies" section)
   - **Satisfied externally**: Proceed

### Blocking Behavior

If ANY dependency is unresolved or incomplete, **stop and present**:

```
⚠️ Implementation blocked. Missing dependencies:

UNRESOLVED (not yet planned):
- billing-system: Invoice generation for order completion
  → No plan exists for this topic. Create with /workflow:start-planning or mark as satisfied externally.

INCOMPLETE (planned but not implemented):
- beads-7x2k (authentication): User context retrieval
  → Status: in_progress. This task must be completed first.

These dependencies must be completed before this plan can be implemented.

OPTIONS:
1. Implement the blocking dependencies first
2. Mark a dependency as "satisfied externally" if it was implemented outside this workflow
3. Run /workflow:link-dependencies to wire up any recently completed plans
```

### Escape Hatch

If the user says a dependency has been implemented outside the workflow:

1. Ask which dependency to mark as satisfied
2. Update the plan index file:
   - Change `- {topic}: {description}` to `- ~~{topic}: {description}~~ → satisfied externally`
3. Commit the change
4. Re-check dependencies

### All Dependencies Satisfied

If all dependencies are resolved and complete (or satisfied externally), proceed to Step 4.

```
✅ External dependencies satisfied:
- billing-system: Invoice generation → beads-b7c2.1.1 (complete)
- authentication: User context → beads-a3f8.1.2 (complete)

Proceeding with environment setup...
```

## Step 4: Check Environment Setup

> **IMPORTANT**: This step is for **information gathering only**. Do NOT execute any setup commands at this stage. The technical-implementation skill will handle execution when invoked.

After the user selects a plan:

1. Check if `docs/workflow/environment-setup.md` exists
2. If it exists, note the file location for the skill handoff
3. If missing, ask: "Are there any environment setup instructions I should follow?"
   - If the user provides instructions, save them to `docs/workflow/environment-setup.md`, commit and push to Git
   - If the user says no, create `docs/workflow/environment-setup.md` with "No special setup required." and commit. This prevents asking again in future sessions.
   - See `skills/technical-implementation/references/environment-setup.md` for format guidance

## Step 5: Ask About Scope

Ask the user about implementation scope:

```
How would you like to proceed?

1. **Implement all phases** - Work through the entire plan sequentially
2. **Implement specific phase** - Focus on one phase (e.g., "Phase 1")
3. **Implement specific task** - Focus on a single task
4. **Next available task** - Auto-discover the next unblocked task

Which approach?
```

If they choose a specific phase or task, ask them to specify which one.

> **Note:** Do NOT verify that the phase or task exists. Accept the user's answer and pass it to the skill. Validation happens during the implementation phase.

## Step 6: Invoke Implementation Skill

Invoke the **technical-implementation** skill for this conversation.

Pass to the technical-implementation skill:
- Plan: `docs/workflow/planning/{topic}.md`
- Format: (from frontmatter)
- Scope: (all phases | specific phase | specific task | next-available)
- Dependencies: (all satisfied - verified in Step 3)
- Environment setup: (completed | not needed)

**Example handoff:**
```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Scope: All phases

Dependencies: All satisfied ✓
Environment setup: Completed (or: Not needed)

Begin implementation using the technical-implementation skill.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- Execute environment setup before starting implementation
