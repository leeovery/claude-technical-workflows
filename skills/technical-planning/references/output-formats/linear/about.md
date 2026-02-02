# Linear

*Output format adapter for **[technical-planning](../../../SKILL.md)***

---

Use this output format when you want **Linear as the source of truth** for plan management. The user can update tasks directly in Linear's UI, and implementation will query Linear for the current state.

## Benefits

- Visual tracking with real-time progress updates
- Team collaboration with shared visibility
- Update tasks directly in Linear UI without editing markdown
- Integrates with existing Linear workflows

## Setup

Requires the Linear MCP server to be configured in Claude Code.

Check if Linear MCP is available by looking for Linear tools. If not configured, inform the user that Linear MCP is required for this format.

Ask the user: **Which team should own this project?**

## Linear Structure Mapping

| Planning Concept | Linear Entity |
|------------------|---------------|
| Specification/Topic | Project |
| Phase | Label (e.g., `phase-1`, `phase-2`) |
| Task | Issue |
| Internal dependency | Issue blocking relationship (within project) |
| Cross-topic dependency | Issue blocking relationship (across projects) |

Each specification topic becomes its own Linear project. Cross-topic dependencies link issues between projects.

## Output Location

```
docs/workflow/planning/
└── {topic}.md                    # Plan Index File (pointer to Linear project)

Linear:
└── Project: {topic}
    ├── Issue: Task 1 [label: phase-1]
    ├── Issue: Task 2 [label: phase-1]
    └── Issue: Task 3 [label: phase-2]
```

The Plan Index File is a thin pointer to the Linear project. Linear is the source of truth for task detail and status.

## Resulting Structure

After planning:

```
docs/workflow/
├── discussion/{topic}.md      # Discussion output
├── specification/{topic}.md   # Specification output
└── planning/{topic}.md        # Plan Index File (format: linear - pointer)

Linear:
└── Project: {topic}
    ├── Issue: Task 1 [label: phase-1]
    ├── Issue: Task 2 [label: phase-1]
    └── Issue: Task 3 [label: phase-2]
```
