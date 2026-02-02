# Local Markdown: Dependencies

Local markdown has no native dependency engine. Dependencies are stored as frontmatter fields on task files and checked manually during task selection.

## Adding Dependencies

Add task IDs to the `depends_on` (blocked by) and/or `blocks` fields in the task's frontmatter. A task can have multiple entries in each field.

**Task A is blocked by Task B** — add to Task A:

```yaml
depends_on:
  - {topic}-1-2
  - {topic}-1-3
```

**Task A blocks Task C** — add to Task A:

```yaml
blocks:
  - {topic}-2-1
```

Both fields are optional. When setting a relationship, update both sides to keep them consistent:

1. Add `{task-b}` to Task A's `depends_on`
2. Add `{task-a}` to Task B's `blocks`

## Removing Dependencies

Remove the task ID from the relevant field. If the field becomes empty, remove it entirely.

When removing, update both sides:

1. Remove `{task-b}` from Task A's `depends_on`
2. Remove `{task-a}` from Task B's `blocks`

## Cross-Topic Dependencies

The same mechanism works across topics. Reference tasks by their full task ID — the task file is at `docs/workflow/planning/{topic}/{task-id}.md`.

```yaml
depends_on:
  - billing-1-2
  - auth-2-1
```

## Querying Dependencies

### Find Blocked Tasks

```bash
grep -rl "depends_on:" docs/workflow/planning/{topic}/
```

### Find Tasks That Block Others

```bash
grep -rl "blocks:" docs/workflow/planning/{topic}/
```

### Check if a Dependency is Resolved

Read the referenced task file and check its status:

```bash
grep "status:" docs/workflow/planning/{topic}/{task-id}.md
```

A dependency is resolved when `status: completed`.

### Find Unblocked Work

For each pending task with `depends_on`, check all referenced tasks. If all are `completed`, the task is unblocked and ready to work on.
