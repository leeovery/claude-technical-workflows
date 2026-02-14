# Display State and Options

*Reference for **[start-planning](../SKILL.md)***

---

Present everything discovered to help the user make an informed choice.

**Present the full state:**

> *Output the next fenced block as a code block:*

```
Planning Overview

{N} specifications found. {M} plans exist.

1. {topic:(titlecase)}
   └─ Plan: @if(has_plan) {plan_status:[in-progress|concluded]} @else (no plan) @endif
   └─ Spec: concluded

2. ...
```

**Tree rules:**

Each numbered item shows a feature specification that is actionable:
- Concluded spec with no plan → `Plan: (no plan)`
- Has a plan with `plan_status: planning` → `Plan: in-progress`
- Has a plan with `plan_status: concluded` → `Plan: concluded`

**If non-plannable specifications exist**, show them in a separate code block:

> *Output the next fenced block as a code block:*

```
Specifications not ready for planning:
These specifications are either still in progress or cross-cutting
and cannot be planned directly.

  • {topic} ({type:[feature|cross-cutting]}, {status:[in-progress|concluded]})
```

**Key/Legend** — show only statuses that appear in the current display. No `---` separator before this section.

> *Output the next fenced block as a code block:*

```
Key:

  Plan status:
    in-progress — planning work is ongoing
    concluded   — plan is complete

  Spec type:
    cross-cutting — architectural policy, not directly plannable
    feature       — plannable feature specification
```

Omit any section entirely if it has no entries.

**Then prompt based on what's actionable:**

**If multiple actionable items:**

The verb in the menu depends on the plan state:
- No plan exists → **Create**
- Plan is `in-progress` → **Continue**
- Plan is `concluded` → **Review**

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
1. Create "Auth Flow" — concluded spec, no plan
2. Continue "Data Model" — plan in-progress
3. Review "Billing" — plan concluded

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual topics and states from discovery.

**STOP.** Wait for user response.

**If single actionable item (auto-select):**

> *Output the next fenced block as a code block:*

```
Automatically proceeding with "{topic:(titlecase)}".
```

→ Proceed directly to **Step 4**.

**If nothing actionable:**

> *Output the next fenced block as a code block:*

```
Planning Overview

No plannable specifications found.

The planning phase requires a concluded feature specification.
Complete any in-progress specifications with /start-specification,
or create a new specification first.
```

**STOP.** Do not proceed — terminal condition.

→ Based on user choice, proceed to **Step 4**.
