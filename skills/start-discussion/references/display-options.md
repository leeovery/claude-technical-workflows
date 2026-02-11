# Present Options

*Reference for **[start-discussion](../SKILL.md)***

---

Present everything discovered to help the user make an informed choice.

**Present the full state:**

```
Workflow Status: Discussion Phase

Research topics:
  1. · {Theme name} - undiscussed
       Source: {filename}.md (lines {start}-{end})
       "{Brief summary}"

  2. ✓ {Theme name} → {topic}.md
       Source: {filename}.md (lines {start}-{end})
       "{Brief summary}"

Discussions:
  - {topic}.md (in-progress)
  - {topic}.md (concluded)
```

**Legend:**
- `·` = undiscussed topic (potential new discussion)
- `✓` = already has a corresponding discussion

**Then present the options based on what exists:**

#### If research and discussions exist

```
· · · · · · · · · · · ·
How would you like to proceed?

- **`r`/`refresh`** — Force fresh research analysis
- From research — pick a topic number above (e.g., "1" or "research 1")
- Continue discussion — name one above (e.g., "continue {topic}")
- Fresh topic — describe what you want to discuss
· · · · · · · · · · · ·
```

#### If only research exists

```
· · · · · · · · · · · ·
How would you like to proceed?

- **`r`/`refresh`** — Force fresh research analysis
- From research — pick a topic number above (e.g., "1" or "research 1")
- Fresh topic — describe what you want to discuss
· · · · · · · · · · · ·
```

#### If only discussions exist

```
· · · · · · · · · · · ·
How would you like to proceed?

- Continue discussion — name one above (e.g., "continue {topic}")
- Fresh topic — describe what you want to discuss
· · · · · · · · · · · ·
```

**STOP.** Wait for user response before proceeding.
