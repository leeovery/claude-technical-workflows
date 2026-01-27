# Formal Planning

*Reference for **[technical-planning](../SKILL.md)***

---

You are creating the formal implementation plan from the specification. The output format has already been chosen and its adapter is loaded alongside this reference.

## Planning is a Gated Process

Planning translates the specification into actionable structure. This translation requires judgment, and the process is designed to ensure that judgment is exercised carefully and collaboratively — not rushed.

### Process Expectations

**This is a step-by-step process with mandatory stop points.** You must work through each step sequentially. Steps end with **STOP** — you must present your work, wait for explicit user confirmation, and only then proceed to the next step.

**Never one-shot the plan.** Do not write the entire plan document in a single operation. The plan is built incrementally — one phase at a time, with the user confirming the structure at each stage. A one-shot plan that misses requirements, hallucinates content, or structures tasks poorly wastes more time than a careful, step-by-step process. Go slow to go fast.

**Stop and ask when judgment is needed.** Planning is collaborative — not in the sense that every line needs approval, but in the sense that the user guides structural decisions and resolves ambiguity. You must stop and ask when:

- The specification is ambiguous about implementation approach
- Multiple valid ways to structure phases or tasks exist
- You're uncertain whether a task is appropriately scoped
- Edge cases aren't fully addressed in the specification
- You need to make any decision the specification doesn't cover
- Something doesn't add up or feels like a gap

**Never invent to fill gaps.** If the specification doesn't address something, flag it with `[needs-info]` and ask the user. The specification is the golden document — everything in the plan must trace back to it. Assuming or guessing — even when it seems reasonable — is not acceptable. Surface the problem immediately rather than continuing and hoping to address it later.

---

## Step 1: Read Specification

Read the specification **in full**. Not a scan, not a summary — read every section, every decision, every edge case. The specification must be fully digested before any structural decisions are made.

The specification contains validated decisions. Your job is to translate it into an actionable plan, not to review or reinterpret it.

**The specification is your sole input.** Everything you need is in the specification — do not reference other documents or prior source materials.

From the specification, absorb:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements
- Whether a Dependencies section exists (you will handle these in Step 5)

Do not present or summarize the specification back to the user — it has already been signed off.

→ Proceed to **Step 2**.

---

## Step 2: Define Phases

Orient the user:

> "I've read the full specification. I'm going to propose a phase structure — how we break this into independently testable stages. Once we agree on the phases, we'll take each one and break it into tasks."

With the full specification understood, break it into logical phases:
- Each independently testable
- Each has acceptance criteria
- Progression: Foundation → Core → Edge cases → Refinement

Understanding what tasks belong in each phase is necessary to determine the right ordering. Consider the natural dependencies between areas of functionality — what must exist before something else can be built. This informs both phase boundaries and phase sequence.

Present the proposed phase structure using this format:

```
Phase {N}: {Phase Name}
  Goal: {What this phase accomplishes}
  Why this order: {Why this phase comes at this position in the sequence}
  Acceptance criteria:
    - [ ] {First verifiable criterion}
    - [ ] {Second verifiable criterion}
```

**Example:**

```
Phase 1: Foundation — Event Model and Storage
  Goal: Establish the core data model and persistence layer for calendar events
  Why this order: All subsequent phases depend on events being storable and retrievable
  Acceptance criteria:
    - [ ] Events can be created with required fields (title, start, end)
    - [ ] Events persist to the database and can be retrieved by ID
    - [ ] Validation rejects events with missing required fields

Phase 2: Core — Recurring Events
  Goal: Support recurring event patterns (daily, weekly, monthly)
  Why this order: Recurrence extends the event model from Phase 1
  Acceptance criteria:
    - [ ] Events can be created with a recurrence rule
    - [ ] Recurring instances are generated correctly for a given date range
    - [ ] Editing a single instance does not affect other instances
```

**STOP.** Present your proposed phase structure and ask:

