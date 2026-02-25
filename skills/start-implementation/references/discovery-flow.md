# Discovery Flow

*Reference for **[start-implementation](../SKILL.md)***

---

Full discovery flow for bare invocation (no topic provided).

## Step A: Run Discovery

!`.claude/skills/start-implementation/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-implementation/scripts/discovery.sh
```

Parse the discovery output to understand:

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - list of plans with: name, topic, status, date, format, specification, specification_exists, plan_id (if present)
- Per plan `external_deps` - array of dependencies with topic, state, task_id
- Per plan `has_unresolved_deps` - whether plan has unresolved dependencies
- Per plan `unresolved_dep_count` - count of unresolved dependencies
- `count` - total number of plans

**From `implementation` section:**
- `exists` - whether any implementation tracking files exist
- `files` - list of tracking files with: topic, status, current_phase, completed_phases, completed_tasks

**From `dependency_resolution` section:**
- Per plan `deps_satisfied` - whether all resolved deps have their tasks completed
- Per plan `deps_blocking` - list of deps not yet satisfied with reason

**From `environment` section:**
- `setup_file_exists` - whether environment-setup.md exists
- `requires_setup` - true, false, or unknown

**From `state` section:**
- `scenario` - one of: `"no_plans"`, `"single_plan"`, `"multiple_plans"`
- `plans_concluded_count` - plans with status concluded
- `plans_with_unresolved_deps` - plans with unresolved external deps
- `plans_ready_count` - concluded plans with all deps satisfied
- `plans_in_progress_count` - implementations in progress
- `plans_completed_count` - implementations completed

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step B**.

---

## Step B: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_plans"

No plans exist yet.

> *Output the next fenced block as a code block:*

```
Implementation Overview

No plans found in .workflows/planning/

The implementation phase requires a plan.
Run /start-planning first to create a plan from a specification.
```

**STOP.** Do not proceed — terminal condition.

#### If scenario is "single_plan" or "multiple_plans"

Plans exist.

→ Proceed to **Step C** to present options.

---

## Step C: Present Plans and Select

Present all discovered plans. Classify each plan into one of three categories based on its state.

**Classification logic:**

A plan is **Implementable** if:
- It has `status: concluded` AND all deps are satisfied (`deps_satisfied: true` or no deps) AND no tracking file or tracking `status: not-started`, OR
- It has an implementation tracking file with `status: in-progress`

A plan is **Implemented** if:
- It has an implementation tracking file with `status: completed`

A plan is **Not implementable** if:
- It has `status: concluded` but deps are NOT satisfied (blocking deps exist)
- It has `status: planning` or other non-concluded status
- It has unresolved deps (`has_unresolved_deps: true`)

**Present the full state:**

> *Output the next fenced block as a code block:*

```
Implementation Overview

{N} plans found. {M} implementations in progress.

1. {topic:(titlecase)}
   └─ Plan: {plan_status:[concluded]} ({format})
   └─ Implementation: @if(has_implementation) {impl_status:[in-progress|completed]} @else (not started) @endif

2. ...
```

**Tree rules:**

Implementable:
- Implementation `status: in-progress` → `Implementation: in-progress (Phase N, Task M)`
- Concluded plan, deps met, not started → `Implementation: (not started)`

Implemented:
- Implementation `status: completed` → `Implementation: completed`

**Ordering:**
1. Implementable first: in-progress, then new (foundational before dependent)
2. Implemented next: completed
3. Not implementable last (separate block below)

**If non-implementable plans exist**, show them in a separate code block:

> *Output the next fenced block as a code block:*

```
Plans not ready for implementation:
These plans are either still in progress or have unresolved
dependencies that must be addressed first.

  • advanced-features (blocked by core-features:core-2-3)
  • reporting (in-progress)
```

**Then prompt based on what's actionable:**

**If single implementable plan and no implemented plans (auto-select):**

> *Output the next fenced block as a code block:*

```
Automatically proceeding with "{topic:(titlecase)}".
```

→ Return to main skill **Step 4** with topic.

**If nothing selectable:**

> *Output the next fenced block as a code block:*

```
Implementation Overview

No implementable plans found.

Complete blocking dependencies first, or finish plans still
in progress with /start-planning. Then re-run /start-implementation.
```

**STOP.** Do not proceed — terminal condition.

**Otherwise (multiple selectable plans):**

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
1. Continue "Billing" — in-progress (Phase 2, Task 3)
2. Start "Core Features" — not yet started
3. Re-review "User Auth" — completed

Select an option (enter number):
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Return to main skill **Step 4** with selected topic.
