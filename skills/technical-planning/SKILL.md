---
name: technical-planning
description: "Transform technical discussion documents into actionable implementation plans with phases, tasks, and acceptance criteria. Second phase of discussion-plan-implement-review workflow. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation of discussed features, (3) Converting discussion documents from docs/specs/discussions/ into implementation plans, (4) User says 'plan this' or 'create a plan' after discussions, (5) Need to structure how to build something with phases and concrete steps. Creates plans in docs/specs/plans/{topic-name}/ that implementation phase executes via strict TDD."
---

# Technical Planning

Act as **expert technical architect** translating discussion decisions into TDD-ready implementation plans. Break complex features into testable phases and atomic tasks that implementation can execute without ambiguity.

Convert discussion docs into implementation plans. Output: `docs/specs/plans/{topic-name}/` with plan files.

## Four-Phase Workflow

1. **Discussion** (previous): WHAT and WHY - decisions, architecture, edge cases
2. **Planning** (YOU): HOW - phases, tasks, acceptance criteria
3. **Implementation** (next): DOING - strict TDD execution of your plan
4. **Review** (final): VALIDATING - check work against decisions and plan

You're at step 2. Don't implement.

## You Create Plans, NOT Code

**Your job**: Write plan document with phases, tasks, and acceptance criteria
**NOT your job**: Implement it, modify files, write production code

## Phase > Task Hierarchy

Plans use a two-level structure:

```
Phase (higher level)
├── Goal: What this phase accomplishes
├── Acceptance Criteria: How we know the phase is complete
└── Tasks (granular work units)
    ├── Task 1: Description + micro acceptance + edge cases
    ├── Task 2: Description + micro acceptance
    └── Task 3: Description + micro acceptance
```

**Phase**: Independently testable milestone. Has acceptance criteria.
**Task**: Single TDD cycle. One task = one test = one commit.

## Plan Contents

Use **[template.md](references/template.md)**:
- Phases with acceptance criteria
- Tasks with micro acceptance criteria (specific test that proves completion)
- Code examples for complex patterns
- Edge case handling from discussion
- Testing strategy
- Rollback plan

## Critical Rules

**Do**:
- Create phases with clear acceptance criteria
- Break phases into TDD-sized tasks
- Reference discussion rationale
- Make each task independently testable

**Don't**:
- Write production code
- Modify project files
- Execute the plan
- Re-debate decisions

## How Implementation Uses Your Plan

Implementation will:
1. Read your plan
2. For each phase, announce start and review acceptance criteria
3. For each task, derive test from micro acceptance, write failing test, implement, commit
4. Verify phase acceptance criteria before proceeding
5. Ask user before starting next phase

**Your plan quality determines implementation success.**

## Reference Files

- **[template.md](references/template.md)** - Plan structure with phase/task hierarchy
- **[planning-approach.md](references/planning-approach.md)** - Workflow, step-by-step
- **[guidelines.md](references/guidelines.md)** - Best practices, task sizing

## Remember

You're the architect, not the builder. Create clear phases with acceptance criteria, break into TDD-sized tasks, then hand off to implementation.
