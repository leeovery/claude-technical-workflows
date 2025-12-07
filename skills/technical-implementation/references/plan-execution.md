# Plan Execution

*Reference for **[technical-implementation](../SKILL.md)***

---

## Plan Structure

```
docs/specs/plans/{topic}/plan.md
├── Overview (goal, done when)
├── Architecture (from discussion)
└── Phases
    ├── Phase 1
    │   ├── Goal
    │   ├── Acceptance (checkboxes)
    │   └── Tasks
    │       ├── Task 1: Do X | Test: "it does X"
    │       └── Task 2: Do Y | Test: "it does Y"
    └── Phase 2...
```

**Phase** = milestone with acceptance criteria
**Task** = one TDD cycle = one commit

## Before Starting

1. Read entire plan
2. Read linked discussion doc
3. Check dependencies - what must exist first?
4. Check for blockers

## Phase Announcements

**Start**:
```
📍 Starting Phase 2: Core Cache Functionality

Goal: Implement CacheManager with get/set/invalidate

Acceptance:
- [ ] CacheManager exists with get(), set(), invalidate()
- [ ] All tests passing
- [ ] Cache hit < 50ms
```

**Complete**:
```
✅ Phase 2 Complete

- [x] CacheManager exists with get(), set(), invalidate()
- [x] All tests passing (12 tests)
- [x] Cache hit: 23ms

Proceed to Phase 3?
```

**Wait for user confirmation before proceeding to next phase.**

## Referencing Discussion

The discussion doc contains the WHY behind decisions.

**When to check**:
- Task rationale unclear
- Multiple valid approaches
- Edge case handling not specified

**How to reference**:
```
Checking discussion for TTL rationale...
Discussion: "5 min TTL - users refresh every 10-15 min"
Using TTL = 300s
```

**Don't re-debate**: Discussion captured the decision. Follow it.

## Handling Problems

**Plan doesn't cover something**:
```
⚠️ Plan doesn't specify Redis timeout handling.
Options: A) Throw B) Return null C) Retry once
Which approach?
```

**Plan seems wrong**:
```
⚠️ Plan says cache in Redis.
Discussion says database for ACID.
Continue with plan or follow discussion?
```

**Discovery during implementation**:
```
⚠️ Redis client doesn't support batch ops.
Phase 3 assumes batch get/set.
Options: A) Individual calls B) Different library C) Revise Phase 3
```

**Never silently deviate.**

## Phase Completion Checklist

```markdown
## Phase 2 Complete

Tasks:
- [x] Task 1: CacheManager.get()
- [x] Task 2: CacheManager.set()
- [x] Task 3: CacheManager.invalidate()

Acceptance:
- [x] CacheManager exists (CacheManager.php)
- [x] Tests passing (12 tests)
- [x] Cache hit: 23ms

Commits:
- abc1234: feat(cache): implement get()
- def5678: feat(cache): implement set()
- ghi9012: feat(cache): implement invalidate()
```

## Context Refresh Recovery

If context refreshes mid-implementation:

1. Check `git log` for recent commits
2. Find current phase/task in plan
3. Resume from last committed task

```
🔄 Resuming

Last commit: feat(cache): implement get() - Task 1 complete
Current: Phase 2, Task 2: CacheManager.set()

Continuing with test: "it stores value with ttl"
```
