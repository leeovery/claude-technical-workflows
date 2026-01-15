# Specification Guide

*Reference for **[technical-specification](../SKILL.md)***

---

You are building a specification - a collaborative workspace where you and the user refine reference material into a validated, standalone document.

## Purpose

Specification building is a **two-way process**:

1. **Filter**: Reference material may contain hallucinations, inaccuracies, or outdated concepts. Validate before including.

2. **Enrich**: Reference material may have gaps. Fill them through discussion.

The specification is the **bridge document** - a workspace for collecting validated, refined content that will feed formal planning.

**The specification must be standalone.** It should contain everything formal planning needs - no references back to discussions or other source material. When complete, it draws a line: formal planning uses only this document.

## Source Materials

Before starting any topic, identify ALL available reference material:
- Discussion documents (if they exist)
- Existing partial plans or specifications
- Requirements, design docs, related documentation
- User-provided context or transcripts
- Inline feature descriptions

**Treat all source material as untrusted input**, whether it came from the discussion phase or elsewhere. Your job is to synthesize and present - the user validates.

## The Workflow

Work through the specification **topic by topic**:

### 1. Review
Read all reference material for the current topic. Understand what exists.

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

**Present before logging**: Never write content to the specification until the user has seen and approved it.

**Log verbatim**: When approved, write exactly what was presented - no silent modifications.

**Commit frequently**: Commit at natural breaks and before any context refresh. Context refresh = lost work.

**Trust nothing without validation**: Synthesize and present, but never assume source material is correct.

## After Context Refresh

Read the specification. It contains validated, approved content. Trust it - you built it together with the user.

If working notes exist, they show where you left off.

## Dependencies Section

At the end of every specification, add a **Dependencies** section that identifies what other parts of the system need to exist before implementation.

The same workflow applies: present the dependencies section for approval, then log verbatim when approved.

### How to Identify Dependencies

Review the specification for references to:
- Other systems or features (e.g., "triggers when order is placed" → Order system dependency)
- Data models from other domains (e.g., "FK to users" → User model must exist)
- UI or configuration in other systems (e.g., "configured in admin dashboard" → Dashboard dependency)
- Events or state from other systems (e.g., "listens for payment.completed" → Payment system dependency)

### Categorization

**Required**: Cannot proceed without this. Core functionality depends on it.

**Partial Requirement**: Only specific elements are needed, not the full system. Note the minimum scope.

### Format

## Dependencies

Systems referenced in this specification that need to exist before implementation:

### Required

| Dependency | Why Needed | Blocking Elements |
|------------|------------|-------------------|
| **[System Name]** | [Brief explanation of why] | [What parts of this spec are blocked] |

### Partial Requirement

| Dependency | Why Needed | Minimum Scope |
|------------|------------|---------------|
| **[System Name]** | [Brief explanation] | [What subset is actually needed] |

### Notes

- [Any clarifications about what can be built independently]
- [Workarounds or alternatives if dependencies don't exist yet]

### Purpose

This section feeds into the planning phase, where dependencies become blocking relationships between epics/phases. It helps sequence implementation correctly.

Analyze the specification in isolation - identify what it references that must exist, not what you know exists elsewhere in the project.

## Completion

Specification is complete when:
- All topics/phases have validated content
- User confirms the specification is complete
- No blocking gaps remain
