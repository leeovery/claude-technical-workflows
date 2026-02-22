---
name: begin-specification
description: "Bridge skill for pipelines. Validates source material and invokes the technical-specification skill. Called by continue-* or workflow:start — not directly by users."
user-invocable: false
allowed-tools: Bash(.claude/skills/start-specification/scripts/discovery.sh), Bash(.claude/hooks/workflows/write-session-state.sh)
---

Invoke the **technical-specification** skill for this conversation with pre-flight context.

> **ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

This skill is a **bridge** — it validates source material for a specification and hands off to the processing skill. The topic and work_type have already been determined by the caller.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 1: Run Discovery

```bash
.claude/skills/start-specification/scripts/discovery.sh
```

Parse the output to understand:

**From `discussions` section:**
- Which discussions exist and their status

**From `specifications` section:**
- Which specifications exist and their status

The caller provided the topic. Check if:
1. A concluded discussion exists for this topic (for feature/greenfield)
2. A concluded investigation exists for this topic (for bugfix)
3. A specification already exists for this topic

→ Proceed to **Step 2**.

---

## Step 2: Validate Source Material

The caller provides:
- **Topic**: The specification topic name
- **Work type**: greenfield, feature, or bugfix

#### For greenfield or feature work_type

Check `.workflows/discussion/{topic}.md`:
- If exists and concluded → use as primary source
- If exists and in-progress → error, discussion not ready
- If not exists → error, no source material

#### For bugfix work_type

Check `.workflows/investigation/{topic}/investigation.md`:
- If exists and concluded → use as primary source
- If exists and in-progress → error, investigation not ready
- If not exists → error, no source material

#### If source material not ready

> *Output the next fenced block as a code block:*

```
Source Material Not Ready

@if(work_type is feature or greenfield)
The discussion for "{topic:(titlecase)}" is not concluded.
Complete the discussion first with /start-discussion.
@else
The investigation for "{topic:(titlecase)}" is not concluded.
Complete the investigation first with /start-investigation.
@endif
```

**STOP.** Do not proceed — terminal condition.

#### If specification already exists

Check `.workflows/specification/{topic}/specification.md`:

If status is "in-progress":

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

If resume → invoke technical-specification with the existing topic.
If start-fresh → archive the existing spec, then continue.

If status is "concluded":

> *Output the next fenced block as a code block:*

```
Specification Concluded

The specification for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-planning` to continue to planning.

#### If source material is ready

→ Proceed to **Step 3**.

---

## Step 3: Load Cross-Cutting Context

Check for cross-cutting specifications that may apply.

Load **[../start-planning/references/cross-cutting-context.md](../start-planning/references/cross-cutting-context.md)** and follow its instructions.

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

Cross-cutting references: {list of applicable cross-cutting specs, or "none"}

The specification frontmatter should include:
- topic: {topic}
- status: in-progress
- type: feature
- work_type: {work_type}
- date: {today}

Invoke the technical-specification skill.
```
