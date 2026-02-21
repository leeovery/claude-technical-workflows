---
name: begin-planning
description: "Bridge skill for the feature pipeline. Runs pre-flight checks for planning and invokes the technical-planning skill. Called by continue-feature — not directly by users."
user-invocable: false
allowed-tools: Bash(.claude/skills/start-planning/scripts/discovery.sh)
---

Invoke the **technical-planning** skill for this conversation with pre-flight context.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

This skill is a **bridge** — it runs pre-flight checks for planning and hands off to the processing skill. The topic has already been selected by the caller.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 1: Run Discovery

!`.claude/skills/start-planning/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-planning/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the output to extract:

- **Cross-cutting specifications** from `specifications.crosscutting` (name, status)
- **Common format** from `plans.common_format`

The topic was provided by the caller. Confirm the specification exists and is concluded:

- Check `specifications.feature` for the topic
- If the spec is missing or not concluded, this is an error — report it and stop

→ Proceed to **Step 2**.

---

## Step 2: Handle Cross-Cutting Context

Load **[cross-cutting-context.md](../start-planning/references/cross-cutting-context.md)** and follow its instructions as written.

→ Proceed to **Step 3**.

---

## Step 3: Gather Additional Context

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Any additional context for planning?

- **`c`/`continue`** — Continue with the specification as-is
- Or provide additional context (priorities, constraints, new considerations)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 4**.

---

## Step 4: Invoke the Skill

Construct the handoff and invoke the [technical-planning](../technical-planning/SKILL.md) skill:

```
Planning session for: {topic}
Specification: .workflows/specification/{topic}/specification.md
Work type: feature
Additional context: {summary of user's answer from Step 3, or "none"}
Cross-cutting references: {list of applicable cross-cutting specs with brief summaries, or "none"}
Recommended output format: {common_format from discovery if non-empty, otherwise "none"}

Invoke the technical-planning skill.
```
