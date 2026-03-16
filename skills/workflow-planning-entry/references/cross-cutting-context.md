# Cross-Cutting Context

*Reference for **[workflow-planning-entry](../SKILL.md)***

---

## A. Check Work Type

#### If work_type is not `epic`

No cross-cutting specifications exist for feature/bugfix work types.

→ Return to **[the skill](../SKILL.md)**.

#### If work_type is `epic`

Use the cross-cutting specs identified in the validate-spec step. For each, the specification file is at `.workflows/{work_unit}/specification/{topic}/specification.md`.

→ Proceed to **B. Check Cross-Cutting Specifications**.

---

## B. Check Cross-Cutting Specifications

#### If no cross-cutting specifications exist

→ Return to **[the skill](../SKILL.md)**.

#### If cross-cutting specifications exist

→ Proceed to **C. Warn About In-Progress**.

---

## C. Warn About In-Progress

If any **in-progress** cross-cutting specifications exist, check whether they could be relevant to the feature being planned (by topic overlap — e.g., a caching strategy is relevant if the feature involves data retrieval or API calls).

#### If relevant in-progress specs exist

> *Output the next fenced block as a code block:*

```
Cross-cutting specifications still in progress:
These may contain architectural decisions relevant to this plan.

  • {topic}
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`c`/`continue`** — Plan without them
- **`s`/`stop`** — Complete them first
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

**If user chose `s`/`stop`:**

**STOP.** Do not proceed — terminal condition.

**If user chose `c`/`continue`:**

→ Proceed to **D. Summarize Completed**.

#### Otherwise

→ Proceed to **D. Summarize Completed**.

---

## D. Summarize Completed

If any **completed** cross-cutting specifications exist, identify which are relevant to the feature being planned and summarize for handoff:

> *Output the next fenced block as a code block:*

```
Cross-cutting specifications to reference:
- caching-strategy: [brief summary of key decisions]
```

These specifications contain validated architectural decisions that should inform the plan. The planning skill will incorporate these as a "Cross-Cutting References" section in the plan.

→ Return to **[the skill](../SKILL.md)**.
