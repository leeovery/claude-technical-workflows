# Cross-Cutting Context

*Reference for **[start-planning](../SKILL.md)***

---

**If no cross-cutting specifications exist**:

Skip this step.

→ Proceed to **Step 7**.

Read each cross-cutting specification from `specifications.crosscutting` in the discovery output.

### 6a: Warn about in-progress cross-cutting specs

If any **in-progress** cross-cutting specifications exist, check whether they could be relevant to the feature being planned (by topic overlap — e.g., a caching strategy is relevant if the feature involves data retrieval or API calls).

If any are relevant:

> *Output the next fenced block as markdown (not a code block):*

```
Cross-cutting specifications still in progress:
These may contain architectural decisions relevant to this plan.

  • {topic}

· · · · · · · · · · · ·
- **`c`/`continue`** — Plan without them
- **`s`/`stop`** — Complete them first (/start-specification)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If the user chooses to stop, end here. If they choose to continue, proceed.

### 6b: Summarize concluded cross-cutting specs

If any **concluded** cross-cutting specifications exist, identify which are relevant to the feature being planned and summarize for handoff:

> *Output the next fenced block as a code block:*

```
Cross-cutting specifications to reference:
- caching-strategy.md: [brief summary of key decisions]
```

These specifications contain validated architectural decisions that should inform the plan. The planning skill will incorporate these as a "Cross-Cutting References" section in the plan.

→ Proceed to **Step 7**.
