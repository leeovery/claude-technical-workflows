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
  {foreach file in research.files}
  • {file}
  {/foreach}
@else
  (none)
@endif

Discussions:
@if(discussions.count > 0)
  {foreach disc in discussions.files}
  • {disc.name} ({disc.status})
  {/foreach}
@else
  (none)
@endif

Specifications:
@if(specifications.count > 0)
  {foreach spec in specifications.files}
  • {spec.name} ({spec.status}, {spec.type})@if(spec.has_plan) — has plan@endif
  {/foreach}
@else
  (none)
@endif

Plans:
@if(plans.count > 0)
  {foreach plan in plans.files}
  • {plan.name} ({plan.status})@if(plan.has_implementation) — has implementation@endif
  {/foreach}
@else
  (none)
@endif

Implementation:
@if(implementation.count > 0)
  {foreach impl in implementation.files}
  • {impl.topic} ({impl.status})@if(impl.has_review) — has review@endif
  {/foreach}
@else
  (none)
@endif
```

## Build Menu Options

Build a numbered menu of actionable items based on state. Include in priority order:

1. **In-progress items first** — work that's actively being done
   - In-progress discussions → "Continue {name} discussion"
   - In-progress specifications → "Continue {name} specification"
   - In-progress plans → "Continue {name} plan"
   - In-progress implementations → "Continue {name} implementation"

2. **Phase transitions** — concluded artifacts ready for next phase
   - Concluded discussions without spec → "Start specification from {name}"
   - Concluded specs (feature type) without plan → "Start planning for {name}"
   - Concluded plans without implementation → "Start implementation of {name}"
   - Completed implementations without review → "Start review for {name}"

3. **New work options** — always available
   - If research exists → "Continue research exploration"
   - If no research → "Start research exploration"
   - "Start new discussion"

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

{numbered_options}
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

## Return Selection

Return the user's selection to the main skill for routing.
