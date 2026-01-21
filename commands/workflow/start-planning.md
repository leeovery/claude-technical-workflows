---
description: Start a planning session from an existing specification. Discovers available specifications, asks where to store the plan, and invokes the technical-planning skill.
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

Before beginning, discover existing work and gather necessary information.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Run `/migrate-documents` and assess its output before proceeding to Step 1.

---

## Step 1: Discover Existing Work

Scan the codebase for specifications and plans:

1. **Find specifications**: Look in `docs/workflow/specification/`
   - Run `ls docs/workflow/specification/` to list specification files
   - Each file is named `{topic}.md`

2. **Check specification metadata**: For each specification file
   - Run `head -20 docs/workflow/specification/{topic}.md` to read the frontmatter
   - Extract the `status:` field (Building specification | Complete)
   - Extract the `type:` field (feature | cross-cutting) - if not present, default to `feature`
   - Do NOT use bash loops - run separate `head` commands for each topic

3. **Categorize specifications**:
   - **Feature specifications** (`type: feature` or unspecified): Candidates for planning
   - **Cross-cutting specifications** (`type: cross-cutting`): Reference context only - do NOT offer for planning

4. **Check for existing plans**: Look in `docs/workflow/planning/`
   - Identify feature specifications that don't have corresponding plans

## Step 2: Check Prerequisites

**If no specifications exist:**

```
⚠️ No specifications found in docs/workflow/specification/

The planning phase requires a completed specification. Please run /start-specification first to validate and refine the discussion content into a standalone specification before creating a plan.
```

Stop here and wait for the user to acknowledge.

## Step 3: Present Options to User

Show what you found, separating feature specs (planning targets) from cross-cutting specs (reference context):

```
📂 Feature Specifications (planning targets):
  ⚠️ {topic-1} - Building specification - not ready for planning
  ✅ {topic-2} - Complete - ready for planning
  ✅ {topic-3} - Complete - plan exists

📚 Cross-Cutting Specifications (reference context):
  ✅ {caching-strategy} - Complete - will inform planning
  ✅ {rate-limiting} - Complete - will inform planning

Which feature specification would you like to create a plan for?
```

**Important:**
- Only completed **feature** specifications should proceed to planning
- **Cross-cutting** specifications are NOT planning targets - they inform feature plans
- If a specification is still being built, advise the user to complete the specification phase first

**Auto-select:** If exactly one completed feature specification exists, automatically select it and proceed to Step 4. Inform the user which specification was selected. Do not ask for confirmation.

Ask: **Which feature specification would you like to plan?**

## Step 4: Choose Output Destination

Ask: **Where should this plan live?**

Load **[output-formats.md](../../skills/technical-planning/references/output-formats.md)** and present the available formats to help the user choose. Then load the corresponding output adapter for that format's setup requirements.

## Step 5: Gather Additional Context

- Any additional context or priorities to consider?
- Any constraints since the specification was completed?

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

**If no cross-cutting specifications exist**: Skip this step.

## Step 6: Invoke the Skill

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
