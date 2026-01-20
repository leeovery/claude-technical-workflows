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

Follow these steps EXACTLY as written. Do not skip steps or combine them.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

---

## Step 1: Gather Initial Context

Ask the user about their exploration:

```
What's on your mind?

1. What idea or topic do you want to explore?
2. What prompted this - a problem, opportunity, curiosity?
```

**STOP.** Wait for user response. Do not proceed until they answer.

→ Proceed to **Step 2**.

---

## Step 2: Understand Existing Knowledge

Ask about their current understanding:

```
What do you already know?

1. Any initial thoughts or research you've done?
2. Constraints or context I should be aware of?
```

**STOP.** Wait for user response. Do not proceed until they answer.

→ Proceed to **Step 3**.

---

## Step 3: Determine Starting Point

Ask where to focus:

```
Where should we start?

1. Technical feasibility?
2. Market landscape?
3. Business model?
4. Or just talk it through and see where it goes?
```

**STOP.** Wait for user response. Do not proceed until they answer.

→ Proceed to **Step 4**.

---

## Step 4: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-research](../../skills/technical-research/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

```
Research session for: {topic from Step 1}

Initial context: {summary of user's answers from Steps 1-3}

---
Invoke the technical-research skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Research is exploratory - let the conversation flow naturally
- This phase captures early thinking before formal discussion begins
