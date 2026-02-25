---
name: start-implementation
description: "Start an implementation session. Supports two modes: discovery mode (bare invocation) discovers plans and offers options; bridge mode (topic provided) skips discovery for pipeline continuation."
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

## Step 1: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided (bridge mode)

Pipeline continuation — skip discovery and proceed directly to validation.

→ Proceed to **Step 2** (Validate Plan).

#### If only topic is provided

Set work_type based on context:
- If invoked from a bugfix pipeline → work_type = "bugfix"
- If invoked from a feature pipeline → work_type = "feature"
- If unclear, default to "greenfield"

→ Proceed to **Step 2** (Validate Plan).

#### If no topic provided (discovery mode)

Full discovery and selection flow.

→ Load **[discovery-flow.md](references/discovery-flow.md)** and follow its instructions.

When discovery completes, it returns with selected topic.

→ Proceed to **Step 4** (Check External Dependencies).

---

## Step 2: Validate Plan

Bridge mode validation — check if plan exists and is ready.

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

→ Proceed to **Step 3**.

---

## Step 3: Run Discovery for Context

Run discovery to get dependency and environment information:

```bash
.claude/skills/start-implementation/scripts/discovery.sh
```

Parse the output to extract for the selected topic:
- `external_deps`, `has_unresolved_deps`
- `deps_satisfied`, `deps_blocking`
- `environment.setup_file_exists`, `environment.requires_setup`
- `format`, `plan_id`, `specification`, `specification_exists`

→ Proceed to **Step 4**.

---

## Step 4: Check External Dependencies

**This step is a confirmation gate.** Dependencies have been pre-analyzed by the discovery script.

#### If all deps satisfied (or no deps)

> *Output the next fenced block as a code block:*

```
External dependencies satisfied.
```

→ Proceed to **Step 5**.

#### If any deps are blocking

> *Output the next fenced block as a code block:*

```
Missing Dependencies

Unresolved (not yet planned):
  • {topic}: {description}
    No plan exists. Create with /start-planning or mark as
    satisfied externally.

Incomplete (planned but not implemented):
  • {topic}: {plan}:{task-id} not yet completed
    This task must be completed first.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`i`/`implement`** — Implement the blocking dependencies first
- **`l`/`link`** — Run /link-dependencies to wire up recently completed plans
- **`s`/`satisfied`** — Mark a dependency as satisfied externally
- **`c`/`continue`** — Continue anyway (at your own risk)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If `implement`, suggest running `/start-implementation` for the blocking topic. If `satisfied`, update the plan frontmatter (`state: satisfied_externally`) and continue. If `continue`, proceed.

→ Proceed to **Step 5**.

---

## Step 5: Check Environment Setup

> **IMPORTANT**: This step is for **information gathering only**. Do NOT execute any setup commands at this stage.

Use the `environment` section from the discovery output:

**If `setup_file_exists: true` and `requires_setup: false`:**

> *Output the next fenced block as a code block:*

```
Environment: No special setup required.
```

→ Proceed to **Step 6**.

**If `setup_file_exists: true` and `requires_setup: true`:**

> *Output the next fenced block as a code block:*

```
Environment setup file found: .workflows/environment-setup.md
```

→ Proceed to **Step 6**.

**If `setup_file_exists: false` or `requires_setup: unknown`:**

> *Output the next fenced block as a code block:*

```
Are there any environment setup instructions I should follow before implementation?
(Or "none" if no special setup is needed)
```

**STOP.** Wait for user response.

- If the user provides instructions, save them to `.workflows/environment-setup.md`, commit
- If the user says no/none, create `.workflows/environment-setup.md` with "No special setup required." and commit

→ Proceed to **Step 6**.

---

## Step 6: Invoke the Skill

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

Determine the implementation tracking state:
- If a tracking file exists for this topic → use its status
- If no tracking file → status is "not-started"

Invoke the [technical-implementation](../technical-implementation/SKILL.md) skill:

```
Implementation session for: {topic}
Plan: .workflows/planning/{topic}/plan.md
Format: {format}
Plan ID: {plan_id} (if applicable)
Specification: .workflows/specification/{topic}/specification.md (exists: {true|false})
Implementation tracking: {exists | new} (status: {status})

Dependencies: {All satisfied | List any notes}
Environment: {Setup required | No special setup required}

Invoke the technical-implementation skill.
```
