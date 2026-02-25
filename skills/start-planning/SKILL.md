---
name: start-planning
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-planning/scripts/discovery.sh), Bash(.claude/hooks/workflows/write-session-state.sh), Bash(ls .workflows/specification/)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Invoke the **technical-planning** skill for this conversation.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Workflow Context

This is **Phase 4** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| 3. Specification | REFINE - validate into standalone spec | |
| **4. Planning** | HOW - phases, tasks, acceptance criteria | ◀ HERE |
| 5. Implementation | DOING - tests first, then code | |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Create the plan - phases, tasks, and acceptance criteria. Don't jump to implementation or write code. The specification is your sole input; transform it into actionable work items.

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

#### If files were updated

**STOP.** Wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding.

#### If no updates needed

→ Proceed to **Step 1**.

---

## Step 1: Discovery State

!`.claude/skills/start-planning/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-planning/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

**From `specifications` section:**
- `exists` - whether any specifications exist
- `feature` - list of feature specs (name, status, has_plan, plan_status, has_impl, impl_status)
- `crosscutting` - list of cross-cutting specs (name, status)
- `counts.feature` - total feature specifications
- `counts.feature_ready` - feature specs ready for planning (concluded + no plan)
- `counts.feature_with_plan` - feature specs that already have plans
- `counts.feature_actionable_with_plan` - specs with plans that are NOT fully implemented
- `counts.feature_implemented` - specs with `impl_status: completed`
- `counts.crosscutting` - total cross-cutting specifications

**From `plans` section:**
- `exists` - whether any plans exist
- `files` - each plan's name, format, status, and plan_id (if present)
- `common_format` - the output format if all existing plans share the same one; empty string otherwise

**From `state` section:**
- `scenario` - one of: `"no_specs"`, `"nothing_actionable"`, `"has_options"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step 2**.

---

## Step 2: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided

→ Proceed to **Step 3** (Validate Specification).

#### Otherwise

→ Proceed to **Step 6** (Route Based on Scenario).

---

## Step 3: Validate Specification

Load **[validate-spec.md](references/validate-spec.md)** and follow its instructions as written.

→ Proceed to **Step 4**.

---

## Step 4: Handle Cross-Cutting Context (Bridge Mode)

Load **[cross-cutting-context.md](references/cross-cutting-context.md)** and follow its instructions as written.

→ Proceed to **Step 5**.

---

## Step 5: Invoke the Skill (Bridge Mode)

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.

---

## Step 6: Route Based on Scenario

Discovery mode — use the discovery output from Step 1.

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "no_specs"

No specifications exist yet.

> *Output the next fenced block as a code block:*

```
Planning Overview

No specifications found in .workflows/specification/

The planning phase requires a concluded specification.
Run /start-specification first.
```

**STOP.** Do not proceed — terminal condition.

#### If scenario is "nothing_actionable"

Specifications exist but none are actionable — all are still in-progress and no plans exist to continue.

→ Proceed to **Step 7** to show the state.

#### If scenario is "has_options"

At least one specification is ready for planning, or an existing plan can be continued or reviewed.

→ Proceed to **Step 7** to present options.

---

## Step 7: Present Workflow State and Options

Load **[display-state.md](references/display-state.md)** and follow its instructions as written.

→ Proceed to **Step 8**.

---

## Step 8: Route by Plan State

Check whether the selected specification already has a plan (from `has_plan` in discovery output).

#### If no existing plan (fresh start)

→ Proceed to **Step 9** to gather context before invoking the skill.

#### If existing plan (continue or review)

The plan already has its context from when it was created. Skip context gathering.

→ Proceed to **Step 11** to invoke the skill.

---

## Step 9: Gather Additional Context

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Any additional context since the specification was concluded?

- **`c`/`continue`** — Continue with the specification as-is
- Or provide additional context (priorities, constraints, new considerations)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 10**.

---

## Step 10: Surface Cross-Cutting Context (Discovery Mode)

Load **[cross-cutting-context.md](references/cross-cutting-context.md)** and follow its instructions as written.

→ Proceed to **Step 11**.

---

## Step 11: Invoke the Skill (Discovery Mode)

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.
