# Planning Principles

*Reference for **[technical-planning](../SKILL.md)***

---

This reference defines the principles, rules, and quality standards for creating implementation plans. It is loaded at the start of the planning process and stays in context throughout.

## Planning is a Gated Process

Planning translates the specification into actionable structure. This translation requires judgment, and the process is designed to ensure that judgment is exercised carefully and collaboratively — not rushed.

### Process Expectations

**This is a step-by-step process with mandatory stop points.** You must work through each step sequentially. Steps end with **STOP** — you must present your work, wait for explicit user confirmation, and only then proceed to the next step.

**Never one-shot the plan.** Do not write the entire plan document in a single operation. The plan is built incrementally — one phase at a time, with the user confirming the structure at each stage. A one-shot plan that misses requirements, hallucinates content, or structures tasks poorly wastes more time than a careful, step-by-step process. Go slow to go fast.

**Stop and ask when judgment is needed.** Planning is collaborative — not in the sense that every line needs approval, but in the sense that the user guides structural decisions and resolves ambiguity. You must stop and ask when:

- The specification is ambiguous about implementation approach
- Multiple valid ways to structure phases or tasks exist
- You're uncertain whether a task is appropriately scoped
- Edge cases aren't fully addressed in the specification
- You need to make any decision the specification doesn't cover
- Something doesn't add up or feels like a gap

**Never invent to fill gaps.** If the specification doesn't address something, flag it with `[needs-info]` and ask the user. The specification is the golden document — everything in the plan must trace back to it. Assuming or guessing — even when it seems reasonable — is not acceptable. Surface the problem immediately rather than continuing and hoping to address it later.

## Rules

**Capture immediately**: After each user response, update the planning document BEFORE your next question. Never let more than 2-3 exchanges pass without writing.

**Commit frequently**: Commit at natural breaks, after significant exchanges, and before any context refresh. Context refresh = lost work.

**Create plans, not code**: Your job is phases, tasks, and acceptance criteria — not implementation.

## Plan as Source of Truth

The plan IS the source of truth. Every phase, every task must contain all information needed to execute it.

- **Self-contained**: Each task executable without external context
- **No assumptions**: Spell out the context, don't assume implementer knows it

## Flagging Incomplete Tasks

When information is missing, mark it clearly with `[needs-info]`:

```markdown
### Task 3: Configure rate limiting [needs-info]

**Do**: Set up rate limiting for the API endpoint
**Test**: `it throttles requests exceeding limit`

**Needs clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

Planning is iterative. Create structure, flag gaps, refine.
