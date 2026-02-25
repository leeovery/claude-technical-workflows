---
name: start-investigation
description: "Start a bug investigation. Supports two modes: discovery mode (bare invocation) discovers existing investigations; bridge mode (topic provided) skips discovery for pipeline continuation."
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-investigation/scripts/discovery.sh), Bash(.claude/hooks/workflows/write-session-state.sh), Bash(ls .workflows/investigation/)
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

## Step 1: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided (bridge mode)

Pipeline continuation — skip discovery and proceed directly to validation.

→ Proceed to **Step 2** (Validate Topic).

#### If only topic is provided

Set work_type = "bugfix" (always for investigation).

→ Proceed to **Step 2** (Validate Topic).

#### If no topic provided (discovery mode)

Full discovery and selection flow.

→ Load **[discovery-flow.md](references/discovery-flow.md)** and follow its instructions.

When discovery completes, it returns with a selected topic and context.

→ Proceed to **Step 4** (Invoke the Skill).

---

## Step 2: Validate Topic

Bridge mode validation — check if investigation already exists for this topic.

```bash
ls .workflows/investigation/
```

#### If investigation exists for this topic

Read `.workflows/investigation/{topic}/investigation.md` frontmatter to check status.

**If status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Investigation In Progress

An investigation for "{topic:(titlecase)}" already exists and is in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`resume`** — Resume the existing investigation
- **`n`/`new`** — Start a new investigation with a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resume → proceed to **Step 4**.
If new → ask for a new topic name, then proceed to **Step 2** with new topic.

**If status is "concluded":**

> *Output the next fenced block as a code block:*

```
Investigation Concluded

The investigation for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` with topic + bugfix to continue to specification.

#### If no collision

→ Proceed to **Step 3**.

---

## Step 3: Gather Bug Context (Bridge Mode)

> *Output the next fenced block as a code block:*

```
Starting investigation: {topic:(titlecase)}

What's the bug? Provide initial context:
- What's broken? (expected vs actual behavior)
- How is it surfacing? (errors, user reports, monitoring)
- Can you reproduce it? (steps to reproduce)
- Any initial hypotheses?
- Links to error tracking? (Sentry, logs, etc.)
```

**STOP.** Wait for user response.

→ Proceed to **Step 4** (Invoke the Skill).

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
  "skills/technical-investigation/SKILL.md" \
  ".workflows/investigation/{topic}/investigation.md"
```

Invoke the [technical-investigation](../technical-investigation/SKILL.md) skill:

```
Investigation session for: {topic}
Work type: bugfix
Initial bug context: {summary of user's input from Step 3 or discovery}

Create investigation file: .workflows/investigation/{topic}/investigation.md

The investigation frontmatter should include:
- topic: {topic}
- status: in-progress
- work_type: bugfix
- date: {today}

Invoke the technical-investigation skill.
```
