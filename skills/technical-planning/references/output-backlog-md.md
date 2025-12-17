# Output: Backlog.md

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this output format when you want a **local Kanban board with MCP integration**. Backlog.md is a markdown-native task manager designed for Git repositories with AI assistant support.

## About Backlog.md

Backlog.md is a CLI + web Kanban tool that:
- Stores tasks as individual markdown files in `backlog/` directory
- Has MCP (Model Context Protocol) support for Claude Code
- Provides terminal and web Kanban views
- Supports dependencies, priorities, assignees
- Built for Git workflows with auto-commit

See: https://github.com/MrLesk/Backlog.md

## Output Location

For Backlog.md integration, use the project's `backlog/` directory:

```
backlog/
├── task-1 - Phase 1 Setup.md
├── task-2 - Implement login endpoint.md
└── task-3 - Add session management.md
```

The plan file in `docs/workflow/planning/{topic}.md` serves as the reference pointer to backlog tasks.

## File Structure

### Plan Reference File (`docs/workflow/planning/{topic}.md`)

```markdown
---
format: backlog-md
project: {TOPIC_NAME}
---

# Plan Reference: {Topic Name}

**Specification**: `docs/workflow/specification/{topic}.md`
**Created**: {DATE}

## About This Plan

This plan is managed via Backlog.md. Tasks are stored in the `backlog/` directory.

## How to Use

**View the board**: Run `backlog board` (terminal) or `backlog browser` (web UI)

**Implementation will**:
1. Read this file to identify the plan
2. Query backlog via MCP or read task files directly
3. Work through tasks by status/priority
4. Update task status as work completes

**To add tasks**: Run `backlog add "Task title"` or create task files directly.

## Phases

Tasks are organized with labels/priorities:
- Label: `phase-1`, `phase-2`, etc.
- Priority: high (foundational), medium (core), low (refinement)

## Key Decisions

[Summary of key decisions from discussion]
```

### Task File Format

Each task is a separate file: `backlog/task-{id} - {title}.md`

```markdown
---
status: To Do
priority: high
labels: [phase-1, api]
---

# {Task Title}

{Brief description of what this task accomplishes}

## Plan

{The "Do" - specific files, methods, approach}

## Acceptance Criteria

1. [ ] Test written: `it does expected behavior`
2. [ ] Test written: `it handles edge case`
3. [ ] Implementation complete
4. [ ] Tests passing
5. [ ] Committed

## Notes

- Specification: `docs/workflow/specification/{topic}.md`
- Related decisions: [link if applicable]
```

### Frontmatter Fields

| Field | Purpose | Values |
|-------|---------|--------|
| `status` | Workflow state | To Do, In Progress, Done |
| `priority` | Importance | high, medium, low |
| `labels` | Categories | `[phase-1, api, edge-case, needs-info]` |
| `assignee` | Who's working on it | (optional) |
| `dependencies` | Blocking tasks | `[task-1, task-3]` |

### Using `needs-info` Label

When creating tasks with incomplete information:

1. **Create the task anyway** - don't block planning
2. **Add `needs-info` to labels** - makes gaps visible
3. **Note what's missing** in task body - be specific
4. **Continue planning** - circle back later

This allows iterative refinement. Create all tasks, identify gaps, circle back to discussion if needed, then update tasks with missing detail.

## Phase Representation

Since Backlog.md doesn't have native milestones, represent phases via:

1. **Labels**: `phase-1`, `phase-2`, etc.
2. **Task naming**: Prefix with phase number `task-X - [P1] Task name.md`
3. **Priority**: Foundation tasks = high, refinement = low

## When to Use

- When you want visual Kanban tracking with MCP support
- Solo or small team development
- Everything stays local and version-controlled
- AI-native workflow (Claude Code integration)
- Projects already using Backlog.md

## MCP Integration

If Backlog.md MCP server is configured, planning can:
- Create tasks via MCP tools
- Set status, priority, labels
- Query existing tasks

Implementation can:
- Query tasks by status/label
- Update task status as work completes
- Add notes to tasks

## Resulting Structure

After planning:

```
project/
├── backlog/
│   ├── task-1 - [P1] Configure auth.md
│   ├── task-2 - [P1] Add login endpoint.md
│   └── task-3 - [P2] Session management.md
├── docs/workflow/
│   ├── discussion/{topic}.md      # Phase 2 output
│   ├── specification/{topic}.md   # Phase 3 output
│   └── planning/{topic}.md        # Phase 4 output (format: backlog-md - pointer)
```

## Implementation Reading

Implementation will:
1. Read `plan.md`, see `format: backlog-md`
2. Query backlog via MCP or read `backlog/` directory
3. Filter tasks by label (e.g., `phase-1`)
4. Process in priority order (high → medium → low)
5. Update task status to "Done" when complete

## CLI Commands Reference

```bash
backlog init "Project"     # Initialize backlog
backlog add "Task title"   # Add task
backlog board              # Terminal Kanban view
backlog browser            # Web UI
backlog list               # List all tasks
backlog search "query"     # Search tasks
```
