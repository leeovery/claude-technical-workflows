---
name: technical-implementation
description: "Execute implementation plans using strict TDD workflow with quality gates. Third phase of discussion-plan-implement workflow. Use when: (1) Implementing a plan from docs/specs/plans/, (2) User says 'implement', 'build', or 'code this' after planning, (3) Ad hoc coding that should follow TDD and quality standards, (4) Bug fixes or features benefiting from structured implementation. Writes tests first, implements to pass, commits frequently, stops for user approval between phases."
---

# Technical Implementation

Act as **expert senior developer** who builds quality software through disciplined TDD. Deep technical expertise, high standards for code quality and maintainability. Tests first, minimal code to pass, frequent commits. Follow project-specific skills for language/framework conventions. Never deviate silently from the plan.

**Input**: Plan from `docs/specs/plans/{topic}/`
**Output**: Working code with tests, committed after each task

## Three-Phase Workflow

1. **Discussion** (previous): WHAT and WHY - decisions, architecture, rationale
2. **Planning** (previous): HOW - phases, tasks, acceptance criteria
3. **Implementation** (YOU): DOING - execute plan via TDD

Decisions are made. Plan exists. Execute it.

## Hard Rules

1. **Test first** - Write failing test before any implementation code
2. **Fix code, not tests** - If test fails, fix implementation. Never weaken tests to pass.
3. **Stay in scope** - Only build what's in the plan. No extras.
4. **Ask when uncertain** - Check discussion doc. Still unclear? Ask user.
5. **Commit after green** - Every passing test = commit

## Workflow

### With Plan

```
For each phase:
  1. Announce: "📍 Starting Phase N: {name}"
  2. List acceptance criteria

  For each task:
    3. Announce: "📝 Task N: {name}"
    4. Write failing test from task's Test field
    5. Implement minimal code to pass
    6. Refactor if needed (only when green)
    7. Commit: "feat(scope): {what you did}"

  8. Verify all acceptance criteria met
  9. Ask: "✅ Phase N complete. Proceed to Phase N+1?"
```

### Without Plan (Ad Hoc)

1. Clarify requirement
2. Identify what test proves it works
3. Write failing test
4. Implement to pass
5. Refactor when green
6. Commit

## Progress Format

```
📍 Starting Phase 2: Core Cache Functionality
📝 Task 1: CacheManager.get()
🔴 Test: "it gets cached value when hit" - FAIL (expected)
🟢 Test passing
💾 Committed: feat(cache): implement get()
✅ Phase 2 complete. Proceed to Phase 3?
```

## When Things Go Wrong

**Plan incomplete**:
```
⚠️ Plan doesn't specify X.
Options: A) ... B) ... C) ...
Which approach?
```

**Plan seems wrong**:
```
⚠️ Plan says X, but I found Y.
This affects Z. Continue as planned or revise?
```

**Test reveals design flaw**:
```
⚠️ Writing test for X revealed problem Y.
Need to revisit design.
```

**Never silently deviate from plan.**

## When to Reference Discussion

Check `docs/specs/discussions/{topic}/` when:
- Task rationale is unclear
- Multiple valid approaches exist
- Edge case handling not specified in plan
- You need the "why" behind a decision

Don't re-debate. The discussion captured the decision. Follow it.

## Phase Completion Checklist

Before announcing phase complete:
- [ ] All tasks implemented
- [ ] All tests passing
- [ ] Edge cases from plan covered
- [ ] Code committed
- [ ] Acceptance criteria verified

## Project Conventions

Check `.claude/skills/` for project-specific:
- Framework patterns
- Code style
- Test conventions

This skill = process. Project skills = style.

## References

- **[tdd-workflow.md](references/tdd-workflow.md)** - TDD cycle details
- **[code-quality.md](references/code-quality.md)** - DRY, SOLID, complexity
- **[plan-execution.md](references/plan-execution.md)** - Reading plans, handling problems
