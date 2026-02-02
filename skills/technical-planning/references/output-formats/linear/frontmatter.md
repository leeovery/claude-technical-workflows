# Linear: Frontmatter

## Plan Index Frontmatter

```yaml
---
topic: {topic-name}
status: planning | concluded
format: linear
specification: ../specification/{topic}.md
cross_cutting_specs:              # Omit if none
  - ../specification/{spec}.md
spec_commit: {git-commit-hash}
plan_id: USER-AUTH-FEATURE
project_id: abc123-def456
team: Engineering
created: YYYY-MM-DD
updated: YYYY-MM-DD
planning:
  phase: 2
  task: 3
---
```

| Field | Required | Description |
|-------|----------|-------------|
| topic | Yes | Feature/topic name, matches filename |
| status | Yes | `planning` or `concluded` |
| format | Yes | `linear` |
| specification | Yes | Relative path to specification |
| cross_cutting_specs | No | List of cross-cutting spec paths |
| spec_commit | Yes | Git commit hash at planning start |
| plan_id | Yes | Linear project name |
| project_id | Yes | Linear project ID (from MCP response) |
| team | Yes | Linear team name |
| created | Yes | Creation date |
| updated | Yes | Last update date |
| planning | Yes | Progress tracking block (phase + task) |

The `planning:` block tracks current progress position. It persists after the plan is concluded — `status:` indicates whether the plan is active or concluded.

## Task Frontmatter

Linear issues do not have YAML frontmatter. Task metadata is stored as Linear issue properties:

| Property | Maps to | Description |
|----------|---------|-------------|
| Issue ID | Task ID | Linear's unique issue identifier |
| Labels | Phase | `phase-1`, `phase-2`, etc. |
| State | Status | Linear workflow state (Todo, In Progress, Done) |
| Created | Created date | Issue creation timestamp |
| Blocking/Blocked by | Dependencies | Linear issue relationships |

## Format-Specific Fields

The `plan_id`, `project_id`, and `team` fields are unique to the Linear format. They provide the connection between the local Plan Index File and the Linear project.
