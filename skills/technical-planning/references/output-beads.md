# Output: Beads

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this output format when you need **dependency-aware task tracking designed for AI agents**. Beads is a git-backed graph issue tracker that excels at complex, multi-phase implementations with real dependency management.

## About Beads

Beads (`bd`) is an issue tracker built specifically for AI agents:
- Git-backed storage in `.beads/` directory (JSONL format)
- Hash-based IDs (`bd-a1b2`) prevent merge conflicts
- Native dependency graph with blocking relationships
- Hierarchical tasks: epics → tasks → subtasks
- `bd ready` command identifies unblocked work
- Semantic summarization preserves context windows
- Multi-agent coordination via sync protocol

See: https://github.com/steveyegge/beads

## Setup

### 1. Check Installation

Check if beads is installed (required every session in ephemeral environments):

```bash
which bd
```

- **Local systems**: May already be installed via Homebrew
- **Ephemeral environments** (Claude Code on web): Needs installation each session

If not installed:
```bash
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

### 2. Check If Project Initialized

Check if beads is already set up in this project:

```bash
ls .beads/config.yaml
```

**If `.beads/` exists**: Project is already initialized - skip to using beads.

**If not initialized**: Continue with steps 3 and 4.

### 3. Choose Database Mode

Beads supports two modes. Ask the user:

> "Beads can run with or without a local database. Database mode buffers changes and requires `bd sync` to persist. No-database mode writes directly to JSONL (simpler, no sync needed). Which do you prefer? (default: database)"

### 4. Initialize

Based on the user's choice:

```bash
bd init -q          # database mode (default) - requires bd sync
bd init -q --no-db  # no-database mode - writes directly to JSONL
```

The `-q` (quiet) flag skips interactive prompts.

This creates `.beads/config.yaml` with the appropriate `no-db` setting.

## When to Use

Choose beads when:
- Complex dependency graphs between tasks
- Multi-session implementations needing context preservation
- Multiple agents may work on the project
- You need `bd ready` to identify actionable work
- Long-horizon task management

Avoid beads when:
- Simple linear features (use local markdown)
- Team collaboration with non-AI members (use Linear)
- Human readability is paramount (JSONL is less readable)
- Single-session implementations

## Beads Structure Mapping

| Planning Concept | Beads Entity |
|------------------|--------------|
| Plan | Epic issue |
| Phase | Sub-issue under epic |
| Task | Sub-task under phase |
| Dependency | `bd dep add` relationship |

Example hierarchy:
```
bd-a3f8        (Epic: User Authentication)
├── bd-a3f8.1  (Phase 1: Core Auth)
│   ├── bd-a3f8.1.1  (Task: Login endpoint)
│   └── bd-a3f8.1.2  (Task: Session management)
└── bd-a3f8.2  (Phase 2: OAuth)
    └── bd-a3f8.2.1  (Task: Google provider)
```

## Output Process

### 1. Create Epic for Plan

```bash
bd create "Plan: {Topic Name}" -p 1
```

Note the returned ID (e.g., `bd-a3f8`). This is the plan epic.

### 2. Create Phase Issues

For each phase, create a sub-issue under the epic:

```bash
bd create "Phase 1: {Phase Name}" -p 1 --parent bd-a3f8
bd create "Phase 2: {Phase Name}" -p 2 --parent bd-a3f8
```

Add phase acceptance criteria in the issue body.

### 3. Create Task Issues

For each task, create under the appropriate phase:

```bash
bd create "{Task Name}" -p 1 --parent bd-a3f8.1
```

Task body should include:
```
## Goal
{What this task accomplishes}

## Implementation
{Specific files, methods, approach}

## Tests
- `it does expected behavior`
- `it handles edge case`

## Specification
docs/workflow/specification/{topic}.md
```

### 4. Add Dependencies

When tasks depend on each other:

```bash
bd dep add bd-a3f8.1.2 bd-a3f8.1.1  # 1.2 blocked by 1.1
```

### 5. Create Local Plan File

Create `docs/workflow/planning/{topic}.md`:

```markdown
---
format: beads
epic: bd-{EPIC_ID}
---

