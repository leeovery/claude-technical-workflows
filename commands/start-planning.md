---
description: Start a planning session from an existing discussion. Discovers available discussions, asks where to store the plan, and invokes the technical-planning skill.
---

Invoke the **technical-planning** skill for this conversation.

Before beginning, discover existing work and gather necessary information.

## Step 1: Discover Existing Work

Scan the codebase for discussions and plans:

1. **Find discussions**: Look in `docs/specs/discussions/*/discussion.md`
   - Note each topic name
   - Check status (Concluded | Deciding | Exploring)

2. **Find existing plans**: Look in `docs/specs/plans/*/plan.md`
   - Check `format` frontmatter: `local-markdown`, `linear`, or `backlog-md`

3. **Identify gaps**: Discussions without corresponding plans

## Step 2: Present Options to User

Show what you found:

```
📂 Discussions found:
  ⏳ {topic-1} - Concluded (ready for planning)
  ⏳ {topic-2} - Concluded (ready for planning)
  ⚠️  {topic-3} - Exploring (not ready)
  ✅ {topic-4} - Concluded (plan exists)

Which discussion would you like to create a plan for?
```

- ⏳ Concluded discussions without plans are ready for planning
- ⚠️ Exploring discussions may not be ready yet
- ✅ Discussions with existing plans can be extended or revised

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
