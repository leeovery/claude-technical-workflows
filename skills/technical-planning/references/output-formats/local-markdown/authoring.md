# Local Markdown: Authoring

## Task Storage

Each task is written to `docs/workflow/planning/{topic}/{task-id}.md` — a file with frontmatter, a title, and a description body.

```markdown
---
id: {topic}-{phase}-{seq}
phase: {phase-number}
status: pending
created: YYYY-MM-DD  # Use today's actual date
---

# {Task Title}

{Task description content}
```

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
