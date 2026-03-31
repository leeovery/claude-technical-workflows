# Conclude Scoping

*Reference for **[workflow-scoping-process](../SKILL.md)***

---

> *Output the next fenced block as a code block:*

```
Scoping complete for "{topic:(titlecase)}".

  Spec: .workflows/{work_unit}/specification/{topic}/specification.md
  Plan: .workflows/{work_unit}/planning/{topic}/
```

> *Output the next fenced block as markdown (not a code block):*

```
> Scoping complete. The implementation phase will execute
> these tasks using the verification workflow.
```

**Pipeline continuation** — Invoke the bridge:

```
Pipeline bridge for: {work_unit}
Completed phase: scoping

Invoke the workflow-bridge skill to enter plan mode with continuation instructions.
```

**STOP.** Do not proceed — terminal condition.
