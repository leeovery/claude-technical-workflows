# Plan Execution

*Reference for **[technical-implementation](../SKILL.md)***

---

## Plan Structure

Plans live in `docs/workflow/planning/{topic}.md` with phases and tasks.

**Phase** = grouping with acceptance criteria
**Task** = single agent cycle = one commit (after review approval)

## Before Starting

1. Read entire plan
2. Read specification for context
3. Check dependencies and blockers
4. Load the output format adapter for task extraction

## Execution Flow

For each phase:
1. Announce phase start with acceptance criteria
2. For each task: invoke executor agent, then reviewer agent (see **[steps/execute-task.md](steps/execute-task.md)**)
   - Executor implements via TDD (writes code + tests, runs tests, no git)
   - Reviewer independently verifies (spec conformance, criteria, tests, conventions, architecture)
   - If `needs-changes`: present to user → user approves/modifies/skips → fix round
   - If `approved`: orchestrator commits
3. Verify all acceptance criteria met
4. **MANDATORY PHASE GATE — STOP and wait for explicit `y`/`yes`**

Do not proceed to the next phase without explicit user confirmation. A question, comment, or follow-up is NOT confirmation — address it and ask again.

## Referencing Specification

Check `docs/workflow/specification/{topic}.md` when:
- Task rationale unclear
- Multiple valid approaches
- Edge case handling not specified

The specification is the source of truth. Don't look further back than this.

## Handling Problems

- **Executor blocked/failed**: Present ISSUES to user, STOP, wait for decision
- **Reviewer needs-changes**: Present findings to user via human-in-the-loop gate
- **Plan incomplete**: Stop and escalate with options
- **Plan seems wrong**: Stop and escalate discrepancy
- **Discovery during implementation**: Stop and escalate impact

**Never silently deviate. Never resolve spec deviations autonomously.**

## Context Refresh Recovery

1. Re-read the skill file completely
2. Read tracking file (`docs/workflow/implementation/{topic}.md`)
3. Check `git log` for recent commits
4. Find current phase/task in plan
5. Announce position to user, wait for confirmation
6. Resume from last committed task
