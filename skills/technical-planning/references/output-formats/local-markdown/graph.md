# Local Markdown: Task Graph

Local markdown has no native dependency or priority engine. Both are stored as frontmatter fields on task files and used during task selection to determine execution order.

This file is used by the graphing agent after all tasks have been authored. The agent receives the complete plan and establishes priority and dependencies across tasks.

## Priority

| Value | Level |
|-------|-------|
| `1` | Urgent |
| `2` | High |
| `3` | Medium |
| `4` | Low |

Lower number = higher priority.

### Setting Priority

Add or update the `priority` field in frontmatter:

```yaml
priority: 2
```

### Removing Priority

Remove the `priority` field from frontmatter entirely.

## Dependencies

### Adding a Dependency

Add the blocking task's ID to the `depends_on` field in the dependent task's frontmatter:

```yaml
depends_on:
  - {topic}-1-2
```

A task can depend on multiple tasks:

```yaml
depends_on:
  - {topic}-1-2
  - {topic}-1-3
```

### Removing a Dependency

Remove the task ID from the `depends_on` field. If the field becomes empty, remove it entirely.
