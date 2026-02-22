---
name: start-investigation
description: "Start a bug investigation. Discovers existing investigations, gathers bug context, and invokes the technical-investigation skill."
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-investigation/scripts/discovery.sh), Bash(.claude/hooks/workflows/write-session-state.sh)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Invoke the **technical-investigation** skill for this conversation.

> **ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Workflow Context

This is **Phase 1** of the bugfix pipeline:

| Phase              | Focus                                              | You    |
|--------------------|----------------------------------------------------|--------|
| **Investigation**  | Symptom gathering + code analysis → root cause     | ◀ HERE |
| 2. Specification   | REFINE - validate into fix specification           |        |
| 3. Planning        | HOW - phases, tasks, acceptance criteria           |        |
| 4. Implementation  | DOING - tests first, then code                     |        |
| 5. Review          | VALIDATING - check work against artifacts          |        |

**Stay in your lane**: Investigate the bug — gather symptoms, trace code, find root cause. Don't jump to fixing or implementing. This is the time for deep analysis.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Discovery State

```bash
.claude/skills/start-investigation/scripts/discovery.sh
```

Parse the discovery output to understand:

**From `investigations` section:**
- `exists` - whether investigation files exist
- `files` - each investigation's topic, status, and date
- `counts.in_progress` and `counts.concluded` - totals for routing

**From `state` section:**
- `scenario` - one of: `"fresh"`, `"has_investigations"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step 2**.

---

## Step 2: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "has_investigations"

> *Output the next fenced block as a code block:*

```
Investigations Overview

@if(investigations.counts.in_progress > 0)
In Progress:
{foreach inv in investigations.files where status is in-progress}
  • {inv.topic}
{/foreach}
@endif

@if(investigations.counts.concluded > 0)
Concluded:
{foreach inv in investigations.files where status is concluded}
  • {inv.topic}
{/foreach}
@endif
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

@if(in_progress investigations exist)
{N}. Resume "{topic}" investigation
{/foreach}
@endif
{N}. Start new investigation
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resuming → proceed with that topic to Step 4.
If new → proceed to Step 3.

#### If scenario is "fresh"

> *Output the next fenced block as a code block:*

```
No existing investigations found.
```

→ Proceed to **Step 3**.

---

## Step 3: Gather Bug Context

> *Output the next fenced block as a code block:*

```
Starting new investigation.

What bug are you investigating? Please provide:
- A short identifier/name for tracking (e.g., "login-timeout-bug")
- What's broken (expected vs actual behavior)
- Any initial context (error messages, how it manifests)
```

**STOP.** Wait for user response.

→ Proceed to **Step 4**.

---

## Step 4: Topic Name and Conflict Check

If the user didn't provide a clear topic name, suggest one based on the bug description:

> *Output the next fenced block as a code block:*

```
Suggested topic name: {suggested-topic:(kebabcase)}

This will create: .workflows/investigation/{suggested-topic}/investigation.md
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Is this name okay?

- **`y`/`yes`** — Use this name
- **`s`/`something else`** — Suggest a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

Once the topic name is confirmed, check for naming conflicts in the discovery output.

If an investigation with the same name exists, inform the user:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
An investigation named "{topic}" already exists.

- **`r`/`resume`** — Resume the existing investigation
- **`n`/`new`** — Choose a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resuming, check the investigation status. If concluded → suggest continue-bugfix. If in-progress → proceed to Step 5.

→ Proceed to **Step 5**.

---

## Step 5: Invoke the Skill

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-investigation/SKILL.md" \
  ".workflows/investigation/{topic}/investigation.md"
```

Invoke the [technical-investigation](../technical-investigation/SKILL.md) skill:

```
Investigation session for: {topic}
Work type: bugfix
Initial bug context: {summary of user's input from Step 3}

Create investigation file: .workflows/investigation/{topic}/investigation.md

The investigation frontmatter should include:
- topic: {topic}
- status: in-progress
- work_type: bugfix
- date: {today}

Invoke the technical-investigation skill.
```
