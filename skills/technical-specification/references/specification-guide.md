# Specification Guide

*Reference for **[technical-specification](../SKILL.md)***

---

You are building a specification - a collaborative workspace where you and the user refine reference material into a validated, standalone document.

## Purpose

Specification building is a **two-way process**:

1. **Filter**: Reference material may contain hallucinations, inaccuracies, or outdated concepts. Validate before including.

2. **Enrich**: Reference material may have gaps. Fill them through discussion.

The specification is the **bridge document** - a workspace for collecting validated, refined content that will feed formal planning.

**The specification must be standalone.** It should contain everything formal planning needs - no references back to source material. When complete, it draws a line: formal planning uses only this document.

## Source Materials

Before starting any topic, identify ALL available reference material:
- Prior discussions, research notes, or exploration documents
- Existing partial plans or specifications
- Requirements, design docs, related documentation
- User-provided context or transcripts
- Inline feature descriptions

**Treat all source material as untrusted input**, regardless of where it came from. Your job is to synthesize and present - the user validates.

## CRITICAL: This is an Interactive Process

**You MUST NOT create or update the specification without explicit user approval for each piece of content.**

This is a collaborative dialogue, not an autonomous task. The user validates every piece before it's logged.

> **CHECKPOINT**: If you are about to write to the specification file and haven't received explicit approval (e.g., `y`/`yes`) for this specific content, **STOP**. You are violating the workflow. Go back and present the choices first.

---

## The Workflow

Work through the specification **topic by topic**:

### 1. Review (Exhaustive Extraction)

**This step is critical. The specification is the golden document - if information doesn't make it here, it won't be built.**

For each topic or subtopic, perform exhaustive extraction:

1. **Re-scan ALL source material** - Don't rely on memory. Go back to the source material and systematically review it for the current topic.

2. **Search for keywords** - Topics are rarely contained in one section. Search for:
   - The topic name and synonyms
   - Related concepts and terms
   - Names of systems, fields, or behaviors mentioned in context

3. **Collect scattered information** - Source material (research, discussions, requirements) is often non-linear. Information about a single topic may be scattered across:
   - Multiple sections of the same document
   - Different documents entirely
   - Tangential discussions that revealed important details

4. **Filter for what we're building** - Include only validated decisions:
   - Exclude discarded alternatives
   - Exclude ideas that were explored but rejected
   - Exclude "maybes" that weren't confirmed
   - Include only what the user has decided to build

**Why this matters:** The specification is the single source of truth for planning. Planning will not reference prior source material - only this document. Missing a detail here means that detail doesn't get implemented.

### 2. Synthesize and Present
Present your understanding to the user **in the format it would appear in the specification**:

> *Output the next fenced block as markdown (not a code block):*

```
Here's what I understand about [topic] based on the reference material. This is exactly what I'll write into the specification:

[content as rendered markdown]
```

