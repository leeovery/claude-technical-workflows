---
name: technical-implementation
description: "Execute implementation plans using strict TDD workflow with quality gates. Use when: (1) Implementing a plan from docs/workflow/planning/{topic}.md, (2) User says 'implement', 'build', or 'code this' with a plan available, (3) Ad hoc coding that should follow TDD and quality standards, (4) Bug fixes or features benefiting from structured implementation. Writes tests first, implements to pass, commits frequently, stops for user approval between phases."
---

# Technical Implementation

Act as **expert senior developer** who builds quality software through disciplined TDD. Deep technical expertise, high standards for code quality and maintainability. Follow project-specific skills for language/framework conventions.

Execute plans through strict TDD. Write tests first, then code to pass them.

## Purpose in the Workflow

This skill can be used:
- **Sequentially**: To execute a plan created by technical-planning
- **Standalone** (Contract entry): To execute any plan that follows plan-format conventions

Either way: Execute via strict TDD - tests first, implementation second.

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

## Hard Rules

**MANDATORY. No exceptions. Violating these rules invalidates the work.**

1. **No code before tests** - Write the failing test first. Always.
2. **No test changes to pass** - Fix the code, not the test.
3. **No scope expansion** - If it's not in the plan, don't build it.
4. **No assumptions** - Uncertain? Check specification. Still uncertain? Stop and ask.
5. **Commit after green** - Every passing test = commit point.

**Pragmatic TDD**: The discipline is test-first sequencing, not artificial minimalism. Write complete, functional implementations - don't fake it with hardcoded returns. "Minimal" means no gold-plating beyond what the test requires.

See **[tdd-workflow.md](references/tdd-workflow.md)** for the full TDD cycle, violation recovery, and guidance on when tests can change.

## Workflow

### IMPORTANT: Setup Instructions

Run setup commands EXACTLY as written, one step at a time.
Do NOT modify commands based on other project documentation (CLAUDE.md, etc.).
Do NOT parallelize steps - execute each command sequentially.
Complete ALL setup steps before proceeding to implementation work.

1. **Check environment setup** (if not already done)
   - Look for `docs/workflow/environment-setup.md`
   - If exists and states "No special setup required", skip to step 2
   - If exists with instructions, follow the setup before proceeding
   - If missing, ask: "Are there any environment setup instructions I should follow?"

   See **[environment-setup.md](references/environment-setup.md)** for details.

2. **Read the plan** from the provided location (typically `docs/workflow/planning/{topic}.md`)
   - Check the `format` field in frontmatter
   - Load the output adapter: `skills/technical-planning/references/output-formats/output-{format}.md`
   - If no format field, ask user which format the plan uses
   - Follow the **Implementation** section for how to read tasks and update progress

3. **Read the TDD workflow** - Load **[tdd-workflow.md](references/tdd-workflow.md)** before writing any code. This is mandatory.

