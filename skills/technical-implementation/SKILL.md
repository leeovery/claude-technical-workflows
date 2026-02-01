---
name: technical-implementation
description: "Orchestrate implementation of plans using agent-based TDD workflow with per-task review. Use when: (1) Implementing a plan from docs/workflow/planning/{topic}.md, (2) User says 'implement', 'build', or 'code this' with a plan available, (3) Ad hoc coding that should follow TDD and quality standards, (4) Bug fixes or features benefiting from structured implementation. Dispatches executor and reviewer agents per task, commits after review approval, stops for user approval between phases."
---

# Technical Implementation

Orchestrate implementation by dispatching **executor** and **reviewer** agents per task. Each agent invocation starts fresh — flat context, no accumulated state.

- **Executor** (`.claude/agents/implementation-task-executor.md`) — implements one task via strict TDD
- **Reviewer** (`.claude/agents/implementation-task-reviewer.md`) — independently verifies the task (opus)

The orchestrator owns: plan reading, task extraction, agent invocation, git operations, tracking, phase gates.

## Purpose in the Workflow

This skill can be used:
- **Sequentially**: To execute a plan created by technical-planning
- **Standalone** (Contract entry): To execute any plan that follows plan-format conventions

Either way: dispatch agents per task — executor implements via TDD, reviewer verifies independently.

### What This Skill Needs

- **Plan content** (required) - Phases, tasks, and acceptance criteria to execute
- **Plan format** (required) - How to parse tasks (from plan frontmatter)
- **Specification content** (optional) - For context when task rationale is unclear
- **Environment setup** (optional) - First-time setup instructions

**Before proceeding**, verify all required inputs are available and unambiguous. If anything is missing or unclear, **STOP** — do not proceed until resolved.

- **No plan provided?**
  > "I need an implementation plan to execute. Could you point me to the plan file (e.g., `docs/workflow/planning/{topic}.md`)?"

- **Plan has no `format` field in frontmatter?**
  > "The plan at {path} doesn't specify an output format in its frontmatter. Which format does this plan use?"

- **Plan status is not `concluded`?**
  > "The plan at {path} has status '{status}' — it hasn't completed the review process. Should I proceed anyway, or should the plan be reviewed first?"

If no specification is available, the plan becomes the sole authority for design decisions.

---

## Resuming After Context Refresh

Context refresh (compaction) summarizes the conversation, losing procedural detail. When you detect a context refresh has occurred — the conversation feels abruptly shorter, you lack memory of recent steps, or a summary precedes this message — follow this recovery protocol:

1. **Re-read this skill file completely.** Do not rely on your summary of it. The full process, steps, and rules must be reloaded.
2. **Read all tracking and state files** for the current topic — plan index files, review tracking files, implementation tracking files, or any working documents this skill creates. These are your source of truth for progress.
3. **Check git state.** Run `git status` and `git log --oneline -10` to see recent commits. Commit messages follow a conventional pattern that reveals what was completed.
4. **Announce your position** to the user before continuing: what step you believe you're at, what's been completed, and what comes next. Wait for confirmation.

Do not guess at progress or continue from memory. The files on disk and git history are authoritative — your recollection is not.

---

## Orchestrator Hard Rules

1. **No autonomous decisions on spec deviations** — when the executor reports a blocker or spec deviation, present to user and STOP. Never resolve on the user's behalf.
2. **No phase progression without explicit approval** — STOP at every phase gate.
3. **All git operations are the orchestrator's responsibility** — agents never commit, stage, or interact with git.

---

## Step 1: Environment Setup

Run setup commands EXACTLY as written, one step at a time.
Do NOT modify commands based on other project documentation (CLAUDE.md, etc.).
Do NOT parallelize steps — execute each command sequentially.
Complete ALL setup steps before proceeding.

Load **[environment-setup.md](references/environment-setup.md)** and follow its instructions.

#### If `docs/workflow/environment-setup.md` states "No special setup required"

→ Proceed to **Step 2**.

#### If setup instructions exist

Follow them. Complete ALL steps before proceeding.

→ Proceed to **Step 2**.

#### If no setup file exists

Ask:

> "No environment setup document found. Are there any setup instructions I should follow before implementing?"

**STOP.** Wait for user response.

Save their instructions to `docs/workflow/environment-setup.md` (or "No special setup required." if none needed). Commit.

