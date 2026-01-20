---
description: Start a planning session from an existing specification. Discovers available specifications, asks where to store the plan, and invokes the technical-planning skill.
allowed-tools: Bash(./scripts/planning-discovery.sh)
---

Invoke the **technical-planning** skill for this conversation.

## Workflow Context

This is **Phase 4** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| 3. Specification | REFINE - validate into standalone spec | |
| **4. Planning** | HOW - phases, tasks, acceptance criteria | ◀ HERE |
| 5. Implementation | DOING - tests first, then code | |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Create the plan - phases, tasks, and acceptance criteria. Don't jump to implementation or write code. The specification is your sole input; transform it into actionable work items.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
./scripts/planning-discovery.sh
```

This outputs structured YAML. Parse it to understand:

**From `specifications` array:**
- Each specification's name, status, type (feature/cross-cutting), and whether it has a plan

**From `plans` array:**
- Each plan's name and format

**From `summary` section:**
- Counts of feature specs (total, complete, building)
- Counts of cross-cutting specs
- Number of existing plans
- Number of specs ready for planning

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Check Prerequisites

#### If no specifications exist

```
No specifications found in docs/workflow/specification/

The planning phase requires a completed specification. Please run /start-specification first to validate and refine the discussion content into a standalone specification before creating a plan.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### If no complete feature specifications exist

```
No complete feature specifications found.

The following specifications are not ready for planning:
  - {topic-1} (building) - still in progress
  - {topic-2} (cross-cutting) - reference only, not a planning target

Please complete the specification phase before creating a plan. Run /start-specification to continue a specification.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### Otherwise (at least one complete feature specification exists)

→ Proceed to **Step 3**.

---

## Step 3: Present Status & Route

Show the current state clearly. Use this EXACT format:

```
Workflow Status: Planning Phase

Feature Specifications (planning targets):
  ✗ {topic-1} - building - not ready for planning
  ✓ {topic-2} - complete - ready for planning
  ○ {topic-3} - complete - plan exists

Cross-Cutting Specifications (reference context):
  • {caching-strategy} - complete - will inform planning
  • {rate-limiting} - complete - will inform planning

{N} feature specifications, {M} ready for planning
```

**Legend:**
- `✗` = Building, not ready
- `✓` = Complete, ready for planning (no plan yet)
- `○` = Complete, plan already exists

**Important:**
- Only completed **feature** specifications should proceed to planning
- **Cross-cutting** specifications are NOT planning targets - they inform feature plans
- If a specification is still being built, advise the user to complete the specification phase first

#### Routing Based on State

#### If exactly ONE complete feature specification exists (ready for planning)

Auto-select and proceed. Do not ask for confirmation.

```
Single specification ready for planning: {topic}

Proceeding with this specification.
```

→ Skip to **Step 4: Choose Output Format**.

#### If MULTIPLE complete feature specifications exist

```
Which feature specification would you like to plan?

1. {topic-1} - ready for planning
2. {topic-2} - ready for planning
3. {topic-3} - plan exists
```

**STOP.** Wait for user to pick a number, then proceed to **Step 4**.

---

## Step 4: Choose Output Format

Ask where the plan should live:

```
Where should this plan live?
```

Load **[output-formats.md](../../skills/technical-planning/references/output-formats.md)** and present the available formats with brief descriptions to help the user choose.

**STOP.** Wait for user to choose a format, then proceed to **Step 5**.

Note: After user chooses, load the corresponding output adapter (`output-{format}.md`) to understand the setup requirements before proceeding.

---

## Step 5: Gather Additional Context

```
Before creating the plan:

1. Any additional context or priorities to consider?
2. Any constraints since the specification was completed?

(Press enter to skip if none)
```

**STOP.** Wait for user response, then proceed to **Step 6**.

---

## Step 6: Surface Cross-Cutting Context

Check if any **completed cross-cutting specifications** exist from the discovery state.

#### If cross-cutting specifications exist

Read each cross-cutting specification and identify which ones are relevant to the feature being planned.

Relevance is determined by topic overlap (e.g., caching strategy applies if the feature involves data retrieval or API calls).

Summarize for handoff:

```
Cross-cutting specifications to reference:
- caching-strategy.md: {brief summary of key decisions}
- rate-limiting.md: {brief summary of key decisions}

These contain validated architectural decisions that will inform the plan.
```

→ Proceed to **Step 7**.

#### If no cross-cutting specifications exist

→ Proceed to **Step 7**.

---

## Step 7: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-planning](../../skills/technical-planning/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Output format: {format}

Additional context: {summary of user's answers from Step 5, or "none"}

Cross-cutting references: {list of applicable cross-cutting specs with brief summaries, or "none"}

---
Invoke the technical-planning skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- The feature specification is the primary source of truth for planning
- Cross-cutting specifications provide supplementary context for architectural decisions
- Do not reference discussions - only specifications
