# Tick: Task Graph

Tick has native support for priority and blocking dependencies with cycle detection. This file is used by the graphing agent after all tasks have been authored.

## Priority

| Level | Name | Value |
|-------|------|-------|
| 0 | Critical | Highest priority |
| 1 | High | |
| 2 | Medium | Default |
| 3 | Low | |
| 4 | Backlog | Lowest priority |

Lower number = higher priority. Tasks are created with priority `2` (medium) by default.

### Setting Priority

```bash
tick update <task-id> --priority 1
```

### Removing Priority

Reset to the default medium priority:

```bash
tick update <task-id> --priority 2
```

Tick does not support unsetting priority — every task has a priority level. Use `2` (medium) as the neutral default.

## Dependencies

Tick validates all dependency changes: prevents cycles, self-references, and children blocked by their own parent.

### Adding a Dependency

Declare that a task is blocked by another task:

```bash
tick dep add <task-id> <blocked-by-id>
```

Example — task `tick-e5f6` depends on `tick-a1b2`:

```bash
tick dep add tick-e5f6 tick-a1b2
```

To add multiple dependencies to a single task, run the command for each:

```bash
tick dep add tick-e5f6 tick-a1b2
tick dep add tick-e5f6 tick-c3d4
```

### Removing a Dependency

```bash
tick dep rm <task-id> <blocked-by-id>
```
