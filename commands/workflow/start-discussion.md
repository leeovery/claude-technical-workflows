---
description: Start a technical discussion. Discovers research and existing discussions, offers multiple entry paths, and invokes the technical-discussion skill.
allowed-tools: Bash(./scripts/discussion-discovery.sh), Bash(mkdir -p docs/workflow/.cache), Bash(rm docs/workflow/.cache/research-analysis.md)
---

Invoke the **technical-discussion** skill for this conversation.

## Workflow Context

This is **Phase 2** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| **2. Discussion** | WHAT and WHY - decisions, architecture, edge cases | ◀ HERE |
| 3. Specification | REFINE - validate into standalone spec | |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| 5. Implementation | DOING - tests first, then code | |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Capture the WHAT and WHY - decisions, rationale, competing approaches, edge cases. Don't jump to specifications, plans, or code. This is the time for debate and documentation.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
./scripts/discussion-discovery.sh
```

This outputs structured YAML. Parse it to understand:

**From `research` section:**
- Whether research files exist
- List of research file names
- Current checksum of research content

**From `discussions` array:**
- Each discussion's name, status (exploring/deciding/concluded), and brief description

**From `cache` section:**
- Whether a research analysis cache exists
- The cached checksum and topics

**From `cache_validity` section:**
- Whether the cache is still valid (`is_valid: true/false`)
- The reason if invalid

**From `summary` section:**
- Counts of research files and discussions by status

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Analyze Research (if exists)

Skip this step if no research files were found in Step 1.

This step uses caching to avoid re-analyzing unchanged research documents.

### Check Cache Validity

Check the `cache_validity.is_valid` value from the discovery state.

#### If cache exists AND is valid

```
Using cached research analysis (unchanged since {date from cache})
```

Load the topics from the cache and proceed to Step 3.

#### If cache missing OR invalid

```
Analyzing research documents...
```

Read each research file and analyze the content to extract key themes and potential discussion topics. For each theme:
- Note the source file and relevant line numbers
- Summarize what the theme is about in 1-2 sentences
- Identify key questions or decisions that need discussion

**Be thorough**: This analysis will be cached, so take time to identify ALL potential topics including:
- Major architectural decisions
- Technical trade-offs mentioned
- Open questions or concerns raised
- Implementation approaches discussed
- Integration points with external systems
- Security or performance considerations
- Edge cases or error handling mentioned

**Save to cache:**

After analysis, create the cache directory if needed:

```bash
mkdir -p docs/workflow/.cache
```

Then create/update `docs/workflow/.cache/research-analysis.md`:

```markdown
---
checksum: {checksum from research.current_checksum}
generated: {ISO date}
research_files:
  - {filename1}.md
  - {filename2}.md
---

# Research Analysis Cache

## Topics

### {Theme name}
- **Source**: {filename}.md (lines {start}-{end})
- **Summary**: {1-2 sentence summary}
- **Key questions**: {what needs deciding}

### {Another theme}
- **Source**: {filename}.md (lines {start}-{end})
- **Summary**: {1-2 sentence summary}
- **Key questions**: {what needs deciding}

[... more topics ...]
```

### Cross-reference with Discussions

For each identified topic, check if a corresponding discussion already exists in the `discussions` array from the discovery state.

→ Proceed to **Step 3**.

---

## Step 3: Present Workflow State and Options

Present everything discovered to help the user make an informed choice.

#### If NOTHING exists (no research, no discussions)

```
Starting fresh - no prior research or discussions found.

What topic would you like to discuss?
```

**STOP.** Wait for user to provide topic, then skip to **Step 5: Gather Context** with the fresh topic path.

#### Otherwise, present the full state

**If research exists, show the topics:**

```
Research topics:

  1. {Theme name}
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"
     {✓ discussed in {topic}.md | ✗ undiscussed}

  2. {Theme name}
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"
     {✓ discussed in {topic}.md | ✗ undiscussed}

  [... more topics ...]
