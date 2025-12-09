# Output: Tasks.md

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this output format when you want a **local Kanban board** backed by markdown files. Tasks.md provides a visual UI while keeping everything version-controlled.

## About Tasks.md

Tasks.md is a self-hosted Kanban application that uses your filesystem:
- **Lanes** = directories
- **Tasks** = individual markdown files
- Web UI for drag-and-drop task management
- Files stay in your repo, version-controlled

See: https://github.com/BaldissaraMatheus/Tasks.md

## Output Location

```
docs/specs/plans/{topic-name}/
├── plan.md                   # Plan overview with format declaration
├── 1-{phase-name}/           # Lane = Phase
│   ├── 01-{task-name}.md     # Task card
│   ├── 02-{task-name}.md
│   └── 03-{task-name}.md
├── 2-{phase-name}/
│   ├── 01-{task-name}.md
│   └── 02-{task-name}.md
└── done/                     # Completed tasks move here
```

## File Structure

### Plan File (`plan.md`)

```markdown
---
format: tasks-md
---

# Plan: {Feature Name}

**Discussion**: `docs/specs/discussions/{topic-name}/`
**Created**: {DATE}
**Status**: Draft | Ready | In Progress | Completed

## Goal
{One sentence description}

## Done When
- {Measurable outcome 1}
- {Measurable outcome 2}

## Key Decisions
- {Decision 1}: {Rationale}
- {Decision 2}: {Rationale}

## Phases

Tasks are organized in subdirectories:

1. **`1-{phase-name}/`**: {Phase 1 goal}
2. **`2-{phase-name}/`**: {Phase 2 goal}

## Notes
{Any additional context}
```

### Frontmatter

The `format: tasks-md` frontmatter tells implementation to look for task subdirectories:

```yaml
---
format: tasks-md
---
```

### Phase Directory

Directory name format: `{N}-{phase-name}` (e.g., `1-core-authentication`)

The number prefix ensures phases display in order.

### Task File

Each task is a separate markdown file within its phase directory.

Filename format: `{NN}-{task-name}.md` (e.g., `01-add-login-endpoint.md`)

```markdown
---
tags: [api, auth]
---

# {Task Name}

## Goal
{What this task accomplishes}

## Implementation
{The "Do" - specific files, methods, approach}

## Tests
- `it does expected behavior`
- `it handles edge case X`

## Edge Cases
- {Specific edge cases for this task}

## Context
See: `docs/specs/discussions/{topic-name}/discussion.md`

## Acceptance
- [ ] Test written and failing
- [ ] Implementation complete
- [ ] Test passing
- [ ] Committed
```

## Task Movement

When implementation completes a task:
1. Check off acceptance items in the task file
2. Move the file to the `done/` directory (or Tasks.md UI handles this)

This provides visual progress tracking in the Kanban board.

## When to Use

- When you want visual Kanban tracking
- Solo or small team development
- Everything stays local and version-controlled
- No external service dependencies
- Works well with Obsidian or other markdown tools

## Resulting Structure

After planning:

```
docs/specs/
├── discussions/
│   └── {topic-name}/
│       └── discussion.md
└── plans/
    └── {topic-name}/
        ├── plan.md               # format: tasks-md
        ├── 1-setup/
        │   └── 01-configure-auth.md
        ├── 2-core-features/
        │   ├── 01-login-endpoint.md
        │   └── 02-session-management.md
        ├── 3-edge-cases/
        │   └── 01-handle-expired-tokens.md
        └── done/
```

## Implementation Reading

Implementation will:
1. Read `plan.md`, see `format: tasks-md`
2. Read `plan.md` for overview context
3. Process phases in directory order (1-, 2-, 3-)
4. Process tasks within each phase in file order (01-, 02-)
5. Move completed task files to `done/` directory

## Integration with Tasks.md UI

If using the Tasks.md web interface:
- Point Tasks.md to `docs/specs/plans/{topic-name}/`
- Phase directories become lanes
- Task files become cards
- Drag cards between lanes to track progress
- Changes sync to filesystem automatically
