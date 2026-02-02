# {Format Name}: Authoring

<!-- Instructions for creating plans and writing tasks during planning -->

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

## Task Writing

<!-- How to create individual tasks. Must use canonical field names -->
<!-- See canonical-task.md for field definitions -->

Each task uses the canonical field names:

```markdown
### Task {id}: {name}

**Problem**: {why this task exists}

**Solution**: {what we're building}

**Outcome**: {verifiable end state}

**Do**:
- {implementation steps}

**Acceptance Criteria**:
- [ ] {pass/fail criteria}

**Tests**:
- `"{test name}"`

**Edge Cases**:
- {boundary conditions}

**Context**:
> {spec decisions}

**Spec Reference**: `docs/workflow/specification/{topic}.md`
```

<!-- Add format-specific instructions for WHERE to write the task -->
{How to store the task in this format - file path, API call, etc.}

After writing:
1. {Step to update task table status to `authored`}
2. {Step to advance `planning:` block in frontmatter}

## Flagging

<!-- How to mark tasks as [needs-info] -->
When information is missing:

{Format-specific flagging instructions}

Add a **Needs Clarification** section to the task:

```markdown
**Needs Clarification**:
- {open question}
```

## Cleanup (Restart)

<!-- How to delete all authored tasks for a topic -->
{Format-specific cleanup command or instructions}
