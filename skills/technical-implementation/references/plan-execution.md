# Plan Execution

*Reference for **[technical-implementation](../SKILL.md)***

---

## Plan Structure

Plans live in `docs/workflow/planning/{topic}.md` with phases and tasks.

**Phase** = grouping with acceptance criteria
**Task** = single TDD cycle = one commit

## Before Starting

1. Read entire plan
2. Read specification for context
3. Check dependencies and blockers

## Execution Flow

For each phase:
1. Announce phase start with acceptance criteria
2. For each task: derive test → write failing test → implement → commit
3. Verify all acceptance criteria met
4. **Wait for user confirmation before next phase**

## Referencing Specification

Check `docs/workflow/specification/{topic}.md` when:
- Task rationale unclear
- Multiple valid approaches
- Edge case handling not specified

The specification is the source of truth. Don't look further back than this.

## Handling Problems

- **Plan incomplete**: Stop and escalate with options
- **Plan seems wrong**: Stop and escalate discrepancy
- **Discovery during implementation**: Stop and escalate impact

**Never silently deviate.**

## Context Refresh Recovery

1. Check `git log` for recent commits
2. Find current phase/task in plan
3. Resume from last committed task
