# Task Normalisation

*Reference for **[technical-implementation](../SKILL.md)***

---

Normalise task content into this shape before passing to executor and reviewer agents. The plan adapter tells you how to extract the task — this reference tells you what shape to present it in.

---

## Template

```
TASK: {id} — {name}
PHASE: {N} — {phase name}

INSTRUCTIONS:
{all instructional content from the task}
```

## Rules

- **Include** everything instructional: goal, implementation steps, acceptance criteria, tests, edge cases, context, notes
- **Strip** meta fields: status, priority, dependencies, dates, progress markers
- **Preserve** the internal structure of the instructional content as-is from the plan — do not summarise, reorder, or rewrite
