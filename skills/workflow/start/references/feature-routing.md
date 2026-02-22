# Feature Routing

*Reference for **[workflow:start](../SKILL.md)***

---

Feature development is topic-centric. A single topic flows through the pipeline: Discussion → Specification → Planning → Implementation → Review. This reference shows in-progress features and offers options to continue or start new.

## Display Feature State

Using the discovery output, check if there are any features in progress.

#### If no features exist

> *Output the next fenced block as a code block:*

```
Features

No features in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Ready to start a new feature.

- **`y`/`yes`** — Start a new feature
- **`n`/`no`** — Go back to work type selection
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If yes, invoke `/start-feature`. It will set `work_type: feature` automatically.

If no, return to the main skill and re-run Step 2 (work type selection).

#### If features exist

> *Output the next fenced block as a code block:*

```
Features

{feature_count} feature(s) in progress:

{foreach topic in features.topics}
1. {topic.name:(titlecase)}
   └─ Next: {topic.next_phase}
{/foreach}
```

## Build Menu Options

Build a numbered menu with all in-progress features plus option to start new:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

{foreach topic in features.topics}
{N}. Continue "{topic.name}" — {next_phase_description}
{/foreach}
{N+1}. Start new feature
· · · · · · · · · · · ·
```

Where `{next_phase_description}` maps next_phase to a human-readable description:
- discussion → "discussion in progress"
- specification → "ready for specification" or "specification in progress"
- planning → "ready for planning" or "planning in progress"
- implementation → "ready for implementation" or "implementation in progress"
- review → "ready for review"
- done → "pipeline complete"

**STOP.** Wait for user response.

## Route Based on Selection

Parse the user's selection:

#### If "start new feature"

Invoke `/start-feature`. It will set `work_type: feature` automatically.

#### If continuing existing feature

Invoke `/continue-feature` with the selected topic:

```
Topic: {topic}
Work type: feature
```

The continue-feature skill will detect the current phase and route appropriately.
