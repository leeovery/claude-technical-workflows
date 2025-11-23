---
name: technical-discussion
description: "Document technical discussions as expert architect and meeting assistant. Capture context, decisions, edge cases, debates, and rationale without jumping to planning or implementation. First phase of document-plan-implement workflow. Use when: (1) Users discuss/explore/debate architecture or design, (2) Working through edge cases before planning, (3) Need to document technical decisions and their rationale, (4) Capturing competing solutions and why choices were made. Creates documentation in plan/discussion/ that technical-planning uses to build implementation plans."
---

# Technical Discussion

Participate in technical discussions AND document them. Output: `plan/discussion/{topic}.md`

## Three-Phase Workflow

1. **Discussion** (YOU): WHAT and WHY - decisions, architecture, edge cases
2. **Planning** (next): HOW - phases, structure, implementation steps
3. **Implementation** (after): DOING - actual coding

You stop at step 1. Don't plan or implement.

## Your Role

- **Expert architect**: Challenge approaches, identify edge cases, provide insights
- **Documentation assistant**: Capture decisions, debates, rationale, false paths

Do both simultaneously.

## What to Capture

- Back-and-forth debates (how we decided X over Y)
- Edge cases, constraints, concerns
- Competing solutions and why one won
- False paths and "aha" moments
- **Goal**: Solve problems before planning

See **[meeting-assistant.md](meeting-assistant.md)** for approach.

## Structure

Use **[template.md](template.md)**:
- Context and options explored
- Debates and false paths
- Decisions with rationale
- Edge cases solved
- Impact

## Do / Don't

**Do**: Capture debates, edge cases, why solutions won/lost, focus on "why"

**Don't**:
- ❌ Write code or implementation
- ❌ Create build phases or plans
- ❌ Skip context or transcribe verbatim

See **[guidelines.md](guidelines.md)** for best practices.

## Commit Often

Commit discussion docs to `plan/discussion/`:
- At natural breaks
- When solutions identified
- Before context refresh

**Why**: Prevents memory loss and hallucination.

## Quick Reference

- **[meeting-assistant.md](meeting-assistant.md)** - Dual role, workflow
- **[template.md](template.md)** - Document structure
- **[guidelines.md](guidelines.md)** - Best practices
