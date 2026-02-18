# Gather Feature Context

*Reference for **[start-feature](../SKILL.md)***

---

Gather context about the feature through a structured interview. Ask questions one at a time with STOP gates between each.

**Note**: If the user has already provided context in their initial message, acknowledge what they've shared and skip questions that are already answered. Only ask what's missing.

## Question 1: What are you building?

> *Output the next fenced block as a code block:*

```
What feature are you adding?

- Brief description of what you're building
- What problem does it solve?
```

**STOP.** Wait for user response.

## Question 2: What's the scope?

> *Output the next fenced block as a code block:*

```
What's the scope?

- Core functionality to implement
- Known edge cases or constraints
- What's explicitly out of scope?
```

**STOP.** Wait for user response.

## Question 3: Integration and constraints

> *Output the next fenced block as a code block:*

```
Any constraints or integration points?

- How does this integrate with existing code?
- Technical decisions already made
- Conventions or patterns to follow
- External dependencies or APIs
```

**STOP.** Wait for user response.

## Compile Context

After gathering answers, compile the feature context into a structured summary that will be passed to the discussion skill. Do not output the summary — it will be used in the next step.

The compiled context should capture:
- **Feature**: What is being built and why
- **Scope**: Core functionality, edge cases, out-of-scope
- **Constraints**: Integration points, decisions, conventions
