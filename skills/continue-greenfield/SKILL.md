---
name: continue-greenfield
description: "Continue greenfield development. Discovers phase state, suggests next actionable work, and routes to the appropriate skill."
allowed-tools: Bash(.claude/skills/continue-greenfield/scripts/discovery.sh)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Route greenfield development to the next actionable phase.

> **ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Resuming After Context Refresh

Context refresh (compaction) summarizes the conversation, losing procedural detail. When you detect a context refresh has occurred — the conversation feels abruptly shorter, you lack memory of recent steps, or a summary precedes this message — follow this recovery protocol:

1. **Re-read this skill file completely.** Do not rely on your summary of it.
2. **Run discovery again** to get current state.
3. **Announce your position** to the user before continuing. Wait for confirmation.

Do not guess at progress or continue from memory. The files on disk are authoritative.

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Run Discovery

```bash
.claude/skills/continue-greenfield/scripts/discovery.sh
```

Parse the output to understand the current greenfield state:

**From `research` section:** Research files that exist

**From `discussions` section:** Discussions with their status

**From `specifications` section:** Specifications with their status

**From `plans` section:** Plans with their status

**From `implementation` section:** Implementations with their status

**From `state` section:** Phase counts and what's actionable

→ Proceed to **Step 2**.

---

## Step 2: Present State and Options

Load **[present-state.md](references/present-state.md)** and follow its instructions.

The reference will present the current greenfield state and ask what the user wants to do next.

→ Proceed to **Step 3** with the user's selection.

---

## Step 3: Route to Selection

Based on the user's selection, route to the appropriate skill:

| Selection | Action |
|-----------|--------|
| Continue a discussion | Invoke `begin-discussion` with topic + work_type: greenfield |
| Start specification from discussion | Invoke `begin-specification` with topic + work_type: greenfield |
| Continue a specification | Invoke `technical-specification` for topic |
| Start planning for spec | Invoke `begin-planning` with topic + work_type: greenfield |
| Continue a plan | Invoke `technical-planning` for topic |
| Start implementation | Invoke `begin-implementation` with topic + work_type: greenfield |
| Continue implementation | Invoke `technical-implementation` for topic |
| Start review | Invoke `begin-review` with topic + work_type: greenfield |
| Continue research | Invoke `technical-research` |
| Start research | Invoke `start-research` |
| Start new discussion | Invoke `start-discussion` with work_type: greenfield |

For skills that require a topic, pass:
- `Topic: {topic}`
- `Work type: greenfield`

For processing skills, the handoff should include pipeline continuation instructions to return here when done.
