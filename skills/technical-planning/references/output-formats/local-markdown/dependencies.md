# Local Markdown: Dependencies

## Within-Plan Dependencies

Not natively supported. Task ordering is determined by phase and sequence. If a task within the same plan must wait on another, note it in the task description — but there is no enforced blocking mechanism.

## Cross-Topic Dependencies

Reference tasks by their task ID (e.g., `billing-1-2`). The task file is at `docs/workflow/planning/{topic}/{task-id}.md`.

No format-level blocking mechanism — local markdown has no native dependency graph. Dependencies are tracked as references and checked manually.

## Creating Dependencies

Add a `depends_on` field to the task frontmatter:

```yaml
depends_on:
  - billing-1-2
  - auth-2-1
```

## Querying Dependencies

### Find Blocked Tasks

Search task files for `depends_on` in frontmatter:

```bash
grep -rl "depends_on:" docs/workflow/planning/{topic}/
```

### Check if a Dependency is Resolved

Read the referenced task file and check its status:

```bash
grep "status:" docs/workflow/planning/billing-system/billing-1-2.md
```

A dependency is resolved when `status: completed`.

### Find Unblocked Work

For each pending task with `depends_on`, check all referenced tasks. If all are `completed`, the task is unblocked.