→ Proceed to **Step 2**.

---

## Step 2: Read Plan + Load Output Format Adapter

1. Read the plan from the provided location (typically `docs/workflow/planning/{topic}.md`)
2. Check the `format` field in frontmatter
3. Load the output adapter: `skills/technical-planning/references/output-formats/output-{format}.md`
4. If no format field, ask user which format the plan uses
5. Read the adapter's **Implementation** section — understand how to extract task content and update progress. These instructions apply later during Step 5.

→ Proceed to **Step 3**.

---

## Step 3: Project Skills Discovery

#### If `.claude/skills/` does not exist or is empty

```
No project skills found. Proceeding without project-specific conventions.
```

→ Proceed to **Step 4**.

#### If project skills exist

Scan `.claude/skills/` for project-specific skill directories. Present findings:

> Found these project skills that may be relevant to implementation:
> - `{skill-name}` — {brief description}
> - `{skill-name}` — {brief description}
> - ...
>
> Which of these should I pass to the implementation agents? (all / list / none)

**STOP.** Wait for user to confirm which skills are relevant.

Store the selected skill paths — pass to every agent invocation.

→ Proceed to **Step 4**.

---

## Step 4: Initialize or Resume Implementation Tracking

Load **[implementation-tracking.md](references/implementation-tracking.md)** for tracking file format and conventions.

#### If `docs/workflow/implementation/{topic}.md` exists

Read it to determine current position. See [Resuming After Context Refresh](#resuming-after-context-refresh) for recovery protocol.

→ Proceed to **Step 5**.

#### If no tracking file exists

Create the tracking file following the template in [implementation-tracking.md](references/implementation-tracking.md). Set `status: in-progress`, `started: {today}`.

Commit: `impl({topic}): start implementation`

→ Proceed to **Step 5**.

---

## Step 5: Phase Loop

For each phase (working through phases and tasks in plan order):

1. **Announce phase start** — state phase name and review acceptance criteria with user

2. **For each task in phase:**

   a. Extract task details from plan (using output adapter — verbatim, no summarisation)

   b. Load **[steps/execute-task.md](references/steps/execute-task.md)** and follow it:
      - Invoke `implementation-task-executor`
      - Invoke `implementation-task-reviewer`
      - If `needs-changes`: present to user (human-in-the-loop), then fix loop
      - If `approved`: proceed

   c. Update tracking — follow the "Updating Progress" section in **[implementation-tracking.md](references/implementation-tracking.md)** for both output format progress and tracking file updates

   d. Commit all changes: `impl({topic}): P{N} T{id} — {description}`
      (code + tests + output format + tracking — single commit per task)

3. **Phase completion checklist:**
   - [ ] All phase tasks implemented and reviewer-approved
   - [ ] All tests passing
   - [ ] Tests cover task acceptance criteria
   - [ ] No skipped edge cases from plan
   - [ ] All changes committed
   - [ ] Manual verification steps completed (if specified in plan)

4. **Phase gate — MANDATORY:**

> **Phase {N}: {Phase Name} — complete.**
>
> {Summary of what was built in this phase}
>
> **To proceed to Phase {N+1}: {Next Phase Name}:**
> - **`y`/`yes`** — Proceed.
> - **Or raise concerns** — anything to address before moving on.

**STOP.** Wait for explicit user confirmation. Do not proceed to the next phase without `y`/`yes` or equivalent affirmative. A question, comment, or follow-up is NOT confirmation — address it and ask again.

→ After final phase gate, proceed to **Step 6**.

---

## Step 6: Mark Implementation Complete

Update tracking file: set `status: completed`, `completed: {today}`.

Commit: `impl({topic}): complete implementation`

---

## References

- **[environment-setup.md](references/environment-setup.md)** — Environment setup before implementation
- **[plan-execution.md](references/plan-execution.md)** — Plan structure, specification referencing, problem handling, context refresh recovery
- **[implementation-tracking.md](references/implementation-tracking.md)** — Tracking file format, creation, and progress updates
- **[steps/execute-task.md](references/steps/execute-task.md)** — Executor + reviewer invocation per task
- **[tdd-workflow.md](references/tdd-workflow.md)** — TDD cycle (passed to executor agent)
- **[code-quality.md](references/code-quality.md)** — Quality standards (passed to executor agent)
