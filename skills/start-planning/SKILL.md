---
name: start-planning
description: "Start a planning session. Supports two modes: discovery mode (bare invocation) discovers specifications and offers planning options; bridge mode (topic provided) skips discovery for pipeline continuation."
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

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided (bridge mode)

Pipeline continuation — skip discovery and proceed directly to validation.

→ Proceed to **Step 2** (Validate Specification).

#### If only topic is provided

Set work_type based on context:
- If invoked from a bugfix pipeline → work_type = "bugfix"
- If invoked from a feature pipeline → work_type = "feature"
- If unclear, default to "greenfield"

→ Proceed to **Step 2** (Validate Specification).

#### If no topic provided (discovery mode)

Full discovery and selection flow.

→ Load **[discovery-flow.md](references/discovery-flow.md)** and follow its instructions.

When discovery completes, it returns with selection context.

→ Proceed to **Step 4** (Route by Plan State).

---

## Step 2: Validate Specification

Bridge mode validation — check if specification exists and is ready.

```bash
ls .workflows/specification/
```

Read `.workflows/specification/{topic}/specification.md` frontmatter.

**If specification doesn't exist:**

> *Output the next fenced block as a code block:*

```
Specification Missing

No specification found for "{topic:(titlecase)}".

A concluded specification is required for planning.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` with topic.

**If specification exists but status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Specification In Progress

The specification for "{topic:(titlecase)}" is not yet concluded.
Complete the specification first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` with topic to continue.

**If specification exists and status is "concluded":**

Run discovery to get cross-cutting context:

```bash
.claude/skills/start-planning/scripts/discovery.sh
```

Parse cross-cutting specs from `specifications.crosscutting`.

→ Proceed to **Step 3**.

---

## Step 3: Handle Cross-Cutting Context

Load **[cross-cutting-context.md](references/cross-cutting-context.md)** and follow its instructions as written.

→ Proceed to **Step 4**.

---

## Step 4: Route by Plan State

Check whether the topic already has a plan (from discovery or by checking `.workflows/planning/{topic}/plan.md`).

#### If no existing plan (fresh start)

→ Proceed to **Step 5** to gather context before invoking the skill.

#### If existing plan (continue or review)

The plan already has its context from when it was created. Skip context gathering.

→ Go directly to **Step 7** to invoke the skill.

---

## Step 5: Gather Additional Context

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Any additional context since the specification was concluded?

- **`c`/`continue`** — Continue with the specification as-is
- Or provide additional context (priorities, constraints, new considerations)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 6**.

---

## Step 6: Surface Cross-Cutting Context (Discovery Mode)

This step is only reached from discovery mode after gathering additional context.

Load **[cross-cutting-context.md](references/cross-cutting-context.md)** and follow its instructions as written.

→ Proceed to **Step 7**.

---

## Step 7: Invoke the Skill

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-planning/SKILL.md" \
  ".workflows/planning/{topic}/plan.md"
```

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.
