# Phase Bridge

*Reference for **[continue-bugfix](../SKILL.md)***

---

The phase bridge clears context between pipeline phases. This is necessary because each phase can consume significant context, and starting fresh prevents degradation.

## Determine Completed Phase

Check which step just completed:

- Just completed **Step 3** (specification) → completed_phase is **specification**
- Just completed **Step 4** (planning) → completed_phase is **planning**
- Just completed **Step 5** (implementation) → completed_phase is **implementation**
- Just completed **Step 6** (review) → completed_phase is **review**

#### If review just completed

> *Output the next fenced block as a code block:*

```
Bugfix Complete

"{topic:(titlecase)}" has completed all pipeline phases.
```

**STOP.** Do not proceed — terminal condition.

## Invoke Workflow Bridge

Invoke the [workflow:bridge](../../workflow/bridge/SKILL.md) skill:

```
Pipeline bridge for: {topic}
Work type: bugfix
Completed phase: {completed_phase}

Invoke the workflow:bridge skill to enter plan mode with continuation instructions.
```

The workflow:bridge skill will enter plan mode with instructions to invoke continue-bugfix for the topic in the next session.
