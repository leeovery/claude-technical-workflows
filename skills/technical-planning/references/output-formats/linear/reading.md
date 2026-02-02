# Linear: Reading

## Extracting a Task

Query Linear MCP for the issue by ID:

```
linear_getIssue(issueId: "{issue_id}")
```

The issue description contains the full task detail.

## Next Incomplete Task

To find the next task to implement:

1. Query Linear MCP for project issues: `linear_getIssues(projectId: "{project_id}")`
2. Filter issues by phase label (e.g., `phase-1`, `phase-2`)
3. Process in phase order — complete all phase-1 issues before phase-2
4. Within a phase, find the first issue whose state is not "completed"
5. If no incomplete issues remain, all tasks are complete.
