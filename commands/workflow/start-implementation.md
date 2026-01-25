---
description: Start an implementation session from an existing plan. Discovers available plans, checks environment setup, and invokes the technical-implementation skill.
allowed-tools: Bash(.claude/scripts/discovery-for-implementation-and-review.sh)
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

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` command and assess its output before proceeding to Step 1.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
.claude/scripts/discovery-for-implementation-and-review.sh
```

This outputs structured YAML. Parse it to understand:

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - list of plans with: name, topic, status, date, format, specification, specification_exists
- `count` - total number of plans

**From `environment` section:**
- `setup_file_exists` - whether environment-setup.md exists
- `requires_setup` - true, false, or unknown

**From `state` section:**
- `scenario` - one of: `"no_plans"`, `"single_plan"`, `"multiple_plans"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_plans"

No plans exist yet.

```
No plans found in docs/workflow/planning/

The implementation phase requires a plan. Please run /start-planning first to create a plan from a specification.
```

**STOP.** Wait for user to acknowledge before ending.

#### If scenario is "single_plan" or "multiple_plans"

Plans exist.

→ Proceed to **Step 3** to present options.

---

## Step 3: Present Plans and Select

Present all discovered plans to help the user make an informed choice.

**Present the full state:**

```
Available Plans:

  1. {topic-1} (in-progress) - format: local-markdown
  2. {topic-2} (concluded) - format: local-markdown
  3. {topic-3} (in-progress) - format: beads

Which plan would you like to implement? (Enter a number or name)
```

**Legend:**
- `in-progress` = implementation ongoing or not started
- `concluded` = implementation complete (can still be selected for review/continuation)

**If single plan exists (auto-select):**
```
Auto-selecting: {topic} (only available plan)
```
→ Proceed directly to **Step 4**.

**If multiple plans exist:**

**STOP.** Wait for user response.

→ Based on user choice, proceed to **Step 4**.

---

## Step 4: Check External Dependencies

**This step is a gate.** Implementation cannot proceed if dependencies are not satisfied.

See **[dependencies.md](../../skills/technical-planning/references/dependencies.md)** for dependency format and states.

After the plan is selected:

1. **Read the External Dependencies section** from the plan file
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
  → No plan exists for this topic. Create with /start-planning or mark as satisfied externally.

INCOMPLETE (planned but not implemented):
- authentication: User context retrieval
  → Status: in-progress. This task must be completed first.

OPTIONS:
1. Implement the blocking dependencies first
2. Mark a dependency as "satisfied externally" if it was implemented outside this workflow
3. Run /link-dependencies to wire up any recently completed plans
```

**STOP.** Wait for user response.

### Escape Hatch

If the user says a dependency has been implemented outside the workflow:

1. Ask which dependency to mark as satisfied
2. Update the plan file: Change `- {topic}: {description}` to `- ~~{topic}: {description}~~ → satisfied externally`
3. Commit the change
4. Re-check dependencies

### All Dependencies Satisfied

If all dependencies are resolved and complete (or satisfied externally), proceed to Step 5.

```
✅ External dependencies satisfied.
```

→ Proceed to **Step 5**.

---

## Step 5: Check Environment Setup

> **IMPORTANT**: This step is for **information gathering only**. Do NOT execute any setup commands at this stage. The skill contains instructions for handling environment setup.

Use the `environment` section from the discovery output:

**If `setup_file_exists: true` and `requires_setup: false`:**
```
Environment: No special setup required.
```
→ Proceed to **Step 6**.

**If `setup_file_exists: true` and `requires_setup: true`:**
```
Environment setup file found: docs/workflow/environment-setup.md
```
→ Proceed to **Step 6**.

**If `setup_file_exists: false` or `requires_setup: unknown`:**

Ask:
```
Are there any environment setup instructions I should follow before implementation?
(Or "none" if no special setup is needed)
```

**STOP.** Wait for user response.

- If the user provides instructions, save them to `docs/workflow/environment-setup.md`, commit and push
- If the user says no/none, create `docs/workflow/environment-setup.md` with "No special setup required." and commit

→ Proceed to **Step 6**.

---

## Step 6: Ask About Scope

Ask the user about implementation scope:

```
How would you like to proceed?

1. Implement all phases - Work through the entire plan sequentially
2. Implement specific phase - Focus on one phase (e.g., "Phase 1")
3. Implement specific task - Focus on a single task
4. Next available task - Auto-discover the next incomplete task

Which approach?
```

**STOP.** Wait for user response.

If they choose a specific phase or task, ask them to specify which one.

> **Note:** Do NOT verify that the phase or task exists at this stage. Record the user's answer in the handoff context. Validation happens when the skill is invoked.

→ Proceed to **Step 7**.

---

## Step 7: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-implementation](../../skills/technical-implementation/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff:**
```
Implementation session for: {topic}
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Specification: {specification} (exists: {true|false})
Scope: {all phases | Phase N | Task N.M | next-available}

Dependencies: {All satisfied ✓ | List any notes}
Environment: {Setup required | No special setup required}

Invoke the technical-implementation skill.
```