Then, **separately from the content above** (clear visual break):

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
**To proceed:**
- **`y`/`yes`** — Approved. I'll add the above to the specification **verbatim** (exactly as shown, no modifications).
- **Or tell me what to change.**
· · · · · · · · · · · ·
```

Content and choices must be visually distinct (not run together).

> **CHECKPOINT**: After presenting, you MUST STOP and wait for the user's response. Do NOT proceed to logging. Do NOT present the next topic. WAIT.

### 3. Discuss and Refine
Work through the content together:
- Validate what's accurate
- Remove what's wrong, outdated, or hallucinated
- Add what's missing through brief discussion
- **Course correct** based on knowledge from subsequent project work
- Refine wording and structure

This is a **human-level conversation**, not form-filling. The user brings context from across the project that may not be in the reference material - decisions from other topics, implications from later work, or knowledge that can't all fit in context.

### 4. STOP - Wait for Explicit Approval

**DO NOT PROCEED TO LOGGING WITHOUT EXPLICIT USER APPROVAL.**

**What counts as approval:**
- **`y`/`yes`** - the standard confirmation you present as a choice
- Or equivalent explicit confirmation: "Approved", "Add it", "That's good"

**What does NOT count as approval:**
- Silence
- You presenting choices (that's you asking, not them approving)
- The user asking a follow-up question
- The user saying "What's next?" or "Continue"
- The user making a minor comment without explicit approval
- ANY response that isn't explicit confirmation

**If you are uncertain, ASK:** "Ready to log it, or do you want to change something?"

> **CHECKPOINT**: If you are about to write to the specification and the user's last message was not explicit approval, **STOP**. You are violating the workflow. Present the choices again.

### 5. Log When Approved
Only after receiving explicit approval do you write to the specification - **verbatim** as presented and approved. No silent modifications.

### 6. Repeat
Move to the next topic.

## Context Resurfacing

When you discover information that affects **already-logged topics**, resurface them. Even mid-discussion - interrupt, flag what you found, and discuss whether it changes anything.

If it does: summarize what's changing in the chat, then re-present the full updated topic. The summary is for discussion only - the specification just gets the clean replacement. **Standard workflow applies: user approves before you update.**

> **CHECKPOINT**: Even when resurfacing content, you MUST NOT update the specification until the user explicitly approves the change. Present the updated version, wait for approval, then update.

This is encouraged. Better to resurface and confirm "already covered" than let something slip past.

## The Specification Document

> **CHECKPOINT**: You should NOT be creating or writing to this file unless you have explicit user approval for specific content. If you're about to create this file with content you haven't presented and had approved, **STOP**. That violates the workflow.

Create `docs/workflow/specification/{topic}/specification.md`

This is a single file per topic. Structure is **flexible** - organize around phases and subject matter, not rigid sections. This is a working document.

Suggested skeleton:

```markdown
---
topic: {topic-name}
status: in-progress
type: feature
date: YYYY-MM-DD  # Use today's actual date
review_cycle: 0
finding_gate_mode: gated
sources:
  - name: discussion-one
    status: incorporated
  - name: discussion-two
    status: pending
---

# Specification: [Topic Name]

## Specification

[Validated content accumulates here, organized by topic/phase]

---

## Working Notes

[Optional - capture in-progress discussion if needed]
```

### Frontmatter Fields

- **topic**: Kebab-case identifier matching the directory name
- **status**: `in-progress` (building) or `concluded` (complete)
- **type**: `feature` (something to build) or `cross-cutting` (patterns/policies)
- **date**: Last updated date
- **review_cycle**: Current review cycle number (starts at 0, incremented each review cycle). Missing field treated as 0.
- **sources**: Array of source discussions with incorporation status (see below)

### Sources and Incorporation Status

**All specifications must track their sources**, even when built from a single discussion. This enables proper tracking when additional discussions are later added to the same grouping.

When a specification is built from discussion(s), track each source with its incorporation status:

```yaml
sources:
  - name: auth-flow
    status: incorporated
  - name: api-design
    status: pending
