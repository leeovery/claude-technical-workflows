# Linear: Dependencies

Linear natively supports blocking relationships between issues, both within a project and across projects. The same mechanism works regardless of which project an issue belongs to.

## Adding Dependencies

**Task A is blocked by Task B:**

```
linear_createIssueRelation(
  issueId: "{task_a_id}",
  relatedIssueId: "{task_b_id}",
  type: "blocks"
)
```

Linear handles both directions automatically — creating a "blocks" relation from B to A also makes A show as "blocked by" B. A task can have multiple blocking relationships.

## Removing Dependencies

Delete the issue relation via MCP:

```
linear_deleteIssueRelation(issueRelationId: "{relation_id}")
```

To find the relation ID, query the issue's relations first:

```
linear_getIssue(issueId: "{task_a_id}")
# Look for the relation in the issue's relations list
```

## Querying Dependencies

### Find Blocked Tasks

```
linear_getIssues(projectId: "{project_id}")
# Filter issues where blockedByIssues is non-empty
```

### Find Tasks That Block Others

```
linear_getIssue(issueId: "{issue_id}")
# Check the blockingIssues field in the response
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
