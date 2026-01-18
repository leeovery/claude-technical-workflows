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

> "Here's what I understand about [topic] based on the reference material. This is how I'd write it into the specification:
>
> [content as it would appear]
>
> Does this capture it? Anything to adjust, remove, or add?"

### 3. Discuss and Refine
Work through the content together:
- Validate what's accurate
- Remove what's wrong, outdated, or hallucinated
- Add what's missing through brief discussion
- **Course correct** based on knowledge from subsequent project work
- Refine wording and structure

This is a **human-level conversation**, not form-filling. The user brings context from across the project that may not be in the reference material - decisions from other topics, implications from later work, or knowledge that can't all fit in context.

### 4. Log When Approved
Only when the user approves ("yes, log it", "that's good", etc.) do you write it to the specification - **verbatim** as presented and approved.

### 5. Repeat
Move to the next topic.

## Context Resurfacing

When you discover information that affects **already-logged topics**, resurface them. Even mid-discussion - interrupt, flag what you found, and discuss whether it changes anything.

If it does: summarize what's changing in the chat, then re-present the full updated topic. The summary is for discussion only - the specification just gets the clean replacement. Standard workflow applies: user approves before you update.

This is encouraged. Better to resurface and confirm "already covered" than let something slip past.

## The Specification Document

Create `docs/workflow/specification/{topic}.md`

This is a single file per topic. Structure is **flexible** - organize around phases and subject matter, not rigid sections. This is a working document.

Suggested skeleton:

```markdown
# Specification: [Topic Name]

**Status**: Building specification
**Last Updated**: [timestamp]

---

## Specification

[Validated content accumulates here, organized by topic/phase]

---

## Working Notes

[Optional - capture in-progress discussion if needed]
```

## Critical Rules

**Exhaustive extraction is non-negotiable**: Before presenting any topic, re-scan source material. Search for keywords. Collect scattered information. The specification is the golden document - planning uses only this. If you miss something, it doesn't get built.

**Present before logging**: Never write content to the specification until the user has seen and approved it.

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

4. **Flag what you find** - When you discover potentially missed content, present it to the user. There are two cases:

   **Enhancing an existing topic** - Details that belong in an already-documented section:

   > "During my final review, I found additional detail about [existing topic] that isn't captured. From [source]:
   >
   > [quote or summary from source material]
   >
   > I'd add this to the [section name] section. Should I include it?"

   **An entirely missed topic** - Something that warrants its own section but was glossed over:

   > "During my final review, I found [topic] discussed in [source] that doesn't have coverage in the specification:
   >
   > [quote or summary from source material]
   >
   > This would be a new section. Should I add it?"

   In both cases, you know where the content belongs - existing topics get enhanced in place, new topics get added at the end.

5. **Never fabricate** - Every item you flag must trace back to specific source material. If you can't point to where it came from, don't suggest it. The goal is to catch missed content, not invent new requirements.

6. **User confirms before inclusion** - Standard workflow applies: present proposed additions, get approval, then log verbatim.

### What You're NOT Doing

- **Not generating new ideas** - Only surfacing what's already in the source material
- **Not assuming gaps** - If something isn't in the sources, it may have been intentionally omitted
- **Not padding the spec** - Only add what's genuinely missing and relevant
- **Not re-litigating decisions** - If something was discussed and rejected, it stays rejected

### Completing the Review

When you've systematically reviewed all source material and either:
- Found nothing missing, or
- Addressed all discovered gaps with the user

...then inform the user the final review is complete and proceed to getting sign-off on the specification.

## Completion

Specification is complete when:
- All topics/phases have validated content
- User confirms the specification is complete
- No blocking gaps remain
