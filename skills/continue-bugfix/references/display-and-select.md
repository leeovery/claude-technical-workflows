# Display and Select Bugfix

*Reference for **[continue-bugfix](../SKILL.md)***

---

Display active bugfixes and let the user select one.

## Display

> *Output the next fenced block as a code block:*

```
Continue Bugfix

{count} bugfix(es) in progress:

@foreach(bugfix in bugfixes)
  {N}. {bugfix.name:(titlecase)}
     └─ {bugfix.phase_label:(titlecase)}

@endforeach
```

Build from the discovery output's `bugfixes` array. Each bugfix shows `name` (titlecased) and `phase_label` (titlecased). Blank line between each numbered item.

## Menu

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Which bugfix would you like to continue?

1. Continue "{bugfix.name:(titlecase)}" — {bugfix.phase_label}
2. ...

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual bugfixes and `phase_label` values from discovery. No auto-select, even with one item.

**STOP.** Wait for user response.

## Process Selection

Store the selected bugfix's data (name, next_phase, phase_label, concluded_phases) for use in subsequent steps.

→ Return to **[the skill](../SKILL.md)**.
