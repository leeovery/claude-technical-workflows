---
description: Start an implementation session from an existing plan. Discovers available plans, checks environment setup, and invokes the technical-implementation skill.
allowed-tools: Bash(./scripts/implementation-discovery.sh), Bash(mkdir -p docs/workflow)
---

Invoke the **technical-implementation** skill for this conversation.

## Workflow Context

This is **Phase 5** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| 3. Specification | REFINE - validate into standalone spec | |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| **5. Implementation** | DOING - tests first, then code | ◀ HERE |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Execute the plan via strict TDD - tests first, then code. Don't re-debate decisions from the specification or expand scope beyond the plan. The plan is your authority.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices. Do NOT install anything or invoke tools until the final step.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
./scripts/implementation-discovery.sh
```

This outputs structured YAML. Parse it to understand:

**From `plans` array:**
- Each plan's name and format
- Each plan's dependencies (with state: unresolved/resolved/satisfied_externally)
- Dependency summary counts

**From `environment` section:**
- Whether environment setup file exists
- Whether it has actual setup steps

**From `summary` section:**
- Total plan count
- Plans ready for implementation
- Plans with unresolved dependencies

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Check Prerequisites

#### If no plans exist

```
No plans found in docs/workflow/planning/

The implementation phase requires a completed plan. Please run /start-planning first to create a plan from a specification.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### Otherwise (at least one plan exists)

→ Proceed to **Step 3**.

---

## Step 3: Present Status & Select Plan

Show the current state clearly. Use this EXACT format:

```
Workflow Status: Implementation Phase

Plans:
  ✓ {topic-1} (format: {format}) - ready
  ✗ {topic-2} (format: {format}) - blocked ({N} unresolved dependencies)

{N} plans, {M} ready for implementation
```

**Legend:**
- `✓` = Ready for implementation (no blocking dependencies)
- `✗` = Blocked (has unresolved dependencies)

#### Routing Based on State

#### If exactly ONE plan exists

This is the simple path - auto-select.

```
Single plan found: {topic}

Proceeding with this plan.
```

→ Proceed to **Step 4: Check External Dependencies**.

#### If MULTIPLE plans exist

```
Which plan would you like to implement?

1. {topic-1} - ready
2. {topic-2} - blocked (2 unresolved dependencies)
```

**STOP.** Wait for user to pick a number, then proceed to **Step 4**.

---

## Step 4: Check External Dependencies

**This step is a gate.** Implementation cannot proceed if dependencies are not satisfied.

Check the selected plan's dependencies from the discovery state.

#### If ALL dependencies are resolved or satisfied

```
External dependencies satisfied:
  ✓ {topic-1}: {description} → {task-id} (complete)
  ✓ {topic-2}: {description} → satisfied externally

Proceeding with environment check...
```

→ Proceed to **Step 5: Check Environment Setup**.

#### If ANY dependencies are unresolved or incomplete

```
Implementation blocked. Missing dependencies:

UNRESOLVED (not yet planned):
  - {topic}: {description}
    → No plan exists for this topic. Create with /start-planning or mark as satisfied externally.

INCOMPLETE (planned but not implemented):
  - {task-id} ({topic}): {description}
    → Status: in_progress. This task must be completed first.

OPTIONS:
1. Implement the blocking dependencies first
2. Mark a dependency as "satisfied externally" if it was implemented outside this workflow
3. Run /link-dependencies to wire up any recently completed plans

Which option?
```

**STOP.** Wait for user response.

#### If user chooses to mark as satisfied externally

```
Which dependency should be marked as satisfied externally?
```

**STOP.** Wait for user to specify.

Update the plan index file:
- Change `- {topic}: {description}` to `- ~~{topic}: {description}~~ → satisfied externally`

Commit the change, then re-check dependencies by returning to the start of **Step 4**.

#### If user chooses another option

Acknowledge their choice and **STOP.** Do not proceed with implementation.

---

## Step 5: Check Environment Setup

Check the `environment.setup_exists` value from the discovery state.

#### If environment setup file exists

```
Environment setup: docs/workflow/environment-setup.md exists
```

Note the file location for the skill handoff.

→ Proceed to **Step 6**.

#### If environment setup file does NOT exist

```
No environment setup file found.

Are there any environment setup instructions I should follow?
(e.g., install dependencies, configure services, set environment variables)

Enter instructions or press enter to skip:
```

**STOP.** Wait for user response.

#### If user provides instructions

Save them to `docs/workflow/environment-setup.md`:

```bash
mkdir -p docs/workflow
```

Write the file with the user's instructions. Commit and push to Git.

→ Proceed to **Step 6**.

#### If user skips (presses enter)

Create `docs/workflow/environment-setup.md` with content:
```
No special setup required.
```

Commit and push to Git. This prevents asking again in future sessions.

→ Proceed to **Step 6**.

---

## Step 6: Ask About Scope

```
How would you like to proceed?

1. **Implement all phases** - Work through the entire plan sequentially
2. **Implement specific phase** - Focus on one phase (e.g., "Phase 1")
3. **Implement specific task** - Focus on a single task
4. **Next available task** - Auto-discover the next unblocked task

Which approach?
```

**STOP.** Wait for user response.

#### If user chooses specific phase or task

```
Which phase/task would you like to implement?
```

**STOP.** Wait for user to specify, then proceed to **Step 7**.

Note: Do NOT validate that the phase or task exists. Accept the user's answer and pass it to the skill. Validation happens during implementation.

#### If user chooses all phases or next available

→ Proceed to **Step 7**.

---

## Step 7: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-implementation](../../skills/technical-implementation/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Scope: {all phases | phase N | task X | next-available}

Dependencies: All satisfied ✓
Environment setup: {docs/workflow/environment-setup.md | not needed}

---
Invoke the technical-implementation skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Dependencies are a hard gate - do not proceed if any are unresolved
- Environment setup is gathered for information only - execution happens in the skill
