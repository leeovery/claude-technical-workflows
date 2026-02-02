# Linear: Task Graph

Linear natively supports both priority levels and blocking relationships between issues. Both are used to determine execution order.

This file is used by the graphing agent after all tasks have been authored. The agent receives the complete plan and establishes priority and dependencies across tasks.

## Priority

Linear has native priority levels:

| Priority | Linear Value | When to Use |
|----------|-------------|-------------|
| Urgent | 1 | Must be done first within its phase |
| High | 2 | Important — do before normal priority |
| Medium | 3 | Standard priority (default) |
| Low | 4 | Can be deferred within the phase |
| No priority | 0 | Unset |

Set priority via MCP:

```
linear_updateIssue(
  issueId: "{issue_id}",
  priority: {priority_level}
)
```

## Dependencies

### Adding a Dependency

To declare that one task depends on another (is blocked by it):

```
linear_createIssueRelation(
  issueId: "{dependent_issue_id}",
  relatedIssueId: "{blocking_issue_id}",
  type: "blocks"
)
```

A task can have multiple dependencies. Call `linear_createIssueRelation` for each one.

### Removing a Dependency

Delete the issue relation via MCP:

```
linear_deleteIssueRelation(issueRelationId: "{relation_id}")
```

To find the relation ID, query the issue's relations first:

```
linear_getIssue(issueId: "{issue_id}")
# Look for the relation in the issue's relations list
```
