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

**Code example** (if pattern is non-obvious):
```pseudocode
// Structure, not production code
```

---

(Repeat for each phase)

---

## Edge Cases

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

## Sizing

**Phase**: 3-7 tasks, independently testable, verifiable completion

**Task**: One TDD cycle (test → implement → commit), ~5-30 min

**Good**:
```markdown
1. **CacheManager.get()**
   - **Do**: Return cached value if exists and not expired
   - **Test**: `"it gets cached value when hit"`
```

**Bad** (too big): "Implement caching layer"
**Bad** (too vague): "Handle errors"

## Ready for Implementation

- [ ] Each phase has acceptance criteria
- [ ] Each task has a test name
- [ ] Edge cases mapped
- [ ] Code examples for complex patterns
