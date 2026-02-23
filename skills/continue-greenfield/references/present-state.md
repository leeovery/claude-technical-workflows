# Present State

*Reference for **[continue-greenfield](../SKILL.md)***

---

Present the current greenfield state and build a menu of actionable options.

## Display State Overview

Using the discovery output, build a phase-centric view.

> *Output the next fenced block as a code block:*

```
Greenfield Overview

Research:
@if(research.count > 0)
  @foreach(file in research.files)
  • {file}
  @endforeach
@else
  (none)
@endif

Discussions:
@if(discussions.count > 0)
  @foreach(disc in discussions.files)
  • {disc.name} ({disc.status})
  @endforeach
@else
  (none)
@endif

Specifications:
@if(specifications.count > 0)
  @foreach(spec in specifications.files)
  • {spec.name} ({spec.status}, {spec.type})@if(spec.has_plan) — has plan@endif
  @endforeach
@else
  (none)
@endif

Plans:
@if(plans.count > 0)
  @foreach(plan in plans.files)
  • {plan.name} ({plan.status})@if(plan.has_implementation) — has implementation@endif
  @endforeach
@else
  (none)
@endif

Implementation:
@if(implementation.count > 0)
  @foreach(impl in implementation.files)
  • {impl.topic} ({impl.status})@if(impl.has_review) — has review@endif
  @endforeach
@else
  (none)
@endif
```

## Build Menu Options

Build a numbered menu of actionable items based on state. The verb depends on state:

| State | Verb |
|-------|------|
| In-progress discussion | Continue ... discussion |
| In-progress specification | Continue ... specification |
| In-progress plan | Continue ... plan |
| In-progress implementation | Continue ... implementation |
| Concluded discussion, no spec | Start specification from |
| Concluded spec (feature), no plan | Start planning for |
| Concluded plan, no impl | Start implementation of |
| Completed impl, no review | Start review for |
| Research exists | Continue research |
| No research | Start research |

Always include "Start new discussion" as a final option.

**Priority order:** In-progress items first, then phase transitions, then new work options.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

1. Continue "Auth Flow" discussion — in-progress
2. Continue "Data Model" specification — in-progress
3. Start specification from "Billing" — discussion concluded
4. Start planning for "User Profiles" — spec concluded
5. Continue research
6. Start new discussion

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual topics and states from discovery. Only include options that apply.

**STOP.** Wait for user response.

## Return Selection

Return the user's selection to the main skill for routing.
