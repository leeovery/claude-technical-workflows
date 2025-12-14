# Output: Local Markdown

*Output adapter for **[technical-planning](../SKILL.md)***

---

Use this format for simple features or when you want everything in a single version-controlled file.

## Output Location

```
docs/workflow/{topic}/
└── plan.md
```

The topic directory contains all workflow artifacts (discussion, specification, plan).

**Single file (default):** `docs/workflow/{topic}/plan.md`

**Multiple files (when needed):** Move to `docs/workflow/{topic}/plans/` with semantically named files.

## Template

Create `plan.md` with this structure:

```markdown
---
format: local-markdown
---

# Implementation Plan: {Feature/Project Name}

**Date**: YYYY-MM-DD
**Status**: Draft | Ready | In Progress | Completed
**Topic**: `docs/workflow/{topic}/`

## Overview

**Goal**: What we're building and why (one sentence)

**Done when**:
- Measurable outcome 1
- Measurable outcome 2

**Key Decisions** (from discussion):
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

Map edge cases from discussion to specific tasks:

| Edge Case | Solution | Phase.Task | Test |
|-----------|----------|------------|------|
| {From discussion} | How handled | 1.2 | `"it handles X"` |

## Testing Strategy

**Unit**: What to test per component
**Integration**: What flows to verify
**Manual**: (if needed)

## Data Models (if applicable)

Tables, schemas, API contracts

## Dependencies

- Prerequisites for Phase 1
- Phase dependencies
- External blockers

## Rollback (if applicable)

Triggers and steps

## Log

| Date | Change |
|------|--------|
| YYYY-MM-DD | Created from discussion |
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
└── {topic}/
    ├── discussion.md      # Phase 1 output
    ├── specification.md   # Phase 2 output
    └── plan.md            # Phase 3 output (format: local-markdown)
```

Implementation reads `plan.md`, sees `format: local-markdown`, and executes directly from file content.
