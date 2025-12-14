---
description: Start a specification session from an existing discussion. Discovers available discussions, checks for existing specifications, and invokes the technical-specification skill.
---

Invoke the **technical-specification** skill for this conversation.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

Before beginning, discover existing work and gather necessary information.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover Existing Work

Scan the codebase for discussions and specifications:

1. **Find discussions**: Look in `docs/specs/discussions/*/discussion.md`
   - First, run `ls docs/specs/discussions/` to list topic directories
   - Then, for each topic, run `head -20 docs/specs/discussions/{topic}/discussion.md` to read the frontmatter and extract the `status:` field
   - Do NOT use bash loops - run separate `head` commands for each topic

2. **Find existing specifications**: Look in `docs/specs/specifications/*/`
   - Run `ls docs/specs/specifications/` to list existing specifications
   - For each specification, run `ls docs/specs/specifications/{topic}/` to see what files exist

3. **Identify gaps**: Discussions without corresponding specifications

## Step 2: Check Prerequisites

**If no discussions exist:**

```
⚠️ No discussions found in docs/specs/discussions/

The specification phase requires a completed discussion. Please run /start-discussion first to document the technical decisions, edge cases, and rationale before creating a specification.
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

Ask: **Which discussion would you like to specify?**

## Step 4: Gather Additional Context

Ask:
- Any additional context or priorities to consider?
- Any constraints or changes since the discussion concluded?
- Are there any existing partial plans or related documentation I should review?

## Step 5: Invoke Specification Skill

Pass to the technical-specification skill:
- Discussion path: `docs/specs/discussions/{topic-name}/`
- Specification path: `docs/specs/specifications/{topic-name}/`
- Additional context gathered

**Example handoff:**
```
Specification session for: {topic-name}
Discussion: docs/specs/discussions/{topic-name}/discussion.md
Output: docs/specs/specifications/{topic-name}/specification.md

Begin specification using the technical-specification skill.
Reference: specification-guide.md
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- The specification phase validates and refines discussion content into a standalone document
- Commit the specification files frequently during the session
