# Gather Epic Context

*Reference for **[start-epic](../SKILL.md)***

---

Gather context about the epic through a structured interview. Ask questions one at a time with STOP gates between each.

**Note**: If the user has already provided context in their initial message, acknowledge what they've shared and skip questions that are already answered. Only ask what's missing.

## Question 1: What's the product or initiative?

> *Output the next fenced block as a code block:*

```
What's the product or initiative?

- What are you building from scratch?
- What prompted this — a market need, internal requirement, new idea?
```

**STOP.** Wait for user response.

## Question 2: What are the goals?

> *Output the next fenced block as a code block:*

```
What are the goals?

- What does success look like?
- Who are the target users or stakeholders?
- What's the core value proposition?
```

**STOP.** Wait for user response.

## Question 3: What's the scope?

> *Output the next fenced block as a code block:*

```
What's the scope?

- Major components or subsystems involved
- Known boundaries — what's in and what's out
- Expected scale or complexity
```

**STOP.** Wait for user response.

## Question 4: Constraints and timeline

> *Output the next fenced block as a code block:*

```
Any constraints or timeline considerations?

- Technical constraints (platform, language, infrastructure)
- External dependencies or integrations
- Timeline expectations — weeks, months, ongoing?
- Team or resource constraints
```

**STOP.** Wait for user response.

## Question 5: Areas needing exploration

> *Output the next fenced block as a code block:*

```
What areas need exploration?

- Technical unknowns or unfamiliar territory
- Design decisions not yet made
- Market or user research needed
- Architecture patterns to evaluate
```

**STOP.** Wait for user response.

## Compile Context

After gathering answers, compile the epic context into a structured summary that will be passed to the processing skill. Do not output the summary — it will be used in later steps.

The compiled context should capture:
- **Product**: What is being built and why
- **Goals**: Success criteria, target users, value proposition
- **Scope**: Major components, boundaries, scale
- **Constraints**: Technical, timeline, team, dependencies
- **Exploration areas**: Unknowns, open questions, research needs
