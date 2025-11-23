# Discussion Document Template

*Part of **[discussion-documentation](skill.md)** | See also: **[meeting-assistant.md](meeting-assistant.md)** · **[guidelines.md](guidelines.md)***

---

Standard structure for `plan/discussion/` documents. DOCUMENT only - no plans or code.

## Template

```markdown
# Discussion: {Topic}

**Date**: YYYY-MM-DD
**Status**: Exploring | Deciding | Concluded
**Participants**: {Who}

## Context

Problem, why now, pain point, current state.

## Open Questions

- [ ] Question 1?
- [ ] Question 2?

(Check off as answered)

## Options Explored

### Option: {Name}

**Pros**: Advantages
**Cons**: Disadvantages
**Trade-offs**: What we gain vs give up

(Repeat for each option)

## Back-and-Forth Debates

When discussion prolonged/challenging - capture it!

### Debate: {Topic}

**Positions**: What each side argued
**Arguments**: Pro/con for each, counter-points
**Resolution**: What made us choose, small details that mattered
**Learning**: What we learned

## Edge Cases

### Edge Case: {Description}

**Problem**: What's the edge case
**Impact**: Why it matters
**Solution**: How we'll address it
**Status**: Solved | Needs Research | Acceptable Risk

## False Paths

### False Path: {Name}

**Tried**: What we attempted
**Why failed**: Reasons it didn't work
**Learned**: Key insights
**Revisit**: Conditions to reconsider

## Decisions Made

### Decision: {What}

**Date**: YYYY-MM-DD
**What chosen**: Clear statement
**Rationale**: Why, deciding factor, trade-offs accepted
**Alternatives**: What else considered, why rejected
**Implications**: System impact, constraints, what enabled
**Confidence**: High | Medium | Low (why?)

## Key Insights

1. Insight 1
2. Insight 2

## Impact

**Who affected**: Users, teams
**Problem solved**: What this fixes
**Enabled**: New capabilities
**Risk mitigated**: What safer now

## Current State

- What's clear now
- What's still uncertain
- Assumptions we're making
- Needs more exploration

## Next Steps

What happens next (NOT implementation - just discussion/exploration):
- [ ] Research X
- [ ] Validate Y
- [ ] Decide Z

## Evolution Log

Track how discussion evolved:

### YYYY-MM-DD - Initial
Started exploring {topic}

### YYYY-MM-DD - {Milestone}
Made decision on X, ruled out Y
```

## Usage Notes

**When creating**:
1. Create: `plan/discussion/{topic}.md`
2. Fill header: date, status, participants
3. Start with context: why discussing?
4. List questions: what needs deciding?

**During discussion**:
- Update open questions as answered
- Add options as explored
- Document false paths immediately
- Record decisions with full rationale
- Update current state

**Optional sections**: Skip what doesn't apply. Always include Context, Decisions, Impact.

**Anti-patterns**:
- ❌ Don't turn into plan (no implementation steps)
- ❌ Don't write code
- ❌ Don't make it formal spec

**Complete when**:
- Major decisions made with rationale
- Questions answered (or parked)
- Trade-offs understood
- Path forward clear
