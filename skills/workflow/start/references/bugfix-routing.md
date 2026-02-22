# Bugfix Routing

*Reference for **[workflow:start](../SKILL.md)***

---

Bugfix work is investigation-centric. A topic flows through: Investigation → Specification → Planning → Implementation → Review. Investigation replaces discussion by combining symptom gathering + code analysis. This reference shows in-progress bugfixes and offers options to continue or start new.

## Display Bugfix State

Using the discovery output, check if there are any bugfixes in progress.

#### If no bugfixes exist

> *Output the next fenced block as a code block:*

```
Bugfixes

No bugfixes in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Ready to start a new bugfix.

- **`y`/`yes`** — Start a new bugfix
- **`n`/`no`** — Go back to work type selection
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If yes, invoke `/start-bugfix`. It will set `work_type: bugfix` automatically.

If no, return to the main skill and re-run Step 2 (work type selection).

#### If bugfixes exist

> *Output the next fenced block as a code block:*

```
Bugfixes

{bugfix_count} bugfix(es) in progress:

{foreach topic in bugfixes.topics}
1. {topic.name:(titlecase)}
   └─ Next: {topic.next_phase}
{/foreach}
```

## Build Menu Options

Build a numbered menu with all in-progress bugfixes plus option to start new:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

{foreach topic in bugfixes.topics}
{N}. Continue "{topic.name}" — {next_phase_description}
{/foreach}
{N+1}. Start new bugfix
· · · · · · · · · · · ·
```

Where `{next_phase_description}` maps next_phase to a human-readable description:
- investigation → "investigation in progress"
- specification → "ready for specification" or "specification in progress"
- planning → "ready for planning" or "planning in progress"
- implementation → "ready for implementation" or "implementation in progress"
- review → "ready for review"
- done → "pipeline complete"

**STOP.** Wait for user response.

## Route Based on Selection

Parse the user's selection:

#### If "start new bugfix"

Invoke `/start-bugfix`. It will set `work_type: bugfix` and begin the investigation phase.

#### If continuing existing bugfix

Invoke `/continue-bugfix` with the selected topic:

```
Topic: {topic}
Work type: bugfix
```

The continue-bugfix skill will detect the current phase and route appropriately.