```

**Status values:**
- `pending` - Source has been selected for this specification but content extraction is not complete
- `incorporated` - Source content has been fully extracted and woven into the specification

**When to update source status:**

1. **When creating the specification**: All sources start as `pending`
2. **After completing exhaustive extraction from a source**: Mark that source as `incorporated`
3. **When adding a new source to an existing spec**: Add it with `status: pending`

**How to determine if a source is incorporated:**

A source is `incorporated` when you have:
- Performed exhaustive extraction (reviewed ALL content in the source for relevant material)
- Presented and logged all relevant content from that source
- No more content from that source needs to be extracted

**Important**: The specification's overall `status: concluded` should only be set when:
- All sources are marked as `incorporated`
- Both review phases are complete
- User has signed off

If a new source is added to a concluded specification (via grouping analysis), the specification effectively needs updating - even if the file still says `status: concluded`, the presence of `pending` sources indicates work remains.

## Specification Types

The `Type` field distinguishes between specifications that result in standalone implementation work versus those that inform how other work is done.

### Feature Specifications (`type: feature`)

Feature specifications describe something to **build** - a concrete piece of functionality with its own implementation plan.

**Examples:**
- User authentication system
- Order processing pipeline
- Notification service
- Dashboard analytics

**Characteristics:**
- Results in a dedicated implementation plan
- Has concrete deliverables (code, APIs, UI)
- Can be planned with phases, tasks, and acceptance criteria
- Progress is measurable ("the feature is done")

**This is the default type.** If not specified, assume `feature`.

### Cross-Cutting Specifications (`type: cross-cutting`)

Cross-cutting specifications describe **patterns, policies, or architectural decisions** that inform how features are built. They don't result in standalone implementation - instead, they're referenced by feature specifications and plans.

**Examples:**
- Caching strategy
- Rate limiting policy
- Error handling conventions
- Logging and observability standards
- API versioning approach
- Security patterns

**Characteristics:**
- Does NOT result in a dedicated implementation plan
- Defines "how to do things" rather than "what to build"
- Referenced by multiple feature specifications
- Implementation happens within features that apply these patterns
- No standalone "done" state - the patterns are applied across features

### Why This Matters

Cross-cutting specifications go through the same Research → Discussion → Specification phases. The decisions are just as important to validate and document. The difference is what happens after:

- **Feature specs** → Planning → Implementation → Review
- **Cross-cutting specs** → Referenced by feature plans → Applied during feature implementation

When planning a feature, the planning process surfaces relevant cross-cutting specifications as context. This ensures that a "user authentication" plan incorporates the validated caching strategy and error handling conventions.

### Determining the Type

Ask: **"Is there a standalone thing to build, or does this inform how we build other things?"**

| Question | Feature | Cross-Cutting |
|----------|---------|---------------|
| Can you demo it when done? | Yes - "here's the login page" | No - it's invisible infrastructure |
| Does it have its own UI/API/data? | Yes | No - lives within other features |
| Can you plan phases and tasks for it? | Yes | Tasks would be "apply X to feature Y" |
| Is it used by one feature or many? | Usually one | By definition, multiple |

**Edge cases:**
- A "caching service" that provides shared caching infrastructure → **Feature** (you're building something)
- "How we use caching across the app" → **Cross-cutting** (policy/pattern)
- Authentication system → **Feature**
- Authentication patterns and security requirements → **Cross-cutting**

## Critical Rules

**EXPLICIT APPROVAL REQUIRED FOR EVERY WRITE**: You MUST NOT write to the specification until the user has explicitly approved. "Presenting" is not approval. "Asking a question" is not approval. You need explicit confirmation. If uncertain, ASK. This rule is non-negotiable.

> **CHECKPOINT**: Before ANY write operation, ask yourself: "Did the user explicitly approve this specific content?" If the answer is no or uncertain, STOP and ask.

**Exhaustive extraction is non-negotiable**: Before presenting any topic, re-scan source material. Search for keywords. Collect scattered information. The specification is the golden document - planning uses only this. If you miss something, it doesn't get built.

**Log verbatim**: When approved, write exactly what was presented - no silent modifications.

**Commit frequently**: Commit at natural breaks and before any context refresh. Context refresh = lost work.

**Trust nothing without validation**: Synthesize and present, but never assume source material is correct.

## Dependencies Section

At the end of every specification, add a **Dependencies** section that identifies **prerequisites** - systems that must exist before this feature can be built.

The same workflow applies: present the dependencies section for approval, then log verbatim when approved.

### What Dependencies Are

Dependencies are **blockers** - things that must exist before implementation can begin.

Think of it like building a house: if you're specifying the roof, the walls are a dependency. You cannot build a roof without walls to support it. The walls must exist first.

**The test**: "If system X doesn't exist, can we still build this feature?"
- If **no** → X is a dependency
- If **yes** → X is not a dependency (even if the systems work together)

### What Dependencies Are NOT

**Do not list systems just because they:**
- Work together with this feature
- Share data or communicate with this feature
- Are related or in the same domain
- Would be nice to have alongside this feature

Two systems that cooperate are not necessarily dependent. A notification system and a user preferences system might work together (preferences control notification settings), but if you can build the notification system with hardcoded defaults and add preference integration later, then preferences are not a dependency.

### How to Identify Dependencies

Review the specification for cases where implementation is **literally blocked** without another system:

- **Data that must exist first** (e.g., "FK to users" → User model must exist, you can't create the FK otherwise)
- **Events you consume** (e.g., "listens for payment.completed" → Payment system must emit this event)
- **APIs you call** (e.g., "fetches inventory levels" → Inventory API must exist)
- **Infrastructure requirements** (e.g., "stores files in S3" → S3 bucket configuration must exist)

**Do not include** systems where you merely reference their concepts or where integration could be deferred.

### Categorization

**Required**: Implementation cannot start without this. The code literally cannot be written.

**Partial Requirement**: Only specific elements are needed, not the full system. Note the minimum scope that unblocks implementation.

### Format

## Dependencies

Prerequisites that must exist before implementation can begin:

### Required

| Dependency | Why Blocked | What's Unblocked When It Exists |
|------------|-------------|--------------------------------|
| **[System Name]** | [Why implementation literally cannot proceed] | [What parts of this spec can then be built] |

### Partial Requirement

| Dependency | Why Blocked | Minimum Scope Needed |
|------------|-------------|---------------------|
| **[System Name]** | [Why implementation cannot proceed] | [Specific subset that unblocks us] |

### Notes

- [What can be built independently, without waiting]
- [Workarounds if dependencies don't exist yet]

### Purpose

This section feeds into the planning phase, where dependencies become blocking relationships between epics/phases. It helps sequence implementation correctly.

**Key distinction**: This is about sequencing what must come first, not mapping out what works together. A feature may integrate with many systems - only list the ones that block you from starting.

## Final Specification Review

After documenting dependencies, perform a **final comprehensive review** in two phases:

1. **Phase 1 - Input Review**: Compare the specification against all source material to catch anything missed from discussions, research, and requirements
2. **Phase 2 - Gap Analysis**: Review the specification as a standalone document for gaps, ambiguity, and completeness

**Why this matters**: The specification is the golden document. Plans are built from it, and those plans inform implementation. If a detail isn't in the specification, it won't make it to the plan, and therefore won't be built. Worse, the implementation agent may hallucinate to fill gaps, potentially getting it wrong. The goal is a specification robust enough that an agent or human could pick it up, create plans, break it into tasks, and write the code.

### Review Tracking Files

To ensure analysis isn't lost during context refresh, create tracking files that capture your findings. These files persist your analysis so work can continue across sessions.

**Location**: Store tracking files in the specification topic directory (`docs/workflow/specification/{topic}/`), cycle-numbered:
- `review-input-tracking-c{N}.md` — Phase 1 findings for cycle N
- `review-gap-analysis-tracking-c{N}.md` — Phase 2 findings for cycle N

Tracking files are **never deleted**. After all findings are processed, mark `status: complete`. Previous cycles' files persist as analysis history.

**Format**:
```markdown
---
status: in-progress | complete
created: YYYY-MM-DD
cycle: {N}
phase: Input Review | Gap Analysis
topic: [Topic Name]
---

