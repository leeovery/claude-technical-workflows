---
description: Start an implementation session from an existing plan. Discovers available plans, checks environment setup, and invokes the technical-implementation skill.
---

Invoke the **technical-implementation** skill for this conversation.

## Instructions

Follow these steps to gather information, then hand off to the skill.

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners.

## Step 1: Discover Existing Plans

1. **Find plans**: Run `ls docs/workflow/planning/` to list plan files

2. **Check plan format**: For each plan file, run `head -10 docs/workflow/planning/{topic}.md` to read the frontmatter

**If no plans exist**, inform the user and suggest running `/start-planning` first.

## Step 2: Present Options

Show what you found and ask which plan to implement.

## Step 3: Check Environment Setup

After the user selects a plan:

1. Check if `docs/workflow/environment-setup.md` exists
2. If it exists, follow the setup instructions
3. If missing, ask: "Are there any environment setup instructions I should follow?"

## Step 4: Ask About Scope

Ask the user:

```
How would you like to proceed?

1. **Implement all phases** - Work through the entire plan sequentially
2. **Implement specific phase** - Focus on one phase
3. **Implement specific task** - Focus on a single task
```

## Step 5: Invoke Implementation Skill

Hand off to the technical-implementation skill with:
- Plan path
- Scope chosen

**Example:**
```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Scope: All phases

Begin implementation using the technical-implementation skill.
```
