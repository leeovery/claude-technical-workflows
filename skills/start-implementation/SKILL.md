---
name: start-implementation
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-implementation/scripts/discovery.sh), Bash(.claude/hooks/workflows/write-session-state.sh), Bash(ls .workflows/planning/)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Invoke the **technical-implementation** skill for this conversation.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Workflow Context

This is **Phase 5** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| 3. Specification | REFINE - validate into standalone spec | |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| **5. Implementation** | DOING - tests first, then code | ◀ HERE |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Execute the plan via strict TDD - tests first, then code. Don't re-debate decisions from the specification or expand scope beyond the plan. The plan is your authority.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Even if the user's initial prompt seems to answer a question, still confirm with them at the appropriate step
- Complete each step fully before moving to the next
- Do not act on gathered information until the skill is loaded - it contains the instructions for how to proceed

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Discovery State

!`.claude/skills/start-implementation/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-implementation/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

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

→ Proceed to **Step 2**.

---

## Step 2: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided

→ Proceed to **Step 3** (Validate Plan).

#### Otherwise

→ Proceed to **Step 6** (Route Based on Scenario).

---

## Step 3: Validate Plan

Check if plan exists and is ready.

```bash
ls .workflows/planning/
```

Read `.workflows/planning/{topic}/plan.md` frontmatter.

**If plan doesn't exist:**

> *Output the next fenced block as a code block:*

```
Plan Missing

No plan found for "{topic:(titlecase)}".

A concluded plan is required for implementation.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic.

**If plan exists but status is not "concluded":**

> *Output the next fenced block as a code block:*

```
Plan Not Concluded

The plan for "{topic:(titlecase)}" is not yet concluded.
Complete the plan first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic to continue.

**If plan exists and status is "concluded":**

→ Proceed to **Step 4**.

---

## Step 4: Check Dependencies (Bridge Mode)

Check if plan has unresolved or blocking dependencies from the discovery output.

**If has_unresolved_deps is true:**

> *Output the next fenced block as a code block:*

```
Unresolved Dependencies

The plan for "{topic:(titlecase)}" has unresolved external dependencies.

These must be resolved before implementation can begin.
```

**STOP.** Do not proceed — terminal condition.

**If deps_blocking contains entries:**

> *Output the next fenced block as a code block:*

```
Blocking Dependencies

The plan for "{topic:(titlecase)}" is blocked by incomplete tasks:

@foreach(dep in deps_blocking)
  • {dep.topic}:{dep.task_id} — {dep.reason}
@endforeach

Complete these tasks first, then re-run implementation.
```

**STOP.** Do not proceed — terminal condition.

**If all dependencies satisfied:**

→ Proceed to **Step 5**.

---

## Step 5: Check Environment (Bridge Mode)

Check environment setup from discovery output.

**If requires_setup is true:**

Load **[environment-check.md](references/environment-check.md)** and follow its instructions as written.

**If requires_setup is false or unknown:**

→ Proceed to **Step 5a** (Invoke Skill - Bridge Mode).

---

### Step 5a: Invoke the Skill (Bridge Mode)

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-implementation/SKILL.md" \
  ".workflows/implementation/{topic}/tracking.md"
```

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.

---

## Step 6: Route Based on Scenario

Discovery mode — use the discovery output from Step 1.

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

→ Proceed to **Step 7** to present options.

---

## Step 7: Present Plans and Select

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

Show implementable and implemented plans as numbered tree items.

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

Numbering is sequential across Implementable and Implemented. Omit any section entirely if it has no entries.

**If non-implementable plans exist**, show them in a separate code block:

> *Output the next fenced block as a code block:*

```
Plans not ready for implementation:
These plans are either still in progress or have unresolved
dependencies that must be addressed first.

  • advanced-features (blocked by core-features:core-2-3)
  • reporting (in-progress)
```

> *Output the next fenced block as a code block:*

```
If a blocked dependency has been resolved outside this workflow,
name the plan and the dependency to unblock it.
```

**Key/Legend** — show only statuses that appear in the current display. No `---` separator before this section.

> *Output the next fenced block as a code block:*

```
Key:

  Implementation status:
    in-progress — work is ongoing
    completed   — all tasks implemented

  Blocking reason:
    blocked     — depends on another plan's task
    in-progress — plan not yet concluded
```

**Then prompt based on what's actionable:**

**If single implementable plan and no implemented plans (auto-select):**

> *Output the next fenced block as a code block:*

```
Automatically proceeding with "{topic:(titlecase)}".
```

→ Proceed directly to **Step 8**.

**If nothing selectable (no implementable or implemented):**

Show "not ready" block only (with unblock hint above).

> *Output the next fenced block as a code block:*

```
Implementation Overview

No implementable plans found.

Complete blocking dependencies first, or finish plans still
in progress with /start-planning. Then re-run /start-implementation.
```

**STOP.** Do not proceed — terminal condition.

**If multiple selectable plans:**

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

→ Proceed to **Step 8** with selected topic.

---

## Step 8: Check Dependencies (Discovery Mode)

Check if selected plan has unresolved or blocking dependencies from the discovery output.

**If has_unresolved_deps is true or deps_blocking contains entries:**

Handle as shown in Step 4.

**If all dependencies satisfied:**

→ Proceed to **Step 9**.

---

## Step 9: Check Environment (Discovery Mode)

Check environment setup from discovery output.

**If requires_setup is true:**

Load **[environment-check.md](references/environment-check.md)** and follow its instructions as written.

**If requires_setup is false or unknown:**

→ Proceed to **Step 10**.

---

## Step 10: Invoke the Skill (Discovery Mode)

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-implementation/SKILL.md" \
  ".workflows/implementation/{topic}/tracking.md"
```

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.