# Review Tracking: [Topic Name] - [Phase]

## Findings

### 1. [Brief Title]

**Source**: [Where this came from - file/section reference, or "Specification analysis" for Phase 2]
**Category**: Enhancement to existing topic | New topic | Gap/Ambiguity
**Affects**: [Which section(s) of the specification]

**Details**:
[Explanation of what was found and why it matters]

**Proposed Addition**:
[What you would add to the specification - leave blank until discussed]

**Resolution**: Pending | Approved | Adjusted | Skipped
**Notes**: [Any discussion notes or adjustments made]

---

### 2. [Next Finding]
...
```

**Workflow with Tracking Files**:
1. Complete your analysis and create the tracking file with all findings
2. Present the summary to the user (from the tracking file)
3. Work through items one at a time:
   - Present the item
   - Discuss and refine
   - Get approval
   - Log to specification
   - Update the tracking file: mark resolution, add notes
4. After all items resolved, mark tracking file `status: complete`
5. Proceed to the next phase (or re-loop prompt)

**Why tracking files**: If context refreshes mid-review, you can read the tracking file and continue where you left off. The tracking file shows which items are resolved and which remain. This is especially important when reviews surface 10-20 items that need individual discussion.

---

### Review Cycle Gate

Each review cycle runs Phase 1 (Input Review) + Phase 2 (Gap Analysis) as a pair. Always start here.

Increment `review_cycle` in the specification frontmatter and commit.

→ If `review_cycle <= 3`, proceed directly to **Phase 1: Input Review**.

If `review_cycle > 3`:

**Do NOT skip review autonomously.** This gate is an escape hatch for the user — not a signal to stop. The expected default is to continue running review until no issues are found. Present the choice and let the user decide.

**Review cycle {N}**

Review has run {N-1} times so far. You can continue (recommended if issues were still found last cycle) or skip to completion.

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`p`/`proceed`** — Continue review *(default)*
- **`s`/`skip`** — Skip review, proceed to completion
· · · · · · · · · · · ·
```

