---
description: Start a review session from an existing plan and implementation. Discovers available plans, validates implementation exists, and invokes the technical-review skill.
---

Invoke the **technical-review** skill for this conversation.

## Workflow Context

This is **Phase 6** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| 3. Specification | REFINE - validate into standalone spec | |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| 5. Implementation | DOING - tests first, then code | |
| **6. Review** | VALIDATING - check work against artifacts | HERE |

**Stay in your lane**: Verify that every plan task was implemented, tested adequately, and meets quality standards. Don't fix code - identify problems. You're reviewing, not building.

---

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

The review phase requires a completed implementation based on a plan. Please run /workflow:start-planning first to create a plan, then /workflow:start-implementation to build it.
```

Stop here and wait for the user to acknowledge.

## Step 3: Present Options to User

Show what you found:

```
Plans found:
  {topic-1} (format: {format})
  {topic-2} (format: {format})

Which plan would you like to review the implementation for?
```

**Auto-select:** If exactly one plan exists, automatically select it and proceed to Step 4. Inform the user which plan was selected. Do not ask for confirmation.

## Step 4: Identify Implementation Scope

Determine what code to review:

1. **Check git status** - See what files have changed
2. **Ask user** if unclear:
   - "What code should I review? (all changes, specific directories, or specific files)"

## Step 5: Locate Specification (Optional)

Check if a specification exists:

1. **Look for specification**: Check `docs/workflow/specification/{topic}.md`
2. **If exists**: Note the path for context
3. **If missing**: Proceed without - the plan is the primary review artifact

## Step 6: Invoke the Skill

**Your work at this stage is complete.** You have gathered the inputs needed.

Now invoke the [technical-review](../skills/technical-review/SKILL.md) skill. The skill will provide the instructions for what to do next.

**Example handoff:**
```
Review session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Specification: docs/workflow/specification/{topic}.md (or: Not available)
Scope: {implementation scope}

Begin using the technical-review skill.
```

⛔ **Do not proceed without invoking the skill.** The skill contains the workflow rules for this phase.

## Notes

- Ask questions clearly and wait for responses before proceeding
- Review produces feedback (approve, request changes, or comments) - it does NOT fix code
