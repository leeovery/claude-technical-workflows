# Local Markdown: Dependencies

## Dependency Format

Cross-topic dependencies reference tasks by their task ID (e.g., `billing-1-2`). The task file is at `docs/workflow/planning/{topic}/{task-id}.md`.

No format-level blocking mechanism — local markdown has no native dependency graph.

## Querying Dependencies

### Check if a Task Exists

```bash
ls docs/workflow/planning/billing-system/billing-1-2.md
```

### Check if a Task is Complete

Read the task file and check the status in frontmatter:

```bash
grep "status:" docs/workflow/planning/billing-system/billing-1-2.md
```