**STOP.** Wait for user choice. You MUST NOT choose on the user's behalf.

- **`proceed`**: → Continue to **Phase 1: Input Review**.
- **`skip`**: → Jump to **Completion**.

---

### Phase 1: Input Review

Compare the specification against all source material to catch anything that was missed from discussions, research, and requirements.

#### The Review Process

1. **Re-read ALL source material** - Go back to every source document, discussion, research note, and reference. Don't rely on memory.

2. **Compare systematically** - For each piece of source material:
   - What topics does it cover?
   - Are those topics fully captured in the specification?
   - Are there details, edge cases, or decisions that didn't make it?

3. **Search for the forgotten** - Look specifically for:
   - Edge cases mentioned in passing
   - Constraints or requirements buried in tangential discussions
   - Technical details that seemed minor at the time
   - Decisions made early that may have been overshadowed
   - Error handling, validation rules, or boundary conditions
   - Integration points or data flows mentioned but not elaborated

4. **Collect what you find** - When you discover potentially missed content, note it for your summary. You'll present all findings together after the review is complete (see "Presenting Review Findings" below).

   Categorize each finding:

   **Enhancing an existing topic** - Details that belong in an already-documented section. Note which section it would enhance.

   **An entirely missed topic** - Something that warrants its own section but was glossed over. New topics get added at the end.

5. **Never fabricate** - Every item you flag must trace back to specific source material. If you can't point to where it came from, don't suggest it. The goal is to catch missed content, not invent new requirements.

6. **User confirms before inclusion** - Standard workflow applies: present proposed additions, get approval, then log verbatim.

7. **Surface potential gaps** - After reviewing source material, consider whether the specification has gaps that the sources simply didn't address. These might be:
   - Edge cases that weren't discussed
   - Error scenarios not covered
   - Integration points that seem implicit but aren't specified
   - Behaviors that are ambiguous without clarification

   Collect these alongside the missed content from step 4. They'll be presented together in the summary (see below).

   This should be infrequent - most gaps will be caught from source material. But occasionally the sources themselves have blind spots worth surfacing.

#### Presenting Review Findings

After completing your review (steps 1-7):

1. **Create the tracking file** - Write all findings to `review-input-tracking-c{N}.md` in the specification topic directory (where N is the current review cycle)
2. **Commit the tracking file** - This ensures it survives context refresh
3. **Present findings** to the user in two stages:

**Stage 1: Summary of All Findings**

Present a numbered summary of everything you found (from your tracking file):

> *Output the next fenced block as markdown (not a code block):*

```
I've completed my final review against all source material. I found [N] items:

1. **[Brief title]**
   [2-4 line explanation: what was missed, where it came from, what it affects]

2. **[Brief title]**
   [2-4 line explanation]

3. **[Brief title]**
   [2-4 line explanation]

Let's work through these one at a time, starting with #1.
```

Each item should have enough context that the user understands what they're about to discuss - not just a label, but clarity on what was missed and why it matters.

**Stage 2: Process One Item at a Time**

For each item, present what you found, where it came from (source reference), and what you propose to add.

> *Output the next fenced block as markdown (not a code block):*

```
{proposed content for this review item}
```

Check `finding_gate_mode` in the specification frontmatter.

#### If `finding_gate_mode: auto`

Auto-approve: log verbatim, update tracking file (Resolution: Approved), commit.

> *Output the next fenced block as a code block:*

```
Item {N} of {total}: {Brief Title} — approved. Added to specification.
```

→ Proceed to the next item. After all items processed, continue to **Completing Phase 1**.

#### If `finding_gate_mode: gated`