> **To proceed, choose one:**
> - **"Approve"** — Phase structure is confirmed. I'll proceed to task breakdown.
> - **"Adjust"** — Tell me what to change: reorder, split, merge, add, or remove phases.

**If approved:** → Proceed to **Step 3**.

**If adjust:** Incorporate feedback, re-present the updated phase structure, and ask again. Repeat until approved.

---

## Step 3: Present Phase Task Overview

Orient the user:

> "Taking Phase {N}: {Phase Name} and breaking it into tasks. Here's the overview — once we agree on the list, I'll write each task out in full detail."

Take the first (or next) phase and break it into tasks. Present a high-level overview so the user can see the shape of the phase before committing to the detail of each task.

Present the task overview using this format:

```
Phase {N}: {Phase Name}

  1. {Task Name} — {One-line summary}
     Edge cases: {comma-separated list, or "none"}

  2. {Task Name} — {One-line summary}
     Edge cases: {comma-separated list, or "none"}
```

**Example:**

```
Phase 1: Foundation — Event Model and Storage

  1. Create Event model and migration — Define the events table and Eloquent model with required fields
     Edge cases: none

  2. Implement event creation endpoint — POST /api/events with validation and persistence
     Edge cases: overlapping time ranges, past dates

  3. Implement event retrieval — GET /api/events/{id} and GET /api/events with date filtering
     Edge cases: empty result sets, invalid date ranges
```

This overview establishes the scope and ordering. The user should be able to see whether the phase is well-structured, whether tasks are in the right order, and whether anything is missing or unnecessary — before investing time in writing out full task detail.

**STOP.** Present the phase task overview and ask:

> **To proceed, choose one:**
> - **"Approve"** — Task list is confirmed. I'll begin writing full task detail.
> - **"Adjust"** — Tell me what to change: reorder, split, merge, add, or remove tasks.

**If approved:** → Proceed to **Step 4**.

**If adjust:** Incorporate feedback, re-present the updated task overview, and ask again. Repeat until approved.

---

## Step 4: Detail, Approve, and Log Each Task

Orient the user:

> "Task list for Phase {N} is agreed. I'll work through each task one at a time — presenting the full detail, discussing if needed, and logging it to the plan once approved."

Work through the agreed task list **one task at a time**.

#### Present

