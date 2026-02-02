# Linear: Authoring

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

For each task, create an issue and apply the appropriate phase label. The planning skill provides the task title and description content.

**Title**: Task title (provided by the planning skill)

**Description**: Task description content (provided by the planning skill)

**Labels**:
- **Required**: `phase-1`, `phase-2`, etc. - denotes which phase the task belongs to
- **Optional**:
  - `needs-info` - task requires additional information before implementation
  - `edge-case` - for edge case handling tasks
  - `foundation` - for setup/infrastructure tasks
  - `refactor` - for cleanup tasks

### 4. Create Plan Index File

Create `docs/workflow/planning/{topic}.md`:

```markdown
---
topic: {topic-name}
status: planning
format: linear
specification: ../specification/{topic}.md
cross_cutting_specs:              # Omit if none
  - ../specification/{spec}.md
spec_commit: {git-commit-hash}
plan_id: {PROJECT_NAME}
project_id: {ID from MCP response}
team: {TEAM_NAME}
created: YYYY-MM-DD  # Use today's actual date
updated: YYYY-MM-DD  # Use today's actual date
planning:
  phase: 1
  task: ~
---

# Plan: {Topic Name}

## About This Plan

This plan is managed in Linear. The source of truth for tasks and progress is the Linear project referenced above.

## How to Use

**To view/edit the plan**: Open Linear and navigate to the project.

**Implementation will**:
1. Read this file to find the Linear project
2. Check External Dependencies below
3. Query Linear for project issues
4. Work through tasks in phase order (by label)
5. Update issue status as tasks complete

**To add tasks**: Create issues in the Linear project. They'll be picked up automatically.

## Key Decisions

[Summary of key decisions from specification - for quick reference]

## Cross-Cutting References

Architectural decisions from cross-cutting specifications that inform this plan:

| Specification | Key Decisions | Applies To |
|---------------|---------------|------------|
| [Caching Strategy](../../specification/caching-strategy.md) | Cache API responses for 5 min | Tasks involving API calls |
| [Rate Limiting](../../specification/rate-limiting.md) | 100 req/min per user | User-facing endpoints |

*Remove this section if no cross-cutting specifications apply.*

## Phases

### Phase 1: {Name}
status: draft
label: phase-1

**Goal**: {What this phase accomplishes}
**Why this order**: {Why this comes at this position}

**Acceptance**:
- [ ] Criterion 1
- [ ] Criterion 2

#### Tasks
| ID | Name | Edge Cases | Status |
|----|------|------------|--------|
| {issue-id} | {Task Name} | {list} | pending |

---

### Phase 2: {Name}
status: draft
label: phase-2

...

## External Dependencies

[Dependencies on other topics - copy from specification's Dependencies section]

- {topic}: {description}
- {topic}: {description} → {issue-id} (resolved)
```

The External Dependencies section tracks what this plan needs from other topics.

## Task Writing

After creating an issue via MCP:
1. Update the task table in the Plan Index File: set `status: authored`
2. Advance the `planning:` block in frontmatter to the next pending task

## Flagging

When creating issues, if something is unclear or missing from the specification:

1. **Create the issue anyway** - don't block planning
2. **Apply `needs-info` label** - makes gaps visible
3. **Note what's missing** in description — add a **Needs Clarification** section:

```markdown
**Needs Clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

4. **Continue planning** - don't stop and circle back

## Cleanup (Restart)

The official Linear MCP server does not support deletion. Ask the user to delete the Linear project manually via the Linear UI.

> "The Linear project **{project name}** needs to be deleted before restarting. Please delete it in the Linear UI (Project Settings → Delete project), then confirm so I can proceed."

**STOP.** Wait for the user to confirm.

### Fallback

If Linear MCP is unavailable:
- Inform the user
- Cannot proceed without MCP access
- Suggest checking MCP configuration or switching to local markdown
