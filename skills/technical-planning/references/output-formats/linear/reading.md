# Linear: Reading

## Reading the Plan Index

1. Read the Plan Index File at `docs/workflow/planning/{topic}.md`
2. Extract `project_id` from frontmatter
3. Query Linear MCP for the project to get the full overview

## Extracting a Task

To read a specific task:

1. Query Linear MCP for the issue by ID: `linear_getIssue(issueId: "{issue_id}")`
2. The issue description contains the full task detail using canonical field names

## Next Incomplete Task

To find the next task to implement:

1. Extract `project_id` from the Plan Index File frontmatter
2. Query Linear MCP for project issues: `linear_getIssues(projectId: "{project_id}")`
3. Filter issues by phase label (e.g., `phase-1`, `phase-2`)
4. Process in phase order — complete all phase-1 issues before phase-2
5. Within a phase, find the first issue whose state is not "completed"
6. If no incomplete issues remain, all tasks are complete.
