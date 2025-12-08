# TDD Workflow

*Reference for **[technical-implementation](../SKILL.md)***

---

## The Cycle

RED → GREEN → REFACTOR → COMMIT

Repeat for each task.

## RED: Write Failing Test

1. Read task's micro acceptance criteria
2. Write test asserting that behavior
3. Run test - must fail
4. Verify it fails for the right reason

**Derive tests from plan**: Task's micro acceptance becomes your first test. Edge cases become additional tests.

**Write test names first**: List all test names before writing bodies. Confirm coverage matches acceptance criteria.

## GREEN: Minimal Implementation

Write the simplest code that passes:
- No extra features
- No "while I'm here" improvements
- No edge cases not yet tested

If you think "I should also handle X" - stop. Write a test for X first.

**One test at a time**: Write → Pass → Commit → Next

## REFACTOR: Only When Green

**Do**: Remove duplication, improve naming, extract methods
**Don't**: Touch code outside current task, optimize prematurely

Run tests after. If they fail, undo.

## COMMIT: After Every Green

Commit with descriptive message referencing the task.

## When Tests CAN Change

- Genuine bug in test
- Tests implementation not behavior
- Missing setup/fixtures

## When Tests CANNOT Change

- To make broken code pass (fix the code)
- To avoid difficult work (the test is the requirement)
- To skip temporarily (fix or escalate)

## Red Flags

- Wrote code before test → delete code, write test first
- Multiple failing tests → work on one at a time
- Test passes immediately → investigate
- Changing tests frequently → design unclear, review plan
