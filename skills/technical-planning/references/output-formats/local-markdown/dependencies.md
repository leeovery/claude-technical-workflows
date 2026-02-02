# Local Markdown: Dependencies

Local markdown has no native dependency engine. Dependencies are stored as a `depends_on` frontmatter field on task files and checked during task selection.

## Adding a Dependency

Add the blocking task's ID to the `depends_on` field in the dependent task's frontmatter:

```yaml
depends_on:
  - {topic}-1-2
```

A task can depend on multiple tasks:

```yaml
depends_on:
  - {topic}-1-2
  - {topic}-1-3
```

## Removing a Dependency

Remove the task ID from the `depends_on` field. If the field becomes empty, remove it entirely.

## Cross-Topic Dependencies

The same mechanism works across topics. Reference tasks by their full task ID:

```yaml
depends_on:
  - billing-1-2
  - auth-2-1
```

The referenced task file is at `docs/workflow/planning/{topic}/{task-id}.md`.

## Querying Dependencies

### Find Tasks With Dependencies

```bash
grep -rl "depends_on:" docs/workflow/planning/{topic}/
```

### Find Tasks That a Specific Task Blocks

```bash
grep -rl "{task-id}" docs/workflow/planning/{topic}/
```

### Check if a Dependency is Resolved

Read the referenced task file and check its status:

```bash
grep "status:" docs/workflow/planning/{topic}/{task-id}.md
```

A dependency is resolved when `status: completed`.

### Find Unblocked Work

For each pending task with `depends_on`, check all referenced tasks. If all are `completed`, the task is unblocked and ready to work on.
