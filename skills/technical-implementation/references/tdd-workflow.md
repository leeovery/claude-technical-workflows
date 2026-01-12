# TDD Workflow

*Reference for **[technical-implementation](../SKILL.md)***

---

## The Cycle

RED → GREEN → REFACTOR → COMMIT

Repeat for each task. **Never skip steps. Never reorder.**

## TDD Violation Recovery

**If you catch yourself violating TDD, stop immediately and recover:**

| Violation | Recovery |
|-----------|----------|
| Wrote code before test | DELETE the code. Write the failing test. Then rewrite the code. |
| Multiple failing tests | Comment out all but one. Fix that one. Uncomment next. |
| Test passes immediately | Suspicious. Verify the test actually exercises your code. Check for false positives. |
| Changed test to make code pass | REVERT the test change. Fix the implementation instead. |
| "While I'm here" improvement | STOP. Is it in the plan? No? Don't do it. |

**These are not suggestions. Skipping recovery corrupts the entire TDD discipline.**

## RED: Write Failing Test

1. Read task's micro acceptance criteria
2. Write test asserting that behavior
3. Run test - **MUST fail**
4. Verify it fails for the **right reason** (not syntax error, not missing import)

**Derive tests from plan**: Task's micro acceptance becomes your first test. Edge cases become additional tests.

**Write test names first**: List all test names before writing bodies. Confirm coverage matches acceptance criteria.

**No implementation code exists yet.** If you're tempted to "just sketch out the class first" - don't. The test comes first. Always.

## GREEN: Minimal Implementation

Write the simplest code that passes:
- No extra features
- No "while I'm here" improvements
- No edge cases not yet tested

If you think "I should also handle X" - STOP. Write a test for X first.

**One test at a time**: Write test → Run (fails) → Implement → Run (passes) → Commit → Next

## REFACTOR: Only When Green

**Do**: Remove duplication, improve naming, extract methods
**Don't**: Touch code outside current task, optimize prematurely

Run tests after. If they fail, undo the refactor.

## COMMIT: After Every Green

Commit with descriptive message referencing the task. This is non-negotiable - it creates recovery points.

## When Tests CAN Change

- Genuine bug in test logic
- Test asserts implementation details, not behavior
- Missing setup/fixtures

## When Tests CANNOT Change

- To make broken code pass → **fix the code**
- To avoid difficult implementation → **the test IS the requirement**
- To skip temporarily → **fix it now or escalate**

Changing a test to pass is admitting the implementation is wrong and hiding it. Don't.