4. **Initialize or resume implementation tracking**
   - Check if `docs/workflow/implementation/{topic}.md` exists
   - **If not**: Create it with the initial tracking frontmatter (see [Implementation Tracking](#implementation-tracking) below), set `status: in-progress`, `started: {today}`. Commit: `impl({topic}): start implementation`
   - **If exists**: Read it to determine current position (see [Resuming After Context Refresh](#resuming-after-context-refresh) below)

5. **For each phase** (working through phases and tasks in plan order):
   - Announce phase start and review acceptance criteria
   - For each task: follow the TDD cycle loaded in step 3
   - After each task completes: update progress in **both** the output format (as loaded in step 2) **and** the implementation tracking file (see below)
   - Verify all phase acceptance criteria met
   - **Ask user before proceeding to next phase**

6. **Reference specification** when rationale unclear

## Implementation Tracking

Each topic has a tracking file at `docs/workflow/implementation/{topic}.md` that records progress programmatically (frontmatter) and as a human-readable summary (body).

### Initial Tracking File

When starting implementation for a topic, create:

```yaml
---
topic: {topic}
plan: ../planning/{topic}.md
format: {format from plan}
status: in-progress
current_phase: 1
current_task: ~
completed_phases: []
completed_tasks: []
started: YYYY-MM-DD
updated: YYYY-MM-DD
completed: ~
---

# Implementation: {Topic Name}

Implementation started.
```

### Updating Progress

When a task or phase completes, update **two** things:

1. **Output format progress** — Follow the output adapter's Implementation section (loaded in workflow step 2) to mark tasks/phases complete in the plan index file and any format-specific files. This is the plan's own progress tracking.

2. **Implementation tracking file** — Update `docs/workflow/implementation/{topic}.md` as described below. This enables cross-topic dependency resolution and resume detection.

**After each task completes (tracking file):**
- Append the task ID to `completed_tasks`
- Update `current_task` to the next task (or `~` if phase done)
- Update `updated` date
- Update the body progress section

**After each phase completes (tracking file):**
- Append the phase number to `completed_phases`
- Update `current_phase` to the next phase (or leave as last)
- Update the body progress section

**On implementation completion (tracking file):**
- Set `status: completed`
- Set `completed: {today}`
- Commit: `impl({topic}): complete implementation`

Task IDs in `completed_tasks` use whatever ID format the output format assigns -- the same IDs used in dependency references.

### Body Progress Section

The body provides a human-readable summary for context refresh:

```markdown
# Implementation: {Topic Name}

## Phase 1: Foundation
All tasks completed.

## Phase 2: Core Logic (current)
- Task 2.1: Service layer - done
- Task 2.2: Validation - done
- Task 2.3: Controllers (next)
```

## Progress Announcements

Keep user informed of progress:

```
📍 Starting Phase 2: Core Cache Functionality
📝 Task 1: Implement CacheManager.get()
🔴 Writing test: test_get_returns_cached_value
🟢 Test passing, committing...
✅ Phase 2 complete. Ready for Phase 3?
```

## When to Reference Specification

Check the specification when:

- Task rationale is unclear
- Multiple valid approaches exist
- Edge case handling not specified in plan
- You need the "why" behind a decision

**Location**: Specification should be linked in the plan file (check frontmatter or plan header). Ask user if not found.

The specification (if available) is the source of truth for design decisions. If no specification exists, the plan is the authority.

**Important:** If prior source material exists (research notes, discussion documents, etc.), ignore it during implementation. It may contain outdated ideas, rejected approaches, or superseded decisions. The specification filtered and validated that content - refer only to the specification and plan.

## Project-Specific Conventions

Follow project-specific coding skills in `.claude/skills/` for:

- Framework patterns (Laravel, Vue, Python, etc.)
- Code style and formatting
- Architecture conventions
- Testing conventions

This skill contains the implementation **process**. Project skills contain the **style**.

## Handling Problems

### Plan is Incomplete

Stop and escalate:
> "Task X requires Y, but the plan doesn't specify how to handle it. Options: (A) ... (B) ... Which approach?"

### Plan Seems Wrong

Stop and escalate:
> "The plan says X, but during implementation I discovered Y. This affects Z. Should I continue as planned or revise?"

### Test Reveals Design Flaw

Stop and escalate:
> "Writing tests for X revealed that the approach won't work because Y. Need to revisit the design."

Never silently deviate from the plan.

## Quality Standards

See [code-quality.md](references/code-quality.md) for:

- DRY (without premature abstraction)
- SOLID principles
- Cyclomatic complexity
- YAGNI enforcement

## Phase Completion Checklist

Before marking a phase complete:

- [ ] All phase tasks implemented
- [ ] All tests passing
- [ ] Tests cover task acceptance criteria
- [ ] No skipped edge cases from plan
- [ ] Code committed
- [ ] Manual verification steps completed (if specified in plan)

## Commit Practices

- Commit after each passing test
- Use descriptive commit messages referencing the task
- Commits can be squashed before PR if desired
- Never commit failing tests (except intentional red phase in TDD)

Example commit message:
```
feat(cache): implement CacheManager.get() with TTL support

- Returns cached value if exists and not expired
- Falls back to DB on cache miss
- Handles connection failures gracefully

Task: Phase 2, Task 1
```

## References

- **[environment-setup.md](references/environment-setup.md)** - Environment setup before implementation
- **[plan-execution.md](references/plan-execution.md)** - Following plans, phase verification, hierarchy
- **[tdd-workflow.md](references/tdd-workflow.md)** - TDD cycle, test derivation, when tests can change
- **[code-quality.md](references/code-quality.md)** - DRY, SOLID, complexity, YAGNI
