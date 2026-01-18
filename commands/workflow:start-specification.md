---
description: Start a specification session from an existing discussion. Discovers available discussions, checks for existing specifications, and invokes the technical-specification skill.
---

Invoke the **technical-specification** skill for this conversation.

## Workflow Context

This is **Phase 3** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| **3. Specification** | REFINE - validate into standalone spec | ◀ HERE |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| 5. Implementation | DOING - tests first, then code | |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Validate and refine discussion content into a standalone specification. Don't jump to planning, phases, tasks, or code. The specification is the "line in the sand" - everything after this has hard dependencies on it.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

Before beginning, discover existing work and gather necessary information.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover Existing Work

Scan the codebase for discussions and specifications:

1. **Find discussions**: Look in `docs/workflow/discussion/`
   - Run `ls docs/workflow/discussion/` to list discussion files
   - Each file is named `{topic}.md`

2. **Check discussion status**: For each discussion file
   - Run `head -20 docs/workflow/discussion/{topic}.md` to read the frontmatter and extract the `status:` field
   - Do NOT use bash loops - run separate `head` commands for each topic

3. **Check for existing specifications**: Look in `docs/workflow/specification/`
   - Identify discussions that don't have corresponding specifications

## Step 2: Check Prerequisites

**If no discussions exist:**

```
⚠️ No discussions found in docs/workflow/discussion/

The specification phase requires a completed discussion. Please run /workflow:start-discussion first to document the technical decisions, edge cases, and rationale before creating a specification.
```

Stop here and wait for the user to acknowledge.

## Step 3: Present Options to User

Show what you found using a list like below:

```
📂 Discussions found:
  ✅ {topic-1} - Concluded - ready for specification
  ⚠️ {topic-2} - Exploring - not ready for specification
  ✅ {topic-3} - Concluded - specification exists

Which discussion would you like to create a specification for?
```

**Important:** Only concluded discussions should proceed to specification. If a discussion is still exploring, advise the user to complete the discussion phase first.

Ask: **Which discussion would you like to specify?**

## Step 4: Gather Additional Context

Ask:
- Any additional context or priorities to consider?
- Any constraints or changes since the discussion concluded?
- Are there any existing partial plans or related documentation I should review?

## Step 5: Invoke the Skill

**Your work at this stage is complete.** You have gathered the inputs needed.

Now invoke the [technical-specification](../skills/technical-specification/SKILL.md) skill. The skill contains the instructions for what to do next.

**Example handoff:**
```
Specification session for: {topic}
Source: docs/workflow/discussion/{topic}.md
Output: docs/workflow/specification/{topic}.md
Additional context: {summary of user's answers from Step 4}

Begin using the technical-specification skill.
```

**STOP: Do not proceed without invoking the skill.** The skill contains the workflow rules for this phase.

## Notes

- Ask questions clearly and wait for responses before proceeding
- The specification phase validates and refines discussion content into a standalone document
