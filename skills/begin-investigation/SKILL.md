---
name: begin-investigation
description: "Bridge skill for bugfix pipeline. Gathers bug context and invokes the technical-investigation skill. Called by continue-bugfix or workflow:start — not directly by users."
user-invocable: false
allowed-tools: Bash(ls .workflows/investigation/), Bash(.claude/hooks/workflows/write-session-state.sh)
---

Invoke the **technical-investigation** skill for this conversation with pre-flight context.

> **ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

This skill is a **bridge** — it gathers initial context for a bug investigation and hands off to the processing skill. The topic and work_type have already been determined by the caller.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 1: Validate Topic

The caller provides:
- **Topic**: The bug/investigation topic name
- **Work type**: bugfix (always for investigation)

Check if an investigation already exists for this topic:

```bash
ls .workflows/investigation/
```

#### If investigation exists for this topic

Check the investigation status. Read `.workflows/investigation/{topic}/investigation.md` frontmatter.

If status is "in-progress":

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

If resume → invoke technical-investigation with the existing topic.
If new → ask for a new topic name, then continue.

If status is "concluded":

> *Output the next fenced block as a code block:*

```
Investigation Concluded

The investigation for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/continue-bugfix` to continue to specification.

#### If no collision

→ Proceed to **Step 2**.

---

## Step 2: Gather Bug Context

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

→ Proceed to **Step 3**.

---

## Step 3: Invoke the Skill

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

Construct the handoff and invoke the [technical-investigation](../technical-investigation/SKILL.md) skill:

```
Investigation session for: {topic}
Work type: bugfix
Initial bug context: {summary of user's input from Step 2}

Create investigation file: .workflows/investigation/{topic}/investigation.md

The investigation frontmatter should include:
- topic: {topic}
- status: in-progress
- work_type: bugfix
- date: {today}

Invoke the technical-investigation skill.
```
