# Greenfield Continuation

*Reference for **[workflow:bridge](../SKILL.md)***

---

Present greenfield state, let the user choose what to do next, then enter plan mode with that specific choice.

Greenfield is phase-centric — all artifacts in a phase complete before moving to the next. Unlike feature/bugfix pipelines, greenfield doesn't route to a single next phase. Instead, present what's actionable across all phases and let the user choose.

## A. Display State

Using the discovery output, build the phase-centric view.

> *Output the next fenced block as a code block:*

```
Greenfield — {completed_phase:(titlecase)} Complete

"{topic:(titlecase)}" {completed_phase} has concluded.

Research:
@if(research.count > 0)
  @foreach(file in research.files)
  └─ {file}
  @endforeach
@else
  (none)
@endif

Discussions:
@if(discussions.count > 0)
  @foreach(disc in discussions.files)
  └─ {disc.name:(titlecase)} ({disc.status})
  @endforeach
@else
  (none)
@endif

Specifications:
@if(specifications.count > 0)
  @foreach(spec in specifications.files)
  └─ {spec.name:(titlecase)}
     └─ Spec: {spec.status} ({spec.type})
     └─ Plan: @if(spec.has_plan) exists @else (no plan) @endif
  @endforeach
@else
  (none)
@endif

Plans:
@if(plans.count > 0)
  @foreach(plan in plans.files)
  └─ {plan.name:(titlecase)}
     └─ Plan: {plan.status}
     └─ Implementation: @if(plan.has_implementation) exists @else (not started) @endif
  @endforeach
@else
  (none)
@endif

Implementation:
@if(implementation.count > 0)
  @foreach(impl in implementation.files)
  └─ {impl.topic:(titlecase)}
     └─ Implementation: {impl.status}
     └─ Review: @if(impl.has_review) exists @else (no review) @endif
  @endforeach
@else
  (none)
@endif
```

→ Proceed to **B. Present Choices**.

---

## B. Present Choices

Build a numbered menu of actionable items. The verb depends on the state:

| State | Verb |
|-------|------|
| In-progress discussion | Continue |
| Concluded spec (feature type), no plan | Start planning for |
| In-progress plan | Continue |
| Concluded plan, no implementation | Start implementation of |
| In-progress implementation | Continue |
| Completed implementation, no review | Start review for |
| Research exists | Continue research |

**Specification phase is different in greenfield**: Don't offer "Start specification from {topic}". Instead, when concluded discussions exist, offer "Start specification" which invokes bare `/start-specification`. The specification skill will analyze ALL concluded discussions and suggest groupings — multiple discussions may become one spec, or split differently.

**Specification readiness:**
- All discussions concluded → "Start specification" (recommended)
- Some discussions still in-progress → "Start specification" with note: "(some discussions still in-progress)"

**Recommendation logic**: Mark one item as "(recommended)" based on phase completion state:
- All discussions concluded, no specifications exist → "Start specification (recommended)"
- All specifications (feature type) concluded, some without plans → first plannable spec "(recommended)"
- All plans concluded, some without implementations → first implementable plan "(recommended)"
- All implementations completed, some without reviews → first reviewable implementation "(recommended)"
- Otherwise → no recommendation (complete in-progress work first)

Always include "Start new research", "Start new discussion", and "Stop here" as final options.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do next?

1. Continue "Auth Flow" discussion — in-progress
2. Start planning for "User Profiles" — spec concluded
3. Continue "Caching" plan — in-progress
4. Start implementation of "Notifications" — plan concluded
5. Start specification — 3 discussions concluded (recommended)
6. Continue research
7. Start new research
8. Start new discussion
9. Stop here — resume later with /workflow:start

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual topics and states from discovery. Only include options that apply based on current state.

**STOP.** Wait for user response.

→ Proceed to **C. Route Selection**.

---

## C. Route Selection

#### If user chose "Stop here"

> *Output the next fenced block as a code block:*

```
Session Paused

To resume later, run /workflow:start — it will discover your
current state and present all available options.
```

**STOP.** Do not proceed — terminal condition.

#### Otherwise

Map the selection to a skill invocation:

| Selection | Skill | Topic | Work Type |
|-----------|-------|-------|-----------|
| Continue discussion | `/start-discussion` | {topic} | greenfield |
| Continue plan | `/start-planning` | {topic} | greenfield |
| Continue implementation | `/start-implementation` | {topic} | greenfield |
| Continue research | `/start-research` | — | — |
| Start specification | `/start-specification` | — | — |
| Start planning for {topic} | `/start-planning` | {topic} | greenfield |
| Start implementation of {topic} | `/start-implementation` | {topic} | greenfield |
| Start review for {topic} | `/start-review` | {topic} | greenfield |
| Start new research | `/start-research` | — | — |
| Start new discussion | `/start-discussion` | — | — |

Skills receive positional arguments: `$0` = topic, `$1` = work_type.

**With arguments** (bridge mode): `/start-discussion {topic} greenfield` — skill skips discovery, validates topic, proceeds to processing.

**Without arguments** (discovery mode): `/start-discussion` — skill runs full discovery and presents its own options.

→ Proceed to **D. Enter Plan Mode**.

---

## D. Enter Plan Mode

#### If Topic and Work Type are present

Enter plan mode with the following content:

```
# Continue Greenfield: {selected_phase:(titlecase)}

Continue {selected_phase} for "{selected_topic}".

## Next Step

Invoke `/start-{selected_phase} {selected_topic} greenfield`

Arguments: topic = {selected_topic}, work_type = greenfield
The skill will skip discovery and proceed directly to validation.

## How to proceed

Clear context and continue.
```

#### If Topic and Work Type are absent

Enter plan mode with the following content:

```
# Continue Greenfield: {selected_phase:(titlecase)}

Start {selected_phase} phase.

## Next Step

Invoke `/start-{selected_phase}`

No arguments — the skill will run full discovery and present options.

## How to proceed

Clear context and continue.
```

Exit plan mode. The user will approve and clear context.
