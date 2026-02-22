---
name: begin-research
description: "Bridge skill for pipelines. Gathers research context and invokes the technical-research skill. Called by continue-* or workflow:start — not directly by users."
user-invocable: false
allowed-tools: Bash(.claude/hooks/workflows/write-session-state.sh)
---

Invoke the **technical-research** skill for this conversation with pre-flight context.

> **ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

This skill is a **bridge** — it gathers context for research and hands off to the processing skill. The caller may optionally provide a topic and work_type.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 1: Determine Research Type

The caller may provide:
- **Topic**: Optional - for feature-specific research
- **Work type**: greenfield, feature, or bugfix

#### If topic is provided (feature-specific research)

This is research for a specific feature. The research file will be:
`.workflows/research/{topic}.md`

→ Proceed to **Step 2**.

#### If no topic (greenfield exploration)

This is general exploration. Use the existing convention:
`.workflows/research/exploration.md`

→ Proceed to **Step 2**.

---

## Step 2: Gather Research Questions

> *Output the next fenced block as a code block:*

```
@if(topic provided)
Research: {topic:(titlecase)}
Work type: {work_type}

What questions or uncertainties do you want to explore?
@else
Research Exploration

What would you like to explore? Consider:
- Technical feasibility questions
- Market or business viability
- Architecture options
- Risk areas to investigate
@endif
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
  "{topic_or_exploration}" \
  "skills/technical-research/SKILL.md" \
  ".workflows/research/{topic_or_exploration}.md"
```

Construct the handoff and invoke the [technical-research](../technical-research/SKILL.md) skill:

```
Research session for: {topic if provided, otherwise "exploration"}
Work type: {work_type}
Research questions: {summary of user's input from Step 2}

@if(topic provided)
Research file: .workflows/research/{topic}.md
This is feature-specific research that may inform a discussion.
@else
Research file: .workflows/research/exploration.md
This is general exploration for greenfield development.
@endif

The research frontmatter should include:
@if(topic provided)
- topic: {topic}
@endif
- work_type: {work_type}
- date: {today}

Invoke the technical-research skill.
```
