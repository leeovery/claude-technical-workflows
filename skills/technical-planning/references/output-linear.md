# Output: Linear

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this output format when you want **Linear as the source of truth** for plan management. The user can update tasks directly in Linear's UI, and implementation will query Linear for the current state.

## Prerequisites

- Linear MCP server must be configured
- User must specify which Linear team to use

## Linear Structure Mapping

| Planning Concept | Linear Entity |
|------------------|---------------|
| Plan | Project |
| Phase | Label (e.g., `phase-1`, `phase-2`) |
| Task | Issue |

## Output Process

### 1. Create Linear Project

Via MCP, create a project with:

- **Name**: Match the discussion topic name
- **Description**: Brief summary + link to discussion file
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
Discussion: `docs/specs/discussions/{topic-name}/discussion.md`
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

When creating issues, if something is unclear or missing from the discussion:

1. **Create the issue anyway** - don't block planning
2. **Apply `needs-info` label** - makes gaps visible
3. **Note what's missing** in description - be specific about what needs clarifying
4. **Continue planning** - don't stop and circle back

This allows iterative refinement. Create all issues, identify gaps, circle back to discussion if needed, then update issues with missing detail. Plans don't have to be perfect on first pass.

### 4. Create Local Plan File

Create `docs/specs/plans/{topic-name}/plan.md`:

```markdown
---
format: linear
project: {PROJECT_NAME}
project_id: {ID from MCP response}
team: {TEAM_NAME}
---

# Plan Reference: {Topic Name}

**Discussion**: `docs/specs/discussions/{topic-name}/`
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

[Summary of key decisions from discussion - for quick reference]
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

Issues should be **self-contained for execution**:

**Include directly**:
- What to implement (specific files/methods)
- Test names (micro acceptance)
- Edge cases for this specific task
- Any code examples for complex patterns

**Link to (don't copy)**:
- Discussion document (for "why" context)
- Specific decision sections if particularly relevant

The goal: anyone (Claude or human) could pick up the issue and execute it.

## When to Use

- Larger features needing visual tracking
- Team collaboration
- When you want to update plans without editing markdown
- Projects already using Linear for issue tracking

## Resulting Structure

After planning:

```
docs/specs/
├── discussions/
│   └── {topic-name}/
│       └── discussion.md     # Source decisions
└── plans/
    └── {topic-name}/
        └── plan.md           # format: linear (pointer)

Linear:
└── Project: {topic-name}
    ├── Issue: Task 1 [label: phase-1]
    ├── Issue: Task 2 [label: phase-1]
    └── Issue: Task 3 [label: phase-2]
```

Implementation will read `plan.md`, see `format: linear`, and query Linear via MCP.

## Fallback Handling

If Linear MCP is unavailable during implementation:
- Implementation should inform the user
- Cannot proceed without MCP access
- Suggest checking MCP configuration or switching to local markdown

## MCP Tools Used

Planning uses these Linear MCP capabilities:
- Create project
- Create issue
- Create/assign labels

Implementation uses:
- Query project issues
- Filter issues by label
- Update issue status
