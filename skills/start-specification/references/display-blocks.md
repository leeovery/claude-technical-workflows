# Display: Block Scenarios

*Reference for **[start-specification](../SKILL.md)***

---

Two terminal paths — the command stops and cannot proceed.

## If no discussions exist

> *Output the next fenced block as a code block:*

```
Specification Overview

No discussions found.

The specification phase requires concluded discussions to work from.
Discussions capture the technical decisions, edge cases, and rationale
that specifications are built upon.

Run /start-discussion to begin documenting technical decisions.
```

**STOP.** Do not proceed — terminal condition.

## If discussions exist but none concluded

> *Output the next fenced block as a code block:*

```
Specification Overview

No concluded discussions found.

The following discussions are still in progress:

  · {discussion-name} (in-progress)
  · {discussion-name} (in-progress)

Specifications can only be created from concluded discussions.
Run /start-discussion to continue working on a discussion.
```

List all in-progress discussions from discovery output.

**STOP.** Do not proceed — terminal condition.
