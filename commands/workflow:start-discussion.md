---
description: Start a technical discussion. Discovers research and existing discussions, offers multiple entry paths, and invokes the technical-discussion skill.
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

4. **Check for cached analysis** (if research files exist):
   - Check if `docs/workflow/.cache/research-analysis.md` exists
   - If it exists, read it to get the stored checksum from the frontmatter

5. **Compute current research checksum** (if research files exist):
   - Run exactly: `cat docs/workflow/research/*.md 2>/dev/null | md5sum | cut -d' ' -f1`
   - IMPORTANT: Use this exact command - glob expansion is alphabetically sorted by default
   - Do NOT modify or "simplify" this command - checksum must be deterministic
   - Store this value to compare with the cached checksum

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

This step uses caching to avoid re-analyzing unchanged research documents.

### Step 3A.1: Check Cache Validity

Compare the current research checksum (computed in Step 1.5) with the cached checksum:

**If cache exists AND checksums match:**
```
📋 Using cached analysis

Research documents unchanged since last analysis ({date from cache}).
Loading {count} previously identified topics...

💡 To force a fresh analysis, enter: refresh
```

Then load the topics from the cache file and skip to Step 3A.3 (Cross-reference).

**If cache missing OR checksums differ:**
```
🔍 Analyzing research documents...
```

Proceed to Step 3A.2 (Full Analysis).

### Step 3A.2: Full Analysis (when cache invalid)

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

### Step 3A.3: Cross-reference with Discussions

**Always performed** (whether using cache or fresh analysis):

For each identified topic, check if a corresponding discussion already exists in `docs/workflow/discussion/`.

### Step 3A.4: Present Findings

**If using cached analysis:**
```
📋 Cached analysis (research unchanged since {date})

💡 Topics identified:

  ✨ {Theme name}
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"

  ✅ {Already discussed theme} → discussed in {topic}.md
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"

Which topic would you like to discuss? (Or enter 'refresh' for fresh analysis)
```

**If fresh analysis:**
```
🔍 Analysis complete (cached for future sessions)

💡 Topics identified:

  ✨ {Theme name}
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"

  ✅ {Already discussed theme} → discussed in {topic}.md
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"

Which topic would you like to discuss? (Or describe something else)
```

**Key:**
- ✨ = Undiscussed topic (potential new discussion)
- ✅ = Already has a corresponding discussion

### Step 3A.5: Handle "refresh" Request

If user enters `refresh`:
- Delete the cache file: `rm docs/workflow/.cache/research-analysis.md`
- Return to Step 3A.2 (Full Analysis)
- Inform user: "Refreshing analysis..."

**Important:** Keep track of the source file and line numbers for the chosen topic - this will be passed to the skill.

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

## Step 5: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-discussion](../skills/technical-discussion/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (from research):**
```
Discussion session for: {topic}
Output: docs/workflow/discussion/{topic}.md

Research reference:
Source: docs/workflow/research/{filename}.md (lines {start}-{end})
Summary: {the 1-2 sentence summary from Step 3A}

Begin using the technical-discussion skill.
```

**Example handoff (continuing or fresh):**
```
Discussion session for: {topic}
Source: {existing discussion | fresh}
Output: docs/workflow/discussion/{topic}.md

Begin using the technical-discussion skill.
```

## Notes

- Ask questions clearly and wait for responses before proceeding
- Discussion captures WHAT and WHY - don't jump to specifications or implementation
