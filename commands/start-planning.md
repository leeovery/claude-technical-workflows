---
description: Start a planning session from an existing specification. Discovers available specifications, asks where to store the plan, and invokes the technical-planning skill.
---

Invoke the **technical-planning** skill for this conversation.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

Before beginning, discover existing work and gather necessary information.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover Existing Work

Scan the codebase for specifications and plans:

1. **Find topic directories**: Look in `docs/workflow/*/`
   - First, run `ls docs/workflow/` to list topic directories
   - Then, for each topic, check for `specification.md` and `plan.md`

2. **Check specification status**: For each topic with a specification
   - Run `head -20 docs/workflow/{topic}/specification.md` to read the frontmatter and extract the `status:` field
   - Do NOT use bash loops - run separate `head` commands for each topic

3. **Identify gaps**: Topics with specifications but no plans

## Step 2: Check Prerequisites

**If no specifications exist:**

```
⚠️ No specifications found in docs/workflow/

The planning phase requires a completed specification. Please run /start-specification first to validate and refine the discussion content into a standalone specification before creating a plan.
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

Ask: **Which specification would you like to plan?**

## Step 4: Choose Output Destination

Ask: **Where should this plan live?**

1. **Local Markdown** - Simple `plan.md` file in `docs/workflow/{topic}/`
   - Best for: Small features, solo work, quick iterations
   - Everything in one version-controlled file

2. **Linear** - Project with labeled issues (requires MCP)
   - Best for: Team collaboration, visual tracking, larger features
   - Update tasks directly in Linear's UI
   - Phases denoted via labels (e.g., `phase-1`, `phase-2`)
   - Requires: Linear MCP server configured

3. **Backlog.md** - Task files in `backlog/` directory with Kanban UI
   - Best for: Local visual tracking with AI/MCP support
   - Terminal and web Kanban views
   - Git-native with auto-commit support

**If Linear or Backlog.md selected**: Check if MCP is available. If not, inform the user and suggest alternatives.

## Step 5: Gather Additional Context

**For Linear destination**:
- Which team should own this project?

**For all destinations**:
- Any additional context or priorities to consider?
- Any constraints since the specification was completed?

## Step 6: Invoke Planning Skill

Pass to the technical-planning skill:
- Topic directory: `docs/workflow/{topic}/`
- Specification: `docs/workflow/{topic}/specification.md`
- Output: `docs/workflow/{topic}/plan.md`
- Output destination: (local-markdown | linear | backlog-md)
- Additional context gathered

**Example handoff:**
```
Planning session for: {topic}
Topic directory: docs/workflow/{topic}/
Specification: docs/workflow/{topic}/specification.md
Output destination: Local Markdown
Output path: docs/workflow/{topic}/plan.md

Begin planning using the technical-planning skill.
Reference: formal-planning.md, then output-local-markdown.md
```

**Example handoff for Linear:**
```
Planning session for: {topic}
Topic directory: docs/workflow/{topic}/
Specification: docs/workflow/{topic}/specification.md
Output destination: Linear
Team: Engineering

Begin planning using the technical-planning skill.
Reference: formal-planning.md, then output-linear.md
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- The specification is the sole source of truth for planning - do not reference discussions
- Commit the plan files when complete
