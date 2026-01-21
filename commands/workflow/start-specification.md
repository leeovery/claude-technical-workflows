---
description: Start a specification session from existing discussions. Discovers available discussions, offers consolidation assessment for multiple discussions, and invokes the technical-specification skill.
allowed-tools: Bash(.claude/scripts/specification-discovery.sh), Bash(mkdir -p docs/workflow/.cache), Bash(rm docs/workflow/.cache/discussion-consolidation-analysis.md)
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

**CRITICAL**: After each user interaction, STOP and wait for their response before proceeding. Never assume or anticipate user choices.

---

## Step 0: Run Migrations

**This step is mandatory. You must complete it before proceeding.**

Run `/migrate-documents` and assess its output before proceeding to Step 1.

---

## Step 1: Run Discovery Script

Run the discovery script to gather current state:

```bash
.claude/scripts/specification-discovery.sh
```

This outputs structured YAML. Parse it to understand:

**From `discussions` array:**
- Each discussion's name, status, and whether it has an individual specification

**From `specifications` array:**
- Each specification's name, status, sources, and superseded_by (if applicable)
- Specifications with `status: superseded` should be noted but excluded from active counts

**From `cache` section:**
- Whether a consolidation analysis cache exists
- The `anchored_names` list - these are grouping names that have existing specifications and MUST be preserved in any regeneration

**From `cache_validity` section:**
- Whether the cache is still valid (`is_valid: true/false`)
- The reason if invalid

**IMPORTANT**: Use ONLY this script for discovery. Do NOT run additional bash commands (ls, head, cat, etc.) to gather state - the script provides everything needed.

→ Proceed to **Step 2**.

---

## Step 2: Check Prerequisites

#### If no discussions exist

```
No discussions found in docs/workflow/discussion/

The specification phase requires a completed discussion. Please run /start-discussion first to document the technical decisions, edge cases, and rationale before creating a specification.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### If discussions exist but none are concluded

```
No concluded discussions found.

The following discussions are still in progress:
  - {topic-1} (in-progress)
  - {topic-2} (in-progress)

Please complete the discussion phase before creating specifications. Run /start-discussion to continue a discussion.
```

**STOP.** Wait for user acknowledgment. Do not proceed.

#### Otherwise

At least one concluded discussion exists.

→ Proceed to **Step 3**.

---

## Step 3: Present Status & Route

Show the current state clearly. Use this EXACT format:

```
Workflow Status: Specification Phase

Discussions:
  ✓ {topic-1} - concluded - ready
  ✓ {topic-2} - concluded - ready
  ○ {topic-3} - concluded - has individual spec
  · {topic-4} - in-progress - not ready

Specifications:
  • {spec-1} (active) - sources: {topic-1}
  • {spec-2} (superseded → {other-spec}) - sources: {topic-x}

{N} concluded discussions available.
```

**Legend:**
- `✓` = concluded, no spec yet (ready to specify)
- `○` = concluded, has individual spec (can be combined or continued)
- `·` = in-progress (not ready)

#### Routing Based on State

#### If only ONE concluded discussion exists

This is the simple path - no choices needed.

```
Single concluded discussion found: {topic}
{If has spec: "An existing specification will be continued/refined."}

Proceeding with this discussion.
```

→ Skip to **Step 9: Confirm Selection** with that discussion as the source.

#### If MULTIPLE concluded discussions exist with NO existing specifications

No existing specs to continue - proceed directly to analysis.

```
{N} concluded discussions found.

Analyzing discussions for natural groupings...
```

→ Proceed to **Step 4: Gather Analysis Context**.

#### If MULTIPLE concluded discussions exist WITH existing specifications

```
What would you like to do?

1. **Continue an existing specification** - Resume work on a spec in progress
2. **Assess for groupings** - Analyze discussions for combinations

Which approach?
```

**STOP.** Wait for user response.

#### If "Continue an existing specification"

```
Which specification would you like to continue?

1. {spec-1} ({status}) - sources: {topics}
2. {spec-2} ({status}) - sources: {topics}
```

**STOP.** Wait for user to pick, then skip to **Step 9**.

#### If "Assess for groupings"

→ Proceed to **Step 4: Gather Analysis Context**.

---

## Step 4: Gather Analysis Context

```
Before I analyze the discussions, is there anything about your project structure or how these topics relate that would help me group them appropriately?

For example:
- Are certain topics part of the same feature or subsystem?
- Are there dependencies I should know about?
- Any topics that MUST stay separate?
```

**STOP.** Wait for user response. Note their input for the analysis.

→ Proceed to **Step 5**.

---

## Step 5: Check Cache Validity

Check the `cache_validity.is_valid` value from the discovery state.

#### If cache is valid

```
Using cached analysis

Discussion documents unchanged since last analysis ({cached_date}).
Loading previously identified groupings...
```

Load groupings from cache and → Skip to **Step 7: Present Grouping Options**.

#### If cache is invalid or missing

```
{Reason from cache_validity.reason}

