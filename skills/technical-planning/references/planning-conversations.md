# Planning Conversations

*Reference for **[technical-planning](../SKILL.md)***

---

## The Problem

Planning complex features requires discussion. Figuring out what phases and tasks should exist IS a conversation - and that conversation can be lost to context window refresh just like any other.

**Lost context = lost nuance**. A summary after refresh contains conclusions, not the reasoning. The "why we structured it this way" is gone.

## Two-Phase Planning

For complex or deeply technical work, planning happens in two phases:

### Phase A: Draft Planning (Capture)

A back-and-forth conversation about structure:
- What phases make sense?
- How should we break this down?
- What order? What dependencies?
- What's the scope of each task?

**Output**: `draft-plan.md` - running log of the planning conversation

### Phase B: Formal Planning (Organize)

Convert draft into structured format:
- Phases with acceptance criteria
- Tasks with micro acceptance
- Ready for implementation

**Output**: `plan.md` (or Linear/Backlog.md depending on destination)

## When to Use Draft Planning

**Use draft planning when**:
- Complex feature with unclear phase boundaries
- Deeply technical work requiring back-and-forth
- Multiple valid ways to structure the work
- User wants to think through the approach together

**Skip to formal planning when**:
- Structure is obvious from discussion doc
- Small feature with clear phases
- User already knows exactly how they want it structured

## Critical Rule: Immediate Capture

> **After each user response, IMMEDIATELY update the draft document before asking your next question.**

This is non-negotiable. Context windows refresh without warning. Three hours of planning discussion can vanish.

### Capture Frequency

- Update after **every natural break** in discussion
- **Never let more than 2-3 exchanges pass** without writing
- When in doubt, write it down NOW

### What to Capture

Record **what the user said AND why**, not just conclusions:

**Bad**: "Phase 1 will handle authentication"

**Good**: "User wants auth first because: (1) everything depends on knowing who the user is, (2) can't test other features without login working, (3) existing auth is partially broken and blocking current work"

### Capture the Reasoning Journey

- Why this phase before that one
- Trade-offs considered
- Alternative structures rejected and why
- Concerns raised and how addressed
- Scope decisions (what's in, what's out, why)

## Draft Document Format

Use a running log format. Raw capture first, organize later.

```markdown
# Draft Plan: [Topic Name]

**Status**: Draft - capturing planning discussion
**Created**: [date]
**Last Updated**: [timestamp]

---

## Planning Log

### [timestamp] Initial Structure Discussion

User wants to start with [X] because [reasoning].

Considered starting with [Y] instead, but [why rejected].

Key constraint: [what limits our options].

### [timestamp] Phase Breakdown

Discussing how to split the work:

**Option A**: [description]
- Pro: [benefit]
- Con: [drawback]

**Option B**: [description]
- Pro: [benefit]
- Con: [drawback]

User leaning toward Option A because [specific reasoning].

### [timestamp] Task Granularity

For Phase 1, user wants tasks like:
- [task idea] - reasoning: [why this granularity]
- [task idea] - concern: [what might be tricky]

Discussed whether [X] should be one task or two. Decision: [outcome] because [why].

### [timestamp] Dependencies and Order

[Y] must come before [Z] because [specific dependency].

User noted that [A] and [B] could be parallel since [reasoning].

---

## Emerging Structure

(Update this as structure becomes clear)

### Phase 1: [Name]
- Goal: [what this accomplishes]
- Tasks identified so far:
  - [ ] [task]
  - [ ] [task]

### Phase 2: [Name]
- Goal: [what this accomplishes]
- Depends on: Phase 1 because [why]
- Tasks identified so far:
  - [ ] [task]

---

## Open Questions

- [ ] [question still being discussed]
- [ ] [decision not yet made]

## Decisions Made

- [decision]: [reasoning captured]
```

## Commit Frequently

**Commit the draft document**:
- After each significant exchange
- At natural breaks in discussion
- When structure becomes clearer
- **Before any context refresh**
- When creating the initial file

Commits are your safety net. A context refresh with uncommitted work = lost work.

## Transitioning to Formal Plan

When draft planning is complete:

1. Review the draft document together
2. User confirms the emerging structure
3. Create formal `plan.md` using the [template](template.md)
4. Keep `draft-plan.md` for reference (the "why we structured it this way")

The draft captures the journey. The formal plan captures the destination.

## Anti-Hallucination

After context refresh, you have summaries, not nuance. The draft document IS the nuance.

**If the draft exists**: Read it. Trust it. It has the reasoning you've lost.

**If no draft exists**: You've lost the planning conversation. Be honest about this. Don't pretend you remember details you don't have.

**Never invent reasoning** that wasn't captured. If it's not in the document, ask again.
