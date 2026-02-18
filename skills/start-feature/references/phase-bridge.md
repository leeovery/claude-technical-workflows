# Phase Bridge

*Reference for **[start-feature](../SKILL.md)***

---

The phase bridge clears context between the discussion phase and the rest of the pipeline. This is necessary because discussion can consume significant context, and starting fresh prevents degradation.

## Enter Plan Mode

Enter plan mode and write the following plan:

```
# Continue Feature: {topic}

The discussion for "{topic}" has concluded. The next session should
continue the feature pipeline from specification onwards.

## Instructions

1. Invoke the `/continue-feature` skill for topic "{topic}"
2. The skill will detect that a concluded discussion exists and route to specification

## Context

- Topic: {topic}
- Completed phase: discussion
- Expected next phase: specification
- Discussion: docs/workflow/discussion/{topic}.md

## How to proceed

Clear context and continue. Claude will invoke continue-feature
with the topic above and route to the specification phase automatically.
```

Exit plan mode. The user will approve and clear context, and the fresh session will pick up with continue-feature routing to specification.