Write the complete task using the required template (Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Context) — see [Task Design](#task-design) for the required structure and field requirements.

Present it to the user **in the format it will be written to the plan**. The output format adapter determines the exact format. What the user sees is what gets logged — no changes between approval and writing.

After presenting, ask:

> **Task {M} of {total}: {Task Name}**
>
> **To proceed, choose one:**
> - **"Approve"** — Task is confirmed. I'll log it to the plan verbatim.
> - **"Adjust"** — Tell me what to change.

**STOP.** Wait for the user's response.

#### If adjust

The user may:
- Request changes to the task content
- Ask questions about scope, granularity, or approach
- Flag that something doesn't match the specification
- Identify missing edge cases or acceptance criteria

Incorporate feedback and re-present the updated task **in full**. Then ask the same choice again. Repeat until approved.

#### If approved

Log the task to the plan — verbatim, as presented. Do not modify content between approval and writing. The output format adapter determines how tasks are written (appending markdown, creating issues, etc.).

After logging, confirm:

> "Task {M} of {total}: {Task Name} — logged."

#### Next task or phase complete

**If tasks remain in this phase:** → Return to the top of **Step 4** with the next task. Present it, ask, wait.

**If all tasks in this phase are logged:**

```
Phase {N}: {Phase Name} — complete ({M} tasks logged).
```

→ Return to **Step 3** for the next phase.

**If all phases are complete:** → Proceed to **Step 5**.

---

## Step 5: Resolve External Dependencies

After all phases are detailed and written, handle external dependencies — things this plan needs from other topics or systems.

Load **[resolve-dependencies.md](resolve-dependencies.md)** and follow its instructions as written.

---

## Step 6: Plan Review

After all phases are detailed, confirmed, and dependencies are documented, perform the comprehensive two-phase review. This is the most important quality gate in the planning process — it ensures the plan faithfully represents the specification and is structurally ready for implementation.

**This review is not optional.** Load **[plan-review.md](plan-review.md)** and follow its instructions as written.

---

## Phase Design

**Each phase should**:
- Be independently testable
- Have clear acceptance criteria (checkboxes)
- Provide incremental value

**Progression**: Foundation → Core functionality → Edge cases → Refinement

## Task Design

**One task = One TDD cycle**: write test → implement → pass → commit

### Task Structure

Every task should follow this structure:

```markdown
### Task N: [Clear action statement]

**Problem**: Why this task exists - what issue or gap it addresses.

**Solution**: What we're building - the high-level approach.

**Outcome**: What success looks like - the verifiable end state.

**Do**:
- Specific implementation steps
- File locations and method names where helpful
- Concrete guidance, not vague directions

**Acceptance Criteria**:
- [ ] First verifiable criterion
- [ ] Second verifiable criterion
- [ ] Edge case handling criterion

**Tests**:
- `"it does the primary expected behavior"`
- `"it handles edge case correctly"`
- `"it fails appropriately for invalid input"`

**Context**: (when relevant)
> Relevant details from specification: code examples, architectural decisions,
> data models, or constraints that inform implementation.
```

### Field Requirements

| Field | Required | Notes |
|-------|----------|-------|
| Problem | Yes | One sentence minimum - why this task exists |
| Solution | Yes | One sentence minimum - what we're building |
| Outcome | Yes | One sentence minimum - what success looks like |
| Do | Yes | At least one concrete action |
| Acceptance Criteria | Yes | At least one pass/fail criterion |
| Tests | Yes | At least one test name; include edge cases, not just happy path |
| Context | When relevant | Only include when spec has details worth pulling forward |

### The Template as Quality Gate

If you struggle to articulate a clear Problem for a task, this signals the task may be:

- **Too granular**: Merge with a related task
- **Mechanical housekeeping**: Include as a step within another task
- **Poorly understood**: Revisit the specification

Every standalone task should have a reason to exist that can be stated simply. The template enforces this - difficulty completing it is diagnostic information, not a problem to work around.

### Vertical Slicing

Prefer **vertical slices** that deliver complete, testable functionality over horizontal slices that separate by technical layer.

**Horizontal (avoid)**:
```
Task 1: Create all database models
Task 2: Create all service classes
Task 3: Wire up integrations
Task 4: Add error handling
```

Nothing works until Task 4. No task is independently verifiable.

**Vertical (prefer)**:
```
Task 1: Fetch and store events from provider (happy path)
Task 2: Handle pagination for large result sets
Task 3: Handle authentication token refresh
Task 4: Handle rate limiting
```

Each task delivers a complete slice of functionality that can be tested in isolation.

Within a bounded feature, vertical slicing means each task completes a coherent unit of that feature's functionality - not that it must touch UI/API/database layers. The test is: *can this task be verified independently?*

TDD naturally encourages vertical slicing - when you think "what test can I write?", you frame work as complete, verifiable behavior rather than technical layers

## Plan as Source of Truth

The plan IS the source of truth. Every phase, every task must contain all information needed to execute it.

- **Self-contained**: Each task executable without external context
- **No assumptions**: Spell out the context, don't assume implementer knows it

## Flagging Incomplete Tasks

When information is missing, mark it clearly with `[needs-info]`:

```markdown
### Task 3: Configure rate limiting [needs-info]

**Do**: Set up rate limiting for the API endpoint
**Test**: `it throttles requests exceeding limit`

**Needs clarification**:
- What's the rate limit threshold?
- Per-user or per-IP?
```

Planning is iterative. Create structure, flag gaps, refine.

## Commit Frequently

Commit planning docs at natural breaks, after significant progress, and before any context refresh.

Context refresh = memory loss. Uncommitted work = lost work.

## Output

Load the appropriate output adapter (linked from the main skill file) for format-specific structure and templates.
