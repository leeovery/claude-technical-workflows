# Local Markdown: Reading

## Extracting a Task

To read a specific task, read the file at `docs/workflow/planning/{topic}/{task-id}.md`.

The task file is self-contained — it has frontmatter (id, phase, status) and a description body with all instructional content.

## Next Incomplete Task

To find the next task to implement:

1. Look for task files in `docs/workflow/planning/{topic}/` with `status: pending` or `status: authored` in frontmatter
2. Order by phase number, then sequence number (both encoded in the task ID: `{topic}-{phase}-{seq}`)
3. The first match is the next task
4. If no incomplete tasks remain, all tasks are complete.
