# Review Template

*Reference for **[technical-review](../SKILL.md)***

---

## Template

```markdown
# Implementation Review: {Topic / Product}

**Scope**: Single Plan ({plan}) | Multi-Plan ({plans}) | Full Product
**QA Verdict**: Approve | Request Changes | Comments Only

## Summary
[One paragraph overall assessment]

## QA Verification

### Specification Compliance
[Implementation aligns with specification / Note any deviations]

### Plan Completion
- [ ] Phase N acceptance criteria met
- [ ] All tasks completed
- [ ] No scope creep

### Code Quality
[Issues or "No issues found"]

### Test Quality
[Issues or "Tests adequately verify requirements"]

### Required Changes (if any)
1. [Specific actionable change]

## Product Assessment

### Robustness
[Where would this break under real-world usage?]

### Gaps
[What's obviously missing now the product exists?]

### Cross-Plan Consistency (multi/all only)
[Are patterns consistent across features?]

### Integration Seams (multi/all only)
[Do independently-built features connect cleanly?]

### Strengthening Opportunities
[Priority improvements for production readiness]

### What's Next
[What does this enable? What should be built next?]

## Recommendations
[Combined non-blocking suggestions]
```

## Verdict Guidelines

**Approve**: All acceptance criteria met, decisions followed, no blocking issues

**Request Changes**: Missing requirements, deviations from decisions, broken functionality, inadequate tests

**Comments Only**: Minor suggestions, style preferences, non-blocking observations

