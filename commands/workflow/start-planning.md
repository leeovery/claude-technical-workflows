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

**From `specifications` section:**
- Each specification's name, status, type (feature/cross-cutting), and whether it has a plan

**From `plans` array:**
- Each plan's name and format

**From `summary` section:**
- Counts of feature specs (total, complete, building)
- Counts of cross-cutting specs
- Number of existing plans

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

#### Otherwise (specifications exist)

→ Proceed to **Step 3**.

---

## Step 3: Present Options to User

Show what you found, separating feature specs (planning targets) from cross-cutting specs (reference context):

```
Feature Specifications (planning targets):
  {topic-1} - Building specification - not ready for planning
  {topic-2} - Complete - ready for planning
  {topic-3} - Complete - plan exists

Cross-Cutting Specifications (reference context):
  {caching-strategy} - Complete - will inform planning
  {rate-limiting} - Complete - will inform planning

Which feature specification would you like to create a plan for?
```

**Important:**
- Only completed **feature** specifications should proceed to planning
- **Cross-cutting** specifications are NOT planning targets - they inform feature plans
- If a specification is still being built, advise the user to complete the specification phase first

#### If exactly ONE completed feature specification exists

Auto-select and proceed. Do not ask for confirmation.

→ Proceed to **Step 4**.

#### If MULTIPLE completed feature specifications exist

Ask: **Which feature specification would you like to plan?**

**STOP.** Wait for user to select, then proceed to **Step 4**.

---

## Step 4: Choose Output Destination

Ask: **Where should this plan live?**

Load **[output-formats.md](../../skills/technical-planning/references/output-formats.md)** and present the available formats to help the user choose. Then load the corresponding output adapter for that format's setup requirements.

**STOP.** Wait for user to choose a format, then proceed to **Step 5**.

---

## Step 5: Gather Additional Context

Ask:
- Any additional context or priorities to consider?
- Any constraints since the specification was completed?

**STOP.** Wait for user response, then proceed to **Step 5b**.

---

## Step 5b: Surface Cross-Cutting Context

If any **completed cross-cutting specifications** exist, surface them as reference context for planning:

1. **List applicable cross-cutting specs**:
   - Read each cross-cutting specification
   - Identify which ones are relevant to the feature being planned
   - Relevance is determined by topic overlap (e.g., caching strategy applies if the feature involves data retrieval or API calls)

2. **Summarize for handoff**:
   ```
   Cross-cutting specifications to reference:
   - caching-strategy.md: [brief summary of key decisions]
   - rate-limiting.md: [brief summary of key decisions]
   ```

These specifications contain validated architectural decisions that should inform the plan. The planning skill will incorporate these as a "Cross-Cutting References" section in the plan.

#### If no cross-cutting specifications exist

Skip this step.

→ Proceed to **Step 6**.

---

## Step 6: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-planning](../../skills/technical-planning/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Output format: {format}
Additional context: {summary of user's answers from Step 5}
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
