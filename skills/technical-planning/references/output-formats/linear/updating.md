# Linear: Updating

## Mark Task Complete

Update the issue status in Linear via MCP after each task. Set the state to the team's "Done" or "Completed" workflow state.

User sees real-time progress in Linear UI.

## Mark Task Skipped

Update the issue status in Linear to "Cancelled" or equivalent workflow state. Add a comment explaining why the task was skipped.

## Update Plan Index

After completing or skipping a task:

1. Update the task's row in the Plan Index File task table: set `Status` to `completed` or `skipped`
2. When all tasks in a phase are complete, check off the phase acceptance criteria

## Advance Progress

Update the `planning:` block in the Plan Index File frontmatter to reflect the current position:

```yaml
planning:
  phase: {current-phase}
  task: {next-task-number or ~}
```
