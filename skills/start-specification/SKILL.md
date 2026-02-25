---
name: start-specification
description: "Start a specification session. Supports two modes: discovery mode (bare invocation) discovers discussions and offers consolidation; bridge mode (topic provided) skips discovery for pipeline continuation."
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-specification/scripts/discovery.sh), Bash(mkdir -p .workflows/.state), Bash(rm .workflows/.state/discussion-consolidation-analysis.md), Bash(.claude/hooks/workflows/write-session-state.sh), Bash(ls .workflows/discussion/), Bash(ls .workflows/investigation/)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Invoke the **technical-specification** skill for this conversation.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Workflow Context

This is **Phase 3** of the six-phase workflow:

| Phase                | Focus                                              | You    |
|----------------------|----------------------------------------------------|--------|
| 1. Research          | EXPLORE - ideas, feasibility, market, business     |        |
| 2. Discussion        | WHAT and WHY - decisions, architecture, edge cases |        |
| **3. Specification** | REFINE - validate into standalone spec             | ◀ HERE |
| 4. Planning          | HOW - phases, tasks, acceptance criteria           |        |
| 5. Implementation    | DOING - tests first, then code                     |        |
| 6. Review            | VALIDATING - check work against artifacts          |        |

**Stay in your lane**: Validate and refine discussion content into standalone specifications. Don't jump to planning, phases, tasks, or code. The specification is the "line in the sand" - everything after this has hard dependencies on it.

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

!`.claude/skills/start-specification/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-specification/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

**From `discussions` array:** Each discussion's name, status, and whether it has an individual specification.

**From `specifications` array:** Each specification's name, status, sources, and superseded_by (if applicable). Specifications with `status: superseded` should be noted but excluded from active counts.

**From `cache` section:** `status` (valid/stale/none), `reason`, `generated`, `anchored_names`.

**From `current_state`:** `concluded_count`, `spec_count`, `has_discussions`, `has_concluded`, `has_specs`, and other counts/booleans for routing.

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step 2**.

---

## Step 2: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided (bridge mode)

Pipeline continuation — skip discovery output and proceed directly to validation.

→ Proceed to **Step 3** (Validate Source Material).

#### If only topic is provided

Set work_type based on context:
- If invoked from a bugfix pipeline → work_type = "bugfix"
- If invoked from a feature pipeline → work_type = "feature"
- If unclear, default to "greenfield"

→ Proceed to **Step 3** (Validate Source Material).

#### If no topic provided (discovery mode)

Use the discovery output from Step 1 to check prerequisites and present options.

→ Proceed to **Step 6** (Check Prerequisites).

---

## Step 3: Validate Source Material

Bridge mode validation — check if source material exists and is ready.

#### For greenfield or feature work_type

Check if discussion exists and is concluded:

```bash
ls .workflows/discussion/
```

Read `.workflows/discussion/{topic}.md` frontmatter.

**If discussion doesn't exist:**

> *Output the next fenced block as a code block:*

```
Source Material Missing

No discussion found for "{topic:(titlecase)}".

A concluded discussion is required before specification.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-discussion` with topic.

**If discussion exists but status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Discussion In Progress

The discussion for "{topic:(titlecase)}" is not yet concluded.
Complete the discussion first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-discussion` with topic to continue.

**If discussion exists and status is "concluded":**

→ Proceed to **Step 4**.

#### For bugfix work_type

Check if investigation exists and is concluded:

```bash
ls .workflows/investigation/
```

Read `.workflows/investigation/{topic}/investigation.md` frontmatter.

**If investigation doesn't exist:**

> *Output the next fenced block as a code block:*

```
Source Material Missing

No investigation found for "{topic:(titlecase)}".

A concluded investigation is required before specification.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-investigation` with topic.

**If investigation exists but status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Investigation In Progress

The investigation for "{topic:(titlecase)}" is not yet concluded.
Complete the investigation first.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-investigation` with topic to continue.

**If investigation exists and status is "concluded":**

→ Proceed to **Step 4**.

---

## Step 4: Check Existing Specification

Check if a specification already exists for this topic.

Read `.workflows/specification/{topic}/specification.md` if it exists.

**If specification doesn't exist:**

→ Proceed to **Step 5** with verb="Creating".

**If specification exists with status "in-progress":**

> *Output the next fenced block as a code block:*

```
Specification In Progress

A specification for "{topic:(titlecase)}" already exists and is in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`resume`** — Resume the existing specification
- **`s`/`start-fresh`** — Archive and start fresh
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resume → proceed to **Step 5** with verb="Continuing".
If start-fresh → archive the existing spec, proceed to **Step 5** with verb="Creating".

**If specification exists with status "concluded":**

> *Output the next fenced block as a code block:*

```
Specification Concluded

The specification for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` with topic to continue to planning.

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
  "skills/technical-specification/SKILL.md" \
  ".workflows/specification/{topic}/specification.md"
```

Construct the handoff and invoke the [technical-specification](../technical-specification/SKILL.md) skill:

```
Specification session for: {topic}
Work type: {work_type}

Source material:
@if(work_type is feature or greenfield)
- Discussion: .workflows/discussion/{topic}.md
@else
- Investigation: .workflows/investigation/{topic}/investigation.md
@endif

Topic name: {topic}
Action: {verb} specification

The specification frontmatter should include:
- topic: {topic}
- status: in-progress
- type: feature
- work_type: {work_type}
- date: {today}

Invoke the technical-specification skill.
```

---

## Step 6: Check Prerequisites

Discovery mode — use the discovery output from Step 1 to check prerequisites.

#### If has_discussions is false or has_concluded is false

→ Load **[display-blocks.md](references/display-blocks.md)** and follow its instructions. **STOP.**

#### Otherwise

→ Proceed to **Step 7**.

---

## Step 7: Route Based on State

Based on discovery state, load exactly ONE reference file:

#### If concluded_count == 1

→ Load **[display-single.md](references/display-single.md)** and follow its instructions.

→ Proceed to **Step 8** with selection.

#### If cache status is "valid"

→ Load **[display-groupings.md](references/display-groupings.md)** and follow its instructions.

→ Proceed to **Step 8** with selection.

#### If spec_count == 0 and cache is "none" or "stale"

→ Load **[display-analyze.md](references/display-analyze.md)** and follow its instructions.

→ Proceed to **Step 8** with selection.

#### Otherwise

→ Load **[display-specs-menu.md](references/display-specs-menu.md)** and follow its instructions.

→ Proceed to **Step 8** with selection.

---

## Step 8: Invoke the Skill (Discovery Mode)

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-specification/SKILL.md" \
  ".workflows/specification/{topic}/specification.md"
```

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.
