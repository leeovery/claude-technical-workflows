---
name: start-discussion
description: "Start a technical discussion. Supports two modes: discovery mode (bare invocation) discovers research and discussions; bridge mode (topic provided) skips discovery for pipeline continuation."
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

## Step 1: Determine Mode

Check for arguments: topic = `$0`, work_type = `$1`

#### If topic and work_type are both provided (bridge mode)

Pipeline continuation — skip discovery and proceed directly to validation.

→ Proceed to **Step 2** (Validate Topic).

#### If only topic is provided

Set work_type based on context:
- If invoked from a feature pipeline → work_type = "feature"
- If invoked from a greenfield context → work_type = "greenfield"
- If unclear, default to "greenfield"

→ Proceed to **Step 2** (Validate Topic).

#### If no topic provided (discovery mode)

Full discovery and selection flow.

→ Load **[discovery-flow.md](references/discovery-flow.md)** and follow its instructions.

When discovery completes, it returns with a selected topic and path (research/continue/fresh).

→ Proceed to **Step 4** (Gather Context).

---

## Step 2: Validate Topic

Bridge mode validation — check if discussion already exists for this topic.

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

If resume → set path="continue", proceed to **Step 3**.
If new → ask for a new topic name, then proceed to **Step 2** with new topic.

**If status is "concluded":**

> *Output the next fenced block as a code block:*

```
Discussion Concluded

The discussion for "{topic:(titlecase)}" has already concluded.
```

**STOP.** Do not proceed — terminal condition. Suggest `/start-specification` to continue to spec.

#### If no collision

→ Proceed to **Step 3**.

---

## Step 3: Gather Initial Context (Bridge Mode)

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

→ Proceed to **Step 5** (Invoke the Skill).

---

## Step 4: Gather Context (Discovery Mode)

This step is reached from the discovery flow with a selected topic and path.

Load **[gather-context.md](references/gather-context.md)** and follow its instructions as written.

→ Proceed to **Step 5**.

---

## Step 5: Invoke the Skill

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
