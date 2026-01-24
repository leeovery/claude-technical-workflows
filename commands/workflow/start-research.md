---
description: Start a research exploration using the technical-research skill. For early-stage ideas, feasibility checks, and broad exploration before formal discussion.
---

Invoke the **technical-research** skill for this conversation.

## Workflow Context

This is **Phase 1** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| **1. Research** | EXPLORE - ideas, feasibility, market, business | ◀ HERE |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| 3. Specification | REFINE - validate into standalone spec | |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| 5. Implementation | DOING - tests first, then code | |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Explore freely. This is the time for broad thinking, feasibility checks, and learning. Don't jump to formal discussions or specifications yet.

---

## Instructions

Follow these steps in order.

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` command and assess its output before proceeding to Step 1.

---

## Step 1: Get the Seed Idea

Ask the first question:

```
What idea or topic would you like to explore?
```

**STOP.** Wait for user response before proceeding.

→ Proceed to **Step 2**.

---

## Step 2: Understand the Prompt

Ask what prompted this:

```
What prompted this - a problem you're facing, an opportunity you spotted, or just curiosity?
```

**STOP.** Wait for user response before proceeding.

→ Proceed to **Step 3**.

---

## Step 3: Gather Context

Ask about constraints:

```
Any constraints or context I should know about upfront? (Or "none" if we're starting fresh)
```

**STOP.** Wait for user response before proceeding.

→ Proceed to **Step 4**.

---

## Step 4: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-research](../../skills/technical-research/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff:**
```
Research session for: {topic}
Output: docs/workflow/research/exploration.md

Context:
- Prompted by: {problem, opportunity, or curiosity}
- Known constraints: {any constraints mentioned, or "none"}

Invoke the technical-research skill.
```
