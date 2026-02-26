# Bugfix Continuation

*Reference for **[workflow:bridge](../SKILL.md)***

---

Route a bugfix to its next pipeline phase and enter plan mode with continuation instructions.

Bugfix pipeline: Investigation → Specification → Planning → Implementation → Review

## Phase Routing

Use `next_phase` from discovery output to determine the target skill:

| next_phase | Target Skill | Plan Mode Instructions |
|------------|--------------|------------------------|
| investigation | start-investigation | Resume investigation for topic |
| specification | start-specification | Start/resume specification for topic |
| planning | start-planning | Start/resume planning for topic |
| implementation | start-implementation | Start/resume implementation for topic |
| review | start-review | Start review for topic |
| done | (terminal) | Pipeline complete |

## Generate Plan Mode Content

#### If next_phase is "done"

> *Output the next fenced block as a code block:*

```
Bugfix Complete

"{topic:(titlecase)}" has completed all pipeline phases.
```

**STOP.** Do not proceed — terminal condition.

#### Otherwise

Enter plan mode with the following content:

```
# Continue Bugfix: {topic}

The previous phase has concluded. Continue the pipeline.

## Next Step

Invoke `/start-{next_phase} {topic} bugfix`

Arguments: topic = {topic}, work_type = bugfix
The skill will skip discovery and proceed directly to validation.

## How to proceed

Clear context and continue.
```

Exit plan mode. The user will approve and clear context.
