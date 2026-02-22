# Work Type Selection

*Reference for **[workflow:start](../SKILL.md)***

---

Present the current state and ask the user which work type they want to work on.

## Display State Overview

Using the discovery output, build a concise state summary.

> *Output the next fenced block as a code block:*

```
Workflow Overview

{state_summary}
```

Where `{state_summary}` is built from the discovery:

- If `state.has_any_work` is false: "No existing work found. Ready to start."
- If there's existing work, summarize it:
  - Greenfield: "{N} discussions, {M} specifications, ..."
  - Features: "{N} features in progress"
  - Bugfixes: "{N} bugfixes in progress"

## Ask Work Type

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
What would you like to work on?

1. **Build the product** — Greenfield development (phase-centric, multi-session)
2. **Add a feature** — Feature work (topic-centric, linear pipeline)
3. **Fix a bug** — Bugfix (investigation-centric, focused pipeline)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

## Process Selection

Map the user's response to a work type:

- "1", "build", "greenfield", "product" → work type is **greenfield**
- "2", "feature", "add" → work type is **feature**
- "3", "bug", "fix", "bugfix" → work type is **bugfix**

If the response doesn't map clearly, ask for clarification.

Return to the main skill with the selected work type.
