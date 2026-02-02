# Linear: Dependencies

## Dependency Format

Cross-topic dependencies link issues between different Linear projects (different specifications/topics). This is how you express "billing depends on authentication being complete."

Linear supports blocking relationships between issues, even across projects.

## Creating Dependencies

Via MCP or the Linear UI:

1. Open the dependent issue (the one that's blocked)
2. Add a "Blocked by" relationship to the issue in the other project
3. Linear will show this issue as blocked until the dependency is complete

Also update the External Dependencies section in the Plan Index File:

```markdown
## External Dependencies

- authentication: User context → {issue-id} (resolved)
- payment-gateway: Payment processing (unresolved - not yet planned)
```

## Querying Dependencies

Use these queries to understand the dependency graph.

### Via MCP

Query Linear for issues with blocking relationships:

```
# Get all issues in a project
linear_getIssues(projectId: "{project_id}")

# Check if an issue has blockers
linear_getIssue(issueId: "{issue_id}")
# Look for blockedByIssues in the response
```

### Check if a Dependency is Complete

Query the blocking issue and check its state:
- `state.type === "completed"` means the dependency is met
- Any other state means it's still blocking

### Find Issues Blocked by a Specific Issue

Via the Linear API or MCP, query for issues where `blockedByIssues` contains the issue ID.
