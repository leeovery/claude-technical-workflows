# Linear: Reading

## Extracting a Task

Query Linear MCP for the issue by ID:

```
linear_getIssue(issueId: "{issue_id}")
```

The response includes title, description, status, priority, labels, estimation, and blocking relationships.

## Next Incomplete Task

To find the next task to implement:

1. Query Linear MCP for project issues: `linear_getIssues(projectId: "{project_id}")`
2. Filter to issues whose state is not "completed" or "cancelled"
3. Exclude issues that have unresolved blockers (check `blockedByIssues`)
4. Filter by phase label — complete all `phase-1` issues before `phase-2`
5. Within a phase, order by priority (Urgent > High > Medium > Low)
6. The first match is the next task
7. If no incomplete issues remain, all tasks are complete.
