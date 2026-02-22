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
  {foreach file in research.files}
  • {file}
  {/foreach}
@else
  (none)
@endif

Discussions:
@if(greenfield.discussions.count > 0)
  {foreach disc in greenfield.discussions.files}
  • {disc.name} ({disc.status})
  {/foreach}
@else
  (none)
@endif

Specifications:
@if(greenfield.specifications.count > 0)
  {foreach spec in greenfield.specifications.files}
  • {spec.name} ({spec.status}, {spec.type})
  {/foreach}
@else
  (none)
@endif

Plans:
@if(greenfield.plans.count > 0)
  {foreach plan in greenfield.plans.files}
  • {plan.name} ({plan.status})
  {/foreach}
@else
  (none)
@endif

Implementation:
@if(greenfield.implementation.count > 0)
  {foreach impl in greenfield.implementation.files}
  • {impl.topic} ({impl.status})
  {/foreach}
@else
  (none)
@endif
```

## Build Menu Options

Build a numbered menu of actionable items. Include:

1. **In-progress items** — discussions, specs, plans that can be continued
2. **Phase transitions** — concluded artifacts ready for next phase
3. **New work** — start new items in phases that are ready

**Menu construction rules:**
- In-progress discussions → "Continue {name} discussion"
- Concluded discussions with no spec → "Start specification from {name}"
- In-progress specifications → "Continue {name} specification"
- Concluded specs (feature type) with no plan → "Start planning for {name}"
- In-progress plans → "Continue {name} plan"
- Concluded plans with no implementation → "Start implementation of {name}"
- In-progress implementations → "Continue {name} implementation"
- Completed implementations with no review → "Start review for {name}"
- Research exists → "Continue research exploration"
- Always offer "Start new discussion" if there's room for new work
- If no discussions exist, offer "Start research exploration"

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

{numbered_options}
· · · · · · · · · · · ·
```

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
