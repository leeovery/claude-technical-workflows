# Local Markdown: Authoring

## Task Storage

Each task is written to `docs/workflow/planning/{topic}/{task-id}.md` — a markdown file with frontmatter and a description body.

```markdown
---
id: {topic}-{phase}-{seq}
phase: {phase-number}
status: pending
created: YYYY-MM-DD
---

# {Task Title}

{Task description content}
```

**Required**: title (`# {Task Title}`) and description (body content). Everything else supports the format's storage mechanics.

## Task Properties

### Status

Stored in frontmatter. Defaults to `pending` if omitted.

| Status | Meaning |
|--------|---------|
| `pending` | Task has been authored but not started |
| `in-progress` | Task is currently being worked on |
| `completed` | Task is done |
| `skipped` | Task was deliberately skipped |
| `cancelled` | Task is no longer needed |

### Priority (optional)

Add a `priority` field to frontmatter:

```yaml
priority: high
```

| Priority | Meaning |
|----------|---------|
| `urgent` | Must be done first within its phase |
| `high` | Important — do before normal priority |
| `normal` | Standard priority (default if omitted) |
| `low` | Can be deferred within the phase |

If omitted, priority is determined by sequence ordering within the phase.

### Phase Grouping

Phases are encoded in the task ID: `{topic}-{phase}-{seq}`. The `phase` frontmatter field also stores the phase number for querying.

### Labels / Tags (optional)

Add a `tags` field to frontmatter if additional categorisation is needed:

```yaml
tags: [edge-case, needs-info]
```

### Dependencies (optional)

Add `depends_on` and/or `blocks` fields to frontmatter:

```yaml
depends_on:
  - {topic}-1-2
blocks:
  - {topic}-2-1
```

See [dependencies.md](dependencies.md) for full details on adding, removing, and querying.

## Flagging

In the task file, add a **Needs Clarification** section:

```markdown
**Needs Clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

## Cleanup (Restart)

Delete the task detail directory for this topic:

```bash
rm -rf docs/workflow/planning/{topic}/
```
