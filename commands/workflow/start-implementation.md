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

## IMPORTANT: Follow these steps EXACTLY. Do not skip steps.

- Ask each question and WAIT for a response before proceeding
- Do NOT install anything or invoke tools until Step 6
- Even if the user's initial prompt seems to answer a question, still confirm with them at the appropriate step
- Do NOT make assumptions about what the user wants
- Complete each step fully before moving to the next

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

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

**From `environment` section:**
- Whether environment setup file exists

**From `summary` section:**
- Total plan count

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Present Options to User

Show what you found.

#### If no plans exist

Inform the user that this workflow is designed to be executed in sequence. They need to create plans from specifications prior to implementation using `/start-planning`.

**STOP.** Wait for user acknowledgment. Do not proceed.

#### If exactly ONE plan exists

Auto-select and proceed. Do not ask for confirmation.

```
Single plan found: {topic}

Proceeding with this plan.
```

→ Proceed to **Step 3: Check External Dependencies**.

#### If MULTIPLE plans exist

```
Plans found:
  {topic-1}
  {topic-2}

Which plan would you like to implement?
```

**STOP.** Wait for user to select a plan, then proceed to **Step 3**.

---

## Step 3: Check External Dependencies

**This step is a gate.** Implementation cannot proceed if dependencies are not satisfied.

See **[dependencies.md](../../skills/technical-planning/references/dependencies.md)** for dependency format and states.

After the user selects a plan:

1. **Read the External Dependencies section** from the plan index file (use discovery state)
2. **Check each dependency** according to its state:
   - **Unresolved**: Block
   - **Resolved**: Check if task is complete (load output format reference, follow "Querying Dependencies" section)
   - **Satisfied externally**: Proceed

### Blocking Behavior

If ANY dependency is unresolved or incomplete, **stop and present**:

```
Implementation blocked. Missing dependencies:

UNRESOLVED (not yet planned):
- billing-system: Invoice generation for order completion
  → No plan exists for this topic. Create with /start-planning or mark as satisfied externally.

INCOMPLETE (planned but not implemented):
- beads-7x2k (authentication): User context retrieval
  → Status: in_progress. This task must be completed first.

These dependencies must be completed before this plan can be implemented.

OPTIONS:
1. Implement the blocking dependencies first
2. Mark a dependency as "satisfied externally" if it was implemented outside this workflow
3. Run /link-dependencies to wire up any recently completed plans
```

**STOP.** Wait for user response.

### Escape Hatch

If the user says a dependency has been implemented outside the workflow:

1. Ask which dependency to mark as satisfied
2. Update the plan index file:
   - Change `- {topic}: {description}` to `- ~~{topic}: {description}~~ → satisfied externally`
3. Commit the change
4. Re-check dependencies

### All Dependencies Satisfied

If all dependencies are resolved and complete (or satisfied externally):

```
External dependencies satisfied:
- billing-system: Invoice generation → beads-b7c2.1.1 (complete)
- authentication: User context → beads-a3f8.1.2 (complete)

Proceeding with environment setup...
```

→ Proceed to **Step 4**.

---

## Step 4: Check Environment Setup

> **IMPORTANT**: This step is for **information gathering only**. Do NOT execute any setup commands at this stage. Execution instructions are in the technical-implementation skill.

Check the `environment.setup_exists` value from the discovery state.

#### If environment setup file exists

Note the file location for the skill handoff.

→ Proceed to **Step 5**.

#### If environment setup file does NOT exist

Ask: "Are there any environment setup instructions I should follow?"

**STOP.** Wait for user response.

#### If user provides instructions

Save them to `docs/workflow/environment-setup.md`:

```bash
mkdir -p docs/workflow
```

Write the file with the user's instructions. Commit and push to Git. See `skills/technical-implementation/references/environment-setup.md` for format guidance.

→ Proceed to **Step 5**.

#### If user says no

Create `docs/workflow/environment-setup.md` with "No special setup required." and commit. This prevents asking again in future sessions.

→ Proceed to **Step 5**.

---

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

**STOP.** Wait for user response.

#### If user chooses specific phase or task

Ask them to specify which one.

**STOP.** Wait for user to specify, then proceed to **Step 6**.

> **Note:** Do NOT verify that the phase or task exists. Accept the user's answer and pass it to the skill. Validation happens during the implementation phase.

#### If user chooses all phases or next available

→ Proceed to **Step 6**.

---

## Step 6: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-implementation](../../skills/technical-implementation/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Scope: {all phases | specific phase | specific task | next-available}

Dependencies: All satisfied ✓
Environment setup: {completed | not needed}

---
Invoke the technical-implementation skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Dependencies are a hard gate - do not proceed if any are unresolved
