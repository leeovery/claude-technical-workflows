# Local Markdown: Updating

## Status Transitions

Update the `status` field in the task file frontmatter at `docs/workflow/planning/{topic}/{task-id}.md`:

| Transition | Value |
|------------|-------|
| Complete | `status: completed` |
| Skipped | `status: skipped` |
| Cancelled | `status: cancelled` |
| In Progress | `status: in-progress` |

## Updating Task Content

Edit the task file directly:

- **Title**: Change the `# {Title}` heading in the body
- **Description**: Edit the body content below the title
- **Priority**: Set or change the `priority:` field in frontmatter
- **Tags**: Set or change the `tags:` field in frontmatter
- **Dependencies**: See [dependencies.md](dependencies.md)
