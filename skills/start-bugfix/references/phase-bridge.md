# Phase Bridge

*Reference for **[start-bugfix](../SKILL.md)***

---

The phase bridge clears context between the investigation phase and the rest of the pipeline. This is necessary because investigation can consume significant context, and starting fresh prevents degradation.

## Enter Plan Mode

Enter plan mode and write the following plan:

```
# Continue Bugfix: {topic}

The investigation for "{topic}" has concluded. The next session should
continue the bugfix pipeline from specification onwards.

## Instructions

1. Invoke the `/continue-bugfix` skill for topic "{topic}"
2. The skill will detect that a concluded investigation exists and route to specification

## Context

- Topic: {topic}
- Work type: bugfix
- Completed phase: investigation
- Expected next phase: specification
- Investigation: .workflows/investigation/{topic}/investigation.md

## How to proceed

Clear context and continue. Claude will invoke continue-bugfix
with the topic above and route to the specification phase automatically.
```

Exit plan mode. The user will approve and clear context, and the fresh session will pick up with continue-bugfix routing to specification.
