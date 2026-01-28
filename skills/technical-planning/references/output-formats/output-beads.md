# Output: Beads

*Output adapter for **[technical-planning](../../SKILL.md)***

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

> "Beads can run with or without a local database. Database mode uses a daemon that auto-syncs to JSONL. No-database mode writes directly to JSONL. Which do you prefer? (default: database)"

### 4. Initialize

Based on the user's choice:

```bash
bd init --quiet          # database mode (default)
bd init --quiet --no-db  # no-database mode
```

This creates `.beads/config.yaml` with the appropriate `no-db` setting.

## Benefits

- Complex dependency graphs with native blocking relationships
- Multi-session context preservation via semantic summarization
- Multi-agent coordination support
- `bd ready` identifies actionable unblocked work
- Git-backed and version-controlled

## Beads Structure Mapping

| Planning Concept | Beads Entity |
|------------------|--------------|
| Specification/Topic | Epic issue |
| Phase | Sub-issue under epic |
| Task | Sub-task under phase |
| Internal dependency | `bd dep add` within same epic |
| Cross-topic dependency | `bd dep add` across epics |

Each specification topic becomes its own epic. All epics live in one beads database, enabling cross-topic dependencies.

Example hierarchy:
```
bd-a3f8        (Epic: User Authentication)
├── bd-a3f8.1  (Phase 1: Core Auth)
│   ├── bd-a3f8.1.1  (Task: Login endpoint)
│   └── bd-a3f8.1.2  (Task: Session management)
└── bd-a3f8.2  (Phase 2: OAuth)
    └── bd-a3f8.2.1  (Task: Google provider)

bd-b7c2        (Epic: Billing System)  ← Different topic, same database
├── bd-b7c2.1  (Phase 1: Invoicing)
│   └── bd-b7c2.1.1  (Task: Invoice generation)
```

## Cross-Epic Dependencies

Cross-topic dependencies link tasks between different epics (different specifications/topics). This is how you express "billing depends on authentication being complete."

### Creating Cross-Epic Dependencies

Use the same `bd dep add` command - it works across epics:

```bash
# Invoice generation (in billing epic) depends on user authentication (in auth epic)
bd dep add bd-b7c2.1.1 bd-a3f8.1.1
```

After adding, `bd ready` will not show `bd-b7c2.1.1` until `bd-a3f8.1.1` is closed.

### Viewing Cross-Epic Dependencies

```bash
# Show what a task depends on
bd show bd-b7c2.1.1

# Show what depends on a task
bd show bd-a3f8.1.1 --deps
```

## Querying Dependencies

Use these queries to understand the dependency graph for implementation blocking and `/link-dependencies`.

### Find Ready Tasks (No Open Blockers)

```bash
bd ready
```

Returns tasks with no incomplete dependencies - these are safe to implement.

### Find All Tasks Blocked By a Specific Task

```bash
bd show bd-a3f8.1.1 --deps
```

Shows what will be unblocked when this task completes.

### Find What a Task Depends On

```bash
bd show bd-b7c2.1.1
```

The output includes a "Blocked by" section listing dependencies.

### Query Via JSONL (Advanced)

For programmatic queries, read `.beads/issues.jsonl` directly:

```bash
# Find all dependencies (grep for blocked_by field)
grep -o '"blocked_by":\[[^]]*\]' .beads/issues.jsonl

# Find tasks depending on a specific ID
grep '"bd-a3f8.1.1"' .beads/issues.jsonl | grep blocked_by
```

### Check if a Task is Complete

```bash
bd show bd-a3f8.1.1
```

Look for `status: closed` in the output. A dependency is "met" when the task is closed.

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

Tasks should be **fully self-contained** - include all context so humans and agents can execute without referencing other files.

