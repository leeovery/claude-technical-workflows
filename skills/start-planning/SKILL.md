---
name: start-planning
description: "Start a planning session from an existing specification. Discovers available specifications, gathers context, and invokes the technical-planning skill."
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-planning/scripts/discovery.sh)
---

Invoke the **technical-planning** skill for this conversation.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

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

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Discovery State

!`.claude/skills/start-planning/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-planning/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

**From `specifications` section:**
- `exists` - whether any specifications exist
- `feature` - list of feature specs (name, status, has_plan, plan_status)
- `crosscutting` - list of cross-cutting specs (name, status)
- `counts.feature` - total feature specifications
- `counts.feature_ready` - feature specs ready for planning (concluded + no plan)
- `counts.feature_with_plan` - feature specs that already have plans
- `counts.crosscutting` - total cross-cutting specifications

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - each plan's name, format, status, and plan_id (if present)
- `common_format` - the output format if all existing plans share the same one; empty string otherwise

**From `state` section:**
- `scenario` - one of: `"no_specs"`, `"nothing_actionable"`, `"has_options"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_specs"

No specifications exist yet.

> *Output the next fenced block as a code block:*

```
Planning Overview

No specifications found in docs/workflow/specification/

The planning phase requires a concluded specification.
Run /start-specification first.
```

**STOP.** Wait for user to acknowledge before ending.

#### If scenario is "nothing_actionable"

Specifications exist but none are actionable — all are still in-progress and no plans exist to continue.

→ Proceed to **Step 3** to show the state.

#### If scenario is "has_options"

At least one specification is ready for planning, or an existing plan can be continued or reviewed.

→ Proceed to **Step 3** to present options.

---

## Step 3: Present Workflow State and Options

Present everything discovered to help the user make an informed choice.

**Present the full state:**

> *Output the next fenced block as a code block:*

```
Planning Overview

{N} specifications found. {M} plans exist.

1. {Topic Title Case}
   └─ Plan: none
   └─ Spec: concluded

2. {Topic Title Case}
   └─ Plan: in-progress
   └─ Spec: concluded

3. {Topic Title Case}
   └─ Plan: concluded
   └─ Spec: concluded
```

**Tree rules:**

Each numbered item shows a feature specification that is actionable:
- Concluded spec with no plan → `Plan: none`
- Has a plan with `plan_status: planning` → `Plan: in-progress`
- Has a plan with `plan_status: concluded` → `Plan: concluded`

Convert topic filenames to title case (`auth-flow` → `Auth Flow`).

**If non-plannable specifications exist**, show them in a separate code block:

> *Output the next fenced block as a code block:*

```
Specifications not ready for planning:
These specifications are either still in progress or cross-cutting
and cannot be planned directly.

  · {topic} (feature, in-progress)
  · {caching-strategy} (cross-cutting, concluded)
  · {rate-limiting} (cross-cutting, in-progress)
```

**Key/Legend** — show only statuses that appear in the current display. No `---` separator before this section.

> *Output the next fenced block as a code block:*

```
Key:

  Plan status:
    none        — no plan exists yet
    in-progress — planning work is ongoing
    concluded   — plan is complete

  Spec type:
    cross-cutting — architectural policy, not directly plannable
    feature       — plannable feature specification
```

Omit any section entirely if it has no entries.

**Then prompt based on what's actionable:**

**If multiple actionable items:**

The verb in the menu depends on the plan state:
- No plan exists → **Create**
- Plan is `in-progress` → **Continue**
- Plan is `concluded` → **Review**

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
1. Create "{Topic}" — concluded spec, no plan
2. Continue "{Topic}" — plan in-progress
3. Review "{Topic}" — plan concluded

Select an option (enter number):
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

**If single actionable item (auto-select):**

> *Output the next fenced block as a code block:*

```
Automatically proceeding with "{Topic}".
```

→ Proceed directly to **Step 4**.

**If nothing actionable:**

> *Output the next fenced block as a code block:*

```
Planning Overview

No plannable specifications found.

The planning phase requires a concluded feature specification.
Complete any in-progress specifications with /start-specification,
or create a new specification first.
```

**STOP.** This workflow cannot continue — do not proceed.

→ Based on user choice, proceed to **Step 4**.

---

## Step 4: Route by Plan State

Check whether the selected specification already has a plan (from `has_plan` in discovery output).

#### If no existing plan (fresh start)

→ Proceed to **Step 5** to gather context before invoking the skill.

#### If existing plan (continue or review)

The plan already has its context from when it was created. Skip context gathering.

→ Go directly to **Step 7** to invoke the skill.

---

## Step 5: Gather Additional Context

> *Output the next fenced block as a code block:*

```
Any additional context since the specification was concluded?

- Priorities, constraints, or new considerations?
- Or "none" if nothing has changed.
```

**STOP.** Wait for user response.

→ Proceed to **Step 6**.

---

## Step 6: Surface Cross-Cutting Context

**If no cross-cutting specifications exist**: Skip this step. → Proceed to **Step 7**.

Read each cross-cutting specification from `specifications.crosscutting` in the discovery output.

### 6a: Warn about in-progress cross-cutting specs

If any **in-progress** cross-cutting specifications exist, check whether they could be relevant to the feature being planned (by topic overlap — e.g., a caching strategy is relevant if the feature involves data retrieval or API calls).

If any are relevant:

> *Output the next fenced block as markdown (not a code block):*

```
Cross-cutting specifications still in progress:
These may contain architectural decisions relevant to this plan.

  · {rate-limiting} (in-progress)

· · · · · · · · · · · ·
- **`c`/`continue`** — Plan without them
- **`s`/`stop`** — Complete them first (/start-specification)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If the user chooses to stop, end here. If they choose to continue, proceed.

### 6b: Summarize concluded cross-cutting specs

If any **concluded** cross-cutting specifications exist, identify which are relevant to the feature being planned and summarize for handoff:

> *Output the next fenced block as a code block:*

```
Cross-cutting specifications to reference:
- caching-strategy.md: [brief summary of key decisions]
```

These specifications contain validated architectural decisions that should inform the plan. The planning skill will incorporate these as a "Cross-Cutting References" section in the plan.

→ Proceed to **Step 7**.

---

## Step 7: Invoke the Skill

After completing the steps above, this skill's purpose is fulfilled.

Invoke the [technical-planning](../technical-planning/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (fresh plan):**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Additional context: {summary of user's answers from Step 5}
Cross-cutting references: {list of applicable cross-cutting specs with brief summaries, or "none"}
Recommended output format: {common_format from discovery if non-empty, otherwise "none"}

Invoke the technical-planning skill.
```

**Example handoff (continue/review existing plan):**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Existing plan: docs/workflow/planning/{topic}.md

Invoke the technical-planning skill.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- The feature specification is the primary source of truth for planning
- Cross-cutting specifications provide supplementary context for architectural decisions
- Do not reference discussions - only specifications
