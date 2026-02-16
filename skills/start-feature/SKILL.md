---
name: start-feature
description: "Start a new feature through the full pipeline. Gathers context via structured interview, creates a discussion, then bridges to continue-feature for specification, planning, and implementation."
disable-model-invocation: true
allowed-tools: Bash(ls docs/workflow/discussion/)
---

Start a new feature and route it through the pipeline: Discussion → Specification → Planning → Implementation.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Even if the user's initial prompt seems to answer a question, still confirm with them at the appropriate step
- Complete each step fully before moving to the next

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Gather Feature Context

**Recovery checkpoint**: If context was compacted, check for a discussion file matching the topic (`docs/workflow/discussion/{topic}.md`).

#### If discussion exists with `status: concluded`

→ Skip to **Step 4**.

#### If discussion exists with `status: in-progress`

→ Skip to **Step 3** to resume.

#### If no topic is known or no discussion exists

Load **[gather-feature-context.md](references/gather-feature-context.md)** and follow its instructions.

→ Proceed to **Step 2**.

---

## Step 2: Topic Name and Conflict Check

Based on the feature description, suggest a topic name:

> *Output the next fenced block as a code block:*

```
Suggested topic name: {suggested-topic:(kebabcase)}

This will create: docs/workflow/discussion/{suggested-topic}.md
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Is this name okay, or would you prefer something else?
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

Once the topic name is confirmed, check for naming conflicts:

```bash
ls docs/workflow/discussion/
```

If a discussion with the same name exists, inform the user:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
A discussion named "{topic}" already exists.

- **`r`/`resume`** — Resume the existing discussion
- **`n`/`new`** — Choose a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resuming, check the discussion status. If concluded → skip to Step 4. If in-progress → proceed to Step 3.

→ Proceed to **Step 3**.

---

## Step 3: Invoke Discussion

Load **[invoke-discussion.md](references/invoke-discussion.md)** and follow its instructions.

After the discussion concludes (status becomes "concluded"):

→ Proceed to **Step 4**.

**Recovery checkpoint**: If context was compacted, check `docs/workflow/discussion/{topic}.md`. If `status: concluded` → proceed to Step 4. If `status: in-progress` → resume discussion.

---

## Step 4: Phase Bridge

Load **[phase-bridge.md](references/phase-bridge.md)** and follow its instructions.

The bridge will enter plan mode with instructions to invoke continue-feature for the topic in the next session.
