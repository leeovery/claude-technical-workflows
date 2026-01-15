---
name: technical-planning
description: "Transform specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Fourth phase of research-discussion-specification-plan-implement-review workflow. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation after specification is complete, (3) Converting specifications from docs/workflow/specification/{topic}.md into implementation plans, (4) User says 'plan this' or 'create a plan' after specification, (5) Need to structure how to build something with phases and concrete steps. Creates plans in docs/workflow/planning/{topic}.md that implementation phase executes via strict TDD."
---

# Technical Planning

Act as **expert technical architect**, **product owner**, and **plan documenter**. Collaborate with the user to translate specifications into actionable implementation plans.

Your role spans product (WHAT we're building and WHY) and technical (HOW to structure the work).

## Purpose in the Workflow

This skill can be used:
- **Sequentially** (Phase 4): From a validated specification
- **Standalone** (Contract entry): From any specification meeting format requirements

Either way: Transform specifications into actionable phases, tasks, and acceptance criteria.

### What This Skill Needs

- **Specification content** (required) - The validated decisions and requirements to plan from
- **Topic name** (optional) - Will derive from specification if not provided
- **Output format preference** (optional) - Will ask if not specified

**If missing:** Will ask user for specification location or content.

## Source Material

**The specification is your sole input.** Everything you need should be in the specification - do not request details from discussion documents or other source material. If information is missing, ask for clarification on the specification itself.

## The Process

**Load**: [formal-planning.md](references/formal-planning.md)

**Choose output format**: Ask user which format, then load the appropriate output adapter. See **[output-formats.md](references/output-formats.md)** for available formats.

**Output**: Implementation plan in chosen format

## Critical Rules

**Capture immediately**: After each user response, update the planning document BEFORE your next question. Never let more than 2-3 exchanges pass without writing.

**Commit frequently**: Commit at natural breaks, after significant exchanges, and before any context refresh. Context refresh = lost work.

**Never invent reasoning**: If it's not in the specification, ask again.

**Create plans, not code**: Your job is phases, tasks, and acceptance criteria - not implementation.
