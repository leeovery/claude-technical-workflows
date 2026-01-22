---
description: Start a technical discussion. Discovers research and existing discussions, offers multiple entry paths, and invokes the technical-discussion skill.
allowed-tools: Bash(.claude/scripts/discussion-discovery.sh), Bash(mkdir -p docs/workflow/.cache), Bash(rm docs/workflow/.cache/research-analysis.md)
---

Invoke the **technical-discussion** skill for this conversation.

## Workflow Context

This is **Phase 2** of the six-phase workflow:

| Phase              | Focus                                              | You    |
|--------------------|----------------------------------------------------|--------|
| 1. Research        | EXPLORE - ideas, feasibility, market, business     |        |
| **2. Discussion**  | WHAT and WHY - decisions, architecture, edge cases | ◀ HERE |
| 3. Specification   | REFINE - validate into standalone spec             |        |
| 4. Planning        | HOW - phases, tasks, acceptance criteria           |        |
| 5. Implementation  | DOING - tests first, then code                     |        |
| 6. Review          | VALIDATING - check work against artifacts          |        |

**Stay in your lane**: Capture the WHAT and WHY - decisions, rationale, competing approaches, edge cases. Don't jump to specifications, plans, or code. This is the time for debate and documentation.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` command and assess its output before proceeding to Step 1.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
.claude/scripts/discussion-discovery.sh
```

This outputs structured YAML. Parse it to understand:

**From `research` section:**
- `exists` - whether research files exist
- `files` - each research file's name and topic
- `checksum` - current checksum of all research files

**From `discussions` section:**
- `exists` - whether discussion files exist
- `files` - each discussion's name, status, and date
- `counts.in_progress` and `counts.concluded` - totals for routing

**From `cache` section:**
- `status` - one of three values:
  - `"valid"` - cache exists and checksums match (safe to load)
  - `"stale"` - cache exists but research has changed (needs re-analysis)
  - `"none"` - no cache file exists
- `reason` - explanation of the status
- `generated` - when the cache was created (null if none)
- `research_files` - list of files that were analyzed

**From `state` section:**
- `scenario` - one of: `"fresh"`, `"research_only"`, `"discussions_only"`, `"research_and_discussions"`

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

## Step 2: Analyze Research (if exists)

Skip this step if no research files were found in Step 1.

This step uses caching to avoid re-analyzing unchanged research documents.

### Step 2.1: Check Cache Validity

Compare the current research checksum (computed in Step 1.5) with the cached checksum:

**If cache exists AND checksums match:**
```
📋 Using cached research analysis (unchanged since {date from cache})
```

Load the topics from the cache file and proceed to Step 2.3.

**If cache missing OR checksums differ:**
```
🔍 Analyzing research documents...
```

Proceed to Step 2.2 (Full Analysis).

### Step 2.2: Full Analysis (when cache invalid)

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
After analysis, create/update `docs/workflow/.cache/research-analysis.md`:

```markdown
---
checksum: {computed_checksum}
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

Ensure the `.cache` directory exists: `mkdir -p docs/workflow/.cache`

### Step 2.3: Cross-reference with Discussions

For each identified topic, check if a corresponding discussion already exists in `docs/workflow/discussion/`.

## Step 3: Present Workflow State and Options

Present everything discovered to help the user make an informed choice.

**If NOTHING exists (no research, no discussions):**
```
Starting fresh - no prior research or discussions found.

What topic would you like to discuss?
```
Then skip to Step 5 (Gather Context) with the fresh topic path.

**Otherwise, present the full state:**

```
📂 Workflow state:
```

**If research exists, show the topics:**
```
📚 Research topics:

  1. ✨ {Theme name}
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"

  2. ✅ {Theme name} → discussed in {topic}.md
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"

  [... more topics ...]
```

**Key:**
- ✨ = Undiscussed topic (potential new discussion)
- ✅ = Already has a corresponding discussion

**If discussions exist, show them:**
```
💬 Existing discussions:

  • {topic}.md — {Status}
    "{Brief description from context section}"

  • {topic}.md — concluded
    "{Brief description}"
```

**Key:**
- in-progress = Active discussion
- concluded = Complete (can still be reopened)

**Then present the options based on what exists:**

**If research AND discussions exist:**
```
How would you like to proceed?

  • **From research** - Pick a topic number above (e.g., "research 1" or "1")
  • **Continue discussion** - Name one above (e.g., "continue {topic}")
  • **Fresh topic** - Describe what you want to discuss
  • **refresh** - Force fresh research analysis
```

**If ONLY research exists:**
```
How would you like to proceed?

  • **From research** - Pick a topic number above (e.g., "research 1" or "1")
  • **Fresh topic** - Describe what you want to discuss
  • **refresh** - Force fresh research analysis
```

**If ONLY discussions exist:**
```
How would you like to proceed?

  • **Continue discussion** - Name one above (e.g., "continue {topic}")
  • **Fresh topic** - Describe what you want to discuss
```

Wait for the user to respond before proceeding.

## Step 4A: "From research" Path

User chose to start from research (e.g., "research 1", "1", "from research", or a topic name).

**If user specified a topic inline** (e.g., "research 2", "2", or topic name):
- Identify the selected topic from Step 3's numbered list
- Proceed to Step 5 (Gather Context)

**If user just said "from research" without specifying:**
```
Which research topic would you like to discuss? (Enter a number or topic name)
```
Wait for response, then proceed to Step 5.

### Handle "refresh" Request

If user enters `refresh`:
- Delete the cache file: `rm docs/workflow/.cache/research-analysis.md`
- Return to Step 2.2 (Full Analysis)
- Inform user: "Refreshing analysis..."
- After analysis, return to Step 3 to present updated findings

**Important:** Keep track of the source file and line numbers for the chosen topic - this will be passed to the skill.

## Step 4B: "Continue discussion" Path

User chose to continue a discussion (e.g., "continue auth-flow" or "continue discussion").

**If user specified a discussion inline** (e.g., "continue auth-flow"):
- Identify the selected discussion from Step 3's list
- Proceed to Step 5 (Gather Context)

**If user just said "continue discussion" without specifying:**
```
Which discussion would you like to continue?
```
Wait for response, then proceed to Step 5.

## Step 4C: "Fresh topic" Path

User wants to start a fresh discussion. Proceed directly to Step 5.

## Step 5: Gather Context

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

## Step 6: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-discussion](../../skills/technical-discussion/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (from research):**
```
Discussion session for: {topic}
Output: docs/workflow/discussion/{topic}.md

Research reference:
Source: docs/workflow/research/{filename}.md (lines {start}-{end})
Summary: {the 1-2 sentence summary from the research analysis}

Invoke the technical-discussion skill.
```

**Example handoff (continuing or fresh):**
```
Discussion session for: {topic}
Source: {existing discussion | fresh}
Output: docs/workflow/discussion/{topic}.md

Invoke the technical-discussion skill.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- Discussion captures WHAT and WHY - don't jump to specifications or implementation
