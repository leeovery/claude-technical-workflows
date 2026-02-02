# Local Markdown: Updating

## Mark Task Complete

Update the task file frontmatter at `docs/workflow/planning/{topic}/{task-id}.md`:

```yaml
status: completed
```

## Mark Task Skipped

Update the task file frontmatter:

```yaml
status: skipped
```

## Update Plan Index

After completing or skipping a task:

1. Update the task's row in the task table: set `Status` to `completed` or `skipped`
2. When all tasks in a phase are complete, check off the phase acceptance criteria

## Advance Progress

Update the `planning:` block in the Plan Index File frontmatter to reflect the current position:

```yaml
planning:
  phase: {current-phase}
  task: {next-task-number or ~}
```
