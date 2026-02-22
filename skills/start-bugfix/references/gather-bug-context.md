# Gather Bug Context

*Reference for **[start-bugfix](../SKILL.md)***

---

Gather initial context about the bug to start the investigation.

## Initial Questions

> *Output the next fenced block as a code block:*

```
Starting new bugfix investigation.

What bug are you investigating? Please tell me:

- What's broken? (expected vs actual behavior)
- How is it manifesting? (errors, UI issues, data problems)
- Can you reproduce it? (steps if known)
- Any initial hypotheses about the cause?
```

**STOP.** Wait for user response.

## Capture Context

From the user's response, extract:
- **Problem description**: What's expected vs actual
- **Manifestation**: How the bug surfaces
- **Reproduction**: Steps to trigger (if known)
- **Initial hypothesis**: User's suspicion about cause

This context will be passed to the technical-investigation skill.

Return to the main skill with the gathered context.
