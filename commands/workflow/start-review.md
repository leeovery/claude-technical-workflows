---
description: Start a review session from an existing plan and implementation. Discovers available plans, validates implementation exists, and invokes the technical-review skill.
allowed-tools: Bash(./scripts/review-discovery.sh)
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
| **6. Review** | VALIDATING - check work against artifacts | ◀ HERE |

**Stay in your lane**: Verify that every plan task was implemented, tested adequately, and meets quality standards. Don't fix code - identify problems. You're reviewing, not building.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
./scripts/review-discovery.sh
```

This outputs structured YAML. Parse it to understand:

**From `plans` array:**
- Each plan's name, format, and whether it has a corresponding specification

**From `git_status` section:**
- Whether there are uncommitted changes
- List of changed files

**From `summary` section:**
- Total plan count
- Plans with specifications

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Check Prerequisites

#### If no plans exist

```
No plans found in docs/workflow/planning/

The review phase requires a completed implementation based on a plan. Please run /start-planning first to create a plan, then /start-implementation to build it.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### Otherwise (at least one plan exists)

→ Proceed to **Step 3**.

---

## Step 3: Present Options to User

Show what you found:

```
Plans found:
  {topic-1} (format: {format})
  {topic-2} (format: {format})

Which plan would you like to review the implementation for?
```

#### If exactly ONE plan exists

Auto-select and proceed. Do not ask for confirmation.

→ Proceed to **Step 4**.

#### If MULTIPLE plans exist

**STOP.** Wait for user to select a plan, then proceed to **Step 4**.

---

## Step 4: Identify Implementation Scope

Determine what code to review:

1. **Check git status** - Use the `git_status` section from the discovery state to see what files have changed

2. **Ask user** if unclear:

```
What code should I review? (all changes, specific directories, or specific files)
```

**STOP.** Wait for user response, then proceed to **Step 5**.

---

## Step 5: Locate Specification (Optional)

Check if a specification exists:

1. **Look for specification**: Check if `docs/workflow/specification/{topic}.md` exists (use `has_specification` from discovery state)

2. **If exists**: Note the path for context

3. **If missing**: Proceed without - the plan is the primary review artifact

→ Proceed to **Step 6**.

---

## Step 6: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-review](../../skills/technical-review/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

```
Review session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Specification: {docs/workflow/specification/{topic}.md | not available}
Scope: {implementation scope}

---
Invoke the technical-review skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Review produces feedback (approve, request changes, or comments) - it does NOT fix code
- The plan is the primary artifact for review; the specification provides additional context if available
