# Plan Sources

*Reference for **[technical-implementation](../SKILL.md)***

---

Plans are always stored in `docs/workflow/planning/{topic}.md`. The file's frontmatter declares the format.

## Detecting Plan Format

Always read the plan file first and check the `format` field in frontmatter:

| Format | Meaning | How to Proceed |
|--------|---------|----------------|
| `local-markdown` | Full plan is in this file | Read content directly |
| `linear` | Plan managed in Linear | Query Linear via MCP |
| `backlog-md` | Tasks in Backlog.md | Query via MCP or read `backlog/` |
| `beads` | Graph tracker for agents | Use `bd` CLI commands |

For full format details, see the planning skill's output adapters:
- [output-local-markdown.md](../../technical-planning/references/output-local-markdown.md)
- [output-linear.md](../../technical-planning/references/output-linear.md)
- [output-backlog-md.md](../../technical-planning/references/output-backlog-md.md)
- [output-beads.md](../../technical-planning/references/output-beads.md)

## Reading Plans

### Local Markdown

1. Read the plan file - all content is inline
2. Phases and tasks are in the document
3. Follow phase order as written

### Linear

1. Extract `project_id` from frontmatter
2. Query Linear MCP for project issues
3. Filter issues by phase label (e.g., `phase-1`, `phase-2`)
4. Process in phase order

**Fallback**: If Linear MCP is unavailable, inform user and suggest checking MCP configuration.

### Backlog.md

1. If Backlog.md MCP is available, query tasks via MCP
2. Otherwise, read task files from `backlog/` directory
3. Filter tasks by label (e.g., `phase-1`) or naming convention
4. Process in priority order (high → medium → low)

**Fallback**: Can read `backlog/` files directly if MCP unavailable.

### Beads

1. Extract `epic` ID from frontmatter
2. Run `bd ready` to get unblocked tasks
3. View task details with `bd show bd-{id}`
4. Process by priority (P0 → P1 → P2 → P3)
5. Respect dependency graph - only work on ready tasks

**Fallback**: If `bd` CLI unavailable, inform user to install beads.

## Updating Progress

### Local Markdown
- Check off acceptance criteria in the plan file
- Update phase status as phases complete

### Linear
- Update issue status in Linear via MCP after each task
- User sees real-time progress in Linear UI

### Backlog.md
- Update task status to "In Progress" when starting
- Check off acceptance criteria items in task file
- Update status to "Done" when complete
- Backlog.md CLI auto-moves to completed folder

### Beads
- Close tasks with `bd close bd-{id} "reason"` when complete
- Include task ID in commit messages: `git commit -m "message (bd-{id})"`
- **Critical**: Run `bd sync` at session end to persist changes
- Use `bd ready` to identify next unblocked task

## Execution Workflow

Regardless of format, execute the same TDD workflow:
1. Derive test from micro acceptance
2. Write failing test
3. Implement to pass
4. Commit
5. Update progress
6. Repeat
