# Gather Context

*Reference for **[start-discussion](../SKILL.md)***

---

Gather context based on the chosen path.

#### If starting from research

Summarise the selected research topic in 2-5 lines, drawing from the source, summary, and key questions in the research analysis.

```
New discussion: {topic}

Based on research: docs/workflow/research/{filename}.md (lines {start}-{end})

{2-5 line summary of the topic and what needs discussing}

· · · · · · · · · · · ·
Do you have anything to add? Extra context, files, or additional
research you'd like to include — drop them in now.

- **`n`/`no`** — Continue as-is
· · · · · · · · · · · ·
```

**STOP.** Wait for user response before proceeding.

#### If starting fresh topic

```
New discussion: {topic}

Before we begin:

1. What's the core problem or decision we need to work through?

2. Any constraints or context I should know about?

3. Are there specific files in the codebase I should review first?
```

**STOP.** Wait for responses before proceeding.

#### If continuing existing discussion

Read the existing discussion document first, then ask:

```
Continuing: {topic}

I've read the existing discussion.

What would you like to focus on in this session?
```

**STOP.** Wait for response before proceeding.
