# Handle Selection

*Reference for **[start-discussion](../SKILL.md)***

---

Route based on the user's choice from the options display.

#### If user chose "From research"

User chose to start from research (e.g., "research 1", "1", "from research", or a topic name).

**If user specified a topic inline** (e.g., "research 2", "2", or topic name):
- Identify the selected topic from the numbered list
- Control returns to the backbone

**If user just said "from research" without specifying:**

> *Output the next fenced block as a code block:*

```
Which research topic would you like to discuss? (Enter a number or topic name)
```

**STOP.** Wait for response.

#### If user chose "Continue discussion"

User chose to continue a discussion (e.g., "continue auth-flow" or "continue discussion").

**If user specified a discussion inline** (e.g., "continue auth-flow"):
- Identify the selected discussion from the list
- Control returns to the backbone

**If user just said "continue discussion" without specifying:**

> *Output the next fenced block as a code block:*

```
Which discussion would you like to continue?
```

**STOP.** Wait for response.

#### If user chose "Fresh topic"

User wants to start a fresh discussion. Control returns to the backbone.

#### If user chose "refresh"

> *Output the next fenced block as a code block:*

```
Refreshing analysis...
```

Delete the cache file:
```bash
rm .workflows/.state/research-analysis.md
```

→ Return to **Step 5** to re-analyze.
