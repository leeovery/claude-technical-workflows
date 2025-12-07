# Implementation Plan Template

*Part of **[technical-planning](../SKILL.md)** | See also: **[planning-approach.md](planning-approach.md)** · **[guidelines.md](guidelines.md)***

---

Standard structure for `docs/specs/plans/` documents. PLAN only - no actual code changes.

## Template

```markdown
# Implementation Plan: {Feature/Project Name}

**Date**: YYYY-MM-DD
**Status**: Draft | Ready | In Progress | Completed
**Discussion Source**: `docs/specs/discussions/{topic-name}/`

## Overview

**Goal**: One sentence describing what we're building and why

**Success Criteria**: What "done" looks like
- Measurable outcome 1
- Measurable outcome 2

**Key Decisions** (from discussion):
- Decision 1: Rationale
- Decision 2: Rationale

## Architecture Overview

High-level architecture:
- Major components
- Data flow
- Integration points
- Technology choices (from discussion)

## Implementation Phases

Each phase is independently testable with clear acceptance criteria.
Each task within a phase is a single TDD cycle (one test, one commit).

---

### Phase 1: {Foundation/Setup}

**Goal**: What this phase accomplishes

**Acceptance Criteria**:
- [ ] Criterion 1 (measurable)
- [ ] Criterion 2 (measurable)
- [ ] All phase tests passing

**Tasks**:

1. **{Task Name}**
   - **Do**: What to implement
   - **Micro Acceptance**: `test_name_that_proves_completion`
   - **Edge Cases**: Any special handling (optional)
   - **Notes**: Implementation guidance (optional)

2. **{Task Name}**
   - **Do**: What to implement
   - **Micro Acceptance**: `test_name_that_proves_completion`

3. **{Task Name}**
   - **Do**: What to implement
   - **Micro Acceptance**: `test_name_that_proves_completion`

**Code Example** (if complex/novel):
```pseudocode
// Show structure, not production code
class Example {
    function method() {
        // key logic here
    }
}
```

---

### Phase 2: {Core Functionality}

**Goal**: What this phase accomplishes

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All phase tests passing

**Tasks**:

1. **{Task Name}**
   - **Do**: What to implement
   - **Micro Acceptance**: `test_name`
   - **Edge Cases**: Special handling

2. **{Task Name}**
   - **Do**: What to implement
   - **Micro Acceptance**: `test_name`

---

### Phase 3: {Edge Cases & Polish}

**Goal**: Handle edge cases and refine

**Acceptance Criteria**:
- [ ] All edge cases from discussion handled
- [ ] Error states graceful
- [ ] All tests passing

**Tasks**:

(List tasks with micro acceptance criteria)

---

## Edge Cases

Map edge cases from discussion to implementation:

| Edge Case | Solution | Phase | Task | Test |
|-----------|----------|-------|------|------|
| {From discussion} | How to handle | Phase N | Task M | `test_name` |
| {From discussion} | How to handle | Phase N | Task M | `test_name` |

## Testing Strategy

### Unit Tests
- Component 1: What to test
- Component 2: What to test

### Integration Tests
- Flow 1: What to verify
- Flow 2: What to verify

### Manual Verification (if needed)
- [ ] Scenario 1
- [ ] Scenario 2

## Data Models

### Database Changes
```sql
-- New tables or modifications
```

### API Contracts
```
GET /api/endpoint
Request: { fields }
Response: { fields }
```

## Dependencies

**Before Phase 1**:
- What must exist

**Phase Dependencies**:
- Phase 2 requires Phase 1 (reason)

**External**:
- External dependency (owner, status)

## Rollback Strategy

**Triggers**:
- Error rate > X%
- Critical bug

**Steps**:
1. Rollback step
2. Rollback step

## Evolution Log

### YYYY-MM-DD - Initial Plan
Created from discussion document: `docs/specs/discussions/{topic}/`

### YYYY-MM-DD - {Update}
{What changed and why}
```

## Phase/Task Sizing Guide

### Good Phase Size
- 3-7 tasks
- Independently testable
- Provides incremental value
- Can verify completion

### Good Task Size
- Single TDD cycle: write test → implement → pass → commit
- 5-30 minutes of work
- One clear thing to build
- One test to prove it works

### Examples

**Good task**:
```markdown
1. **Implement CacheManager.get()**
   - **Do**: Return cached value if exists and not expired
   - **Micro Acceptance**: `test_get_returns_cached_value_when_hit`
   - **Edge Cases**: Return None on cache miss
```

**Bad task** (too big):
```markdown
1. **Implement caching layer**
   - **Do**: Add caching to the application
```

**Bad task** (too vague):
```markdown
1. **Handle errors**
   - **Do**: Add error handling
```

## Usage Notes

**When creating**:
1. Start with discussion document
2. Identify logical phases
3. Break each phase into TDD-sized tasks
4. Add micro acceptance (test name) for each task
5. Map edge cases from discussion

**Task micro acceptance**:
- Name the specific test that proves the task is done
- Implementation will write this test first, then implement
- Format: `test_{method}_{scenario}_{expected}`

**Ready for implementation when**:
- [ ] Each phase has clear acceptance criteria
- [ ] Each task has micro acceptance (test name)
- [ ] Edge cases mapped to tasks
- [ ] Code examples for complex patterns
- [ ] Dependencies identified

**What to avoid**:
- Tasks too big for single TDD cycle
- Vague acceptance criteria
- Missing edge case handling
- Re-debating discussion decisions
