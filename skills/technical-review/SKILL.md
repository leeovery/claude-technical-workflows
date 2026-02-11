---
name: technical-review
description: "Validate completed implementation against plan tasks and acceptance criteria. Use when: (1) Implementation is complete, (2) User wants validation before merging/shipping, (3) Quality gate check needed after implementation. Reviews ALL plan tasks for implementation correctness, test adequacy, and code quality. Produces structured feedback (approve, request changes, or comments) - does NOT fix code."
user-invocable: false
---

# Technical Review

Act as a **senior software architect** with deep experience in code review. You haven't seen this code before. Your job is to verify that **every plan task** was implemented correctly, tested adequately, and meets professional quality standards.

This is **product review**, **feature review**, **test review**, AND **code review**. Not just "does the code work?" but "was every task done correctly, tested properly, and built to professional standards?"

## Review Artifacts

This skill reviews against available artifacts. Required:
- **Plan(s)** (the tasks and acceptance criteria)

Optional but helpful:
- **Specification(s)** (context for design decisions)

## Review Scopes

This skill supports three review scopes:

- **Single plan** — Review one plan's implementation (QA verification + product assessment)
- **Multi-plan** — Review selected plans together (optional QA + cross-cutting product assessment)
- **All plans** — Review all implemented plans (optional QA + full product assessment)

The entry-point skill determines the scope and provides the plan(s).

## Purpose in the Workflow

This skill can be used:
- **Sequentially**: After implementation of a planned feature
- **Standalone** (Contract entry): To review any implementation against a plan

Either way: Verify plan tasks were implemented, tested adequately, and meet quality standards — then assess the product holistically.

### What This Skill Needs

- **Review scope** (required) - single, multi, or all
- **Plan content** (required) - Tasks and acceptance criteria to verify against (one or more plans)
- **Specification content** (optional) - Context for design decisions

**Before proceeding**, verify the required input is available. If anything is missing, **STOP** — do not proceed until resolved.

- **No plan provided?**
  > "I need the implementation plan to review against. Could you point me to the plan file (e.g., `docs/workflow/planning/{topic}.md`)?"

- **Plan references a specification that can't be found?**
  > "The plan references a specification but I can't locate it at the expected path. Could you confirm where the specification is? I can proceed without it, but having it provides better context for the review."

The specification is optional — the review can proceed with just the plan.

---

## Resuming After Context Refresh

Context refresh (compaction) summarizes the conversation, losing procedural detail. When you detect a context refresh has occurred — the conversation feels abruptly shorter, you lack memory of recent steps, or a summary precedes this message — follow this recovery protocol:

1. **Re-read this skill file completely.** Do not rely on your summary of it. The full process, steps, and rules must be reloaded.
2. **Read all tracking and state files** for the current topic — plan index files, review tracking files, implementation tracking files, or any working documents this skill creates. These are your source of truth for progress.
3. **Check git state.** Run `git status` and `git log --oneline -10` to see recent commits. Commit messages follow a conventional pattern that reveals what was completed.
4. **Announce your position** to the user before continuing: what step you believe you're at, what's been completed, and what comes next. Wait for confirmation.

Do not guess at progress or continue from memory. The files on disk and git history are authoritative — your recollection is not.

---

## Review Approach

The review has two stages:

**Stage 1: QA Verification** — Per-task correctness check
**Stage 2: Product Assessment** — Holistic product evaluation

Both stages contribute to the final review document.

### Stage 1: QA Verification

Start from the **plan** - it contains the granular tasks and acceptance criteria.

Use the **specification** for context if available. If no specification exists, the plan is the source of truth for design decisions.

**For single-plan scope:** Verify **all** tasks, not a sample.

```
Plan (tasks + acceptance criteria)
    ↓
    For EACH task:
        → Load Spec Context (deeper understanding)
        → Verify Implementation (code exists, correct)
        → Verify Tests (adequate, not over/under tested)
        → Check Code Quality (readable, conventions)
```

**Use parallel `review-task-verifier` subagents** to verify ALL plan tasks simultaneously. Each verifier checks one task for implementation, tests, and quality. This enables comprehensive review without sequential bottlenecks.

**For multi-plan / all scope:** Per-task QA is optional since individual plans were presumably already reviewed during implementation. Offer the choice:

```
These plans were already reviewed during implementation.
Run per-task QA verification anyway? (y/n)
```

If yes, run task verifiers across all selected plans. If no (default), skip to Stage 2.

#### What You Verify (Per Task)

##### Implementation

- Is the task implemented?
- Does it match the acceptance criteria?
- Does it align with spec context?
- Any drift from what was planned?

##### Tests

Evaluate test coverage critically - both directions:

- **Not under-tested**: Does a test exist? Does it verify acceptance criteria? Are edge cases covered?
- **Not over-tested**: Are tests focused and necessary? No redundant or bloated checks?
- Would the test fail if the feature broke?

##### Code Quality

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

### Stage 2: Product Assessment

After QA verification (or in place of it for multi/all scope), spawn a single `review-product-assessor` agent with the full scope context.

**Provide to the assessor:**
- All implementation files in scope
- All relevant specifications
- All relevant plans
- Project skills (`.claude/skills/`)
- Review scope indicator (single-plan / multi-plan / full-product)

The assessor evaluates the implementation holistically — robustness, gaps, strengthening opportunities, and what's next. For multi-plan/full-product scope, it additionally assesses cross-plan consistency and integration seams.

Product Assessment findings are always **advisory** — they don't affect the QA Verdict.

## Review Process

1. **Read plan(s) and specification(s)** for selected scope
2. **Determine review mode** (single vs multi/all)
3. **Stage 1: QA Verification**
   - Single: Spawn review-task-verifiers in parallel for all tasks
   - Multi/All: Skip or offer optional per-task QA
4. **Stage 2: Product Assessment**
   - Spawn review-product-assessor with full scope context
5. **Aggregate findings** into review document
6. **Present review** with QA Verdict + Product Assessment

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
