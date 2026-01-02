# Output Formats

*Reference for **[technical-planning](../SKILL.md)***

---

Plans can be stored in different formats. **Ask the user which format they prefer** - this is their choice based on their workflow and preferences.

Present the options below and let the user decide. Each format's full benefits are documented in its output adapter file.

## Available Formats

### Local Markdown

Single `{topic}.md` file in `docs/workflow/planning/`

- No external tools required
- Everything in one version-controlled file
- Human-readable and easy to edit

**Details**: [output-local-markdown.md](output-local-markdown.md)

---

### Linear

Project with labeled issues (requires Linear MCP)

- Visual tracking with real-time updates
- Team collaboration with shared visibility
- Update tasks directly in Linear UI

**Details**: [output-linear.md](output-linear.md)

---

### Backlog.md

Task files in `backlog/` directory with Kanban UI

- Visual Kanban board (terminal or web)
- Local and fully version-controlled
- MCP integration for Claude Code

**Details**: [output-backlog-md.md](output-backlog-md.md)

---

### Beads

Git-backed graph issue tracker for AI agents

- Native dependency tracking with `bd ready`
- Multi-session context preservation
- Multi-agent coordination support

**Details**: [output-beads.md](output-beads.md)

---

## Adding New Formats

To add a new output format:
1. Create `output-{format}.md` in this directory
2. Include: Setup, Structure, Reading Plans, Updating Progress sections
3. Update this file with the new format
4. Update `start-planning.md` command with user-facing description
