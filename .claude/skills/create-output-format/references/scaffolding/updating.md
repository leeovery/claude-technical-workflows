# {Format Name}: Updating

<!-- Instructions for recording progress during implementation -->

## Mark Task Complete

<!-- How to update a task's status to completed -->
{Format-specific instructions for marking a task done}

## Mark Task Skipped

<!-- How to record a skipped task -->
{Format-specific instructions for marking a task skipped}

## Update Plan Index

<!-- How to update the task table and phase status -->
After completing or skipping a task:

1. {Update task table in Plan Index File}
2. {Check off phase acceptance criteria if all phase tasks complete}

## Advance Progress

<!-- How to update the planning: frontmatter block -->
Update the `planning:` block in the Plan Index File frontmatter to reflect the current position:

```yaml
planning:
  phase: {current-phase}
  task: {next-task-number or ~}
```