```

**Legend:**
- ✓ discussed in {topic}.md = Already has a corresponding discussion
- ✗ undiscussed = Potential new discussion

**If discussions exist, show them:**

```
Existing discussions:

  • {topic}.md — {Status}
    "{Brief description from context section}"

  • {topic}.md — Concluded
    "{Brief description}"
```

**Status key:**
- Exploring/Deciding = In progress
- Concluded = Complete (can still be reopened)

**Then present the options based on what exists:**

#### If research AND discussions exist

```
How would you like to proceed?

  • **From research** - Pick a topic number above (e.g., "research 1" or "1")
  • **Continue discussion** - Name one above (e.g., "continue {topic}")
  • **Fresh topic** - Describe what you want to discuss
  • **refresh** - Force fresh research analysis
```

**STOP.** Wait for user response.

#### If ONLY research exists

```
How would you like to proceed?

  • **From research** - Pick a topic number above (e.g., "research 1" or "1")
  • **Fresh topic** - Describe what you want to discuss
  • **refresh** - Force fresh research analysis
```

**STOP.** Wait for user response.

#### If ONLY discussions exist

```
How would you like to proceed?

  • **Continue discussion** - Name one above (e.g., "continue {topic}")
  • **Fresh topic** - Describe what you want to discuss
```

**STOP.** Wait for user response.

→ Based on choice, proceed to **Step 4**.

---

## Step 4A: "From research" Path

User chose to start from research (e.g., "research 1", "1", "from research", or a topic name).

#### If user specified a topic inline (e.g., "research 2", "2", or topic name)

Identify the selected topic from Step 3's numbered list.

**Important:** Keep track of the source file and line numbers for the chosen topic - this will be passed to the skill.

→ Proceed to **Step 5: Gather Context**.

#### If user just said "from research" without specifying

```
Which research topic would you like to discuss? (Enter a number or topic name)
```

**STOP.** Wait for response, then proceed to **Step 5**.

### Handle "refresh" Request

If user enters `refresh`:
- Delete the cache file: `rm docs/workflow/.cache/research-analysis.md`
- Return to Step 2 (Analyze Research)
- Inform user: "Refreshing analysis..."
- After analysis, return to Step 3 to present updated findings

---

## Step 4B: "Continue discussion" Path

User chose to continue a discussion (e.g., "continue auth-flow" or "continue discussion").

#### If user specified a discussion inline (e.g., "continue auth-flow")

Identify the selected discussion from Step 3's list.

→ Proceed to **Step 5: Gather Context**.

#### If user just said "continue discussion" without specifying

```
Which discussion would you like to continue?
```

**STOP.** Wait for response, then proceed to **Step 5**.

---

## Step 4C: "Fresh topic" Path

User wants to start a fresh discussion.

→ Proceed directly to **Step 5**.

---

## Step 5: Gather Context

Gather context based on the chosen path.

#### If starting new discussion (from research or fresh)

```
## New discussion: {topic}

Before we begin:

1. What's the core problem or decision we need to work through?

2. Any constraints or context I should know about?

3. Are there specific files in the codebase I should review first?
```

**STOP.** Wait for responses, then proceed to **Step 6**.

#### If continuing existing discussion

Read the existing discussion document first, then ask:

```
## Continuing: {topic}

I've read the existing discussion.

What would you like to focus on in this session?
```

**STOP.** Wait for response, then proceed to **Step 6**.

---

## Step 6: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-discussion](../../skills/technical-discussion/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format (from research)

```
Discussion session for: {topic}
Output: docs/workflow/discussion/{topic}.md

Research reference:
Source: docs/workflow/research/{filename}.md (lines {start}-{end})
Summary: {the 1-2 sentence summary from the research analysis}

---
Invoke the technical-discussion skill.
```

#### Handoff Format (continuing or fresh)

```
Discussion session for: {topic}
Source: {existing discussion | fresh}
Output: docs/workflow/discussion/{topic}.md

---
Invoke the technical-discussion skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Discussion captures WHAT and WHY - don't jump to specifications or implementation
