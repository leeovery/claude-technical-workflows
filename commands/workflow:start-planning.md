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

## Step 1: Discover Existing Work

Scan the codebase for specifications and plans:

1. **Find specifications**: Look in `docs/workflow/specification/`
   - Run `ls docs/workflow/specification/` to list specification files
   - Each file is named `{topic}.md`

2. **Check specification status**: For each specification file
   - Run `head -20 docs/workflow/specification/{topic}.md` to read the frontmatter and extract the `status:` field
   - Do NOT use bash loops - run separate `head` commands for each topic

3. **Check for existing plans**: Look in `docs/workflow/planning/`
   - Identify specifications that don't have corresponding plans

## Step 2: Check Prerequisites

**If no specifications exist:**

```
⚠️ No specifications found in docs/workflow/specification/

The planning phase requires a completed specification. Please run /workflow:start-specification first to validate and refine the discussion content into a standalone specification before creating a plan.
```

Stop here and wait for the user to acknowledge.

## Step 3: Present Options to User

Show what you found using a list like below:

```
📂 Specifications found:
  ⚠️ {topic-1} - Building specification - not ready for planning
  ✅ {topic-2} - Complete - ready for planning
  ✅ {topic-3} - Complete - plan exists

Which specification would you like to create a plan for?
```

**Important:** Only completed specifications should proceed to planning. If a specification is still being built, advise the user to complete the specification phase first.

**Auto-select:** If exactly one specification exists, automatically select it and proceed to Step 4. Inform the user which specification was selected. Do not ask for confirmation.

Ask: **Which specification would you like to plan?**

## Step 4: Choose Output Destination

Ask: **Where should this plan live?**

Load **[output-formats.md](../skills/technical-planning/references/output-formats.md)** and present the available formats to help the user choose. Then load the corresponding output adapter for that format's setup requirements.

## Step 5: Gather Additional Context

- Any additional context or priorities to consider?
- Any constraints since the specification was completed?

## Step 6: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-planning](../skills/technical-planning/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff:**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Output format: {format}
Additional context: {summary of user's answers from Step 5}

Begin using the technical-planning skill.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- The specification is the sole source of truth for planning - do not reference discussions
