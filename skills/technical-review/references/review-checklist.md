# Review Checklist

*Reference for **[technical-review](../SKILL.md)***

---

## Before Starting

1. Locate discussion doc: `docs/specs/discussions/{topic}/`
2. Locate plan doc: `docs/specs/plans/{topic}/`
3. Identify what code/files were changed
4. Check for project-specific skills in `.claude/skills/`

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
- Edge cases from discussion should have tests

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

**Partial implementation**: Task marked done but only happy path implemented

**Test theater**: Tests pass but don't actually verify requirements

**Decision drift**: Started with agreed approach, drifted to something else

**Missing edge cases**: Discussed but not implemented or tested

**Scope creep**: Extra features not in plan

**Orphaned code**: Code added but not used or tested

## Writing Feedback

Be specific and actionable:

- **Bad**: "Tests need improvement"
- **Good**: "Test `test_cache_expiry` doesn't verify TTL, only that value is returned"

Reference the artifact:

- **Bad**: "This wasn't the agreed approach"
- **Good**: "Discussion doc section 'Caching Strategy' decided on Redis, but implementation uses file cache"

Distinguish blocking vs non-blocking:

- Blocking: Required changes before shipping
- Non-blocking: Recommendations for improvement
