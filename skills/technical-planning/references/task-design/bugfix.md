# Bugfix Task Design

*Context guidance for **[task-design.md](../task-design.md)** — bug fixes*

---

## Root-Cause-First Ordering

In bugfix work, the first task always reproduces the bug with a failing test, then fixes it. Foundation = the reproduction test and the minimal fix.

**Example** ordering within a phase:

```
Task 1: Failing test for the N+1 query + add eager loading (reproduce + fix)
Task 2: Verify performance with large dataset (validation)
Task 3: Regression tests for related query paths (prevention)
```

The first task proves the bug exists and fixes it. Subsequent tasks harden the fix.

---

## Bugfix Vertical Slicing

Each task changes the minimum code needed. A bugfix task is well-scoped when you can describe both the before (broken) and after (fixed) states in one sentence.

**Example** (Single root cause):

```
Task 1: Add failing test demonstrating the race condition + add lock (fix)
Task 2: Handle lock timeout and retry (error handling)
Task 3: Concurrent access regression tests (prevention)
```

**Example** (Multiple related issues):

```
Task 1: Fix primary null pointer with guard clause + test (core fix)
Task 2: Fix secondary data truncation at boundary + test (related fix)
Task 3: Add integration test covering the full workflow (regression)
```

---

## Minimal Change Focus

Each task changes the minimum code needed:

- Don't refactor adjacent code, even if the fix reveals it could be cleaner
- Don't add features while fixing bugs — if the fix area suggests improvements, note them for a separate specification
- Keep the diff small and reviewable — a reviewer should immediately see what changed and why
- If a task starts growing beyond the fix, it's probably two tasks