Task body should include:
```
## Goal
{What this task accomplishes and why - include rationale from specification}

## Implementation
{Specific files, methods, approach}

## Tests
- `it does expected behavior`
- `it handles edge case`

## Edge Cases
{Specific edge cases for this task}

## Context
{Relevant decisions and constraints from specification}

Specification reference: docs/workflow/specification/{topic}.md (for ambiguity resolution)
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
topic: {topic-name}
status: planning
format: beads
specification: ../specification/{topic}.md
spec_hash: {sha256-first-8-chars}
plan_id: bd-{EPIC_ID}
created: YYYY-MM-DD  # Use today's actual date
updated: YYYY-MM-DD
planning:
  phase: 1
  task: ~
  note: "Starting planning"
---

# Plan: {Topic Name}

## About This Plan

This plan is managed via Beads. Tasks are stored in `.beads/` and tracked as a dependency graph.

## How to Use

**View ready tasks**: Run `bd ready`
**View all tasks**: Run `bd list --tree`
**View specific task**: Run `bd show bd-{id}`

**Implementation will**:
1. Read this file to identify the epic
2. Check External Dependencies below
3. Query `bd ready` for unblocked tasks
4. Work through tasks respecting dependencies
5. Close tasks with `bd close bd-{id} "reason"`

## Key Decisions

[Summary of key decisions from specification]

## Cross-Cutting References

Architectural decisions from cross-cutting specifications that inform this plan:

| Specification | Key Decisions | Applies To |
|---------------|---------------|------------|
| [Caching Strategy](../../specification/caching-strategy.md) | Cache API responses for 5 min | Tasks involving API calls |
| [Rate Limiting](../../specification/rate-limiting.md) | 100 req/min per user | User-facing endpoints |

*Remove this section if no cross-cutting specifications apply.*

## Phases

### Phase 1: {Name}
status: draft
beads_id: bd-{id}.1

**Goal**: {What this phase accomplishes}
**Why this order**: {Why this comes at this position}

**Acceptance**:
- [ ] Criterion 1
- [ ] Criterion 2

#### Tasks
| ID | Name | Edge Cases | Status |
|----|------|------------|--------|
| bd-{id}.1.1 | {Task Name} | {list} | pending |

---

### Phase 2: {Name}
status: draft
beads_id: bd-{id}.2

...

## External Dependencies

[Dependencies on other topics - copy from specification's Dependencies section]

- {topic}: {description}
- {topic}: {description} → {task-id} (resolved)
```

The External Dependencies section tracks what this plan needs from other topics. See `../dependencies.md` for the format and states (unresolved, resolved, satisfied externally).

## Frontmatter

The frontmatter tells implementation to use beads CLI and tracks planning progress:

```yaml
---
topic: {topic-name}
status: planning | concluded
format: beads
specification: ../specification/{topic}.md
spec_hash: {sha256-first-8-chars}
plan_id: bd-a3f8
created: YYYY-MM-DD
updated: YYYY-MM-DD
planning:                          # Removed when concluded
  phase: 2
  task: 3
  note: "Authoring Phase 2 tasks"
---
```

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

1. Extract `plan_id` (beads epic ID) from frontmatter
2. Check `.beads/config.yaml` for `no-db` setting
3. Run `bd ready` to get unblocked tasks
4. View task details with `bd show bd-{id}`
5. Process by priority (P0 → P1 → P2 → P3)
6. Respect dependency graph - only work on ready tasks

### Updating Progress

- Close tasks with `bd close bd-{id} "reason"` when complete
- Include task ID in commit messages: `git commit -m "message (bd-{id})"`
- **Database mode**: Run `bd sync` before committing or ending session to ensure changes are persisted
- **No-db mode**: No sync needed - changes write directly to JSONL
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
| `bd sync` | Force immediate sync to JSONL (database mode only) |

## Sync Protocol (Database Mode Only)

In database mode, a daemon auto-syncs changes to JSONL with a ~5 second debounce. Run `bd sync` before committing or ending a session to ensure all pending changes are persisted:

```bash
bd sync
```

**Skip this entirely if `no-db: true`** - changes write directly to JSONL, no sync needed.

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
│   ├── discussion/{topic}.md      # Discussion output
│   ├── specification/{topic}.md   # Specification output
│   └── planning/{topic}.md        # Planning output (format: beads)
```

## Priority Mapping

| Planning Priority | Beads Priority |
|-------------------|----------------|
| Foundation/Setup | P0 |
| Core functionality | P1 |
| Enhancement | P2 |
| Nice-to-have | P3 |

Use `-p {0-3}` flag when creating issues.