Analyzing discussions...
```

→ Proceed to **Step 6: Analyze Discussions**.

---

## Step 6: Analyze Discussions

**This step is critical. You MUST read every concluded discussion document thoroughly.**

For each concluded discussion:
1. Read the ENTIRE document using the Read tool (not just frontmatter)
2. Understand the decisions, systems, and concepts it defines
3. Note dependencies on or references to other discussions
4. Identify shared data structures, entities, or behaviors

Then analyze coupling between discussions:
- **Data coupling**: Discussions that define or depend on the same data structures
- **Behavioral coupling**: Discussions where one's implementation requires another
- **Conceptual coupling**: Discussions that address different facets of the same problem

Group discussions that are tightly coupled - they should become a single specification because their decisions are inseparable.

#### Preserve Anchored Names

**CRITICAL**: Check the `cache.anchored_names` from discovery state. These are grouping names that have existing specifications.

When forming groupings:
- If a grouping contains a majority of the same discussions as an anchored name's spec, you MUST reuse that anchored name
- Only create new names for genuinely new groupings with no overlap
- If an anchored spec's discussions are now scattered across multiple new groupings, note this as a **naming conflict** to present to the user

#### Save to Cache

After analysis, create the cache directory if needed:
```bash
mkdir -p docs/workflow/.cache
```

Write to `docs/workflow/.cache/discussion-consolidation-analysis.md`:

```markdown
---
checksum: {checksum from current_state.discussions_checksum}
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

**Coupling**: {Brief explanation of what binds these together}

### {Another Specification Name}
- **{topic-d}**: {why it belongs}
- **{topic-e}**: {why it belongs}

**Coupling**: {Brief explanation}

## Independent Discussions
- **{topic-f}**: {Why this stands alone - no strong coupling to others}

## Analysis Notes
{Any additional context about the relationships discovered}
{Note any naming conflicts with anchored specs here}
```

→ Proceed to **Step 7**.

---

## Step 7: Present Grouping Options

Present the groupings with FULL status information.

For each grouping, show:
- The grouping name
- Whether a specification already exists for this grouping
- Each discussion in the grouping and whether it has an individual spec

**Format:**

```
{Fresh analysis / Cached analysis} complete

Recommended Groupings:

### 1. {Grouping Name} {if spec exists: "(specification exists)"}
| Discussion | Status |
|------------|--------|
| {topic-a} | discussion only |
| {topic-b} | has individual spec |
| {topic-c} | discussion only |

Coupling: {explanation}

### 2. {Another Grouping}
| Discussion | Status |
|------------|--------|
| {topic-d} | discussion only |

Coupling: {explanation}

### Independent
- {topic-f}: standalone

---

How would you like to proceed?

