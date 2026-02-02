# Local Markdown: Frontmatter

## Plan Index Frontmatter

```yaml
---
topic: {feature-name}                    # Matches filename (without .md)
status: planning | concluded             # Planning status
format: local-markdown                   # Output format used
specification: ../specification/{topic}.md
cross_cutting_specs:                     # Omit if none
  - ../specification/{spec}.md
spec_commit: {git-commit-hash}           # Git commit when planning started
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
| format | Yes | `local-markdown` |
| specification | Yes | Relative path to specification |
| cross_cutting_specs | No | List of cross-cutting spec paths |
| spec_commit | Yes | Git commit hash at planning start |
| created | Yes | Creation date |
| updated | Yes | Last update date |
| planning | Yes | Progress tracking block (phase + task) |

The `planning:` block tracks current progress position. It persists after the plan is concluded — `status:` indicates whether the plan is active or concluded.

## Task Frontmatter

Each task file at `{topic}/{task-id}.md` has:

```yaml
---
id: {topic}-{phase}-{seq}
phase: {phase-number}
status: pending | completed | skipped
created: YYYY-MM-DD
---
```

| Field | Required | Description |
|-------|----------|-------------|
| id | Yes | Task identifier (`{topic}-{phase}-{seq}`) |
| phase | Yes | Phase number this task belongs to |
| status | Yes | `pending`, `completed`, or `skipped` |
| created | Yes | Creation date |
