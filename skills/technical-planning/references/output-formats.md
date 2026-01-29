# Output Formats

*Reference for **[technical-planning](../SKILL.md)***

---

Plans can be stored in different formats.

**IMPORTANT**: Only offer formats listed below. Do not invent or suggest formats that don't have corresponding `output-*.md` files in the [output-formats/](output-formats/) directory.

## Available Formats

### Local Markdown
format: `local-markdown`

adapter: [output-local-markdown.md](output-formats/output-local-markdown.md)


Single markdown file per topic containing all phases, tasks, and progress tracking inline. No external tools or setup required.

- **Pros**: Zero setup, works offline, human-readable, easy to edit in any text editor
- **Cons**: No visual board, everything in one file can get long for complex features, no dependency graph
- **Best for**: Simple features, small plans, quick iterations

### Linear
format: `linear`

adapter: [output-linear.md](output-formats/output-linear.md)


Tasks managed as Linear issues within a Linear project. A thin Plan Index File points to the Linear project; Linear is the source of truth.

- **Pros**: Visual tracking, team collaboration, real-time updates, integrates with existing Linear workflows
- **Cons**: Requires Linear account and MCP server, external dependency, not fully local
- **Best for**: Teams already using Linear, collaborative projects needing shared visibility

### Backlog.md
format: `backlog-md`

adapter: [output-backlog-md.md](output-formats/output-backlog-md.md)


Individual task files in a `backlog/` directory with a local Kanban board. Each task is a self-contained markdown file with frontmatter for status, priority, labels, and dependencies.

- **Pros**: Visual Kanban (terminal + web), individual task files for focused editing, version-controlled, MCP integration, auto-commit
- **Cons**: Requires npm install, flat directory (phases via labels not folders), external tool dependency
- **Best for**: Solo developers wanting a local Kanban board with per-task files

### Beads
format: `beads`

adapter: [output-beads.md](output-formats/output-beads.md)


Git-backed graph issue tracker with hierarchical tasks (epics → phases → tasks) and native dependency management. Uses JSONL storage with a CLI interface.

- **Pros**: Native dependency graph, `bd ready` surfaces unblocked work, hierarchical task structure, multi-agent coordination, hash-based IDs prevent merge conflicts
- **Cons**: Requires CLI install, JSONL not human-editable, learning curve, less familiar tooling
- **Best for**: Complex multi-phase features with many dependencies, AI-agent-driven workflows