1. **Proceed as recommended** - I'll ask which to start with
2. **Combine differently** - Tell me your preferred groupings
3. **Single specification** - Consolidate ALL into one unified spec
4. **Individual specifications** - Create 1:1 specs (I'll ask which to start)

(Enter 'refresh' to re-analyze)
```

**STOP.** Wait for user to choose.

→ Based on choice, proceed to **Step 8**.

---

## Step 8: Select Grouping

Based on user's choice from Step 7:

#### If "Proceed as recommended"

```
Which would you like to start with?

Grouped:
1. {Grouping Name A} - {N} discussions
2. {Grouping Name B} - {N} discussions (specification exists)
3. {Grouping Name C} - {N} discussions

Independent:
4. {topic-f} - standalone
5. {topic-g} - standalone
```

List ALL items from the analysis: grouped specifications first, then independent discussions. Number them consecutively.

**STOP.** Wait for user to pick a number, then proceed to **Step 9**.

#### If "Combine differently"

```
Please describe your preferred groupings. Which discussions should be combined together?
```

**STOP.** Wait for user to describe their groupings.

Confirm understanding and present as a numbered list. Check if any grouping names match existing specifications.

```
Based on your description, here are the groupings:

1. {User's Grouping A} - {topics}
2. {User's Grouping B} - {topics}

Which grouping would you like to start with?
```

**STOP.** Wait for user to pick, then proceed to **Step 9**.

#### If "Single specification"

Use "unified" as the specification name.
Check if `docs/workflow/specification/unified.md` already exists.

```
{If exists: "A unified specification already exists. Proceeding will continue/refine it."}

This will consolidate ALL {N} concluded discussions into a single specification.

Proceed with unified specification? (y/n)
```

**STOP.** Wait for user to confirm, then proceed to **Step 9** with all discussions as sources.

#### If "Individual specifications"

```
Which discussion would you like to specify?

1. {topic-1}
2. {topic-2} (has individual spec - will continue/refine)
3. {topic-3}
```

**STOP.** Wait for user to pick, then proceed to **Step 9**.

#### If "refresh"

```
Refreshing analysis...
```

Delete the cache file:
```bash
rm docs/workflow/.cache/discussion-consolidation-analysis.md
```

→ Return to **Step 6: Analyze Discussions**.

---

## Step 9: Confirm Selection

Present what will happen based on the selection:

#### If creating a NEW grouped specification (with individual specs to incorporate)

```
Creating specification: {grouping-name}

Sources:
| Type | File | Action |
|------|------|--------|
| Discussion | {topic-a}.md | Extract content |
| Discussion | {topic-b}.md | Extract content |
| Existing Spec | specification/{topic-c}.md | Incorporate and supersede |

Output: docs/workflow/specification/{grouping-name}.md

After completion:
- specification/{topic-c}.md will be marked as superseded

Proceed? (y/n)
```

#### If creating a NEW grouped specification (no existing specs)

```
Creating specification: {grouping-name}

Sources:
- docs/workflow/discussion/{topic-a}.md
- docs/workflow/discussion/{topic-b}.md
- docs/workflow/discussion/{topic-c}.md

Output: docs/workflow/specification/{grouping-name}.md

Proceed? (y/n)
```

#### If CONTINUING an existing grouped specification

```
Continuing specification: {grouping-name}

Existing: docs/workflow/specification/{grouping-name}.md (will be refined)

Sources:
- docs/workflow/discussion/{topic-a}.md
- docs/workflow/discussion/{topic-b}.md

Proceed? (y/n)
```

#### If creating/continuing an INDIVIDUAL specification

```
{Creating / Continuing} specification: {topic}

Source: docs/workflow/discussion/{topic}.md
Output: docs/workflow/specification/{topic}.md

Proceed? (y/n)
```

**STOP.** Wait for user confirmation.

**If user confirms (y):** → Proceed to **Step 10**.
**If user declines (n):** → Return to **Step 8** to select a different grouping or discussion.

---

## Step 10: Gather Additional Context

```
Before invoking the specification skill:

1. Any additional context or priorities to consider?
2. Any constraints or changes since the discussion(s) concluded?
3. Are there existing partial implementations or related documentation I should review?

(Say 'none' or 'continue' if nothing to add)
```

**STOP.** Wait for user response.

→ Proceed to **Step 11**.

---

## Step 11: Invoke the Skill

After completing all steps above, this command's purpose is fulfilled.

Invoke the [technical-specification](../../skills/technical-specification/SKILL.md) skill for your next instructions. Do not act on the gathered information until the skill is loaded - it contains the instructions for how to proceed.

#### Handoff Format

**Single source (individual specification):**

```
Specification session for: {topic}

Source: docs/workflow/discussion/{topic}.md
Output: docs/workflow/specification/{topic}.md

Additional context: {summary of user's answers from Step 10}

---
Invoke the technical-specification skill.
```

**Multiple sources (grouped specification, no existing specs to incorporate):**

```
Specification session for: {specification-name}

Sources:
- docs/workflow/discussion/{topic-1}.md
- docs/workflow/discussion/{topic-2}.md
- docs/workflow/discussion/{topic-3}.md

Output: docs/workflow/specification/{specification-name}.md

Additional context: {summary of user's answers from Step 10}

---
Invoke the technical-specification skill.
```

**Multiple sources WITH existing specs to incorporate:**

```
Specification session for: {specification-name}

Source discussions:
- docs/workflow/discussion/{topic-1}.md
- docs/workflow/discussion/{topic-2}.md

Existing specifications to incorporate:
- docs/workflow/specification/{topic-3}.md (covers: {topic-3} discussion)

Output: docs/workflow/specification/{specification-name}.md

Context: This consolidates multiple sources. The existing {topic-3}.md specification should be incorporated - extract and adapt its content alongside the discussion material. The result should be a unified specification, not a simple merge.

After the {specification-name} specification is complete, mark the incorporated specs as superseded by updating their frontmatter:

    status: superseded
    superseded_by: {specification-name}

Additional context: {summary of user's answers from Step 10}

---
Invoke the technical-specification skill.
```

**Continuing an existing specification:**

```
Specification session for: {specification-name}

Continuing existing: docs/workflow/specification/{specification-name}.md

Sources for reference:
- docs/workflow/discussion/{topic-1}.md
- docs/workflow/discussion/{topic-2}.md

Context: This specification already exists. Review and refine it based on the source discussions and any new context provided.

Additional context: {summary of user's answers from Step 10}

---
Invoke the technical-specification skill.
```

---

## Notes

- Ask questions clearly and STOP after each to wait for responses
- Only concluded discussions should proceed to specification
- When multiple sources are provided, the skill will extract exhaustively from ALL of them
- Attribution in the specification should trace content back to its source discussion(s)
- Superseded specifications are excluded from future planning phases
- The specification is the "line in the sand" - be thorough, not hasty
