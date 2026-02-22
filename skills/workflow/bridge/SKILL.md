---
name: workflow:bridge
description: "Pipeline continuation bridge. Enters plan mode with deterministic instructions to invoke continue-{work_type}. Called by processing skills at phase conclusion."
user-invocable: false
---

Enter plan mode with deterministic continuation instructions.

This skill is invoked by processing skills (technical-discussion, technical-specification, etc.) when a pipeline phase concludes. It creates a plan mode handoff that survives context compaction.

## Instructions

This skill receives:
- **Topic**: The topic name
- **Work type**: greenfield, feature, or bugfix
- **Completed phase**: The phase that just concluded

## Enter Plan Mode

The plan content differs based on work type:

#### If work type is "feature" or "bugfix"

These are topic-centric, linear pipelines. The plan includes the topic for routing.

```
# Continue Pipeline: {topic}

The {completed_phase} phase for "{topic}" has concluded.
The next session should continue the pipeline.

## Instructions

1. Invoke `/continue-{work_type}` for topic "{topic}"
2. The skill will detect the current phase and route accordingly

## Context

- Topic: {topic}
- Work type: {work_type}
- Completed phase: {completed_phase}

## How to proceed

Clear context and continue. Claude will invoke continue-{work_type}
with the topic above and route to the next phase automatically.
```

#### If work type is "greenfield"

Greenfield is phase-centric, not topic-centric. The plan invokes continue-greenfield without a specific topic — it will do full discovery and present options.

```
# Continue Greenfield

The {completed_phase} phase for "{topic}" has concluded.
The next session should assess what's actionable across all phases.

## Instructions

1. Invoke `/continue-greenfield`
2. The skill will discover state across all phases and present options

## Context

- Just completed: {completed_phase} for "{topic}"
- Work type: greenfield (phase-centric)

## How to proceed

Clear context and continue. Claude will invoke continue-greenfield
which will show what's actionable and let you choose the next step.
```

Exit plan mode. The user will approve and clear context, and the fresh session will pick up with the continue-* skill.
