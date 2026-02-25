---
name: start-review
description: "Start a review session. Supports two modes: discovery mode (bare invocation) discovers plans and offers review options; bridge mode (topic provided) skips discovery for pipeline continuation."
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

## Step 1: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided (bridge mode)

Pipeline continuation — skip discovery and proceed directly to validation.

→ Proceed to **Step 2** (Validate Implementation).

#### If only topic is provided

Set work_type based on context:
- If invoked from a bugfix pipeline → work_type = "bugfix"
- If invoked from a feature pipeline → work_type = "feature"
- If unclear, default to "greenfield"

→ Proceed to **Step 2** (Validate Implementation).

#### If no topic provided (discovery mode)

Full discovery and selection flow.

→ Load **[discovery-flow.md](references/discovery-flow.md)** and follow its instructions.

When discovery completes, it returns with selection context.

→ Proceed to **Step 4** (Invoke the Skill).

---

## Step 2: Validate Implementation

Bridge mode validation — check if plan and implementation exist.

```bash
ls .workflows/planning/
```

```bash
ls .workflows/implementation/
```

Read `.workflows/planning/{topic}/plan.md` frontmatter.

**If plan doesn't exist:**

> *Output the next fenced block as a code block:*

```
Plan Missing

No plan found for "{topic:(titlecase)}".

A plan is required before review can be performed.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic.

Check `.workflows/implementation/{topic}/tracking.md`:

**If implementation tracking doesn't exist or status is "not-started":**

> *Output the next fenced block as a code block:*

```
Implementation Missing

"{topic:(titlecase)}" has no implementation to review.

Implementation must be completed or in-progress before review.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-implementation` with topic.

**If implementation exists:**

→ Proceed to **Step 3**.

---

## Step 3: Determine Review Version

Run discovery to get review state:

```bash
.claude/skills/start-review/scripts/discovery.sh
```

Parse the output to find the topic's review state:
- `review_count` - number of existing reviews
- `latest_review_version` - most recent review version number

Determine review version:
- If `review_count` is 0 → review version is `r1`
- If `review_count` > 0 → review version is `r{latest_review_version + 1}`

Also extract:
- `format`, `plan_id`, `specification`, `specification_exists`

→ Proceed to **Step 4**.

---

## Step 4: Invoke the Skill

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-review/SKILL.md" \
  ".workflows/review/{topic}/r{N}/review.md"
```

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.
