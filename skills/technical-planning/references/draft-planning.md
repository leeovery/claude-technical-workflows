# Draft Planning

*Reference for **[technical-planning](../SKILL.md)** - Path A*

---

You are creating a draft plan. The user has directed you here because the source materials need enrichment or filtering before formal planning can begin.

## Purpose

Draft planning produces a **standalone specification** - everything needed to construct formal phases and tasks. It is NOT a summary. It is NOT conversation notes.

**Two purposes**:

1. **Enrichment**: Source materials capture WHAT and WHY but need more detail on HOW, constraints, edge cases. Add this through collaborative discussion.

2. **Filtering**: Source materials contain noise, tangents, speculation, or hallucinated content. Remove this through collaborative review.

Most drafts involve both.

## Output

Create `draft-plan.md` in `docs/specs/plans/{topic-name}/`

## Critical Rules

**Capture immediately**: After each user response, update the draft document BEFORE your next question. Never let more than 2-3 exchanges pass without writing.

**Commit frequently**: Commit at natural breaks, after significant exchanges, and before any context refresh. Context refresh = lost work.

**Never invent reasoning**: If it's not in the document, ask again.

## Draft Document Format

The draft has two sections: **Planning Log** (running capture) and **Specification** (the deliverable).

```markdown
# Draft Plan: [Topic Name]

**Status**: Draft - building specification
**Created**: [date]
**Last Updated**: [timestamp]

---

## Specification

This section is the deliverable. Update it continuously as clarity emerges.

### What We're Building

[Specific, concrete description. What does it do? What problem does it solve?]

### Why We're Building It

[The motivation. What need does this address?]

### Approach (Optional)

[Include when there's a specific approach to follow. Leave light when implementation should figure it out.]

### Scope Boundaries

**In scope**:
- [Specific item]

**Out of scope**:
- [Item and why excluded]

### Technical Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| [decision point] | [what we chose] | [why] |

### Edge Cases to Handle

- [Edge case that implementation must handle]

### Constraints

- [Technical or business constraint]

### Testing and Acceptance

How we'll know this is complete:
- [Acceptance criterion]

Testing ideas:
- [Test scenario]

### Open Questions (Blocking)

- [ ] [Question that MUST be answered before formal planning]

---

## Planning Log

Running capture of discussion. Use this to build the Specification above.

### [timestamp] [Topic]

[What was discussed, decisions made, reasoning.]
```

## The Specification is the Deliverable

The Planning Log is working notes. The Specification section is what matters.

As you discuss:
1. Capture in the Planning Log
2. **Immediately** distill validated information into the Specification
3. The Specification grows more complete with each exchange

## What to Capture

Record **what the user said AND why**, not just conclusions.

Capture:
- Trade-offs considered
- Alternatives rejected and why
- Concerns raised and how addressed
- Scope decisions (in/out and why)

## Transitioning to Formal Planning

Draft is complete when the Specification contains:
- [ ] Clear WHAT and WHY
- [ ] Scope boundaries (in/out)
- [ ] Edge cases to handle
- [ ] Testing ideas and acceptance criteria
- [ ] Approach guidance (if needed)
- [ ] No blocking open questions

**Transition**:
1. Review the Specification with user
2. User confirms it's complete
3. Proceed to formal planning → Load [formal-planning.md](formal-planning.md)
4. Keep `draft-plan.md` for reference

## After Context Refresh

If the draft exists: Read it. Trust it. The Specification has detail you've lost.

If no draft exists: You've lost the conversation. Be honest and ask again.
