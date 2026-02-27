# Work Type Selection

*Reference for **[workflow-start](../SKILL.md)***

---

Present the current state and ask the user which work type they want to work on.

## Display State Overview

Using the discovery output, render the appropriate state display.

#### If `state.has_any_work` is false

> *Output the next fenced block as a code block:*

```
Workflow Overview

No existing work found. Ready to start fresh.
```

#### If `state.has_any_work` is true

Build the summary from `state` counts. Only show sections with work.

> *Output the next fenced block as a code block:*

```
Workflow Overview

@if(state.greenfield has any counts > 0)
Greenfield:
  @if(research_count > 0)└─ Research: {research_count} @if(research_count == 1)file@else files@endif
  @endif
  @if(discussion_count > 0)└─ Discussions: {discussion_count} @if(discussion_concluded > 0)({discussion_concluded} concluded)@endif
  @endif
  @if(specification_count > 0)└─ Specifications: {specification_count} @if(specification_concluded > 0)({specification_concluded} concluded)@endif
  @endif
  @if(plan_count > 0)└─ Plans: {plan_count} @if(plan_concluded > 0)({plan_concluded} concluded)@endif
  @endif
  @if(implementation_count > 0)└─ Implementations: {implementation_count} @if(implementation_completed > 0)({implementation_completed} completed)@endif
  @endif
@endif

@if(feature_count > 0)
Features: {feature_count} in progress
@endif

@if(bugfix_count > 0)
Bugfixes: {bugfix_count} in progress
@endif
```

Use values from `state.greenfield.*`, `state.feature_count`, `state.bugfix_count`.

## Ask Work Type

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to work on?

1. **Build the product** — Greenfield development (phase-centric, multi-session)
2. **Add a feature** — Feature work (topic-centric, linear pipeline)
3. **Fix a bug** — Bugfix (investigation-centric, focused pipeline)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

## Process Selection

Map the user's response to a work type:

- "1", "build", "greenfield", "product" → work type is **greenfield**
- "2", "feature", "add" → work type is **feature**
- "3", "bug", "fix", "bugfix" → work type is **bugfix**

If the response doesn't map clearly, ask for clarification.

→ Return to **[the skill](../SKILL.md)** with the selected work type.
