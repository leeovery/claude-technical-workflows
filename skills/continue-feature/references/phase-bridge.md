# Phase Bridge

*Reference for **[continue-feature](../SKILL.md)***

---

The phase bridge clears context between pipeline phases using plan mode. This is necessary because each phase can consume significant context, and starting fresh prevents degradation.

## Determine Next Phase

Check which step just completed to determine what continue-feature will route to next:

- Just completed **specification** (Step 3) → next session routes to planning
- Just completed **planning** (Step 4) → next session routes to implementation
- Just completed **implementation** (Step 5) → next session routes to review
- Just completed **review** (Step 6) → pipeline is done

#### If review just completed

> *Output the next fenced block as a code block:*

```
Feature Complete

"{topic:(titlecase)}" has completed all pipeline phases.
```

**STOP.** Do not proceed — terminal condition.

## Enter Plan Mode

Enter plan mode and write the following plan:

```
# Continue Feature: {topic}

The previous phase for "{topic}" has concluded. The next session should
continue the feature pipeline.

## Instructions

1. Invoke the `/continue-feature` skill for topic "{topic}"
2. The skill will detect the current phase and route accordingly

## Context

- Topic: {topic}
- Previous phase: {phase that just completed}
- Expected next phase: {next phase based on routing above}

## How to proceed

Clear context and continue. Claude will invoke continue-feature
with the topic above and route to the next phase automatically.
```

Exit plan mode. The user will approve and clear context, and the fresh session will pick up with continue-feature routing to the correct phase.
