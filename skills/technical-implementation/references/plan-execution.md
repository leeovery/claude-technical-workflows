# Plan Execution

*Reference for **[technical-implementation](../SKILL.md)***

---

## Plan Structure

Plans live in `docs/workflow/planning/{topic}.md` with phases and tasks.

**Phase** = organizational grouping with acceptance criteria
**Task** = single agent cycle = one commit (after review approval)

## Before Starting

1. Read entire plan
2. Read specification for context
3. Check dependencies and blockers
4. Load the output format adapter — instructions for reading and updating the plan

## Execution Flow

For each task (flat loop, phases are metadata not workflow states):
1. Invoke executor agent (see **[steps/invoke-executor.md](steps/invoke-executor.md)**)
   - Executor implements via TDD (writes code + tests, runs tests, no git)
2. Invoke reviewer agent (see **[steps/invoke-reviewer.md](steps/invoke-reviewer.md)**)
   - Reviewer independently verifies (spec conformance, criteria, tests, conventions, architecture)
   - If `needs-changes`: present to user → user approves/modifies/skips → fix round
   - If `approved`: task gate check
3. Task gate: if `gated`, prompt user (`y`/`auto`/comment); if `auto`, announce and continue
4. Orchestrator commits

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
3. Check `task_gate_mode` in tracking file — if `auto`, preserve it
4. Check `git log` for recent commits
5. Find current task in plan
6. Announce position to user, wait for confirmation
7. Resume from last committed task
