# Linear: Dependencies

Linear natively supports blocking relationships between issues, both within a project and across projects.

## Adding a Dependency

To declare that one task depends on another (is blocked by it):

```
linear_createIssueRelation(
  issueId: "{dependent_issue_id}",
  relatedIssueId: "{blocking_issue_id}",
  type: "blocks"
)
```

A task can have multiple dependencies. Call `linear_createIssueRelation` for each one.

## Removing a Dependency

Delete the issue relation via MCP:

```
linear_deleteIssueRelation(issueRelationId: "{relation_id}")
```

To find the relation ID, query the issue's relations first:

```
linear_getIssue(issueId: "{issue_id}")
# Look for the relation in the issue's relations list
```

## Cross-Topic Dependencies

The same mechanism works across projects. Linear doesn't distinguish between within-project and cross-project blocking relationships.

## Querying Dependencies

### Find Tasks With Dependencies

```
linear_getIssues(projectId: "{project_id}")
# Filter issues where blockedByIssues is non-empty
```

### Check if a Dependency is Resolved

```
linear_getIssue(issueId: "{blocking_issue_id}")
```

- `state.type === "completed"` — dependency is resolved
- Any other state — still blocking

### Find Unblocked Work

Query all project issues, filter to those where:
- State is not "completed" or "cancelled"
- `blockedByIssues` is empty OR all blocking issues have `state.type === "completed"`
