---
name: workflow:bridge
description: "Pipeline continuation bridge. Enters plan mode with deterministic instructions to invoke continue-{work_type} for a topic. Called by processing skills at phase conclusion."
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

Enter plan mode and write the following plan:

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
- Expected routing: continue-{work_type} will detect next phase from artifact state

## How to proceed

Clear context and continue. Claude will invoke the appropriate
continue-* skill with the topic above and route to the next phase automatically.
```

Exit plan mode. The user will approve and clear context, and the fresh session will pick up with the continue-* skill routing to the correct phase.
