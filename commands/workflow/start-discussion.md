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

## Step 2: Check Prerequisites

#### If nothing exists (no research AND no discussions)

```
Starting fresh - no prior research or discussions found.

What topic would you like to discuss?
```

**STOP.** Wait for user to provide a topic.

→ Skip to **Step 7: Gather Context** with the fresh topic path.

#### Otherwise (research and/or discussions exist)

→ Proceed to **Step 3**.

---

## Step 3: Check Cache Validity

Skip this step if no research files exist (proceed directly to **Step 5**).

Check the `cache_validity.is_valid` value from the discovery state.

#### If cache is valid

```
Using cached research analysis (unchanged since {cached_date}).
```

Load topics from the `cache.topics` array.

→ Skip to **Step 5: Present Status & Options**.

#### If cache is invalid or missing

```
{Reason from cache_validity.reason}

Analyzing research documents...
```

→ Proceed to **Step 4: Analyze Research**.

---

## Step 4: Analyze Research

**This step is critical. You MUST read every research document thoroughly.**

For each research file:
1. Read the ENTIRE document using the Read tool
2. Extract key themes and potential discussion topics
3. For each theme, note:
   - Source file and relevant line numbers
   - 1-2 sentence summary
   - Key questions or decisions that need discussion

**Be thorough**: This analysis will be cached. Identify ALL potential topics including:
- Major architectural decisions
- Technical trade-offs mentioned
- Open questions or concerns raised
- Implementation approaches discussed
- Integration points with external systems
- Security or performance considerations
- Edge cases or error handling mentioned

#### Save to Cache

Create the cache directory if needed:
```bash
mkdir -p docs/workflow/.cache
```

Write to `docs/workflow/.cache/research-analysis.md`:

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

→ Proceed to **Step 5**.

---

## Step 5: Present Status & Options

Present everything discovered to help the user make an informed choice.

Show the current state clearly. Use this EXACT format:

```
Workflow Status: Discussion Phase

{If research exists with topics:}
Research Topics:
  1. {Theme name}
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"
     {✓ has discussion | ✗ undiscussed}

  2. {Another theme}
     Source: {filename}.md (lines {start}-{end})
     "{Brief summary}"
     {✓ has discussion | ✗ undiscussed}

{If discussions exist:}
Existing Discussions:
  • {topic-1} - {status}
    "{Brief description}"

  • {topic-2} - concluded
    "{Brief description}"

{Summary line}
{N} research topics, {M} existing discussions ({X} concluded)
```

**Legend:**
- `✓ has discussion` = A discussion already exists for this research topic
- `✗ undiscussed` = No discussion yet (potential new discussion)

#### Present Options Based on State

#### If research AND discussions exist

```
How would you like to proceed?

1. **From research** - Pick a topic number above
2. **Continue discussion** - Name one above (e.g., "continue {topic}")
3. **Fresh topic** - Describe what you want to discuss
4. **refresh** - Force fresh research analysis

Which approach?
```

**STOP.** Wait for user response.

#### If ONLY research exists (no discussions)

```
How would you like to proceed?

1. **From research** - Pick a topic number above
2. **Fresh topic** - Describe what you want to discuss
3. **refresh** - Force fresh research analysis

Which approach?
```

**STOP.** Wait for user response.

#### If ONLY discussions exist (no research)

```
How would you like to proceed?

1. **Continue discussion** - Name one above (e.g., "continue {topic}")
2. **Fresh topic** - Describe what you want to discuss

Which approach?
```

**STOP.** Wait for user response.

→ Based on choice, proceed to **Step 6**.

---

## Step 6: Route Based on Choice

#### If user chose "From research" (e.g., "1", "research 1", topic name)

**If user specified a topic inline:**
- Identify the selected topic from Step 5's numbered list
- Note the source file and line numbers
- → Proceed to **Step 7: Gather Context** with research path

**If user just said "from research" without specifying:**

```
Which research topic would you like to discuss? (Enter a number or topic name)
```

**STOP.** Wait for response, then → Proceed to **Step 7: Gather Context** with research path.

#### If user chose "Continue discussion" (e.g., "continue auth-flow")

**If user specified a discussion inline:**
- Identify the selected discussion from Step 5's list
- → Proceed to **Step 7: Gather Context** with continue path

**If user just said "continue discussion" without specifying:**

```
Which discussion would you like to continue?
```

**STOP.** Wait for response, then → Proceed to **Step 7: Gather Context** with continue path.

#### If user chose "Fresh topic"

→ Proceed to **Step 7: Gather Context** with fresh path.

#### If user chose "refresh"

```
Refreshing analysis...
```

Delete the cache file:
```bash
rm docs/workflow/.cache/research-analysis.md
```

→ Return to **Step 4: Analyze Research**.

---

## Step 7: Gather Context

#### If starting NEW discussion (from research or fresh topic)

```
New discussion: {topic}

Before we begin:

1. What's the core problem or decision we need to work through?
2. Any constraints or context I should know about?
3. Are there specific files in the codebase I should review first?
```

**STOP.** Wait for user response.

→ Proceed to **Step 8**.

#### If CONTINUING existing discussion

Read the existing discussion document first, then ask:

```
Continuing: {topic}

I've read the existing discussion (status: {status}).

What would you like to focus on in this session?
```

**STOP.** Wait for user response.

→ Proceed to **Step 8**.

---

## Step 8: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-discussion](../../skills/technical-discussion/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

**From research:**

```
Discussion session for: {topic}
Output: docs/workflow/discussion/{topic-slug}.md

Research reference:
Source: docs/workflow/research/{filename}.md (lines {start}-{end})
Summary: {the 1-2 sentence summary from the research analysis}

Additional context: {summary of user's answers from Step 7}

---
Invoke the technical-discussion skill.
```

**Continuing existing:**

```
Discussion session for: {topic}
Source: docs/workflow/discussion/{topic}.md (continuing)
Output: docs/workflow/discussion/{topic}.md

Focus: {what user wants to focus on from Step 7}

---
Invoke the technical-discussion skill.
```

**Fresh topic:**

```
Discussion session for: {topic}
Source: fresh
Output: docs/workflow/discussion/{topic-slug}.md

Additional context: {summary of user's answers from Step 7}

---
Invoke the technical-discussion skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Discussion captures WHAT and WHY - don't jump to specifications or implementation
- The cache system avoids re-analyzing unchanged research documents
