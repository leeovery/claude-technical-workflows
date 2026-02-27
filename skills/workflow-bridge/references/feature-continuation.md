# Feature Continuation

*Reference for **[workflow-bridge](../SKILL.md)***

---

Route a feature to its next pipeline phase and enter plan mode with continuation instructions.

Feature pipeline: (Research) → Discussion → Specification → Planning → Implementation → Review

## Phase Routing

Use `next_phase` from discovery output to determine the target skill:

| next_phase | Target Skill | Plan Mode Instructions |
|------------|--------------|------------------------|
| research | start-research | Resume research for topic |
| discussion | start-discussion | Start/resume discussion for topic |
| specification | start-specification | Start/resume specification for topic |
| planning | start-planning | Start/resume planning for topic |
| implementation | start-implementation | Start/resume implementation for topic |
| review | start-review | Start review for topic |
| done | (terminal) | Pipeline complete |

## Generate Plan Mode Content

#### If next_phase is "done"

> *Output the next fenced block as a code block:*

```
Feature Complete

"{topic:(titlecase)}" has completed all pipeline phases.
```

**STOP.** Do not proceed — terminal condition.

#### Otherwise

Enter plan mode with the following content:

```
# Continue Feature: {topic}

The previous phase has concluded. Continue the pipeline.

## Next Step

Invoke `/start-{next_phase} feature {topic}`

Arguments: work_type = feature, topic = {topic}
The skill will skip discovery and proceed directly to validation.

## How to proceed

Clear context and continue.
```

Exit plan mode. The user will approve and clear context.
