# Implementation Plan Template

*Part of **[technical-planning](../SKILL.md)** | See also: **[planning-approach.md](planning-approach.md)** · **[guidelines.md](guidelines.md)***

---

## Template

```markdown
# Implementation Plan: {Feature/Project Name}

**Date**: YYYY-MM-DD
**Status**: Draft | Ready | In Progress | Completed
**Discussion**: `docs/specs/discussions/{topic-name}/`

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

## How to Create a Plan

1. Start with the discussion document
2. Extract key decisions and architecture choices
3. Identify logical phases (each independently testable)
4. Break each phase into TDD-sized tasks
5. Add test name for each task
6. Map edge cases from discussion to specific tasks

## Sizing

**Phase**: 3-7 tasks, independently testable, verifiable completion

**Task**: One TDD cycle (test → implement → commit), ~5-30 min

**Too big**: "Implement caching layer" (multiple TDD cycles)
**Too vague**: "Handle errors" (no testable criteria)

## Ready for Implementation

- [ ] Each phase has acceptance criteria
- [ ] Each task has a test name
- [ ] Edge cases mapped to tasks
- [ ] Dependencies identified

## What to Avoid

- Tasks too big for a single TDD cycle
- Vague acceptance criteria
- Missing edge case coverage
- Re-debating decisions already made in discussion
