# Local Markdown: Reading

## Reading the Plan Index

1. Read the Plan Index File at `docs/workflow/planning/{topic}.md`
2. The file contains phases with task tables showing ID, name, edge cases, and status
3. Follow phase order as written in the index

## Extracting a Task

To read a specific task, read the file at `docs/workflow/planning/{topic}/{task-id}.md`.

The task file is self-contained with all instructional content: Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Edge Cases, Context, and Spec Reference.

## Next Incomplete Task

To find the next task to implement:

1. Read the Plan Index File's `planning:` frontmatter block for the current phase and task position
2. In the task tables, find the first task with `status: authored` (not `completed` or `skipped`)
3. Follow phase order — complete all tasks in phase N before moving to phase N+1
4. If no authored tasks remain, all tasks are complete.
