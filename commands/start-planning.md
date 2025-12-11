---
description: Start a planning session from an existing discussion. Discovers available discussions, asks where to store the plan, and invokes the technical-planning skill.
---

Invoke the **technical-planning** skill for this conversation.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

Before beginning, discover existing work and gather necessary information.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover Existing Work

Scan the codebase for discussions and plans:

1. **Find discussions**: Look in `docs/specs/discussions/*/discussion.md`
   - First, run `ls docs/specs/discussions/` to list topic directories
   - Then, for each topic, run `head -20 docs/specs/discussions/{topic}/discussion.md` to read the frontmatter and extract the `status:` field
   - Do NOT use bash loops - run separate `head` commands for each topic

2. **Find existing plans**: Look in `docs/specs/plans/*/`
   - Run `ls docs/specs/plans/` to list existing plans
   - For each plan, run `ls docs/specs/plans/{topic}/` to see what files exist

3. **Identify gaps**: Discussions without corresponding plans

## Step 2: Present Options to User

Show what you found using a list like below:

```
📂 Discussions found:
  ⏳ {topic-1} - Concluded - ready for planning
  ⚠️ {topic-2} - Exploring - not ready for planning
  ✅ {topic-3} - Concluded - plan exists

Which discussion would you like to create a plan for?
```

**Note:** You can pick any option—continue an exploring discussion, extend an existing plan, or even start a plan without a prior discussion.

Ask: **Which discussion would you like to plan?**

## Step 3: Choose Planning Path

Ask: **Do you want to create a draft plan first, or proceed directly to formal planning?**

**Path A: Draft Planning**
- Use when: Source materials need enrichment or filtering
- Creates `draft-plan.md` to build the specification collaboratively
- After draft is signed off, proceed to formal planning

**Path B: Formal Planning**
- Use when: Source materials already contain complete specification
- Go straight to creating phases and tasks

If user chooses Path A, skip to Step 5 (invoke skill with draft planning).
If user chooses Path B, continue to Step 4.

## Step 4: Choose Output Destination

*Skip this step if doing draft planning (Path A).*

Ask: **Where should this plan live?**

1. **Local Markdown** - Simple `plan.md` file in `docs/specs/plans/`
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
- Any constraints since the discussion concluded?

## Step 6: Invoke Planning Skill

Pass to the technical-planning skill:
- Discussion path: `docs/specs/discussions/{topic-name}/`
- Planning path: (draft | formal)
- Output destination: (local-markdown | linear | backlog-md) - only if formal
- Additional context gathered

**Example handoff for Path A (Draft)**:
```
Planning session for: {topic-name}
Discussion: docs/specs/discussions/{topic-name}/discussion.md
Path: Draft planning

Begin planning using the technical-planning skill.
Reference: draft-planning.md
```

**Example handoff for Path B (Formal)**:
```
Planning session for: {topic-name}
Discussion: docs/specs/discussions/{topic-name}/discussion.md
Path: Formal planning
Output destination: Linear
Team: Engineering

Begin planning using the technical-planning skill.
Reference: formal-planning.md, then output-linear.md
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- If the user wants to plan something without a discussion doc, that's okay - just note there's no prior discussion to reference
- Commit the plan files when complete
