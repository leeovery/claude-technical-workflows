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

1. **Local Markdown** - Simple `{topic}.md` file in `docs/workflow/planning/`
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

4. **Beads** - Git-backed graph issue tracker for AI agents
   - Best for: Complex dependency graphs, multi-session implementations
   - Native dependency tracking with `bd ready` for unblocked work
   - Hierarchical: epics → phases → tasks
   - Requires: Beads CLI installed (`bd`)

**If Linear or Backlog.md selected**: Check if MCP is available. If not, inform the user and suggest alternatives.

**If Beads selected**: Check if `bd` command is available. If not, offer to install it:

```bash
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

This works on both local Claude Code and Claude Code on the web.

## Step 5: Gather Additional Context

**For Linear destination**:
- Which team should own this project?

**For all destinations**:
- Any additional context or priorities to consider?
- Any constraints since the specification was completed?

## Step 6: Invoke Planning Skill

Pass to the technical-planning skill:
- Specification: `docs/workflow/specification/{topic}.md`
- Output: `docs/workflow/planning/{topic}.md`
- Output destination: (local-markdown | linear | backlog-md | beads)
- Additional context gathered

**Example handoff:**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Output destination: Local Markdown
Output path: docs/workflow/planning/{topic}.md

Begin planning using the technical-planning skill.
Reference: formal-planning.md, then output-local-markdown.md
```

**Example handoff for Linear:**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Output destination: Linear
Team: Engineering

Begin planning using the technical-planning skill.
Reference: formal-planning.md, then output-linear.md
```

**Example handoff for Beads:**
```
Planning session for: {topic}
Specification: docs/workflow/specification/{topic}.md
Output destination: Beads
Output path: docs/workflow/planning/{topic}.md

Begin planning using the technical-planning skill.
Reference: formal-planning.md, then output-beads.md
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- The specification is the sole source of truth for planning - do not reference discussions
- Commit the plan files when complete
