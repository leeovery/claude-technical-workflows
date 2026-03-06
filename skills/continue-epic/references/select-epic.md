# Select Epic

*Reference for **[continue-epic](../SKILL.md)***

---

Display active epics and let the user select one.

> *Output the next fenced block as a code block:*

```
Continue Epic

{count} epic(s) in progress:

@foreach(epic in epics)
  {N}. {epic.name:(titlecase)}
     └─ {epic.active_phases:(titlecase, comma-separated)}

@endforeach
```

Build from the discovery output's `epics` array. Each epic shows `name` (titlecased) and a comma-separated list of `active_phases` (titlecased). Blank line between each numbered item.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Which epic would you like to continue?

1. Continue "{epic.name:(titlecase)}"
2. ...

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual epics from discovery. No auto-select, even with one item.

**STOP.** Wait for user response.

Store the selected epic's name as `work_unit`.

→ Return to **[the skill](../SKILL.md)**.
