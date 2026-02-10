# Display: Analyze Prompt

*Reference for **[start-specification](../SKILL.md)***

---

Prompted when multiple concluded discussions exist, no specifications exist, and cache is none or stale.

## Display

```
Specification Overview

{N} concluded discussions found. No specifications exist yet.

Concluded discussions:
  • {discussion-name}
  • {discussion-name}
  • {discussion-name}
```

List all concluded discussions from discovery output.

### If in-progress discussions exist

```
---
Discussions not ready for specification:
These discussions are still in progress and must be concluded
before they can be included in a specification.
  · {discussion-name} (in-progress)
```

### Cache-Aware Message

#### If cache status is "none"

```
---
These discussions will be analyzed for natural groupings to determine
how they should be organized into specifications. Results are cached
and reused until discussions change.

· · · · · · · · · · · ·
Proceed with analysis?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

#### If cache status is "stale"

```
---
A previous grouping analysis exists but is outdated — discussions
have changed since it was created.

These discussions will be re-analyzed for natural groupings. Results
are cached and reused until discussions change.

· · · · · · · · · · · ·
Proceed with analysis?
- **`y`/`yes`**
- **`n`/`no`**
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If user confirms (y)

If cache is stale, delete it first:
```bash
rm docs/workflow/.cache/discussion-consolidation-analysis.md
```

Load **[analysis-flow.md](analysis-flow.md)** and follow its instructions.

#### If user declines (n)

```
Understood. You can run /start-discussion to continue working on
discussions, or re-run this command when ready.
```

**Command ends.** Control returns to the user.