1. **Discuss** if needed - clarify ambiguities, answer questions, refine the content
2. **Present for approval** - show as rendered markdown (not a code block) exactly what will be written to the specification. Then, separately, show the choices:

   > *Output the next fenced block as markdown (not a code block):*

   ```
   · · · · · · · · · · · ·
   **To proceed:**
   - **`y`/`yes`** — Approved. I'll add the above to the specification **verbatim**.
   - **`a`/`auto`** — Approve this and all remaining findings automatically
   - **Or tell me what to change.**
   · · · · · · · · · · · ·
   ```

   Content and choices must be visually distinct.

3. **Wait for explicit approval** - same rules as always: `y`/`yes` or equivalent before writing
4. **Log verbatim** when approved
5. **Update tracking file** - Mark the item's resolution (Approved/Adjusted/Skipped) and add any notes
6. **If user chose `auto`**: update `finding_gate_mode: auto` in the spec frontmatter, then process all remaining items using the auto-mode flow above → After all processed, continue to **Completing Phase 1**.
7. **Move to the next item**: "Moving to #2: [Brief title]..."

> **CHECKPOINT**: Each review item requires the full present → approve → log cycle (unless `finding_gate_mode: auto`). Do not batch multiple items together. Do not proceed to the next item until the current one is resolved (approved, adjusted, or explicitly skipped by the user).

For potential gaps (items not in source material), you're asking questions rather than proposing content. If the user wants to address a gap, discuss it, then present what you'd add for approval.

#### What You're NOT Doing in Phase 1

- **Not inventing requirements** - When surfacing gaps not in sources, you're asking questions, not proposing answers
- **Not assuming gaps need filling** - If something isn't in the sources, it may have been intentionally omitted
- **Not padding the spec** - Only add what's genuinely missing and relevant
- **Not re-litigating decisions** - If something was discussed and rejected, it stays rejected

#### Completing Phase 1

When you've:
- Systematically reviewed all source material for missed content
- Addressed any discovered gaps with the user
- Surfaced any potential gaps not covered by sources (and resolved them)
- Updated the tracking file with all resolutions

**Mark the Phase 1 tracking file as complete** — Set `status: complete` in `review-input-tracking-c{N}.md`. Do not delete it; it persists as analysis history.

Inform the user Phase 1 is complete and proceed to Phase 2: Gap Analysis.

---

### Phase 2: Gap Analysis

At this point, you've captured everything from your source materials. Phase 2 reviews the **specification as a standalone document** - looking *inward* at what's been specified, not outward at what else the product might need.

**Purpose**: Ensure that *within the defined scope*, the specification flows correctly, has sufficient detail, and leaves nothing open to interpretation or assumption. This might be a full product spec or a single feature - the scope is whatever the inputs defined. Your job is to verify that within those boundaries, an agent or human could create plans, break them into tasks, and write code without having to guess.

**Key distinction**: You're not asking "what features are missing from this product?" You're asking "within what we've decided to build, is everything clear and complete?"

#### What to Look For

Review the specification systematically for gaps *within what's specified*:

1. **Internal Completeness**
   - Workflows that start but don't show how they end
   - States or transitions mentioned but not fully defined
   - Behaviors referenced elsewhere but never specified
   - Default values or fallback behaviors left unstated

2. **Insufficient Detail**
   - Areas where an implementer would have to guess
   - Sections that are too high-level to act on
   - Missing error handling for scenarios the spec introduces
   - Validation rules implied but not defined
   - Boundary conditions for limits the spec mentions

3. **Ambiguity**
   - Vague language that could be interpreted multiple ways
   - Terms used inconsistently across sections
   - "It should" without defining what "it" is
   - Implicit assumptions that aren't stated

4. **Contradictions**
   - Requirements that conflict with each other
   - Behaviors defined differently in different sections
   - Constraints that make other requirements impossible

5. **Edge Cases Within Scope**
   - For the behaviors specified, what happens at boundaries?
   - For the inputs defined, what happens when they're empty or malformed?
   - For the integrations described, what happens when they're unavailable?

6. **Planning Readiness**
   - Could you break this into clear tasks?
   - Would an implementer know what to build?
   - Are acceptance criteria implicit or explicit?
   - Are there sections that would force an implementer to make design decisions?

#### The Review Process

1. **Read the specification end-to-end** - Not scanning, but carefully reading as if you were about to implement it

