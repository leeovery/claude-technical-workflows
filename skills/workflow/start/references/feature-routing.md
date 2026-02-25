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

If yes, invoke `start-feature`. It will set `work_type: feature` automatically.

If no, return to the main skill and re-run Step 2 (work type selection).

#### If features exist

> *Output the next fenced block as a code block:*

```
Features

{feature_count} feature(s) in progress:

1. {topic:(titlecase)}
   └─ Next: {next_phase}

2. ...
```

Build tree from `features.topics` array. Each topic shows `name` (titlecased) and `next_phase`.

## Build Menu Options

Build a numbered menu with all in-progress features plus option to start new. The description maps `next_phase`:

| next_phase | Description |
|------------|-------------|
| discussion | discussion in-progress |
| specification | ready for specification |
| planning | ready for planning |
| implementation | ready for implementation |
| review | ready for review |
| done | pipeline complete |

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to do?

1. Continue "Auth Flow" — discussion in-progress
2. Continue "Caching" — ready for specification
3. Continue "Notifications" — ready for planning
4. Start new feature

Select an option (enter number):
· · · · · · · · · · · ·
```

Recreate with actual topics and states from discovery.

**STOP.** Wait for user response.

## Route Based on Selection

Parse the user's selection:

#### If "start new feature"

Invoke `start-feature`. It will set `work_type: feature` automatically.

#### If continuing existing feature

Route to the appropriate start-* skill based on `next_phase`:

| next_phase | Invoke |
|------------|--------|
| discussion | `start-discussion` with topic + "feature" |
| specification | `start-specification` with topic + "feature" |
| planning | `start-planning` with topic + "feature" |
| implementation | `start-implementation` with topic + "feature" |
| review | `start-review` with topic + "feature" |

The start-* skill receives topic and work_type, which triggers bridge mode (skipping discovery).

Example invocation:

```
Topic: {topic}
Work type: feature

Invoke start-{next_phase} with the topic and work type.
```

The start-{phase} skill will validate the topic exists and proceed to the processing skill.
