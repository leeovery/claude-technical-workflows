---
name: continue-feature
description: "Continue a feature through the pipeline. Routes to the next phase (specification, planning, or implementation) based on artifact state. Can be invoked manually or from plan mode bridges."
allowed-tools: Bash(.claude/skills/continue-feature/scripts/discovery.sh), Bash(.claude/hooks/workflows/write-session-state.sh), Bash(.claude/skills/start-review/scripts/discovery.sh)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Route a feature to its next pipeline phase.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Resuming After Context Refresh

Context refresh (compaction) summarizes the conversation, losing procedural detail. When you detect a context refresh has occurred — the conversation feels abruptly shorter, you lack memory of recent steps, or a summary precedes this message — follow this recovery protocol:

1. **Re-read this skill file completely.** Do not rely on your summary of it. The full process, steps, and rules must be reloaded.
2. **Identify the topic.** Check conversation history for the topic name. If unknown, ask the user.
3. **Determine current step from artifacts** (check top-down, first match wins):
   - Review exists for topic → resume at **Step 7** (phase bridge — pipeline complete)
   - Implementation tracking exists with `status: completed`, no review → resume at **Step 6** (invoke begin-review)
   - Implementation tracking exists with `status: in-progress` → resume at **Step 5** (re-invoke begin-implementation)
   - Plan exists with `status: concluded` → resume at **Step 5** (invoke begin-implementation)
   - Plan exists with other status → resume at **Step 4** (re-invoke begin-planning)
   - Specification exists with `status: concluded` → resume at **Step 4** (invoke begin-planning)
   - Specification exists with other status → resume at **Step 3** (re-invoke technical-specification)
   - Discussion exists with `status: concluded` → resume at **Step 3** (invoke technical-specification)
   - Discussion exists with other status → terminal — suggest `/start-discussion`
4. **Announce your position** to the user before continuing: what step you believe you're at, what's been completed, and what comes next. Wait for confirmation.

Do not guess at progress or continue from memory. The files on disk and git history are authoritative — your recollection is not.

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Determine Topic

Check whether a topic was provided by the caller (e.g., from a plan mode bridge: "invoke continue-feature for {topic}").

#### If topic was provided

Use the provided topic directly.

→ Proceed to **Step 2**.

#### If no topic provided (bare invocation)

Run the discovery script to gather current state:

```bash
.claude/skills/continue-feature/scripts/discovery.sh
```

Parse the output to understand:

**From `topics` array:** Each topic's name, discussion/specification/plan/implementation state, next_phase, and actionable flag.

**From `state` section:** topic_count, actionable_count, scenario.

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

#### If scenario is "no_topics"

> *Output the next fenced block as a code block:*

```
Continue Feature

No workflow topics found.

Start a new feature with /start-feature.
```

**STOP.** Do not proceed — terminal condition.

#### If topics exist

Present the discovered state as context, then ask the user to select:

> *Output the next fenced block as a code block:*

```
Continue Feature

This skill continues a feature through the pipeline phases:
Discussion → Specification → Planning → Implementation → Review

It's designed for features started with /start-feature, but works
with any topic that has workflow artifacts.

Topics found:

1. {topic:(titlecase)}
   └─ Next: {next_phase}

2. ...
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Which topic would you like to continue?

Select by number, or enter a topic name directly:
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 2**.

---

## Step 2: Detect Phase and Route

Load **[detect-phase.md](references/detect-phase.md)** and follow its instructions.

→ The reference file will route you to **Step 3**, **Step 4**, **Step 5**, **Step 6**, or a terminal condition. Follow its routing.

---

## Step 3: Specification Phase

Load **[invoke-specification.md](references/invoke-specification.md)** and follow its instructions.

**CRITICAL**: When the specification concludes (status becomes "concluded"), you MUST proceed to **Step 7** below. Do not end the session — the feature pipeline continues to the phase bridge.

---

## Step 4: Planning Phase

Load **[invoke-planning.md](references/invoke-planning.md)** and follow its instructions.

**CRITICAL**: When the plan concludes (status becomes "concluded"), you MUST proceed to **Step 7** below. Do not end the session — the feature pipeline continues to the phase bridge.

---

## Step 5: Implementation Phase

Load **[invoke-implementation.md](references/invoke-implementation.md)** and follow its instructions.

**CRITICAL**: When implementation completes (tracking status becomes "completed"), you MUST proceed to **Step 7** below. Do not end the session — the feature pipeline continues to the phase bridge.

---

## Step 6: Review Phase

Load **[invoke-review.md](references/invoke-review.md)** and follow its instructions.

**CRITICAL**: When review concludes, you MUST proceed to **Step 7** below. Do not end the session — the feature pipeline continues to the phase bridge.

---

## Step 7: Phase Bridge

Load **[phase-bridge.md](references/phase-bridge.md)** and follow its instructions.

The bridge will enter plan mode with instructions to invoke continue-feature for the topic in the next session, or show a terminal message if the pipeline is complete.
