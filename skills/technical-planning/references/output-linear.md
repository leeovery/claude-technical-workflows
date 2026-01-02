# Output: Linear

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this output format when you want **Linear as the source of truth** for plan management. The user can update tasks directly in Linear's UI, and implementation will query Linear for the current state.

## Setup

Requires the Linear MCP server to be configured in Claude Code.

Check if Linear MCP is available by looking for Linear tools. If not configured, inform the user that Linear MCP is required for this format.

Ask the user: **Which team should own this project?**

## Linear Structure Mapping

| Planning Concept | Linear Entity |
|------------------|---------------|
| Plan | Project |
| Phase | Label (e.g., `phase-1`, `phase-2`) |
| Task | Issue |

## Output Process

### 1. Create Linear Project

Via MCP, create a project with:

- **Name**: Match the specification topic name
- **Description**: Brief summary + link to specification file
- **Team**: As specified by user

### 2. Create Labels for Phases

Create labels to denote phases (if they don't already exist):

- `phase-1`
- `phase-2`
- etc.

Document the phase goals and acceptance criteria in a pinned issue or the project description:

```
Phase 1: Core Authentication
Goal: Implement basic login/logout flow
Acceptance:
- [ ] User can log in with email/password
- [ ] Session persists across page refresh
- [ ] Logout clears session

Phase 2: ...
```

### 3. Create Issues for Tasks

For each task, create an issue and apply the appropriate phase label:

**Title**: Clear action statement

**Description** (use this structure):
```markdown
## Goal
[What this task accomplishes - one sentence]

## Implementation
[The "Do" from planning - specific files, methods, approach]

## Tests (Micro Acceptance)
- `it does expected behavior`
- `it handles edge case X`

## Edge Cases
- [Specific edge cases for this task]

## Context
Specification: `docs/workflow/specification/{topic}.md`
[Optional: link to specific decision if relevant]
```

**Labels**:
- **Required**: `phase-1`, `phase-2`, etc. - denotes which phase the task belongs to
- **Optional**:
  - `needs-info` - task requires additional information before implementation
  - `edge-case` - for edge case handling tasks
  - `foundation` - for setup/infrastructure tasks
  - `refactor` - for cleanup tasks

### Using `needs-info` Label

When creating issues, if something is unclear or missing from the specification:

1. **Create the issue anyway** - don't block planning
2. **Apply `needs-info` label** - makes gaps visible
3. **Note what's missing** in description - be specific about what needs clarifying
4. **Continue planning** - don't stop and circle back

This allows iterative refinement. Create all issues, identify gaps, circle back to specification if needed, then update issues with missing detail. Plans don't have to be perfect on first pass.

### 4. Create Local Plan File

Create `docs/workflow/planning/{topic}.md`:

```markdown
---
format: linear
project: {PROJECT_NAME}
project_id: {ID from MCP response}
team: {TEAM_NAME}
---

# Plan Reference: {Topic Name}

**Specification**: `docs/workflow/specification/{topic}.md`
**Created**: {DATE}

## About This Plan

This plan is managed in Linear. The source of truth for tasks and progress is the Linear project referenced above.

## How to Use

**To view/edit the plan**: Open Linear and navigate to the project.

**Implementation will**:
1. Read this file to find the Linear project
2. Query Linear for project issues
3. Work through tasks in phase order (by label)
4. Update issue status as tasks complete

**To add tasks**: Create issues in the Linear project. They'll be picked up automatically.

## Key Decisions

[Summary of key decisions from specification - for quick reference]
```

## Frontmatter

The frontmatter contains all information needed to query Linear:

```yaml
---
format: linear
project: USER-AUTH-FEATURE
project_id: abc123-def456
team: Engineering
---
```

## Issue Content Guidelines

Issues should be **fully self-contained**. Include all context directly so humans and agents can execute without referencing other files.

**Include in each issue**:
- Goal and rationale (the "why" from the specification)
- What to implement (specific files/methods)
- Test names (micro acceptance)
- Edge cases for this specific task
- Relevant decisions and constraints
- Any code examples for complex patterns

**Specification reference**: The specification at `docs/workflow/specification/{topic}.md` remains available for resolving ambiguity or getting additional context, but issues should contain all information needed for execution.

The goal: anyone (Claude or human) could pick up the issue and execute it without opening another document.

## Benefits

- Visual tracking with real-time progress updates
- Team collaboration with shared visibility
- Update tasks directly in Linear UI without editing markdown
- Integrates with existing Linear workflows

## Resulting Structure

After planning:

```
docs/workflow/
├── discussion/{topic}.md      # Phase 2 output
├── specification/{topic}.md   # Phase 3 output
└── planning/{topic}.md        # Phase 4 output (format: linear - pointer)

Linear:
└── Project: {topic}
    ├── Issue: Task 1 [label: phase-1]
    ├── Issue: Task 2 [label: phase-1]
    └── Issue: Task 3 [label: phase-2]
```

## Implementation

### Reading Plans

1. Extract `project_id` from frontmatter
2. Query Linear MCP for project issues
3. Filter issues by phase label (e.g., `phase-1`, `phase-2`)
4. Process in phase order

### Updating Progress

- Update issue status in Linear via MCP after each task
- User sees real-time progress in Linear UI

### Fallback

If Linear MCP is unavailable:
- Inform the user
- Cannot proceed without MCP access
- Suggest checking MCP configuration or switching to local markdown
