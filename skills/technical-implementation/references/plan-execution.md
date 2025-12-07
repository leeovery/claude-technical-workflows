# Plan Execution

*Part of **[technical-implementation](../SKILL.md)** | See also: **[tdd-workflow.md](tdd-workflow.md)** · **[code-quality.md](code-quality.md)***

---

How to read, follow, and execute implementation plans.

## Plan Structure

Plans live in `docs/specs/plans/{topic}/` and follow this hierarchy:

```
Plan
├── Overview (goal, success criteria)
├── Architecture (from discussion decisions)
└── Phases
    ├── Phase 1
    │   ├── Goal
    │   ├── Acceptance Criteria
    │   └── Tasks
    │       ├── Task 1 (description, edge cases, micro acceptance)
    │       ├── Task 2
    │       └── Task 3
    ├── Phase 2
    └── Phase 3
```

### Phase vs Task

**Phase**: Higher-level grouping. Independently testable. Has acceptance criteria.
- "Phase 2: Core Cache Functionality"

**Task**: Granular unit of work. Single TDD cycle. Has micro acceptance criteria.
- "Task 1: Implement CacheManager.get()"

One task = one TDD cycle = one commit.

## Reading the Plan

### Before Starting

1. **Read the entire plan** - Understand the full scope
2. **Read the linked discussion** - Understand the rationale
3. **Identify dependencies** - What must exist before Phase 1?
4. **Check for blockers** - External dependencies, missing info?

### What to Extract

From each phase:
- Goal: What this phase accomplishes
- Acceptance criteria: How to verify phase completion
- Tasks: What to implement

From each task:
- Description: What to build
- Edge cases: Special handling needed
- Micro acceptance: Specific test that proves completion

## Execution Flow

```
📍 Start Phase
   │
   ├─→ 📝 Task 1
   │     ├─→ 🔴 Write failing test
   │     ├─→ 🟢 Implement to pass
   │     ├─→ 🔧 Refactor (if needed)
   │     └─→ 💾 Commit
   │
   ├─→ 📝 Task 2 (repeat)
   │
   ├─→ 📝 Task N (repeat)
   │
   ├─→ ✓ Verify phase acceptance criteria
   │
   └─→ 🙋 Ask before next phase
```

### Phase Start

Announce what you're beginning:
```
📍 Starting Phase 2: Core Cache Functionality

Goal: Implement CacheManager with get/set/invalidate operations

Acceptance Criteria:
- CacheManager class exists with get(), set(), invalidate()
- All unit tests passing
- Cache hit < 50ms, cache miss < 500ms

Tasks:
1. Implement CacheManager.get()
2. Implement CacheManager.set()
3. Implement CacheManager.invalidate()
```

### Task Execution

For each task, follow [TDD workflow](tdd-workflow.md):

```
📝 Task 1: Implement CacheManager.get()
   Edge cases: Handle connection failure gracefully
   Micro acceptance: "it gets cached value when hit"

🔴 Writing test: "it gets cached value when hit"
   [Write test code]
   Running tests... FAIL (expected)

🟢 Implementing CacheManager.get()
   [Write implementation]
   Running tests... PASS

💾 Committing: feat(cache): implement CacheManager.get()
```

### Phase Completion

After all tasks, verify acceptance criteria:

```
✅ Phase 2 Complete

Verification:
- [x] CacheManager class exists with get(), set(), invalidate()
- [x] All unit tests passing (12 tests)
- [x] Cache hit: 23ms (target: <50ms)
- [x] Cache miss: 180ms (target: <500ms)

Ready to proceed to Phase 3?
```

**Wait for user confirmation before proceeding.**

## Referencing Discussion

The discussion document (`docs/specs/discussions/{topic}/`) contains:

- **Why** decisions were made
- **Alternatives** that were considered and rejected
- **Edge cases** and how to handle them
- **Trade-offs** that were accepted

### When to Reference

- Task rationale unclear
- Multiple valid approaches for implementation detail
- Edge case handling not specified
- Need to understand constraints

