---
description: Start a specification session from existing discussions. Discovers available discussions, offers consolidation assessment for multiple discussions, and invokes the technical-specification skill.
---

Invoke the **technical-specification** skill for this conversation.

## Workflow Context

This is **Phase 3** of the six-phase workflow:

| Phase | Focus | You |
|-------|-------|-----|
| 1. Research | EXPLORE - ideas, feasibility, market, business | |
| 2. Discussion | WHAT and WHY - decisions, architecture, edge cases | |
| **3. Specification** | REFINE - validate into standalone spec | ◀ HERE |
| 4. Planning | HOW - phases, tasks, acceptance criteria | |
| 5. Implementation | DOING - tests first, then code | |
| 6. Review | VALIDATING - check work against artifacts | |

**Stay in your lane**: Validate and refine discussion content into standalone specifications. Don't jump to planning, phases, tasks, or code. The specification is the "line in the sand" - everything after this has hard dependencies on it.

---

## Instructions

Follow these steps EXACTLY as written. Do not skip steps or combine them. Present output using the EXACT format shown in examples - do not simplify or alter the formatting.

Before beginning, discover existing work and gather necessary information.

## Important

Use simple, individual commands. Never combine multiple operations into bash loops or one-liners. Execute commands one at a time.

## Step 1: Discover Existing Work

Scan the codebase for discussions and specifications:

1. **Find discussions**: Look in `docs/workflow/discussion/`
   - Run `ls docs/workflow/discussion/` to list discussion files
   - Each file is named `{topic}.md`

2. **Check discussion status**: For each discussion file
   - Run `head -20 docs/workflow/discussion/{topic}.md` to read the frontmatter and extract the `status:` field
   - Do NOT use bash loops - run separate `head` commands for each topic

3. **Check for existing specifications**: Look in `docs/workflow/specification/`
   - Identify discussions that don't have corresponding specifications

4. **Check for cached consolidation analysis** (if multiple discussions):
   - Check if `docs/workflow/.cache/discussion-consolidation-analysis.md` exists
   - If it exists, read it to get the stored checksum from the frontmatter

5. **Compute current discussions checksum** (if multiple concluded discussions):
   - Run exactly: `cat docs/workflow/discussion/*.md 2>/dev/null | md5sum | cut -d' ' -f1`
   - IMPORTANT: Use this exact command - glob expansion is alphabetically sorted by default
   - Do NOT modify or "simplify" this command - checksum must be deterministic
   - Store this value to compare with the cached checksum

## Step 2: Check Prerequisites

**If no discussions exist:**

```
No discussions found in docs/workflow/discussion/

The specification phase requires a completed discussion. Please run /workflow:start-discussion first to document the technical decisions, edge cases, and rationale before creating a specification.
```

Stop here and wait for the user to acknowledge.

## Step 3: Present Options

Show what you found:

```
Discussions found:
  {topic-1} - Concluded - ready for specification
  {topic-2} - Exploring - not ready for specification
  {topic-3} - Concluded - specification exists
```

**Important:** Only concluded discussions should proceed to specification. If a discussion is still exploring, advise the user to complete the discussion phase first.

**If only ONE concluded discussion is ready:** Skip to Step 4 (single-source path).

**If MORE THAN ONE concluded discussion is ready:** Proceed to Step 3A (consolidation assessment).

---

## Step 3A: Consolidation Assessment (Multiple Discussions)

When multiple concluded discussions exist, offer to assess how they should be organized into specifications.

```
You have {N} concluded discussions ready for specification.

Would you like me to assess how these might be combined into specifications?

1. **Yes, assess them** - I'll analyze all discussions for natural groupings
2. **No, proceed individually** - Create specifications 1:1 with discussions

Which approach?
```

**If user chooses individual:** Skip to Step 4 and ask which discussion to specify.

**If user chooses assessment:** Proceed to Step 3A.1.

### Step 3A.1: Gather Context for Analysis

Before analyzing, ask:

```
Before I analyze the discussions, is there anything about your project structure or how these topics relate that would help me group them appropriately?

(This is optional - just press enter to skip)
```

Wait for response (or skip).

### Step 3A.2: Check Cache Validity

Compare the current discussions checksum (computed in Step 1.5) with the cached checksum:

**If cache exists AND checksums match:**
```
Using cached analysis

Discussion documents unchanged since last analysis ({date from cache}).
Loading previously identified groupings...

To force a fresh analysis, enter: refresh
```

Then load the groupings from the cache file and skip to Step 3A.4 (Present Options).

**If cache missing OR checksums differ:**
```
Analyzing discussions...
```

