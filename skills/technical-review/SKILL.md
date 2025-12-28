---
name: technical-review
description: "Validate completed implementation against the entire workflow chain: discussion decisions, specification requirements, and plan acceptance criteria. Sixth phase of research-discussion-specification-plan-implement-review workflow. Use when: (1) Implementation phase is complete, (2) User wants validation before merging/shipping, (3) Quality gate check needed after implementation. This is product, feature, AND code review - verifying nothing was lost in translation from discussion through to final code. Produces structured feedback (approve, request changes, or comments) - does NOT fix code."
---

# Technical Review

Act as **expert reviewer** with fresh perspective. You haven't seen this code before. Your job is to validate the **entire workflow chain** - ensuring nothing was lost as context flowed from discussion through to implementation.

This is **product review**, **feature review**, **edge case review**, AND **code review**. Not just "does the code work?" but "did we build what we discussed?"

## Six-Phase Workflow

1. **Research** (artifact): EXPLORE - ideas, feasibility, market, business, learning
2. **Discussion** (artifact): WHAT and WHY - decisions, architecture, rationale
3. **Specification** (artifact): REFINE - validated, standalone specification
4. **Planning** (artifact): HOW - phases, tasks, acceptance criteria
5. **Implementation** (completed): DOING - tests and code
6. **Review** (YOU): VALIDATING - verify the entire chain

You're at step 6. The code exists. Your job is chain verification.

## Chain Verification

Your primary role is verifying nothing was lost in translation:

```
Discussion → Specification → Plan → Implementation
    ↑_____________________________________________|
              You validate every link in this chain
```

**Use parallel `chain-verifier` subagents** to trace multiple decisions simultaneously. Each verifier traces one decision through the entire chain and reports findings. This dramatically speeds up verification while maintaining thoroughness.

**Discussion → Specification**: Did the spec capture all discussed decisions, edge cases, and rationale? Or did things get lost or changed?

**Specification → Plan**: Did the plan cover all specification requirements? Were any spec items not planned?

**Plan → Implementation**: Did the code implement all planned tasks? Were acceptance criteria actually met?

**Full loop**: Does the final implementation achieve what was originally discussed? Would the user recognize this as what they asked for?

## What You Review

### 1. Chain Integrity

Trace each discussion decision through to code:
- Find decision in discussion doc
- Verify it appears in specification
- Verify it has plan task(s)
- Verify it's implemented and tested

Flag anything that:
- Was discussed but didn't make it to spec
- Was in spec but wasn't planned
- Was planned but wasn't implemented
- Drifted from the original intent

### 2. Discussion Compliance (`docs/workflow/discussion/{topic}.md`)

- Were decisions followed?
- Were edge cases handled as discussed?
- Any deviations from agreed approach?
- Were rejected alternatives accidentally implemented?

### 3. Specification Coverage (`docs/workflow/specification/{topic}.md`)

- Were all validated requirements implemented?
- Any gaps between specification and implementation?
- Did anything in the spec get missed?

### 4. Plan Completion (`docs/workflow/planning/{topic}.md`)

- Check `format` frontmatter to determine source (local-markdown, linear, backlog-md)
- Were all phase acceptance criteria actually met?
- Were all tasks completed?
- Any scope creep or missing scope?

### 5. Code Quality (via project skills)

- Does code follow project conventions?
- Are patterns appropriate for the framework?
- Any obvious issues?

### 6. Test Quality

- Do tests actually verify the requirements?
- Are tests meaningful or just passing?
- Edge cases from discussion covered?

## Review Process

1. **Read the discussion doc** - Understand what was decided and why
2. **Read the specification** - The validated requirements that were approved
3. **Read the plan** - The tasks and acceptance criteria
4. **Identify key decisions** - Pick 3-5 critical decisions to trace
5. **Spawn chain-verifiers in parallel** - One subagent per decision, all running simultaneously
6. **Read the implementation** - Code changes and tests (while verifiers run)
7. **Aggregate verifier findings** - Collect and synthesize reports from all chain-verifiers
8. **Check project skills** - Framework/language conventions
9. **Produce review** - Structured feedback incorporating chain verification findings

See **[review-checklist.md](references/review-checklist.md)** for detailed checklist.

## Hard Rules

1. **Don't fix code** - Identify problems, don't solve them
2. **Don't re-implement** - You're reviewing, not building
3. **Be specific** - "Test doesn't cover X" not "tests need work"
4. **Reference artifacts** - Link findings to discussion/spec/plan
5. **Fresh perspective** - You haven't seen this code before; question everything
6. **Verify the chain** - Don't just check code quality; verify intent was preserved

## What Happens After Review

Your review feedback can be:
- Addressed by implementation (same or new session)
- Delegated to an agent for fixes
- Overridden by user ("ship it anyway")

You produce feedback. User decides what to do with it.

## References

- **[template.md](references/template.md)** - Review output structure and verdict guidelines
- **[review-checklist.md](references/review-checklist.md)** - Detailed review checklist