# Plan Reference: {Topic Name}

**Specification**: `docs/workflow/specification/{topic}.md`
**Created**: {DATE}

## About This Plan

This plan is managed via Beads. Tasks are stored in `.beads/` and tracked as a dependency graph.

## How to Use

**View ready tasks**: Run `bd ready`
**View all tasks**: Run `bd list --tree`
**View specific task**: Run `bd show bd-{id}`

**Implementation will**:
1. Read this file to identify the epic
2. Check `.beads/config.yaml` for database mode
3. Query `bd ready` for unblocked tasks
4. Work through tasks respecting dependencies
5. Close tasks with `bd close bd-{id} "reason"`
6. If using database mode: sync with `bd sync` at session end

## Key Decisions

[Summary of key decisions from specification]

## Phase Overview

| Phase | Goal | Epic ID |
|-------|------|---------|
| Phase 1 | {Goal} | bd-{id}.1 |
| Phase 2 | {Goal} | bd-{id}.2 |
```

## Frontmatter

The `format: beads` frontmatter tells implementation to use beads CLI:

```yaml
---
format: beads
epic: bd-a3f8
---
```

Database mode is stored in `.beads/config.yaml`, not in frontmatter.

## Flagging Incomplete Tasks

When information is missing, note it in the task body:

```bash
bd create "Configure rate limiting [needs-info]" -p 2 --parent bd-a3f8.1
```

In the task body:
```
## Needs Clarification
- What's the rate limit threshold?
- Per-user or per-IP?
```

## Implementation

### Reading Plans

1. Extract `epic` ID from frontmatter
2. Check `.beads/config.yaml` for `no-db` setting (determines if sync needed)
3. Run `bd ready` to get unblocked tasks
4. View task details with `bd show bd-{id}`
5. Process by priority (P0 → P1 → P2 → P3)
6. Respect dependency graph - only work on ready tasks

### Updating Progress

- Close tasks with `bd close bd-{id} "reason"` when complete
- Include task ID in commit messages: `git commit -m "message (bd-{id})"`
- **If `no-db: false` or not set** (database mode): Run `bd sync` at session end to persist changes
- **If `no-db: true`**: No sync needed - changes write directly to JSONL
- Use `bd ready` to identify next unblocked task

### Fallback

If `bd` CLI is unavailable, follow the installation steps in the **Setup** section above.

## Beads Workflow Commands

| Command | Purpose |
|---------|---------|
| `bd ready` | List tasks with no open blockers |
| `bd list --tree` | Show full task hierarchy |
| `bd show bd-{id}` | View task details |
| `bd close bd-{id} "reason"` | Complete a task |
| `bd dep add child parent` | Add dependency |
| `bd sync` | Commit and push changes (database mode only) |

## Sync Protocol (Database Mode Only)

When using database mode (`no-db: false` or not set in `.beads/config.yaml`), implementation must run `bd sync` at session end to:
- Export pending changes to JSONL
- Commit to git
- Push to remote

Without sync, changes stay in a 30-second debounce window and may not persist.

**Skip this section entirely if `no-db: true`** - changes write directly to JSONL.

## Commit Message Convention

Include issue IDs in commits:

```bash
git commit -m "Add login endpoint (bd-a3f8.1.1)"
```

This enables `bd doctor` to identify orphaned issues.

## Resulting Structure

After planning:

```
project/
├── .beads/
│   └── issues.jsonl          # Beads database
├── docs/workflow/
│   ├── discussion/{topic}.md      # Phase 2 output
│   ├── specification/{topic}.md   # Phase 3 output
│   └── planning/{topic}.md        # Phase 4 output (format: beads)
```

## Priority Mapping

| Planning Priority | Beads Priority |
|-------------------|----------------|
| Foundation/Setup | P0 |
| Core functionality | P1 |
| Enhancement | P2 |
| Nice-to-have | P3 |

Use `-p {0-3}` flag when creating issues.
