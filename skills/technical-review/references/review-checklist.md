# Review Checklist

*Reference for **[technical-review](../SKILL.md)***

---

## Before Starting

1. Read discussion: `docs/workflow/discussion/{topic}.md`
2. Read specification: `docs/workflow/specification/{topic}.md`
3. Read plan: `docs/workflow/planning/{topic}.md`
4. Identify what code/files were changed
5. Check for project-specific skills in `.claude/skills/`

## Chain Verification

This is the primary review task - verifying nothing was lost in translation.

### Discussion → Specification

For each key decision in the discussion:
- Does it appear in the specification?
- Was it accurately captured or did meaning change?
- Were any decisions dropped without justification?

For each edge case discussed:
- Is it documented in the specification?
- Was any nuance lost?

### Specification → Plan

For each requirement in the specification:
- Is there a corresponding plan task?
- Does the task fully address the requirement?
- Were any spec items not planned?

### Plan → Implementation

For each planned task:
- Was it implemented?
- Does the implementation match the task description?
- Were acceptance criteria actually met?

### Full Chain Trace (Parallel Verification)

Pick 3-5 key requirements from the **specification**, then spawn `chain-verifier` subagents **in parallel** to trace each one simultaneously:

```
Requirement 1 ──▶ [chain-verifier] ──▶ Findings
Requirement 2 ──▶ [chain-verifier] ──▶ Findings  (all running in parallel)
Requirement 3 ──▶ [chain-verifier] ──▶ Findings
```

**Why start from specification?**

The specification is the **validated source of truth**. It has already filtered, enriched, and validated content from research and discussion phases. Earlier phases may contain rejected ideas or rough thoughts that were intentionally filtered out. Starting from spec avoids false positives.

**How to invoke:**

For each requirement, spawn a chain-verifier with:
- The specific requirement to trace (from specification)
- Paths to specification and plan documents
- The implementation scope (files/directories changed)

Each chain-verifier traces one requirement through:
1. Specification → 2. Plan → 3. Implementation → 4. Tests

**Aggregate the findings:**

Once all chain-verifiers complete, synthesize their reports:
- Collect all "Broken" chains as blocking issues
- Collect all "Drifted" items for review
- Include specific file:line references in your review output

Flag any breaks in the chain.

## Discussion Compliance

For each decision documented in the discussion:

- Was it followed in implementation?
- If deviated, was there documented justification?
- Were the "why" reasons preserved in the approach?

For each edge case discussed:

- Is it handled in the code?
- Is it tested?
- Does the handling match what was agreed?

For competing solutions that were rejected:

- Did implementation accidentally use a rejected approach?
- Are there traces of discarded ideas?

## Specification Coverage

For each validated requirement:

- Is it implemented?
- Is it tested?
- Does the implementation match the spec exactly?

Look for gaps:

- Requirements in spec but not in code
- Code that doesn't trace back to a spec requirement

## Plan Completion

For each phase:

- Are all acceptance criteria actually met (not just claimed)?
- Verify each criterion independently

For each task:

- Was a test written for the micro acceptance?
- Does the test actually verify the requirement?
- Is there a commit for the task?

Scope check:

- Was anything built that wasn't in the plan? (scope creep)
- Was anything in the plan not built? (missing scope)

## Test Quality

Tests exist vs tests are meaningful:

- Does the test name match what it actually tests?
- Would the test fail if the feature broke?
- Are assertions specific or overly broad?

Coverage of requirements:

- Each plan task should have corresponding test(s)
- Edge cases from specification should have tests

Test isolation:

- Do tests depend on each other?
- Are tests repeatable?

## Code Quality

Check against project-specific skills for:

- Framework patterns and conventions
- Code style requirements
- Architecture guidelines

General checks:

- Obvious bugs or logic errors
- Error handling present where needed
- No hardcoded values that should be configurable

## Common Issues

**Chain breaks**: Requirement in spec but never made it to code

**Partial implementation**: Task marked done but only happy path implemented

**Test theater**: Tests pass but don't actually verify requirements

**Requirement drift**: Started with specified approach, drifted to something else

**Missing edge cases**: In specification but not implemented or tested

**Scope creep**: Extra features not in plan

**Orphaned code**: Code added but not used or tested

**Lost nuance**: Requirement simplified in a way that loses important detail

## Writing Feedback

Be specific and actionable:

- **Bad**: "Tests need improvement"
- **Good**: "Test `test_cache_expiry` doesn't verify TTL, only that value is returned"

Reference the artifact and chain position:

- **Bad**: "This wasn't the agreed approach"
- **Good**: "Spec requirement 3.2 specifies Redis cache → Plan task 2.1 says 'implement Redis cache' → but implementation uses file cache. Chain broke at implementation."

Distinguish blocking vs non-blocking:

- Blocking: Required changes before shipping (chain breaks, missing requirements)
- Non-blocking: Recommendations for improvement (code style, minor optimizations)
