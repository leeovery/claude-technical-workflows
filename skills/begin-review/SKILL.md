---
name: begin-review
description: "Bridge skill for the feature pipeline. Runs pre-flight checks for review and invokes the technical-review skill. Called by continue-feature — not directly by users."
user-invocable: false
allowed-tools: Bash(.claude/skills/start-review/scripts/discovery.sh)
---

Invoke the **technical-review** skill for this conversation with pre-flight context.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them.

This skill is a **bridge** — it runs pre-flight checks for review and hands off to the processing skill. The topic has already been selected by the caller.

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Complete each step fully before moving to the next

---

## Step 1: Run Discovery

!`.claude/skills/start-review/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-review/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the output to find the plan matching the provided topic. Extract:

- **Plan details**: status, format, plan_id, specification, specification_exists
- **Implementation status**: implementation_status
- **Review state**: review_count, latest_review_version

If the plan is missing, this is an error — report it and stop.

If `implementation_status` is `"none"`, this is an error:

> *Output the next fenced block as a code block:*

```
Review Pre-Flight Failed

"{topic:(titlecase)}" has no implementation to review.

Implementation must be completed or in-progress before review.
```

**STOP.** Do not proceed — terminal condition.

→ Proceed to **Step 2**.

---

## Step 2: Determine Review Version

Check the topic's review state from discovery output:

- If `review_count` is 0 → review version is `r1`
- If `review_count` > 0 → review version is `r{latest_review_version + 1}`

→ Proceed to **Step 3**.

---

## Step 3: Invoke the Skill

Construct the handoff and invoke the [technical-review](../technical-review/SKILL.md) skill:

```
Review session
Plans to review:
  - topic: {topic}
    plan: .workflows/planning/{topic}/plan.md
    format: {format}
    plan_id: {plan_id} (if applicable)
    specification: {specification} (exists: {true|false})
    review_version: r{N}

Invoke the technical-review skill.
```
