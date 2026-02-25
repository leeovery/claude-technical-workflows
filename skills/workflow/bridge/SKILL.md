---
name: workflow:bridge
user-invocable: false
allowed-tools: Bash(.claude/skills/workflow/bridge/scripts/discovery.sh)
---

Enter plan mode with deterministic continuation instructions.

This skill is invoked by processing skills (technical-discussion, technical-specification, etc.) when a pipeline phase concludes. It discovers the next phase and creates a plan mode handoff that survives context compaction.

> **ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

## Instructions

This skill receives context from the calling processing skill:
- **Topic**: The topic name
- **Work type**: greenfield, feature, or bugfix
- **Completed phase**: The phase that just concluded

---

## Step 1: Run Discovery

Determine the next phase by running discovery.

#### If work type is "feature" or "bugfix"

Run topic-specific discovery:

```bash
.claude/skills/workflow/bridge/scripts/discovery.sh "{topic}" "{work_type}"
```

Parse the output to extract:
- `next_phase`: The computed next phase for this topic

#### If work type is "greenfield"

Run phase-centric discovery:

```bash
.claude/skills/workflow/bridge/scripts/discovery.sh --greenfield
```

Parse the output to extract:
- `state`: Counts of artifacts across all phases
- Phase-specific file lists with their statuses

→ Proceed to **Step 2**.

---

## Step 2: Route to Continuation Reference

Based on work type, load the appropriate continuation reference:

#### If work type is "feature"

→ Load **[feature-continuation.md](references/feature-continuation.md)** and follow its instructions.

#### If work type is "bugfix"

→ Load **[bugfix-continuation.md](references/bugfix-continuation.md)** and follow its instructions.

#### If work type is "greenfield"

→ Load **[greenfield-continuation.md](references/greenfield-continuation.md)** and follow its instructions.

---

## Notes

The continuation references will:
1. Use discovery output to determine routing
2. Enter plan mode with instructions to invoke `start-{next_phase}` with topic + work_type
3. Exit plan mode for user approval

The user will then clear context, and the fresh session will invoke the appropriate start-* skill with the topic and work_type provided, causing it to skip discovery and proceed directly to validation/processing.
