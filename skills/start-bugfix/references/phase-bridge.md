# Phase Bridge

*Reference for **[start-bugfix](../SKILL.md)***

---

The phase bridge clears context between the investigation phase and the rest of the pipeline. This is necessary because investigation can consume significant context, and starting fresh prevents degradation.

## Invoke Workflow Bridge

Invoke the [workflow:bridge](../../workflow/bridge/SKILL.md) skill:

```
Pipeline bridge for: {topic}
Work type: bugfix
Completed phase: investigation

Invoke the workflow:bridge skill to enter plan mode with continuation instructions.
```

The workflow:bridge skill will run discovery, detect the next phase (specification), and enter plan mode with instructions to invoke start-specification with the topic and work_type.
