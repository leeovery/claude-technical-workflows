# Linear: Dependencies

## Within-Plan Dependencies

Linear natively supports blocking relationships between issues in the same project. Use "Blocked by" relationships to enforce task ordering beyond phase/priority.

To create a within-plan dependency via MCP:

```
linear_createIssueRelation(
  issueId: "{blocked_issue_id}",
  relatedIssueId: "{blocking_issue_id}",
  type: "blocks"
)
```

## Cross-Topic Dependencies

Linear supports blocking relationships across projects. The same mechanism works regardless of which project an issue belongs to.

## Creating Dependencies

Via MCP or the Linear UI:

1. Identify the dependent issue (the one that's blocked)
2. Create a "Blocked by" relationship to the blocking issue
3. Linear will show the issue as blocked until the dependency is complete

```
linear_createIssueRelation(
  issueId: "{blocked_issue_id}",
  relatedIssueId: "{blocking_issue_id}",
  type: "blocks"
)
```

## Querying Dependencies

### Find Blocked Tasks

Query project issues and check for blockers:

```
linear_getIssues(projectId: "{project_id}")
# Filter issues where blockedByIssues is non-empty
```

### Check if a Dependency is Resolved

Query the blocking issue and check its state:

```
linear_getIssue(issueId: "{blocking_issue_id}")
```

- `state.type === "completed"` — dependency is resolved
- Any other state — still blocking

### Find Unblocked Work

Query all project issues, filter to those where:
- State is not "completed" or "cancelled"
- `blockedByIssues` is empty OR all blocking issues have `state.type === "completed"`

These are the tasks ready to work on.