### How to Reference

```
Checking discussion doc for cache TTL rationale...
Discussion says: "5 minute TTL acceptable - users refresh every 10-15 min"
Proceeding with TTL = 300 seconds.
```

### Don't Re-debate

The discussion captured the decision. Implementation follows it.

```
# Wrong
"I think we should use 10 minute TTL instead of 5..."

# Right
"Discussion specifies 5 minute TTL. Implementing as specified."
```

## Handling Problems

### Plan Doesn't Cover Something

Stop and escalate:
```
⚠️ Issue: Plan doesn't specify error handling for Redis connection timeout

Options:
A) Throw exception and let caller handle
B) Return null and log warning
C) Retry once then fail

The discussion mentions graceful degradation but doesn't specify.
Which approach should I take?
```

### Plan Seems Incorrect

Stop and escalate:
```
⚠️ Issue: Plan says "cache user preferences in Redis"
         But discussion decided "preferences in database for ACID"

This appears to be a discrepancy. Should I:
A) Follow the plan (Redis)
B) Follow the discussion (database)
C) Clarify before proceeding
```

### Discovered During Implementation

Stop and escalate:
```
⚠️ Issue: While implementing CacheManager.get(), discovered that
         the Redis client doesn't support the assumed batch operations.

Impact: Phase 3 tasks assume batch get/set which won't work.

Options:
A) Use individual calls (slower, simpler)
B) Switch to different Redis library
C) Revise Phase 3 approach

Need guidance before continuing.
```

### Never Silently Deviate

Don't make significant decisions alone. The plan exists for a reason. Deviations need acknowledgment.

## Phase Completion Checklist

Before marking a phase complete:

```markdown
## Phase X Complete

### Tasks
- [x] Task 1: Description
- [x] Task 2: Description
- [x] Task 3: Description

### Acceptance Criteria
- [x] Criterion 1 (evidence: ...)
- [x] Criterion 2 (evidence: ...)

### Tests
- [x] All tests passing
- [x] Coverage: X tests for this phase

### Edge Cases (from plan)
- [x] Edge case 1: Handled in Task 2
- [x] Edge case 2: Handled in Task 3

### Commits
- abc1234: feat(cache): implement get()
- def5678: feat(cache): implement set()
- ghi9012: feat(cache): implement invalidate()

### Manual Verification (if specified in plan)
- [x] Step 1: Result
- [x] Step 2: Result
```

## Updating the Plan

### When Implementation Reveals Issues

If you discover something during implementation that affects the plan:

1. **Stop** current work
2. **Document** the discovery
3. **Escalate** to user
4. **Update plan** if directed (Evolution Log section)

### Evolution Log

Plans have an Evolution Log for tracking changes:

```markdown
## Evolution Log

### 2024-01-15 - Initial Plan
Created from discussion document

### 2024-01-16 - Phase 2 Revised
During implementation, discovered Redis client doesn't support batch ops.
Revised Phase 3 to use individual calls per user guidance.
```

### Don't Update Silently

Plan updates should be explicit and documented, not silent drift.

## Multiple Plans

If implementing across multiple plans:

1. Complete one plan fully before starting another
2. Or work on independent phases across plans (only if truly independent)
3. Track which plan each commit belongs to

## Progress Tracking

### Announce Clearly

```
📍 Starting Phase 2: Core Cache Functionality (3 tasks)
📝 Task 1/3: Implement CacheManager.get()
🔴 Test 1/4: "it gets cached value when hit"
🟢 Test passing (1/4 complete)
...
✅ Task 1/3 complete
📝 Task 2/3: Implement CacheManager.set()
...
```

### On Context Refresh

If context refreshes mid-implementation:

1. Check git log for recent commits
2. Check plan for current phase/task
3. Resume from last committed task
4. Announce where you're resuming

```
🔄 Resuming implementation

Last commit: feat(cache): implement get() - Task 1 complete
Current: Phase 2, Task 2: Implement CacheManager.set()

Continuing from test: "it stores value with configured ttl"
```
