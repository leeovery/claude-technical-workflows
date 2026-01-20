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

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

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

**From `specifications` array:**
- Each specification's name, status, and type

**From `git_status` section:**
- Whether there are uncommitted changes
- List of changed files and directories

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

The review phase requires a completed implementation based on a plan. Please run /workflow:start-planning first to create a plan, then /workflow:start-implementation to build it.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### Otherwise (at least one plan exists)

→ Proceed to **Step 3**.

---

## Step 3: Present Status & Select Plan

Show the current state clearly. Use this EXACT format:

```
Workflow Status: Review Phase

Plans:
  • {topic-1} (format: {format}) - has specification
  • {topic-2} (format: {format}) - no specification

{If git has changes:}
Recent Changes:
  {directory-1}/: {N} files
  {directory-2}/: {N} files

{N} plans available for review
```

#### Routing Based on State

#### If exactly ONE plan exists

This is the simple path - auto-select.

```
Single plan found: {topic}

Proceeding with this plan.
```

→ Proceed to **Step 4: Identify Implementation Scope**.

#### If MULTIPLE plans exist

```
Which plan would you like to review the implementation for?

1. {topic-1} - has specification
2. {topic-2} - no specification
```

**STOP.** Wait for user to pick a number, then proceed to **Step 4**.

---

## Step 4: Identify Implementation Scope

Determine what code to review based on the discovery state.

#### If git has changes

```
I see the following changes in the repository:

{List changed directories with file counts}

Would you like me to:

1. **Review all changes** - All modified files
2. **Review specific directories** - Tell me which directories
3. **Review specific files** - Tell me which files

Which approach?
```

**STOP.** Wait for user response.

#### If user chooses "Review all changes"

→ Proceed to **Step 5**.

#### If user chooses specific directories or files

```
Which directories/files should I review?
```

**STOP.** Wait for user to specify, then proceed to **Step 5**.

#### If git has NO changes

```
No uncommitted changes detected.

What code should I review?

1. **Specific directories** - Tell me which directories
2. **Specific files** - Tell me which files
3. **Recent commits** - Review changes from recent commits

Which approach?
```

**STOP.** Wait for user response.

#### If user chooses specific directories or files

```
Which directories/files should I review?
```

**STOP.** Wait for user to specify, then proceed to **Step 5**.

#### If user chooses recent commits

```
How many recent commits should I review?
```

**STOP.** Wait for user to specify, then proceed to **Step 5**.

---

## Step 5: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-review](../../skills/technical-review/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

```
Review session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Specification: {docs/workflow/specification/{topic}.md | not available}
Scope: {all changes | directories: X, Y | files: A, B | last N commits}

---
Invoke the technical-review skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Review produces feedback (approve, request changes, or comments) - it does NOT fix code
- The plan is the primary artifact for review; the specification provides additional context if available
