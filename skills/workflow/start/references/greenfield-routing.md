# Greenfield Routing

*Reference for **[workflow:start](../SKILL.md)***

---

Greenfield development is phase-centric. All artifacts in a phase complete before moving to the next. This reference shows what's actionable in each phase and offers options to continue existing work or start new.

## Display Greenfield State

Using the discovery output, build the phase-centric view.

> *Output the next fenced block as a code block:*

```
Greenfield Overview

Research:
@if(research_count > 0)
  @foreach(file in research.files)
  • {file}
  @endforeach
@else
  (none)
@endif

Discussions:
@if(greenfield.discussions.count > 0)
  @foreach(disc in greenfield.discussions.files)
  • {disc.name} ({disc.status})
  @endforeach
@else
  (none)
@endif

Specifications:
@if(greenfield.specifications.count > 0)
  @foreach(spec in greenfield.specifications.files)
  • {spec.name} ({spec.status}, {spec.type})
  @endforeach
@else
  (none)
@endif

Plans:
@if(greenfield.plans.count > 0)
  @foreach(plan in greenfield.plans.files)
  • {plan.name} ({plan.status})
  @endforeach
@else
  (none)
@endif

Implementation:
@if(greenfield.implementation.count > 0)
  @foreach(impl in greenfield.implementation.files)
  • {impl.topic} ({impl.status})
  @endforeach
@else
  (none)
@endif
```

## Build Menu Options

Build a numbered menu of actionable items. The verb depends on the state:

| State | Verb |
|-------|------|
| In-progress discussion | Continue |
| Concluded discussion, no spec | Start specification from |
| In-progress specification | Continue |
| Concluded spec (feature), no plan | Start planning for |
| In-progress plan | Continue |
| Concluded plan, no implementation | Start implementation of |
| In-progress implementation | Continue |
| Completed implementation, no review | Start review for |
| Research exists | Continue research |
| No discussions yet | Start research / Start new discussion |

Always include "Start new discussion" as a final option.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

1. Continue "Auth Flow" discussion — in-progress
2. Start specification from "Data Model" — discussion concluded
3. Continue "Billing" specification — in-progress
4. Start planning for "User Profiles" — spec concluded
5. Continue "Caching" plan — in-progress
6. Start implementation of "Notifications" — plan concluded
7. Continue research
8. Start new discussion

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual topics and states from discovery. Only include options that apply based on current state.

**STOP.** Wait for user response.

## Route Based on Selection

Parse the user's selection and route to the appropriate skill with `work_type: greenfield`:

| Selection | Action |
|-----------|--------|
| Continue discussion | Invoke `begin-discussion` with topic + work_type |
| Start specification | Invoke `begin-specification` with topic + work_type |
| Continue specification | Invoke `technical-specification` for topic |
| Start planning | Invoke `begin-planning` with topic + work_type |
| Continue plan | Invoke `technical-planning` for topic |
| Start implementation | Invoke `begin-implementation` with topic + work_type |
| Continue implementation | Invoke `technical-implementation` for topic |
| Start review | Invoke `begin-review` with topic + work_type |
| Continue research | Invoke `technical-research` |
| Start research | Invoke `start-research` |
| Start new discussion | Invoke `start-discussion` with work_type: greenfield |

For skills that require a topic, pass:
- `Topic: {topic}`
- `Work type: greenfield`

For "continue" actions on processing skills, they will resume from artifact state.
