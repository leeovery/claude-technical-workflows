# Gap Analysis

*Reference for **[spec-review](spec-review.md)***

---

Phase 2 reviews the **specification as a standalone document** — looking *inward* at what's been specified, not outward at what else the product might need.

**Purpose**: Ensure that *within the defined scope*, the specification flows correctly, has sufficient detail, and leaves nothing open to interpretation or assumption. This might be a full product spec or a single feature — the scope is whatever the inputs defined. Your job is to verify that within those boundaries, an agent or human could create plans, break them into tasks, and write code without having to guess.

**Key distinction**: You're not asking "what features are missing from this product?" You're asking "within what we've decided to build, is everything clear and complete?"

## What to Look For

Review the specification systematically for gaps *within what's specified*:

1. **Internal Completeness**
   - Workflows that start but don't show how they end
   - States or transitions mentioned but not fully defined
   - Behaviors referenced elsewhere but never specified
   - Default values or fallback behaviors left unstated

2. **Insufficient Detail**
   - Areas where an implementer would have to guess
   - Sections that are too high-level to act on
   - Missing error handling for scenarios the spec introduces
   - Validation rules implied but not defined
   - Boundary conditions for limits the spec mentions

3. **Ambiguity**
   - Vague language that could be interpreted multiple ways
   - Terms used inconsistently across sections
   - "It should" without defining what "it" is
   - Implicit assumptions that aren't stated

4. **Contradictions**
   - Requirements that conflict with each other
   - Behaviors defined differently in different sections
   - Constraints that make other requirements impossible

5. **Edge Cases Within Scope**
   - For the behaviors specified, what happens at boundaries?
   - For the inputs defined, what happens when they're empty or malformed?
   - For the integrations described, what happens when they're unavailable?

6. **Planning Readiness**
   - Could you break this into clear tasks?
   - Would an implementer know what to build?
   - Are acceptance criteria implicit or explicit?
   - Are there sections that would force an implementer to make design decisions?

## The Review Process

1. **Read the specification end-to-end** — Not scanning, but carefully reading as if you were about to implement it

2. **For each section, ask**:
   - Is this internally complete? Does it define everything it references?
   - Is this clear? Would an implementer know exactly what to build?
   - Is this consistent? Does it contradict anything else in the spec?
   - Are there areas left open to interpretation or assumption?

3. **Collect findings** — Note each gap, ambiguity, or area needing clarification

4. **Prioritize** — Focus on issues that would block or confuse implementation:
   - **Critical**: Would prevent implementation or cause incorrect behavior
   - **Important**: Would require implementer to guess or make design decisions
   - **Minor**: Polish or clarification that improves understanding

5. **Create the tracking file** — If findings exist, write them to `review-gap-analysis-tracking-c{N}.md` using the format from **[review-tracking-format.md](review-tracking-format.md)**. Commit the tracking file.

## What You're NOT Doing in Phase 2

- **Not expanding scope** — Looking for gaps *within* what's specified, not suggesting features the product should have. A feature spec for "user login" doesn't need you to ask about password reset if it wasn't in scope.
- **Not gold-plating** — Only flag gaps that would actually impact implementation of what's specified
- **Not second-guessing decisions** — The spec reflects validated decisions; you're checking for clarity and completeness, not re-opening debates
- **Not being exhaustive for its own sake** — Focus on what matters for implementing *this* specification

## Completing Phase 2

When you've:
- Reviewed the specification for completeness, clarity, and implementation readiness
- Created the tracking file (if findings exist) and committed it

→ Return to **[spec-review.md](spec-review.md)** for finding processing.
