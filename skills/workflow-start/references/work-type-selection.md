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

Build the summary from `state` counts and topic arrays. Only show sections with work.

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
Features:
@foreach(topic in features.topics)
  {N}. {topic.name:(titlecase)}
     └─ {topic.phase_label:(titlecase)}
@endforeach
@endif

@if(bugfix_count > 0)
Bugfixes:
@foreach(topic in bugfixes.topics)
  {N}. {topic.name:(titlecase)}
     └─ {topic.phase_label:(titlecase)}
@endforeach
@endif
```

Use values from `state.greenfield.*`, `features.topics`, `bugfixes.topics`.

## Ask Work Type

Collect actionable in-progress items: features/bugfixes where `next_phase` is not `done`, `superseded`, or `unknown`. These become continue options in the menu.

#### If actionable in-progress items exist

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to work on?

1. **Continue "{topic:(titlecase)}"** — {work_type}, {phase_label}

2. **Large initiative** — MVP, new build, or multi-spec work
3. **Start a feature** — New feature work
4. **Fix a bug** — Start a new bugfix
· · · · · · · · · · · ·
```

Recreate with actual topics and `phase_label` values from discovery. Continue items show: `Continue "{topic:(titlecase)}" — {work_type}, {phase_label}`. Blank line separates continue options from start-new options.

#### If no actionable in-progress items

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to work on?

1. **Large initiative** — MVP, new build, or multi-spec work
2. **Start a feature** — New feature work
3. **Fix a bug** — Start a new bugfix
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

## Process Selection

#### If user selected a continue option

Route directly to the appropriate skill based on the topic's `next_phase` and work type:

| next_phase | work_type | Skill |
|------------|-----------|-------|
| discussion | feature | `/start-discussion feature {topic}` |
| investigation | bugfix | `/start-investigation bugfix {topic}` |
| specification | feature/bugfix | `/start-specification {work_type} {topic}` |
| planning | feature/bugfix | `/start-planning {work_type} {topic}` |
| implementation | feature/bugfix | `/start-implementation {work_type} {topic}` |
| review | feature/bugfix | `/start-review {work_type} {topic}` |

Invoke the skill with positional arguments. This is terminal — do not return to the backbone.

#### If user selected a start-new option

Map the user's response to a work type:

- "Large initiative", "large", "initiative", "build", "greenfield", "mvp" → work type is **greenfield**
- "Start a feature", "feature" → work type is **feature**
- "Fix a bug", "bug", "fix", "bugfix" → work type is **bugfix**

If the response doesn't map clearly, ask for clarification.

→ Return to **[the skill](../SKILL.md)** with the selected work type.
