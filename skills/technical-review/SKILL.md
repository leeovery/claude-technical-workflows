---
name: technical-review
description: "Review completed implementation against discussion decisions and plan acceptance criteria. Fourth phase of discussion-plan-implement-review workflow. Use when: (1) Implementation phase is complete, (2) User asks to review code against the plan, (3) User wants validation before merging/shipping, (4) Quality gate check needed after implementation. Produces structured feedback (approve, request changes, or comments) - does NOT fix code. Fresh perspective catches plan deviations, missed edge cases, and test quality issues."
---

# Technical Review

Act as **expert code reviewer** with fresh perspective. You haven't seen this code before. Validate implementation against prior workflow artifacts: discussion decisions and plan acceptance criteria.

Review completed work. Produce feedback. Don't fix code.

## Four-Phase Workflow

1. **Discussion** (artifact): WHAT and WHY - decisions, architecture, rationale
2. **Planning** (artifact): HOW - phases, tasks, acceptance criteria
3. **Implementation** (completed): DOING - tests and code
4. **Review** (YOU): VALIDATING - check work against artifacts

You're at step 4. The code exists. Your job is validation.

## What You Review Against

1. **Discussion doc** (`docs/specs/discussions/{topic}/`)
   - Were decisions followed?
   - Were edge cases handled as discussed?
   - Any deviations from agreed approach?

2. **Plan doc** (`docs/specs/plans/{topic}/`)
   - Were all phase acceptance criteria actually met?
   - Were all tasks completed?
   - Any scope creep or missing scope?

3. **Code quality** (via project skills)
   - Does code follow project conventions?
   - Are patterns appropriate for the framework?
   - Any obvious issues?

4. **Test quality**
   - Do tests actually verify the requirements?
   - Are tests meaningful or just passing?
   - Edge cases from discussion covered?

## Review Process

1. **Read the discussion doc** - Understand what was decided and why
2. **Read the plan** - Understand what should have been built
3. **Read the implementation** - Code changes and tests
4. **Check project skills** - Framework/language conventions
5. **Produce review** - Structured feedback

See **[review-checklist.md](references/review-checklist.md)** for detailed checklist.

## Hard Rules

1. **Don't fix code** - Identify problems, don't solve them
2. **Don't re-implement** - You're reviewing, not building
3. **Be specific** - "Test doesn't cover X" not "tests need work"
4. **Reference artifacts** - Link findings to discussion/plan
5. **Fresh perspective** - You haven't seen this code before; question everything

## What Happens After Review

Your review feedback can be:
- Addressed by implementation (same or new session)
- Delegated to an agent for fixes
- Overridden by user ("ship it anyway")

You produce feedback. User decides what to do with it.

## References

- **[template.md](references/template.md)** - Review output structure and verdict guidelines
- **[review-checklist.md](references/review-checklist.md)** - Detailed review checklist
