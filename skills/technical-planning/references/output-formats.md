# Output Formats

*Reference for **[technical-planning](../SKILL.md)***

---

Plans can be stored in different formats. Ask the user which format they want, then load the corresponding output adapter.

## Available Formats

### Local Markdown

Single `{topic}.md` file in `docs/workflow/planning/`

- **Best for**: Small features, solo work, quick iterations
- **Pros**: Everything in one version-controlled file, no external tools
- **Cons**: No visual tracking, manual progress updates

**Reference**: [output-local-markdown.md](output-local-markdown.md)

---

### Linear

Project with labeled issues (requires Linear MCP)

- **Best for**: Team collaboration, visual tracking, larger features
- **Pros**: Update tasks directly in Linear's UI, real-time progress visibility
- **Cons**: Requires MCP configuration, external dependency

**Reference**: [output-linear.md](output-linear.md)

---

### Backlog.md

Task files in `backlog/` directory with Kanban UI

- **Best for**: Local visual tracking with AI/MCP support
- **Pros**: Terminal and web Kanban views, git-native with auto-commit
- **Cons**: Requires npm install

**Reference**: [output-backlog-md.md](output-backlog-md.md)

---

### Beads

Git-backed graph issue tracker for AI agents

- **Best for**: Complex dependency graphs, multi-session implementations
- **Pros**: Native dependency tracking with `bd ready`, hierarchical (epics → phases → tasks)
- **Cons**: Requires CLI install, JSONL less human-readable

**Reference**: [output-beads.md](output-beads.md)

---

## Choosing a Format

| Need | Recommended |
|------|-------------|
| Simple, quick | Local Markdown |
| Team visibility | Linear |
| Local Kanban | Backlog.md |
| Complex dependencies | Beads |
| Multi-agent work | Beads |

## Adding New Formats

To add a new output format:
1. Create `output-{format}.md` in this directory
2. Include: Setup, Structure, Reading Plans, Updating Progress sections
3. Update this file with the new format
4. Update `start-planning.md` command with user-facing description
