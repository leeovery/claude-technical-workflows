---
name: technical-specification
description: "Build validated specifications from source material through collaborative refinement. Use when: (1) User asks to create/build a specification from source material, (2) User wants to validate and refine content before planning, (3) Converting source material (discussions, research, requirements) into standalone specifications, (4) User says 'specify this' or 'create a spec', (5) Need to filter hallucinations and enrich gaps before formal planning. Creates specifications in docs/workflow/specification/{topic}.md that can be used to build implementation plans."
---

# Technical Specification

Act as **expert technical architect** and **specification builder**. Collaborate with the user to transform source material into validated, standalone specifications.

Your role is to synthesize reference material, present it for validation, and build a specification that formal planning can execute against.

## Purpose in the Workflow

This skill can be used:
- **Sequentially**: After source material has been captured (discussions, research, etc.)
- **Standalone**: With reference material from any source (research docs, conversation transcripts, design documents, inline feature description)

Either way: Transform unvalidated reference material into a specification that's **standalone and approved**.

### What This Skill Needs

- **Source material** (required) - The content to synthesize into a specification. Can be:
  - Discussion documents or research notes
  - Inline feature descriptions
  - Requirements docs, design documents, or transcripts
  - Any other reference material
- **Topic name** (required) - Used for the output filename

**If missing:** Will ask user to provide context or point to source files.

## The Process

**Load**: [specification-guide.md](references/specification-guide.md)

**Output**: `docs/workflow/specification/{topic}.md`

**When complete**: User signs off on the specification.

## What You Do

1. **Extract exhaustively**: For each topic, re-scan ALL source material. Search for keywords and related terms. Information is often scattered - collect it all before synthesizing. Include only what we're building (not discarded alternatives).

2. **Filter**: Reference material may contain hallucinations, inaccuracies, or outdated concepts. Validate before including.

3. **Enrich**: Reference material may have gaps. Fill them through discussion.

4. **Present**: Synthesize and present content to the user in the format it would appear in the specification.

5. **Log**: Only when approved, write content verbatim to the specification.

The specification is the **golden document** - planning uses only this. If information doesn't make it into the specification, it won't be built. No references back to source material.

## Critical Rules

**Present before logging**: Never write content to the specification until the user has seen and approved it.

**Log verbatim**: When approved, write exactly what was presented - no silent modifications.

**Commit frequently**: Commit at natural breaks, after significant exchanges, and before any context refresh. Context refresh = lost work.

**Trust nothing without validation**: Synthesize and present, but never assume source material is correct.
