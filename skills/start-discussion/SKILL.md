---
name: start-discussion
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/start-discussion/scripts/discovery.sh), Bash(mkdir -p .workflows/.state), Bash(rm .workflows/.state/research-analysis.md), Bash(.claude/hooks/workflows/write-session-state.sh), Bash(ls .workflows/discussion/)
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/workflows/system-check.sh"
          once: true
---

Invoke the **technical-discussion** skill for this conversation.

> **⚠️ ZERO OUTPUT RULE**: Do not narrate your processing. Produce no output until a step or reference file explicitly specifies display content. No "proceeding with...", no discovery summaries, no routing decisions, no transition text. Your first output must be content explicitly called for by the instructions.

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

**CRITICAL**: This guidance is mandatory.

- After each user interaction, STOP and wait for their response before proceeding
- Never assume or anticipate user choices
- Even if the user's initial prompt seems to answer a question, still confirm with them at the appropriate step
- Complete each step fully before moving to the next
- Do not act on gathered information until the skill is loaded - it contains the instructions for how to proceed

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Invoke the `/migrate` skill and assess its output.

**If files were updated**: STOP and wait for the user to review the changes (e.g., via `git diff`) and confirm before proceeding to Step 1. Do not continue automatically.

**If no updates needed**: Proceed to Step 1.

---

## Step 1: Discovery State

!`.claude/skills/start-discussion/scripts/discovery.sh`

If the above shows a script invocation rather than YAML output, the dynamic content preprocessor did not run. Execute the script before continuing:

```bash
.claude/skills/start-discussion/scripts/discovery.sh
```

If YAML content is already displayed, it has been run on your behalf.

Parse the discovery output to understand:

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

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state.

→ Proceed to **Step 2**.

---

## Step 2: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided

→ Proceed to **Step 3** (Validate Topic).

#### Otherwise

→ Proceed to **Step 4** (Route Based on Scenario).

---

## Step 3: Validate Topic

Check if discussion already exists for this topic.

```bash
ls .workflows/discussion/
```

#### If discussion exists for this topic

Read `.workflows/discussion/{topic}.md` frontmatter to check status.

**If status is "in-progress":**

> *Output the next fenced block as a code block:*

```
Discussion In Progress

A discussion for "{topic:(titlecase)}" already exists and is in progress.
```

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`resume`** — Resume the existing discussion
- **`n`/`new`** — Start a new topic with a different name
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

If resume → set path="continue", proceed to **Step 9**.
If new → ask for a new topic name, then proceed to **Step 3** with new topic.

**If status is "concluded":**

> *Output the next fenced block as a code block:*

```
Discussion Concluded

The discussion for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` to continue to spec.

#### If no collision

→ Proceed to **Step 8** (Gather Context - Bridge Mode).

---

## Step 4: Route Based on Scenario

Use `state.scenario` from the discovery output to determine the path:

#### If scenario is "research_only" or "research_and_discussions"

Research exists and may need analysis.

→ Proceed to **Step 5**.

#### If scenario is "discussions_only"

No research exists, but discussions do. Skip research analysis.

→ Proceed to **Step 6**.

#### If scenario is "fresh"

No research or discussions exist yet.

```
Starting fresh - no prior research or discussions found.

What topic would you like to discuss?
```

**STOP.** Wait for user response.

When user responds, proceed with their topic.

→ Proceed to **Step 9** (Gather Context - Discovery Mode).

---

## Step 5: Research Analysis

Load **[research-analysis.md](references/research-analysis.md)** and follow its instructions as written.

→ Proceed to **Step 6**.

---

## Step 6: Present Options

Load **[display-options.md](references/display-options.md)** and follow its instructions as written.

→ Proceed to **Step 7**.

---

## Step 7: Handle Selection

Load **[handle-selection.md](references/handle-selection.md)** and follow its instructions as written.

→ Proceed to **Step 9** (Gather Context - Discovery Mode).

---

## Step 8: Gather Context (Bridge Mode)

> *Output the next fenced block as a code block:*

```
Starting discussion: {topic:(titlecase)}
Work type: {work_type}

What would you like to discuss? Provide some initial context:
- What's the problem or opportunity?
- What prompted this?
- Any initial thoughts or constraints?
```

**STOP.** Wait for user response.

→ Proceed to **Step 10** (Invoke the Skill).

---

## Step 9: Gather Context (Discovery Mode)

This step is reached from the discovery flow with a selected topic and path.

Load **[gather-context.md](references/gather-context.md)** and follow its instructions as written.

→ Proceed to **Step 10**.

---

## Step 10: Invoke the Skill

Before invoking the processing skill, save a session bookmark.

> *Output the next fenced block as a code block:*

```
Saving session state so Claude can pick up where it left off if the conversation is compacted.
```

```bash
.claude/hooks/workflows/write-session-state.sh \
  "{topic}" \
  "skills/technical-discussion/SKILL.md" \
  ".workflows/discussion/{topic}.md"
```

Load **[invoke-skill.md](references/invoke-skill.md)** and follow its instructions as written.
