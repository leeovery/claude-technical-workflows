# Local Markdown: Reading

## Extracting a Task

To read a specific task, read the file at `docs/workflow/planning/{topic}/{task-id}.md`.

The task file is self-contained — frontmatter holds id, phase, status, priority, and creation date. The body contains the title and full description.

## Next Incomplete Task

To find the next task to implement:

1. List task files in `docs/workflow/planning/{topic}/`
2. Filter to tasks where `status` is `pending` or `in-progress`
3. Order by phase number (from task ID: `{topic}-{phase}-{seq}`) — complete all earlier phases first
4. Within a phase, order by priority (`urgent` > `high` > `normal` > `low`), then by sequence number
5. The first match is the next task
6. If no incomplete tasks remain, all tasks are complete.
