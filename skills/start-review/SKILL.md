---
name: start-review
description: "Start a review session from an existing plan and implementation. Discovers available plans, validates implementation exists, and invokes the technical-review skill."
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-review/scripts/discovery.sh)
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

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Even if the user's initial prompt seems to answer a question, still confirm with them at the appropriate step
- Complete each step fully before moving to the next
- Do not act on gathered information until the skill is loaded - it contains the instructions for how to proceed

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Discovery State

!`.claude/skills/start-review/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-review/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - list of plans with: name, topic, status, date, format, specification, specification_exists, plan_id (if present)
- `count` - total number of plans

**From `state` section:**
- `scenario` - one of: `"no_plans"`, `"single_plan"`, `"multiple_plans"`
- `implemented_count` - plans with implementation_status != "none"
- `completed_count` - plans with implementation_status == "completed"

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_plans"

No plans exist yet.

```
No plans found in docs/workflow/planning/

The review phase requires a completed implementation based on a plan. Please run /start-planning first to create a plan, then /start-implementation to build it.
```

**STOP.** Wait for user to acknowledge before ending.

#### If scenario is "single_plan" or "multiple_plans"

Plans exist.

→ Proceed to **Step 3** to present options.

---

## Step 3a: Review Scope

Present the scope selection. If only one implemented plan exists, auto-select single scope and proceed to Step 3b.

```
· · · · · · · · · · · ·
What scope would you like to review?

- **`s`/`single`** — Review one plan's implementation
- **`m`/`multi`** — Review selected plans together (cross-cutting)
- **`a`/`all`** — Review all implemented plans (full product)
· · · · · · · · · · · ·
```

**If only one implemented plan exists (auto-select):**
```
Auto-selecting single scope (only one implemented plan)
```
→ Proceed directly to **Step 3b**.

**If multiple implemented plans exist:**

**STOP.** Wait for user response.

→ Based on user choice, proceed to **Step 3b**.

---

## Step 3b: Plan Selection

**For single scope:** Present list of implemented plans, user picks one.

```
Available Plans:

  1. {topic-1} ({status}) - format: {format}, impl: {implementation_status}, spec: {exists|missing}
  2. {topic-2} ({status}) - format: {format}, impl: {implementation_status}, spec: {exists|missing}

· · · · · · · · · · · ·
Which plan would you like to review? (Enter a number or name)
```

Only show plans with implementation_status != "none".

**If single plan auto-selected from Step 3a:**
```
Auto-selecting: {topic} (only implemented plan)
```
→ Proceed directly to **Step 4**.

**If multiple plans exist:**

**STOP.** Wait for user response.

→ Based on user choice, proceed to **Step 4**.

**For multi scope:** Present list with multi-select.

```
Available Plans:

  1. {topic-1} ({status}) - impl: {implementation_status}
  2. {topic-2} ({status}) - impl: {implementation_status}
  3. {topic-3} ({status}) - impl: {implementation_status}

· · · · · · · · · · · ·
Which plans to include? (Enter numbers separated by commas, e.g. 1,3)
```

Only show plans with implementation_status != "none".

**STOP.** Wait for user response.

→ Based on user choice, proceed to **Step 4**.

**For all scope:** No selection needed — include all plans with implementation_status != "none".

→ Proceed directly to **Step 4**.

---

## Step 4: Identify Implementation Scope

**For single scope:** Ask what code to review:

```
· · · · · · · · · · · ·
What code should I review?

- **`a`/`all`** — All changes since the plan was created
- **`g`/`git`** — Identify from git status
- Specific directories or files — tell me which
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If they choose specific directories/files, ask them to specify.

**For multi/all scope:** Default to all changes. Briefly confirm:

```
· · · · · · · · · · · ·
For multi-plan review, defaulting to all implementation changes.
Override with specific paths? (Enter paths or press enter to continue)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 5**.

---

## Step 5: Invoke the Skill

After completing the steps above, this skill's purpose is fulfilled.

Invoke the [technical-review](../technical-review/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (single):**
```
Review session for: {topic}
Review scope: single
Plan: docs/workflow/planning/{topic}.md
Format: {format}
Plan ID: {plan_id} (if applicable)
Specification: {specification} (exists: {true|false})
Implementation scope: {all changes | specific paths | from git status}

Invoke the technical-review skill.
```

**Example handoff (multi/all):**
```
Review session for: {scope description}
Review scope: {multi | all}
Plans:
  - docs/workflow/planning/{topic-1}.md (format: {format}, spec: {spec})
  - docs/workflow/planning/{topic-2}.md (format: {format}, spec: {spec})
Implementation scope: {all changes | specific paths}

Invoke the technical-review skill.
```
