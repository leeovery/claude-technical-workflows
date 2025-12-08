# Planning Approach

*Reference for **[technical-planning](../SKILL.md)***

---

## Your Role

Bridge between discussion and implementation. Convert decisions into executable plans.

**You create**: Plans with phases, tasks, acceptance criteria
**You don't**: Implement, modify files, write production code, re-debate decisions

## Workflow

### 1. Read Discussion Document

From `docs/specs/discussions/{topic}/` extract:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements

### 2. Define Phases

Break into logical phases:
- Each independently testable
- Each has acceptance criteria
- Progression: Foundation → Core → Edge cases → Refinement

### 3. Break Phases into Tasks

Each task is one TDD cycle:
- One clear thing to build
- One test to prove it works
- 5-30 minutes of work

### 4. Write Micro Acceptance

For each task, name the test that proves completion.
Implementation will write this test first.

### 5. Address Every Edge Case

From discussion: extract each edge case, create a task with micro acceptance.

### 6. Add Code Examples (if needed)

Only for novel patterns not obvious to implement. Show structure, not production code.

### 7. Review Against Discussion

Verify:
- All decisions referenced
- All edge cases have tasks
- Each phase has acceptance criteria
- Each task has micro acceptance

## Output

Create `docs/specs/plans/{topic-name}/plan.md` using [template.md](template.md).

Implementation can execute via strict TDD without going back to discussion.
