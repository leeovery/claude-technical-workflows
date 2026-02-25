# Phase Bridge

*Reference for **[start-feature](../SKILL.md)***

---

The phase bridge clears context between phases. This is necessary because processing skills can consume significant context, and starting fresh prevents degradation.

## Determine Completed Phase

Check which phase just concluded:
- If research file exists with `status: concluded` and no discussion exists → completed_phase is **research**
- If discussion file exists with `status: concluded` → completed_phase is **discussion**

## Invoke Workflow Bridge

Invoke the [workflow:bridge](../../workflow/bridge/SKILL.md) skill:

```
Pipeline bridge for: {topic}
Work type: feature
Completed phase: {completed_phase}

Invoke the workflow:bridge skill to enter plan mode with continuation instructions.
```

The workflow:bridge skill will run discovery, detect the next phase, and enter plan mode with instructions to invoke the appropriate start-{phase} skill with the topic and work_type.
