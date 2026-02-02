# Local Markdown: Task Graph

Local markdown has no native dependency or priority engine. Both are stored as frontmatter fields on task files and used during task selection to determine execution order.

This file is used by the graphing agent after all tasks have been authored. The agent receives the complete plan and establishes priority and dependencies across tasks.

## Priority

Add a `priority` field to frontmatter:

```yaml
priority: 2
```

| Priority | Value | When to Use |
|----------|-------|-------------|
| Urgent | `1` | Must be done first within its phase |
| High | `2` | Important — do before normal priority |
| Medium | `3` | Standard priority |
| Low | `4` | Can be deferred within the phase |
| Lowest | `5` | Lowest — defer if possible |
| No priority | `0` | Unset (default if omitted) |

Lower number = higher priority. `0` means no priority — it sorts after `5`, not before `1`. If omitted, priority is determined by sequence ordering within the phase.

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

### Cross-Topic Dependencies

The same mechanism works across topics. Reference tasks by their full task ID:

```yaml
depends_on:
  - billing-1-2
  - auth-2-1
```

The referenced task file is at `docs/workflow/planning/{topic}/{task-id}.md`.

## Querying

### Find Tasks With Dependencies

```bash
grep -rl "depends_on:" docs/workflow/planning/{topic}/
```

### Find Tasks That a Specific Task Blocks

```bash
grep -rl "{task-id}" docs/workflow/planning/{topic}/
```

### Check if a Dependency is Resolved

Read the referenced task file and check its status:

```bash
grep "status:" docs/workflow/planning/{topic}/{task-id}.md
```

A dependency is resolved when `status: completed`.

### Find Unblocked Work

For each pending task with `depends_on`, check all referenced tasks. If all are `completed`, the task is unblocked and ready to work on.
