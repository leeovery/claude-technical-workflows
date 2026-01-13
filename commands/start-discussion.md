---
description: Start a technical discussion. Discovers research and existing discussions, offers multiple entry paths, and invokes the technical-discussion skill.
---

Invoke the **technical-discussion** skill for this conversation.

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

Before beginning, discover existing work and determine the best entry path.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover Existing Work

Scan the codebase for research and discussions:

1. **Find research**: Look in `docs/workflow/research/`
   - Run `ls docs/workflow/research/` to list research files
   - Note which files exist (may include `exploration.md` and semantic files like `market-landscape.md`)

2. **Find discussions**: Look in `docs/workflow/discussion/`
   - Run `ls docs/workflow/discussion/` to list discussion files
   - Each file is named `{topic}.md`

3. **Check discussion status**: For each discussion file
   - Run `head -10 docs/workflow/discussion/{topic}.md` to extract the `Status:` field
   - Status values: `Exploring`, `Deciding`, or `Concluded`
   - Do NOT use bash loops - run separate commands for each file

## Step 2: Present Workflow State and Options

Present the workflow state and available options based on what was discovered.

**Format:**
```
📂 Workflow state:
  📚 Research: {count} files found / None found
  💬 Discussions: {count} existing / None yet
```

Then present the appropriate options:

**If research AND discussions exist:**
```
How would you like to proceed?

1. **From research** - Analyze research and suggest undiscussed topics
2. **Continue discussion** - Resume an existing discussion
3. **Fresh topic** - Start a new discussion
```

**If ONLY research exists:**
```
How would you like to proceed?

1. **From research** - Analyze research and suggest topics to discuss
2. **Fresh topic** - Start a new discussion
```

**If ONLY discussions exist:**
```
How would you like to proceed?

1. **Continue discussion** - Resume an existing discussion
2. **Fresh topic** - Start a new discussion
```

**If NOTHING exists:**
```
Starting fresh - no prior research or discussions found.

What topic would you like to discuss?
```
Then skip to Step 5 (Fresh topic path).

Wait for the user to choose before proceeding.

## Step 3A: "From research" Path

Read each research file and analyze the content to extract key themes and potential discussion topics. Summarize what each theme is about in 1-2 sentences.

Cross-reference with existing discussions to identify what has and hasn't been discussed.

**Present findings:**
```
🔍 Analyzing research documents...

💡 Topics identified:

  ✨ {Theme name}
     Source: {filename}.md
     "{Brief 1-2 sentence summary of the theme and what needs deciding}"

  ✨ {Another theme}
     Source: {filename}.md
     "{Brief summary}"

  ✅ {Already discussed theme} → discussed in {topic}.md
     Source: {filename}.md
     "{Brief summary}"

Which topic would you like to discuss? (Or describe something else)
```

**Key:**
- ✨ = Undiscussed topic (potential new discussion)
- ✅ = Already has a corresponding discussion

Wait for the user to choose before proceeding to Step 4.

## Step 3B: "Continue discussion" Path

List existing discussions with their status:

```
💬 Existing discussions:

  ⚡ {topic}.md — {Status}
     "{Brief description from context section}"

  ⚡ {topic}.md — {Status}
     "{Brief description}"

  ✅ {topic}.md — Concluded
     "{Brief description}"

Which discussion would you like to continue?
```

**Key:**
- ⚡ = In progress (Exploring or Deciding)
- ✅ = Concluded (can still be continued/reopened)

Wait for the user to choose, then proceed to Step 4.

## Step 3C: "Fresh topic" Path

Proceed directly to Step 4.

## Step 4: Gather Context

Gather context based on the chosen path.

**If starting new discussion (from research or fresh):**

```
## New discussion: {topic}

Before we begin:

1. What's the core problem or decision we need to work through?

2. Any constraints or context I should know about?

3. Are there specific files in the codebase I should review first?
```

Wait for responses before proceeding.

**If continuing existing discussion:**

Read the existing discussion document first, then ask:

```
## Continuing: {topic}

I've read the existing discussion.

What would you like to focus on in this session?
```

Wait for response before proceeding.

## Step 5: Invoke Discussion Skill

Begin the discussion session:

```
Discussion session for: {topic}
Source: {research file | existing discussion | fresh}
Output: docs/workflow/discussion/{topic}.md

Begin discussion using the technical-discussion skill.
```

**Setup:**
- Ensure discussion directory exists: `docs/workflow/discussion/`
- If new: Create file using the template structure
- If continuing: Work with existing file
- Commit frequently at natural discussion breaks

## Notes

- Ask questions clearly and wait for responses before proceeding
- Discussion captures WHAT and WHY - don't jump to specifications or implementation
- The goal is to work through edge cases, debates, and decisions before planning
- Commit the discussion document frequently during the session
