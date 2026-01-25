---
description: Start a planning session from an existing specification. Discovers available specifications, asks where to store the plan, and invokes the technical-planning skill.
allowed-tools: Bash(.claude/scripts/discovery-for-planning.sh)
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

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Even if the user's initial prompt seems to answer a question, still confirm with them at the appropriate step
- Complete each step fully before moving to the next
- Do not act on gathered information until the skill is loaded - it contains the instructions for how to proceed

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` command and assess its output before proceeding to Step 1.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
.claude/scripts/discovery-for-planning.sh
```

This outputs structured YAML. Parse it to understand:

**From `specifications` section:**
- `exists` - whether any specifications exist
- `feature` - list of feature specs (name, status, has_plan)
- `crosscutting` - list of cross-cutting specs (name, status)
- `counts.feature` - total feature specifications
- `counts.feature_ready` - feature specs ready for planning (concluded + no plan)
- `counts.crosscutting` - total cross-cutting specifications

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - each plan's name, format, status, and plan_id (if present)

**From `state` section:**
- `scenario` - one of: `"no_specs"`, `"no_ready_specs"`, `"single_ready_spec"`, `"multiple_ready_specs"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_specs"

No specifications exist yet.

```
No specifications found in docs/workflow/specification/

The planning phase requires a concluded specification. Please run /start-specification first.
```

**STOP.** Wait for user to acknowledge before ending.

#### If scenario is "no_ready_specs"

Specifications exist but none are ready for planning (either still in-progress, or already have plans).

→ Proceed to **Step 3** to show the state.

#### If scenario is "single_ready_spec" or "multiple_ready_specs"

Specifications are ready for planning.

→ Proceed to **Step 3** to present options.

## Step 3: Present Workflow State and Options

Present everything discovered to help the user make an informed choice.

**Present the full state:**

```
Workflow Status: Planning Phase

Feature specifications:
  1. · {topic-1} (in-progress) - not ready
  2. ✓ {topic-2} (concluded) - ready for planning
  3. - {topic-3} (concluded) → plan exists

Cross-cutting specifications (reference context):
  - {caching-strategy} (concluded)
  - {rate-limiting} (concluded)

Existing plans:
  - {topic-3}.md (in-progress, {format})
```

**Legend:**
- `·` = not ready for planning (still in-progress)
- `✓` = ready for planning (concluded, no plan yet)
- `-` = already has a plan

**Then present options based on what's ready:**

**If multiple specs ready for planning:**
```
Which specification would you like to plan? (Enter a number or name)
```

**STOP.** Wait for user response.

**If single spec ready for planning (auto-select):**
```
Auto-selecting: {topic} (only ready specification)
```
→ Proceed directly to **Step 4**.

**If no specs ready for planning:**
```
No specifications ready for planning.

To proceed:
- Complete any "in-progress" specifications with /start-specification
- Or create a new specification first
```

**STOP.** Wait for user response before ending.

→ Based on user choice, proceed to **Step 4**.

---

## Step 4: Choose Output Destination

Ask: **Where should this plan live?**

Load **[output-formats.md](../../skills/technical-planning/references/output-formats.md)** and present the available formats to help the user choose. Then load the corresponding output adapter for that format's setup requirements.

**STOP.** Wait for user response.

→ Proceed to **Step 5**.

---

## Step 5: Gather Additional Context

Ask:
- Any additional context or priorities to consider?
- Any constraints since the specification was concluded?

**STOP.** Wait for user response.

→ Proceed to **Step 6**.

---

## Step 6: Surface Cross-Cutting Context

If any **concluded cross-cutting specifications** exist (from `specifications.crosscutting` in discovery), surface them as reference context for planning:

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

**If no cross-cutting specifications exist**: Skip this step.

→ Proceed to **Step 7**.

---

## Step 7: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-planning](../../skills/technical-planning/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff:**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Output format: {format}
Additional context: {summary of user's answers from Step 5}
Cross-cutting references: {list of applicable cross-cutting specs with brief summaries, or "none"}

Invoke the technical-planning skill.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- The feature specification is the primary source of truth for planning
- Cross-cutting specifications provide supplementary context for architectural decisions
- Do not reference discussions - only specifications
