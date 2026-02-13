# Select Plans

*Reference for **[start-review](../SKILL.md)***

---

This step only applies for `single` or `multi` scope chosen in Step 3.

#### If scope is "all"

All reviewable plans are included. No selection needed.

→ Proceed directly to **Step 5**.

#### If scope is "single"

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Which plan would you like to review? (Enter a number from Step 3)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 5**.

#### If scope is "multi"

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
Which plans to include? (Enter numbers separated by commas, e.g. 1,3)
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

→ Proceed to **Step 5**.
