# Local Markdown: Authoring

## Task Storage

Each task is written to `docs/workflow/planning/{topic}/{task-id}.md` — a markdown file with frontmatter and a description body.

```markdown
---
id: {topic}-{phase}-{seq}
phase: {phase-number}
status: pending
priority: normal
created: YYYY-MM-DD
---

# {Task Title}

{Task description content}
```

## Task Properties

### Status

| Status | Meaning |
|--------|---------|
| `pending` | Task has been authored but not started |
| `in-progress` | Task is currently being worked on |
| `completed` | Task is done |
| `skipped` | Task was deliberately skipped |
| `cancelled` | Task is no longer needed |

### Priority

| Priority | Meaning |
|----------|---------|
| `urgent` | Must be done first within its phase |
| `high` | Important — do before normal priority |
| `normal` | Standard priority (default) |
| `low` | Can be deferred within the phase |

Priority is set in frontmatter. Within a phase, tasks are ordered by priority first, then by sequence number.

### Phase Grouping

Phases are encoded in the task ID: `{topic}-{phase}-{seq}`. The `phase` frontmatter field also stores the phase number for querying.

### Labels / Tags

No native label/tag system. Use a `tags` frontmatter field if additional categorisation is needed:

```yaml
tags: [edge-case, needs-info]
```

## Flagging

In the task file, add a **Needs Clarification** section and optionally add `needs-info` to the `tags` field:

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
