# Output: Local Markdown

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this format for simple features or when you want everything in a single version-controlled file.

## Benefits

- No external tools or dependencies required
- Everything in a single version-controlled file
- Human-readable and easy to edit
- Works offline with any text editor
- Simplest setup - just create a markdown file

## Setup

No external tools required. This format uses plain markdown files stored in the repository.

## Output Location

```
docs/workflow/planning/
└── {topic}.md
```

This is a single file per topic in the planning directory.

## Template

Create `{topic}.md` with this structure:

```markdown
---
format: local-markdown
---

# Implementation Plan: {Feature/Project Name}

**Date**: YYYY-MM-DD
**Status**: Draft | Ready | In Progress | Completed
**Specification**: `docs/workflow/specification/{topic}.md`

## Overview

**Goal**: What we're building and why (one sentence)

**Done when**:
- Measurable outcome 1
- Measurable outcome 2

**Key Decisions** (from specification):
- Decision 1: Rationale
- Decision 2: Rationale

## Architecture

- Components
- Data flow
- Integration points

## Phases

Each phase is independently testable with clear acceptance criteria.
Each task is a single TDD cycle: write test → implement → commit.

---

### Phase 1: {Name}

**Goal**: What this phase accomplishes

**Acceptance**:
- [ ] Criterion 1
- [ ] Criterion 2

**Tasks**:

1. **{Task Name}**
   - **Do**: What to implement
   - **Test**: `"it does expected behavior"`
   - **Edge cases**: (if any)

2. **{Task Name}**
   - **Do**: What to implement
   - **Test**: `"it does expected behavior"`

---

### Phase 2: {Name}

**Goal**: What this phase accomplishes

**Acceptance**:
- [ ] Criterion 1
- [ ] Criterion 2

**Tasks**:

1. **{Task Name}**
   - **Do**: What to implement
   - **Test**: `"it does expected behavior"`

(Continue pattern for remaining phases)

---

## Edge Cases

Map edge cases from specification to specific tasks:

| Edge Case | Solution | Phase.Task | Test |
|-----------|----------|------------|------|
| {From specification} | How handled | 1.2 | `"it handles X"` |

## Testing Strategy

**Unit**: What to test per component
**Integration**: What flows to verify
**Manual**: (if needed)

## Data Models (if applicable)

Tables, schemas, API contracts

## Internal Dependencies

- Prerequisites for Phase 1
- Phase dependencies (Phase 2 depends on Phase 1, etc.)

## External Dependencies

[Dependencies on other topics - copy from specification's Dependencies section]

- {topic}: {description}
- {topic}: {description} → {task-reference} (resolved)
- ~~{topic}: {description}~~ → satisfied externally

## Rollback (if applicable)

Triggers and steps

## Log

| Date | Change |
|------|--------|
| YYYY-MM-DD | Created from specification |
```

## Cross-Topic Dependencies

Cross-topic dependencies link tasks between different plan files. This is how you express "this feature depends on the billing system being implemented."

### In the External Dependencies Section

Use the format `{topic}: {description} → {task-reference}` where task-reference points to a specific task in another plan file:

```markdown
## External Dependencies

- billing-system: Invoice generation → billing-system.md#phase-1-task-2 (resolved)
- authentication: User context → authentication.md#phase-2-task-1 (resolved)
- payment-gateway: Payment processing (unresolved - not yet planned)
```

### Task References

For local markdown plans, reference tasks using:
- `{topic}.md#phase-{n}-task-{m}` - references a specific task by phase and number
- Consider adding nano IDs to task headers for more stable references

## Querying Dependencies

Use these queries to understand the dependency graph for implementation blocking and `/link-dependencies`.

### Find Plans With External Dependencies

```bash
# Find all plans with external dependencies
grep -l "## External Dependencies" docs/workflow/planning/*.md

# Find unresolved dependencies (no arrow →)
grep -A 10 "## External Dependencies" docs/workflow/planning/*.md | grep "^- " | grep -v "→"
```

### Find Dependencies on a Specific Topic

```bash
# Find plans that depend on billing-system
grep -l "billing-system:" docs/workflow/planning/*.md
```

### Check if a Dependency Task Exists

Read the referenced plan file and verify the task exists:

```bash
# Check if a task exists in another plan
grep "Phase 1.*Task 2" docs/workflow/planning/billing-system.md
```

### Check if a Dependency is Complete

For local markdown, check if the task's acceptance criteria are checked off:

```bash
# Look for completed acceptance criteria
grep -A 5 "### Phase 1" docs/workflow/planning/billing-system.md | grep "\[x\]"
```

## Frontmatter

The `format: local-markdown` frontmatter tells implementation that the full plan content is in this file.

## Flagging Incomplete Tasks

When information is missing, mark clearly with `[needs-info]`:

```markdown
### Task 3: Configure rate limiting [needs-info]

**Do**: Set up rate limiting for the API endpoint
**Test**: `it throttles requests exceeding limit`

**Needs clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

## Resulting Structure

After planning:

```
docs/workflow/
├── discussion/{topic}.md      # Discussion output
├── specification/{topic}.md   # Specification output
└── planning/{topic}.md        # Planning output (format: local-markdown)
```

## Implementation

### Reading Plans

1. Read the plan file - all content is inline
2. Phases and tasks are in the document
3. Follow phase order as written

### Updating Progress

- Check off acceptance criteria in the plan file
- Update phase status as phases complete
