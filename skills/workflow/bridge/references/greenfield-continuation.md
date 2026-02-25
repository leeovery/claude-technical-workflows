# Greenfield Continuation

*Reference for **[workflow:bridge](../SKILL.md)***

---

Present greenfield state and enter plan mode with instructions to use workflow:start.

Greenfield is phase-centric — all artifacts in a phase complete before moving to the next. Unlike feature/bugfix pipelines, greenfield doesn't route to a specific next phase. Instead, it presents what's actionable across all phases.

## Present State Overview

Using the discovery output, build a phase-centric summary for the plan mode content.

Count actionable items:
- In-progress discussions
- In-progress specifications
- Concluded specifications without plans (ready for planning)
- In-progress plans
- Concluded plans without implementation (ready for implementation)
- In-progress implementations
- Completed implementations without review (ready for review)

## Generate Plan Mode Content

Enter plan mode with the following content:

```
# Continue Greenfield

The {completed_phase} phase for "{topic}" has concluded.
Greenfield development is phase-centric — assess what's actionable next.

## Current State

@if(state.discussion_in_progress > 0)
• {state.discussion_in_progress} discussion(s) in progress
@endif
@if(state.specification_in_progress > 0)
• {state.specification_in_progress} specification(s) in progress
@endif
@if(state.specification_concluded > 0 and specs_without_plans > 0)
• {specs_without_plans} specification(s) ready for planning
@endif
@if(state.plan_in_progress > 0)
• {state.plan_in_progress} plan(s) in progress
@endif
@if(state.plan_concluded > 0 and plans_without_impl > 0)
• {plans_without_impl} plan(s) ready for implementation
@endif
@if(state.implementation_in_progress > 0)
• {state.implementation_in_progress} implementation(s) in progress
@endif
@if(state.implementation_completed > 0 and impls_without_review > 0)
• {impls_without_review} implementation(s) ready for review
@endif
@if(state.discussion_concluded > 0)
• {state.discussion_concluded} concluded discussion(s) available for specification
@endif

## Next Step

Invoke `/workflow:start` to see all options and choose what to work on next.

Alternatively, invoke a specific skill directly if you know what you want:
- `/start-discussion` — Start or continue a discussion
- `/start-specification` — Start or continue a specification
- `/start-planning` — Start or continue a plan
- `/start-implementation` — Start or continue implementation
- `/start-review` — Start a review

## Context

- Just completed: {completed_phase} for "{topic}"
- Work type: greenfield (phase-centric)

## How to proceed

Clear context and continue. Claude will invoke workflow:start (or your
chosen skill) to discover state and present options.
```

Render the template with actual counts from discovery output. Omit bullet points for zero counts.

Exit plan mode. The user will approve and clear context.
