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
| In-progress specification | Continue |
| Concluded spec (feature), no plan | Start planning for |
| In-progress plan | Continue |
| Concluded plan, no implementation | Start implementation of |
| In-progress implementation | Continue |
| Completed implementation, no review | Start review for |
| Research exists | Continue research |
| No discussions yet | Start research / Start new discussion |

**Specification phase is different in greenfield**: Don't offer "Start specification from {topic}". Instead, when concluded discussions exist, offer "Start specification" which invokes `/start-specification`. The specification skill will analyze ALL concluded discussions and suggest groupings — multiple discussions may become one spec, or split differently.

**Specification readiness:**
- All discussions concluded → "Start specification" (recommended)
- Some discussions still in-progress → "Start specification" with note: "(some discussions still in-progress)"

Always include "Start new discussion" as a final option.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

1. Continue "Auth Flow" discussion — in-progress
2. Continue "Billing" specification — in-progress
3. Start planning for "User Profiles" — spec concluded
4. Continue "Caching" plan — in-progress
5. Start implementation of "Notifications" — plan concluded
6. Start specification — 3 discussions concluded (recommended)
7. Continue research
8. Start new discussion

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual topics and states from discovery. Only include options that apply based on current state.

**STOP.** Wait for user response.

## Route Based on Selection

Parse the user's selection and route to the appropriate skill:

| Selection | Action |
|-----------|--------|
| Continue discussion | Invoke `begin-discussion` with topic + work_type: greenfield |
| Continue specification | Invoke `begin-specification` with topic + work_type: greenfield |
| Continue plan | Invoke `begin-planning` with topic + work_type: greenfield |
| Continue implementation | Invoke `begin-implementation` with topic + work_type: greenfield |
| Continue research | Invoke `start-research` (handles resume from existing file) |
| Start specification | Invoke `start-specification` (analyzes all discussions, suggests groupings) |
| Start planning | Invoke `begin-planning` with topic + work_type: greenfield |
| Start implementation | Invoke `begin-implementation` with topic + work_type: greenfield |
| Start review | Invoke `begin-review` with topic + work_type: greenfield |
| Start research | Invoke `start-research` |
| Start new discussion | Invoke `start-discussion` |

**Routing principle**: `begin-*` skills handle cases where topic + work_type are already known (continue existing or start from concluded artifact). `start-*` skills handle full discovery and context gathering for new work.

**Note on specification**: Unlike feature/bugfix pipelines, greenfield specification is NOT topic-centric. The `start-specification` skill discovers all concluded discussions, analyzes them, and suggests how to group them into specifications. Multiple discussions may become one spec, or vice versa.
