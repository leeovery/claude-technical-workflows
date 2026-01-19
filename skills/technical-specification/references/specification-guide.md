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

> **CHECKPOINT**: If you are about to write to the specification file and haven't received explicit approval (e.g., "Log it") for this specific content, **STOP**. You are violating the workflow. Go back and present the choices first.

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

> "Here's what I understand about [topic] based on the reference material. This is exactly what I'll write into the specification:
>
> [content as it would appear]

Then present two explicit choices:

> **To proceed, choose one:**
> - **"Log it"** - I'll add the above to the specification **verbatim** (exactly as shown, no modifications)
> - **"Adjust"** - Tell me which part to change and what you want it to say instead

**Do not paraphrase these choices.** Present them exactly as written so users always know what to expect.

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
- **"Log it"** - the standard confirmation you present as a choice
- Or equivalent explicit confirmation: "Yes", "Approved", "Add it", "That's good"

**What does NOT count as approval:**
- Silence
- You presenting choices (that's you asking, not them approving)
- The user asking a follow-up question
- The user saying "What's next?" or "Continue"
- The user making a minor comment without explicit approval
- ANY response that isn't explicit confirmation

**If you are uncertain, ASK:** "Would you like me to log it, or do you want to adjust something?"

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

Create `docs/workflow/specification/{topic}.md`

This is a single file per topic. Structure is **flexible** - organize around phases and subject matter, not rigid sections. This is a working document.

Suggested skeleton:

```markdown
# Specification: [Topic Name]

**Status**: Building specification
**Type**: feature | cross-cutting
**Last Updated**: YYYY-MM-DD *(use today's actual date)*

---

## Specification

[Validated content accumulates here, organized by topic/phase]

---

## Working Notes

[Optional - capture in-progress discussion if needed]
```

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

## After Context Refresh

Read the specification. It contains validated, approved content. Trust it - you built it together with the user.

If working notes exist, they show where you left off.

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

After documenting dependencies, perform a **final comprehensive review** of the entire specification against all source material. This is your last chance to catch anything that was missed.

**Why this matters**: The specification is the golden document. Plans are built from it. If a detail isn't in the specification, it won't be built - regardless of whether it was in the source material.

### The Review Process

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

4. **Flag what you find** - When you discover potentially missed content, present it to the user. **Do NOT add it to the specification without explicit approval.**

   > **CHECKPOINT**: If you found missed content and are about to add it to the specification without presenting it first and receiving explicit approval, **STOP**. Every addition requires the present → approve → log cycle, even during final review.

   There are two cases:

   **Enhancing an existing topic** - Details that belong in an already-documented section:

   > "During my final review, I found additional detail about [existing topic] that isn't captured. From [source]:
   >
   > [quote or summary from source material]
   >
   > I'd add this to the [section name] section. Would you like me to include it, or show you the full section with this addition first?"

   If the user wants to see context, present the entire section with the new content clearly marked (e.g., with a comment like `<!-- NEW -->` or by calling it out before the block).

   **An entirely missed topic** - Something that warrants its own section but was glossed over:

   > "During my final review, I found [topic] discussed in [source] that doesn't have coverage in the specification:
   >
   > [quote or summary from source material]
   >
   > This would be a new section. Should I add it?"

   In both cases, you know where the content belongs - existing topics get enhanced in place, new topics get added at the end.

5. **Never fabricate** - Every item you flag must trace back to specific source material. If you can't point to where it came from, don't suggest it. The goal is to catch missed content, not invent new requirements.

6. **User confirms before inclusion** - Standard workflow applies: present proposed additions, get approval, then log verbatim.

7. **Surface potential gaps** - After reviewing source material, consider whether the specification has gaps that the sources simply didn't address. These might be:
   - Edge cases that weren't discussed
   - Error scenarios not covered
   - Integration points that seem implicit but aren't specified
   - Behaviors that are ambiguous without clarification

   Present these as a batch for the user to triage:

   > "I've identified some potential gaps that aren't covered in the source material:
   >
   > 1. **[Gap A]** - [brief description of what's unclear/missing]
   > 2. **[Gap B]** - [brief description]
   > 3. **[Gap C]** - [brief description]
   >
   > Are any of these areas you'd like to discuss, or are they intentionally out of scope?"

   The user can then pick which gaps (if any) need addressing. For those they want to discuss, work through them and add to the specification with standard approval workflow.

   This should be infrequent - most gaps will be caught from source material. But occasionally the sources themselves have blind spots worth surfacing.

### What You're NOT Doing

- **Not inventing requirements** - When surfacing gaps not in sources, you're asking questions, not proposing answers
- **Not assuming gaps need filling** - If something isn't in the sources, it may have been intentionally omitted
- **Not padding the spec** - Only add what's genuinely missing and relevant
- **Not re-litigating decisions** - If something was discussed and rejected, it stays rejected

### Completing the Review

When you've:
- Systematically reviewed all source material for missed content
- Addressed any discovered gaps with the user
- Surfaced any potential gaps not covered by sources (and resolved them)

...then inform the user the final review is complete and proceed to getting sign-off on the specification.

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

> "This specification appears to be a **[feature/cross-cutting]** specification.
>
> [Brief rationale - e.g., "It defines a caching strategy that will inform how multiple features handle data retrieval, rather than being a standalone piece of functionality to build."]
>
> - **Feature specs** proceed to planning and implementation
> - **Cross-cutting specs** are referenced by feature plans but don't have their own implementation plan
>
> Does this assessment seem correct?"

Wait for user confirmation before proceeding.

### Step 2: Sign-Off

Once the type is confirmed, ask for final sign-off:

> "The specification is ready for sign-off:
> - **Type**: [feature/cross-cutting]
> - **Status**: Complete
>
> [If feature]: This will be available for planning via `/workflow:start-planning`
> [If cross-cutting]: This will be surfaced as reference context when planning features
>
> Ready to mark as complete?"

### Step 3: Update Frontmatter

After user confirms, update the specification frontmatter:

```markdown
# Specification: [Topic Name]

**Status**: Complete
**Type**: [feature/cross-cutting]
**Last Updated**: YYYY-MM-DD
```

Specification is complete when:
- All topics/phases have validated content
- Type has been determined and confirmed
- User confirms the specification is complete
- No blocking gaps remain

---

## Self-Check: Have You Followed the Rules?

Before ANY write operation to the specification file, verify:

| Question | If No... |
|----------|----------|
| Did I present this specific content to the user? | **STOP**. Present it first. |
| Did the user explicitly approve? (e.g., "Log it") | **STOP**. Wait for approval or ask. |
| Am I writing exactly what was approved, with no additions? | **STOP**. Present any changes first. |

> **FINAL CHECK**: If you have written to the specification file and cannot answer "yes" to all three questions above for that content, you have violated the workflow. Every piece of content requires explicit user approval before logging.