2. **For each section, ask**:
   - Is this internally complete? Does it define everything it references?
   - Is this clear? Would an implementer know exactly what to build?
   - Is this consistent? Does it contradict anything else in the spec?
   - Are there areas left open to interpretation or assumption?

3. **Collect findings** - Note each gap, ambiguity, or area needing clarification

4. **Prioritize** - Focus on issues that would block or confuse implementation of what's specified:
   - **Critical**: Would prevent implementation or cause incorrect behavior
   - **Important**: Would require implementer to guess or make design decisions
   - **Minor**: Polish or clarification that improves understanding

5. **Create the tracking file** - Write findings to `review-gap-analysis-tracking-c{N}.md` in the specification topic directory (where N is the current review cycle)

6. **Commit the tracking file** - Ensures it survives context refresh

#### Presenting Gap Analysis Findings

Follow the same two-stage presentation as Phase 1:

**Stage 1: Summary**

> *Output the next fenced block as markdown (not a code block):*

```
I've completed the gap analysis of the specification. I found [N] items:

1. **[Brief title]** (Critical/Important/Minor)
   [2-4 line explanation: what the gap is, why it matters for implementation]

2. **[Brief title]** (Critical/Important/Minor)
   [2-4 line explanation]

Let's work through these one at a time, starting with #1.
```

**Stage 2: Process One Item at a Time**

For each item, present what's missing or unclear, what questions an implementer would have, and what you propose to add.

> *Output the next fenced block as markdown (not a code block):*

```
{proposed content for this review item}
```

Check `finding_gate_mode` in the specification frontmatter.

#### If `finding_gate_mode: auto`

Auto-approve: log verbatim, update tracking file (Resolution: Approved), commit.

> *Output the next fenced block as a code block:*

```
Item {N} of {total}: {Brief Title} — approved. Added to specification.
```

→ Proceed to the next item. After all items processed, continue to **Completing Phase 2**.

#### If `finding_gate_mode: gated`

1. **Discuss** - work with the user to determine the correct specification content
2. **Present for approval** - show as rendered markdown (not a code block) exactly what will be written. Then, separately, show the choices:

   > *Output the next fenced block as markdown (not a code block):*

   ```
   · · · · · · · · · · · ·
   **To proceed:**
   - **`y`/`yes`** — Approved. I'll add the above to the specification **verbatim**.
   - **`a`/`auto`** — Approve this and all remaining findings automatically
   - **Or tell me what to change.**
   · · · · · · · · · · · ·
   ```

   Content and choices must be visually distinct.

3. **Wait for explicit approval**
4. **Log verbatim** when approved
5. **Update tracking file** - Mark resolution and add notes
6. **If user chose `auto`**: update `finding_gate_mode: auto` in the spec frontmatter, then process all remaining items using the auto-mode flow above → After all processed, continue to **Completing Phase 2**.
7. **Move to next item**

> **CHECKPOINT**: Same rules apply - each item requires explicit approval before logging (unless `finding_gate_mode: auto`). No batching.

#### What You're NOT Doing in Phase 2

- **Not expanding scope** - You're looking for gaps *within* what's specified, not suggesting features the product should have. A feature spec for "user login" doesn't need you to ask about password reset if it wasn't in scope.
- **Not gold-plating** - Only flag gaps that would actually impact implementation of what's specified
- **Not second-guessing decisions** - The spec reflects validated decisions; you're checking for clarity and completeness, not re-opening debates
- **Not being exhaustive for its own sake** - Focus on what matters for implementing *this* specification

#### Completing Phase 2

When you've:
- Reviewed the specification for completeness, clarity, and implementation readiness
- Addressed all critical and important gaps with the user
- Updated the tracking file with all resolutions

**Mark the Phase 2 tracking file as complete** — Set `status: complete` in `review-gap-analysis-tracking-c{N}.md`. Do not delete it; it persists as analysis history.

Both review phases for this cycle are now complete.

---

### Re-Loop Prompt

After Phase 2 completes, check whether either phase surfaced findings in this cycle.

#### If no findings were surfaced in either phase of this cycle

→ Skip the re-loop prompt and proceed directly to **Completion** (nothing to re-analyse).

#### If findings were surfaced

Do not skip review autonomously — present the choice and let the user decide.

