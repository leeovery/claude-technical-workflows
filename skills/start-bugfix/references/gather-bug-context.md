# Gather Bug Context

*Reference for **[start-bugfix](../SKILL.md)***

---

Gather context about the bug through a structured interview. Ask questions one at a time with STOP gates between each.

**Note**: If the user has already provided context in their initial message, acknowledge what they've shared and skip questions that are already answered. Only ask what's missing.

## Question 1: What's broken?

> *Output the next fenced block as a code block:*

```
Starting new bugfix investigation.

What's broken?

- Expected behavior vs actual behavior
- Error messages, if any
```

**STOP.** Wait for user response.

## Question 2: How does it manifest?

> *Output the next fenced block as a code block:*

```
How is the bug manifesting?

- Where does it surface? (UI, API, logs, data)
- How often? (always, intermittent, specific conditions)
```

**STOP.** Wait for user response.

## Question 3: Reproduction

> *Output the next fenced block as a code block:*

```
Can you reproduce it?

- Steps to trigger the bug
- Environment or conditions where it occurs
(Or "unknown" if not yet reproducible)
```

**STOP.** Wait for user response.

## Question 4: Hypotheses

> *Output the next fenced block as a code block:*

```
Any initial hypotheses about the cause?

- Suspected area of code or component
- Recent changes that might be related
(Or "none" if no suspicion yet)
```

**STOP.** Wait for user response.

## Compile Context

After gathering answers, compile the bug context into a structured summary that will be passed to the investigation skill. Do not output the summary — it will be used in the next step.

The compiled context should capture:
- **Problem**: Expected vs actual behavior
- **Manifestation**: How and where the bug surfaces
- **Reproduction**: Steps to trigger, if known
- **Initial hypothesis**: User's suspicion about cause
