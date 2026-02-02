# {Format Name}: Authoring

<!-- Instructions for creating plans and storing task content during planning -->

## Plan Index Template

Create `docs/workflow/planning/{topic}.md` with this structure:

<!-- Include the full Plan Index template with frontmatter and body -->
<!-- See frontmatter.md for the frontmatter schema -->
```markdown
---
{frontmatter fields - see frontmatter.md}
---

# Plan: {Topic Name}

{body structure}
```

## Task Storage

<!-- Define WHERE and HOW task content is stored — not what's in it -->
<!-- The planning skill decides task content; the format provides the container -->

Each task has a **title** and **description** (content body). The planning skill provides both.

{How to store a task in this format — file path, API call, etc.}

After storing:
1. {Step to update task table status to `authored`}
2. {Step to advance `planning:` block in frontmatter}

## Flagging

<!-- How to mark tasks as [needs-info] -->
When information is missing:

{Format-specific flagging instructions}

## Cleanup (Restart)

<!-- How to delete all authored tasks for a topic -->
{Format-specific cleanup command or instructions}
