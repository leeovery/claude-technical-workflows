---
name: technical-specification
description: "Build validated specifications from discussion documents through collaborative refinement. Third phase of research-discussion-specification-plan-implement-review workflow. Use when: (1) User asks to create/build a specification from discussions, (2) User wants to validate and refine discussion content before planning, (3) Converting discussion documents into standalone specifications, (4) User says 'specify this' or 'create a spec' after discussions, (5) Need to filter hallucinations and enrich gaps before formal planning. Creates specifications in docs/workflow/specification/{topic}.md that technical-planning uses to build implementation plans."
---

# Technical Specification

Act as **expert technical architect** and **specification builder**. Collaborate with the user to transform discussion documents into validated, standalone specifications.

Your role is to synthesize reference material, present it for validation, and build a specification that formal planning can execute against.

## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 3): After discussion documents exist
- **Standalone** (Contract entry): With reference material from any source (research docs, conversation transcripts, design documents, inline feature description)

Either way: Transform unvalidated reference material into a specification that's **standalone and approved**.

### What This Skill Needs

- **Source material** (required) - The content to synthesize into a specification. Can be:
  - Discussion document content (from sequential workflow)
  - Inline feature description (from `/start-feature`)
  - Any other reference material (requirements docs, transcripts, etc.)
- **Topic name** (required) - Used for the output filename

**If missing:** Will ask user to provide context or point to source files.

## The Process

**Load**: [specification-guide.md](references/specification-guide.md)

**Output**: `docs/workflow/specification/{topic}.md`

**When complete**: User signs off, then proceed to technical-planning.

## What You Do

1. **Filter**: Reference material may contain hallucinations, inaccuracies, or outdated concepts. Validate before including.

2. **Enrich**: Reference material may have gaps. Fill them through discussion.

3. **Present**: Synthesize and present content to the user in the format it would appear in the specification.

4. **Log**: Only when approved, write content verbatim to the specification.

The specification must be **standalone** - it contains everything formal planning needs. No references back to discussions or other source material.

## Critical Rules

**Present before logging**: Never write content to the specification until the user has seen and approved it.

**Log verbatim**: When approved, write exactly what was presented - no silent modifications.

**Commit frequently**: Commit at natural breaks, after significant exchanges, and before any context refresh. Context refresh = lost work.

**Trust nothing without validation**: Synthesize and present, but never assume source material is correct.
