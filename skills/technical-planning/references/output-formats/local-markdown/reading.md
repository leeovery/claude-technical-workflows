# Local Markdown: Reading

## Extracting a Task

To read a specific task, read the file at `docs/workflow/planning/{topic}/{task-id}.md`.

The task file is self-contained — frontmatter holds id, phase, and status. The body contains the title and full description.

## Next Incomplete Task

To find the next task to implement:

1. List task files in `docs/workflow/planning/{topic}/`
2. Filter to tasks where `status` is `pending` or `in-progress` (or missing — treat as `pending`)
3. If any tasks have `depends_on`, exclude those with unresolved dependencies
4. Order by phase number (from task ID: `{topic}-{phase}-{seq}`) — complete all earlier phases first
5. Within a phase, order by `priority` if present (`urgent` > `high` > `normal` > `low`), then by sequence number
6. The first match is the next task
7. If no incomplete tasks remain, all tasks are complete.