> *Output the next fenced block as a code block:*

```
Review cycle {N}

Review has run {N-1} times so far.
@if(finding_gate_mode = auto and review_cycle >= 5)
Auto-review has not converged after 5 cycles — escalating for human review.
@endif
```

Check `finding_gate_mode` and `review_cycle` in the specification frontmatter.

#### If `finding_gate_mode: auto` and `review_cycle < 5`

> *Output the next fenced block as a code block:*

```
Review cycle {N} complete — findings applied. Running follow-up cycle.
```

→ Return to the **Review Cycle Gate**.

#### If `finding_gate_mode: auto` and `review_cycle >= 5`

→ Present the re-loop prompt below.

#### If `finding_gate_mode: gated`

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`r`/`reanalyse`** — Run another review cycle (Phase 1 + Phase 2)
- **`p`/`proceed`** — Proceed to completion
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If reanalyse

→ Return to the **Review Cycle Gate** to begin a fresh cycle.

#### If proceed

→ Continue to **Completion**.

---

## Completion

### Step 1: Determine Specification Type

Before asking for sign-off, assess whether this is a **feature** or **cross-cutting** specification:

**Feature specification** - Something to build:
- Has concrete deliverables (code, APIs, UI)
- Can be planned with phases, tasks, acceptance criteria
- Results in a standalone implementation

**Cross-cutting specification** - Patterns/policies that inform other work:
- Defines "how to do things" rather than "what to build"
- Will be referenced by multiple feature specifications
- Implementation happens within features that apply these patterns

Present your assessment to the user:

> *Output the next fenced block as markdown (not a code block):*

```
This specification appears to be a **[feature/cross-cutting]** specification.

[Brief rationale - e.g., "It defines a caching strategy that will inform how multiple features handle data retrieval, rather than being a standalone piece of functionality to build."]

- **Feature specs** proceed to planning and implementation
- **Cross-cutting specs** are referenced by feature plans but don't have their own implementation plan

Does this assessment seem correct?
```

Wait for user confirmation before proceeding.

### Step 2: Verify Tracking Files Complete

Before proceeding to sign-off, confirm that all review tracking files across all cycles have `status: complete`:

- `review-input-tracking-c{N}.md` — should be marked complete after each Phase 1
- `review-gap-analysis-tracking-c{N}.md` — should be marked complete after each Phase 2

If any tracking file still shows `status: in-progress`, mark it complete now.

> **CHECKPOINT**: Do not proceed to sign-off if any tracking files still show `status: in-progress`. They indicate incomplete review work.

### Step 3: Sign-Off

Once the type is confirmed and tracking files are complete:

> *Output the next fenced block as markdown (not a code block):*

```
· · · · · · · · · · · ·
- **`y`/`yes`** — Conclude specification and mark as concluded
- **Comment** — Add context before concluding
· · · · · · · · · · · ·
```

**STOP.** Wait for user response.

#### If comment

Discuss the user's context, apply any changes, then re-present the sign-off prompt above.

#### If yes

→ Proceed to **Step 4**.

### Step 4: Update Frontmatter

After user confirms, update the specification frontmatter:

```markdown
---
topic: {topic-name}
status: concluded
type: feature  # or cross-cutting
date: YYYY-MM-DD  # Use today's actual date
review_cycle: {N}
finding_gate_mode: gated
---
```

Specification is complete when:
- All topics/phases have validated content
- At least one review cycle completed with no findings, OR user explicitly chose to proceed past the re-loop prompt
- All review tracking files marked `status: complete`
- Type has been determined and confirmed
- User confirms the specification is complete
- No blocking gaps remain

---

## Self-Check: Have You Followed the Rules?

Before ANY write operation to the specification file, verify:

| Question | If No... |
|----------|----------|
| Did I present this specific content to the user? | **STOP**. Present it first. |
| Did the user explicitly approve? (e.g., `y`/`yes`) | **STOP**. Wait for approval or ask. |
| Am I writing exactly what was approved, with no additions? | **STOP**. Present any changes first. |

> **FINAL CHECK**: If you have written to the specification file and cannot answer "yes" to all three questions above for that content, you have violated the workflow. Every piece of content requires explicit user approval before logging.