Proceed to Step 3A.3 (Full Analysis).

### Step 3A.3: Full Analysis (when cache invalid)

**This step is critical. You MUST read every concluded discussion document thoroughly.**

For each concluded discussion:
1. Read the ENTIRE document (not just frontmatter)
2. Understand the decisions, systems, and concepts it defines
3. Note dependencies on or references to other discussions
4. Identify shared data structures, entities, or behaviors

Then analyze coupling between discussions:
- **Data coupling**: Discussions that define or depend on the same data structures
- **Behavioral coupling**: Discussions where one's implementation requires another
- **Conceptual coupling**: Discussions that address different facets of the same problem

Group discussions that are tightly coupled - they should become a single specification because their decisions are inseparable.

**Save to cache:**
After analysis, ensure `.cache` directory exists: `mkdir -p docs/workflow/.cache`

Create/update `docs/workflow/.cache/discussion-consolidation-analysis.md`:

```markdown
---
checksum: {computed_checksum}
generated: {ISO date}
discussion_files:
  - {topic1}.md
  - {topic2}.md
---

# Discussion Consolidation Analysis

## Recommended Groupings

### {Suggested Specification Name}
- **{topic-a}**: {why it belongs in this group}
- **{topic-b}**: {why it belongs in this group}
- **{topic-c}**: {why it belongs in this group}

**Coupling**: {Brief explanation of what binds these together - shared data, dependencies, etc.}

### {Another Specification Name}
- **{topic-d}**: {why it belongs}
- **{topic-e}**: {why it belongs}

**Coupling**: {Brief explanation}

## Independent Discussions
- **{topic-f}**: {Why this stands alone - no strong coupling to others}

## Analysis Notes
{Any additional context about the relationships discovered}
```

### Step 3A.4: Present Options

Present the analysis and options:

**If using cached analysis:**
```
Cached analysis (discussions unchanged since {date})

{Display the Recommended Groupings section from cache}

How would you like to proceed?

1. **Combine as recommended** - Create specifications per the groupings above
2. **Combine differently** - Tell me your preferred groupings
3. **Single specification** - Consolidate all discussions into one spec
4. **Individual specifications** - Create 1:1 (I'll ask which to start with)

(Or enter 'refresh' to re-analyze)
```

**If fresh analysis:**
```
Analysis complete (cached for future sessions)

{Display the Recommended Groupings section}

How would you like to proceed?

1. **Combine as recommended** - Create specifications per the groupings above
2. **Combine differently** - Tell me your preferred groupings
3. **Single specification** - Consolidate all discussions into one spec
4. **Individual specifications** - Create 1:1 (I'll ask which to start with)
```

Wait for user to choose.

### Step 3A.5: Handle Choices

**If "Combine as recommended":**
- Confirm the first specification to create
- Proceed to Step 4 with the grouped sources

**If "Combine differently":**
- Ask user to describe their preferred groupings
- Confirm understanding
- Proceed to Step 4 with user-specified sources

**If "Single specification":**
- Ask for a name for the unified specification
- Proceed to Step 4 with all discussions as sources

**If "Individual specifications":**
- Ask which discussion to specify first
- Proceed to Step 4 with single source

**If "refresh":**
- Delete the cache file: `rm docs/workflow/.cache/discussion-consolidation-analysis.md`
- Return to Step 3A.3 (Full Analysis)
- Inform user: "Refreshing analysis..."

---

## Step 4: Gather Additional Context

Ask:
- Any additional context or priorities to consider?
- Any constraints or changes since the discussion(s) concluded?
- Are there any existing partial plans or related documentation I should review?

## Step 5: Invoke the Skill

After completing the steps above, this command's purpose is fulfilled.

Invoke the [technical-specification](../skills/technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

**Example handoff (single source):**
```
Specification session for: {topic}
Source: docs/workflow/discussion/{topic}.md
Output: docs/workflow/specification/{topic}.md
Additional context: {summary of user's answers from Step 4}

Invoke the technical-specification skill.
```

**Example handoff (multiple sources):**
```
Specification session for: {specification-name}

Sources:
- docs/workflow/discussion/{topic-1}.md
- docs/workflow/discussion/{topic-2}.md
- docs/workflow/discussion/{topic-3}.md

Output: docs/workflow/specification/{specification-name}.md
Additional context: {summary of user's answers from Step 4}

Invoke the technical-specification skill.
```

---

## Notes

- Ask questions clearly and wait for responses before proceeding
- The specification phase validates and refines discussion content into standalone documents
- When multiple sources are provided, the skill will extract exhaustively from ALL of them
- Attribution in the specification should trace content back to its source discussion(s)
