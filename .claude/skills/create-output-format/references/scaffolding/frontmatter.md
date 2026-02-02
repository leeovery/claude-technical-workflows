# {Format Name}: Frontmatter

<!-- Schema definitions for all YAML frontmatter used by this format -->

## Plan Index Frontmatter

```yaml
---
topic: {feature-name}                    # Matches filename (without .md)
status: planning | concluded             # Planning status
format: {format-key}                     # Output format identifier
specification: ../specification/{topic}.md
cross_cutting_specs:                     # Omit if none
  - ../specification/{spec}.md
spec_commit: {git-commit-hash}           # Git commit when planning started
created: YYYY-MM-DD
updated: YYYY-MM-DD
planning:
  phase: {current-phase}
  task: {current-task or ~}
# {Add any format-specific fields below}
---
```

| Field | Required | Description |
|-------|----------|-------------|
| topic | Yes | Feature/topic name, matches filename |
| status | Yes | `planning` or `concluded` |
| format | Yes | `{format-key}` |
| specification | Yes | Relative path to specification |
| cross_cutting_specs | No | List of cross-cutting spec paths |
| spec_commit | Yes | Git commit hash at planning start |
| created | Yes | Creation date |
| updated | Yes | Last update date |
| planning | Yes | Progress tracking block |

<!-- Add format-specific fields to the table above -->

## Task Frontmatter

<!-- If tasks have their own frontmatter (e.g., markdown task files), define the schema here -->
<!-- If tasks are stored externally (e.g., API), note that here instead -->

```yaml
---
id: {task-id}
phase: {phase-number}
status: pending | completed | skipped
created: YYYY-MM-DD
---
```

| Field | Required | Description |
|-------|----------|-------------|
| id | Yes | Task identifier |
| phase | Yes | Phase number |
| status | Yes | Task status |
| created | Yes | Creation date |
