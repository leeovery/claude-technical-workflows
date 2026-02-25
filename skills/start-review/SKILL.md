---
name: start-review
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-review/scripts/discovery.sh), Bash(.claude/hooks/workflows/write-session-state.sh), Bash(ls .workflows/planning/), Bash(ls .workflows/implementation/)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Invoke the **technical-review** skill for this conversation.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Workflow Context

This is **Phase 6** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| 3. Specification | REFINE - validate into standalone spec | |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| 5. Implementation | DOING - tests first, then code | |
| **6. Review** | VALIDATING - check work against artifacts | ◀ HERE |

**Stay in your lane**: Verify that every plan task was implemented, tested adequately, and meets quality standards. Don't fix code - identify problems. You're reviewing, not building.

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

!`.claude/skills/start-review/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-review/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

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

→ Proceed to **Step 2**.

---

## Step 2: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided

→ Proceed to **Step 3** (Validate Plan and Implementation).

#### Otherwise

→ Proceed to **Step 5** (Route Based on Scenario).

---

## Step 3: Validate Plan and Implementation

Check if plan and implementation exist and are ready.

```bash
ls .workflows/planning/
ls .workflows/implementation/
```

Read `.workflows/planning/{topic}/plan.md` frontmatter.

**If plan doesn't exist:**

> *Output the next fenced block as a code block:*

```
Plan Missing

No plan found for "{topic:(titlecase)}".

A concluded plan and implementation are required for review.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic.

Read `.workflows/implementation/{topic}/tracking.md` frontmatter.

**If implementation tracking doesn't exist:**

> *Output the next fenced block as a code block:*

```
Implementation Missing

No implementation found for "{topic:(titlecase)}".

A completed implementation is required for review.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-implementation` with topic.

**If implementation status is not "completed":**

> *Output the next fenced block as a code block:*

```
Implementation Not Complete

The implementation for "{topic:(titlecase)}" is not yet completed.
Complete the implementation first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-implementation` with topic to continue.

**If plan and implementation are both ready:**

→ Proceed to **Step 4**.

---

## Step 4: Determine Review Version (Bridge Mode)

Check if reviews already exist for this topic from the discovery output.

**If no reviews exist:**

Set review_version = 1.

**If reviews exist:**

Find the latest review version for this topic.
Set review_version = latest_version + 1.

> *Output the next fenced block as a code block:*

```
Starting review r{review_version} for "{topic:(titlecase)}".
```

→ Proceed to **Step 5** (Invoke Skill - Bridge Mode).

---

## Step 5: Invoke the Skill (Bridge Mode)

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-review/SKILL.md" \
  ".workflows/review/{topic}/r{review_version}/review.md"
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

#### If analysis

→ Proceed to **Step 9** with scope set to "analysis".

#### If re-review

→ Proceed to **Step 7** to select which plan, incrementing the review version.

#### If scenario is "single_plan" or "multiple_plans"

Plans exist (some may have reviews, some may not).

→ Proceed to **Step 7** to present options.

---

## Step 7: Display Plans

Load **[display-plans.md](references/display-plans.md)** and follow its instructions as written.

→ Proceed to **Step 8**.

---

## Step 8: Select Plans

Load **[select-plans.md](references/select-plans.md)** and follow its instructions as written.

→ Proceed to **Step 9**.

---

## Step 9: Invoke the Skill (Discovery Mode)

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-review/SKILL.md" \
  ".workflows/review/{topic}/r{review_version}/review.md"
```

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.
