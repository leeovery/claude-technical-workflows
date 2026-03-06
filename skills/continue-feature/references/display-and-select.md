# Display and Select Feature

*Reference for **[continue-feature](../SKILL.md)***

---

Display active features and let the user select one.

## A. Check for Terminal Conditions

#### If `count` is 0

> *Output the next fenced block as a code block:*

```
Continue Feature

No features in progress.

Run /start-feature to begin a new one.
```

**STOP.** Do not proceed — terminal condition.

#### If `work_unit` was provided but not found in features array

> *Output the next fenced block as a code block:*

```
Continue Feature

No active feature named "{work_unit}" found.

Run /continue-feature to see available features, or /start-feature to begin a new one.
```

**STOP.** Do not proceed — terminal condition.

→ Proceed to **B. Route by Context**.

## B. Route by Context

#### If `work_unit` was provided and matched a feature

Store the matched feature's data (name, next_phase, phase_label, concluded_phases). Skip display.

→ Return to **[the skill](../SKILL.md)**.

#### If `work_unit` was not provided

→ Proceed to **C. Display and Menu**.

## C. Display and Menu

> *Output the next fenced block as a code block:*

```
Continue Feature

{count} feature(s) in progress:

@foreach(feature in features)
  {N}. {feature.name:(titlecase)}
     └─ {feature.phase_label:(titlecase)}

@endforeach
```

Build from the discovery output's `features` array. Each feature shows `name` (titlecased) and `phase_label` (titlecased). Blank line between each numbered item.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Which feature would you like to continue?

1. Continue "{feature.name:(titlecase)}" — {feature.phase_label}
2. ...

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual features and `phase_label` values from discovery. No auto-select, even with one item.

**STOP.** Wait for user response.

## Process Selection

Store the selected feature's data (name, next_phase, phase_label, concluded_phases) for use in subsequent steps.

→ Return to **[the skill](../SKILL.md)**.
