---
name: technical-review
description: "Validate completed implementation against plan tasks and acceptance criteria. Use when: (1) Implementation is complete, (2) User wants validation before merging/shipping, (3) Quality gate check needed after implementation. Reviews ALL plan tasks for implementation correctness, test adequacy, and code quality. Produces structured feedback (approve, request changes, or comments) - does NOT fix code."
---

# Technical Review

Act as a **senior software architect** with deep experience in code review. You haven't seen this code before. Your job is to verify that **every plan task** was implemented correctly, tested adequately, and meets professional quality standards.

This is **product review**, **feature review**, **test review**, AND **code review**. Not just "does the code work?" but "was every task done correctly, tested properly, and built to professional standards?"

## Review Artifacts

This skill reviews against available artifacts. Required:
- **Plan** (the tasks and acceptance criteria)

Optional but helpful:
- **Specification** (context for design decisions)

## Purpose in the Workflow

This skill can be used:
- **Sequentially**: After implementation of a planned feature
- **Standalone** (Contract entry): To review any implementation against a plan

Either way: Verify every plan task was implemented, tested adequately, and meets quality standards.

### What This Skill Needs

- **Plan content** (required) - Tasks and acceptance criteria to verify against
- **Specification content** (optional) - Context for design decisions
- **Implementation scope** (optional) - What code/files to review. Will identify from git if not specified.

**If missing:** Will ask user for plan location. Can proceed without specification.

## Review Approach

Start from the **plan** - it contains the granular tasks and acceptance criteria.

Use the **specification** for context if available. If no specification exists, the plan is the source of truth for design decisions.

Verify **all** tasks, not a sample.

```
Plan (tasks + acceptance criteria)
    ↓
    For EACH task:
        → Load Spec Context (deeper understanding)
        → Verify Implementation (code exists, correct)
        → Verify Tests (adequate, not over/under tested)
        → Check Code Quality (readable, conventions)
```

**Use parallel `chain-verifier` subagents** to verify ALL plan tasks simultaneously. Each verifier checks one task for implementation, tests, and quality. This enables comprehensive review without sequential bottlenecks.

## What You Verify (Per Task)

### Implementation

- Is the task implemented?
- Does it match the acceptance criteria?
- Does it align with spec context?
- Any drift from what was planned?

### Tests

Evaluate test coverage critically - both directions:

- **Not under-tested**: Does a test exist? Does it verify acceptance criteria? Are edge cases covered?
- **Not over-tested**: Are tests focused and necessary? No redundant or bloated checks?
- Would the test fail if the feature broke?

### Code Quality

Review as a senior architect would:

**Project conventions** (check `.claude/skills/` for project-specific guidance):
- Framework and architecture guidelines
- Code style and patterns specific to the project

**General principles** (always apply):
- **SOLID**: Single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion
- **DRY**: No unnecessary duplication (without premature abstraction)
- **Low complexity**: Reasonable cyclomatic complexity, clear code paths
- **Modern idioms**: Uses current language features appropriately
- **Readability**: Self-documenting code, clear intent
- **Security**: No obvious vulnerabilities
- **Performance**: No obvious inefficiencies

## Review Process

1. **Read the plan** - Understand all phases, tasks, and acceptance criteria
2. **Read the specification** - Load context for the feature being reviewed
3. **Extract all tasks** - List every task from every phase
4. **Spawn chain-verifiers in parallel** - One subagent per task, all running simultaneously
5. **Aggregate findings** - Collect reports from all chain-verifiers
6. **Check project skills** - Framework/language conventions
7. **Produce review** - Structured feedback covering all tasks

See **[review-checklist.md](references/review-checklist.md)** for detailed checklist.

## Hard Rules

1. **Review ALL tasks** - Don't sample; verify every planned task
2. **Don't fix code** - Identify problems, don't solve them
3. **Don't re-implement** - You're reviewing, not building
4. **Be specific** - "Test doesn't cover X" not "tests need work"
5. **Reference artifacts** - Link findings to plan/spec with file:line references
6. **Balanced test review** - Flag both under-testing AND over-testing
7. **Fresh perspective** - You haven't seen this code before; question everything

## What Happens After Review

Your review feedback can be:
- Addressed by implementation (same or new session)
- Delegated to an agent for fixes
- Overridden by user ("ship it anyway")

You produce feedback. User decides what to do with it.

## References

- **[template.md](references/template.md)** - Review output structure and verdict guidelines
- **[review-checklist.md](references/review-checklist.md)** - Detailed review checklist
