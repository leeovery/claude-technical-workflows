# Output: Backlog.md

*Output adapter for **[technical-planning](../../SKILL.md)***

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

## Setup

Install via npm:

```bash
npm install -g backlog-md
```

Initialize in your project:

```bash
backlog init "Project Name"
```

For MCP integration, configure the Backlog.md MCP server in Claude Code settings.

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
plan_id: {TOPIC_NAME}
---

# Plan Reference: {Topic Name}

**Specification**: `docs/workflow/specification/{topic}.md`
**Created**: YYYY-MM-DD *(use today's actual date)*

## About This Plan

This plan is managed via Backlog.md. Tasks are stored in the `backlog/` directory.

## How to Use

**View the board**: Run `backlog board` (terminal) or `backlog browser` (web UI)

**Implementation will**:
1. Read this file to identify the plan
2. Check External Dependencies below
3. Query backlog via MCP or read task files directly
4. Work through tasks by status/priority
5. Update task status as work completes

**To add tasks**: Run `backlog add "Task title"` or create task files directly.

## Phases

Tasks are organized with labels/priorities:
- Label: `phase-1`, `phase-2`, etc.
- Priority: high (foundational), medium (core), low (refinement)

## Key Decisions

[Summary of key decisions from specification]

## Cross-Cutting References

Architectural decisions from cross-cutting specifications that inform this plan:

| Specification | Key Decisions | Applies To |
|---------------|---------------|------------|
| [Caching Strategy](../../specification/caching-strategy.md) | Cache API responses for 5 min | Tasks involving API calls |
| [Rate Limiting](../../specification/rate-limiting.md) | 100 req/min per user | User-facing endpoints |

*Remove this section if no cross-cutting specifications apply.*

## External Dependencies

[Dependencies on other topics - copy from specification's Dependencies section]

- {topic}: {description}
- {topic}: {description} → {task-id} (resolved)
```

The External Dependencies section tracks what this plan needs from other topics. See `../dependencies.md` for the format and states (unresolved, resolved, satisfied externally).

### Task File Format

Each task is a separate file: `backlog/task-{id} - {title}.md`

Tasks should be **fully self-contained** - include all context so humans and agents can execute without referencing other files.

```markdown
---
status: To Do
priority: high
labels: [phase-1, api]
---

# {Task Title}

## Goal

{What this task accomplishes and why - include rationale from specification}

## Implementation

{The "Do" - specific files, methods, approach}

## Acceptance Criteria

1. [ ] Test written: `it does expected behavior`
2. [ ] Test written: `it handles edge case`
3. [ ] Implementation complete
4. [ ] Tests passing
5. [ ] Committed

## Edge Cases

{Specific edge cases for this task}

## Context

{Relevant decisions and constraints from specification}

Specification reference: `docs/workflow/specification/{topic}.md` (for ambiguity resolution)
```

### Frontmatter Fields

| Field | Purpose | Values |
|-------|---------|--------|
| `status` | Workflow state | To Do, In Progress, Done |
| `priority` | Importance | high, medium, low |
| `labels` | Categories | `[phase-1, api, edge-case, needs-info]` |
| `assignee` | Who's working on it | (optional) |
| `dependencies` | Blocking tasks (internal) | `[task-1, task-3]` |
| `external_deps` | Cross-topic dependencies | `[billing-system#task-5]` |

## Cross-Topic Dependencies

Cross-topic dependencies link tasks between different plan topics. This is how you express "this task depends on the billing system being implemented."

### In Task Frontmatter

Use the `external_deps` field with the format `{topic}#{task-id}`:

```yaml
---
status: To Do
priority: high
labels: [phase-1]
external_deps: [billing-system#task-5, authentication#task-3]
---
```

### In Plan Reference File

The plan reference file at `docs/workflow/planning/{topic}.md` tracks external dependencies in a dedicated section (see template below).

## Querying Dependencies

Use these queries to understand the dependency graph for implementation blocking and `/link-dependencies`.

### Find Tasks With External Dependencies

```bash
# Find all tasks with external dependencies
grep -l "external_deps:" backlog/*.md

# Find tasks depending on a specific topic
grep -l "billing-system#" backlog/*.md
```

### Check Internal Dependencies

```bash
# Find tasks with dependencies
grep -l "dependencies:" backlog/*.md

# Show dependency values
grep "dependencies:" backlog/*.md
```

### Check if a Dependency is Complete

Read the task file and check the frontmatter:
- `status: Done` means the dependency is met
- Any other status means it's still blocking

### Parse Frontmatter Programmatically

For more complex queries, parse the YAML frontmatter:

```bash
# Extract frontmatter from a task file
sed -n '/^---$/,/^---$/p' backlog/task-5*.md
```

### Using `needs-info` Label

When creating tasks with incomplete information:

1. **Create the task anyway** - don't block planning
2. **Add `needs-info` to labels** - makes gaps visible
3. **Note what's missing** in task body - be specific
4. **Continue planning** - circle back later

This allows iterative refinement. Create all tasks, identify gaps, circle back to specification if needed, then update tasks with missing detail.

## Phase Representation

Since Backlog.md doesn't have native milestones, represent phases via:

1. **Labels**: `phase-1`, `phase-2`, etc.
2. **Task naming**: Prefix with phase number `task-X - [P1] Task name.md`
3. **Priority**: Foundation tasks = high, refinement = low

## Benefits

- Visual Kanban board in terminal or web UI
- Local and fully version-controlled
- MCP integration for Claude Code
- Auto-commit on task changes
- Individual task files for easy editing

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
│   ├── discussion/{topic}.md      # Discussion output
│   ├── specification/{topic}.md   # Specification output
│   └── planning/{topic}.md        # Planning output (format: backlog-md - pointer)
```

## Implementation

### Reading Plans

1. If Backlog.md MCP is available, query tasks via MCP
2. Otherwise, read task files from `backlog/` directory
3. Filter tasks by label (e.g., `phase-1`) or naming convention
4. Process in priority order (high → medium → low)

### Updating Progress

- Update task status to "In Progress" when starting
- Check off acceptance criteria items in task file
- Update status to "Done" when complete
- Backlog.md CLI auto-moves to completed folder

### Fallback

Can read `backlog/` files directly if MCP unavailable.

## CLI Commands Reference

```bash
backlog init "Project"     # Initialize backlog
backlog add "Task title"   # Add task
backlog board              # Terminal Kanban view
backlog browser            # Web UI
backlog list               # List all tasks
backlog search "query"     # Search tasks
```
