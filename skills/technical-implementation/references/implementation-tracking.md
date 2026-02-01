# Implementation Tracking

*Reference for **[technical-implementation](../SKILL.md)***

---

Each topic has a tracking file at `docs/workflow/implementation/{topic}.md` that records progress programmatically (frontmatter) and as a human-readable summary (body).

## Initial Tracking File

When starting implementation for a topic, create:

```yaml
---
topic: {topic}
plan: ../planning/{topic}.md
format: {format from plan}
status: in-progress
current_phase: 1
current_task: ~
completed_phases: []
completed_tasks: []
started: YYYY-MM-DD
updated: YYYY-MM-DD
completed: ~
---

# Implementation: {Topic Name}

Implementation started.
```

## Updating Progress

When a task or phase completes, update **two** things:

1. **Output format progress** — Follow the output adapter's Implementation section (loaded during plan reading) to mark tasks/phases complete in the plan index file and any format-specific files. This is the plan's own progress tracking.

2. **Implementation tracking file** — Update `docs/workflow/implementation/{topic}.md` as described below. This enables cross-topic dependency resolution and resume detection.

**After each task completes (tracking file):**
- Append the task ID to `completed_tasks`
- Update `current_task` to the next task (or `~` if phase done)
- Update `updated` date
- Update the body progress section

**After each phase completes (tracking file):**
- Append the phase number to `completed_phases`
- Update `current_phase` to the next phase (or leave as last)
- Update the body progress section

**On implementation completion (tracking file):**
- Set `status: completed`
- Set `completed: {today}`
- Commit: `impl({topic}): complete implementation`

Task IDs in `completed_tasks` use whatever ID format the output format assigns — the same IDs used in dependency references.

## Body Progress Section

The body provides a human-readable summary for context refresh:

```markdown
# Implementation: {Topic Name}

## Phase 1: Foundation
All tasks completed.

## Phase 2: Core Logic (current)
- Task 2.1: Service layer - done
- Task 2.2: Validation - done
- Task 2.3: Controllers (next)
```
