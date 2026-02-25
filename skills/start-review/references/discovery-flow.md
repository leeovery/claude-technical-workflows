# Discovery Flow

*Reference for **[start-review](../SKILL.md)***

---

Full discovery flow for bare invocation (no topic provided).

## Step A: Run Discovery

!`.claude/skills/start-review/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-review/scripts/discovery.sh
```

Parse the discovery output to understand:

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - list of plans with: name, topic, status, date, format, specification, specification_exists, plan_id (if present)
- `count` - total number of plans

**From `reviews` section:**
- `exists` - whether any reviews exist
- `entries` - list of reviews with: scope, type, plans, versions, latest_version, latest_verdict, latest_path, has_synthesis

**From `state` section:**
- `scenario` - one of: `"no_plans"`, `"single_plan"`, `"multiple_plans"`
- `implemented_count` - plans with implementation_status != "none"
- `completed_count` - plans with implementation_status == "completed"
- `reviewed_plan_count` - plans that have been reviewed
- `all_reviewed` - whether all implemented plans have reviews

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step B**.

---

## Step B: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_plans"

No plans exist yet.

> *Output the next fenced block as a code block:*

```
Review Overview

No plans found in .workflows/planning/

The review phase requires a completed implementation based on a plan.
Run /start-planning first to create a plan, then /start-implementation
to build it.
```

**STOP.** Do not proceed — terminal condition.

#### If all_reviewed is true

All implemented plans have been reviewed.

> *Output the next fenced block as a code block:*

```
Review Overview

All {N} implemented plans have been reviewed.

1. {topic:(titlecase)}
   └─ Review: x{review_count} — r{latest_review_version} ({latest_review_verdict})
   └─ Synthesis: @if(has_synthesis) completed @else pending @endif

2. ...
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
All plans have been reviewed.

- **`a`/`analysis`** — Synthesize findings from existing reviews into tasks
- **`r`/`re-review`** — Re-review a plan (creates new review version)

Select an option:
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If analysis → return to main skill **Step 4** with scope="analysis".
If re-review → proceed to **Step C**, then return with incremented review version.

#### If scenario is "single_plan" or "multiple_plans"

Plans exist (some may have reviews, some may not).

→ Proceed to **Step C** to present options.

---

## Step C: Display Plans

Load **[display-plans.md](display-plans.md)** and follow its instructions as written.

→ Proceed to **Step D**.

---

## Step D: Select Plans

Load **[select-plans.md](select-plans.md)** and follow its instructions as written.

→ Return to main skill **Step 4** with selection context.
