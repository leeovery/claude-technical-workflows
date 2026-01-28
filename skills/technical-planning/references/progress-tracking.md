# Progress Tracking

*Reference for **[technical-planning](../SKILL.md)***

---

During planning Steps 4-6, approved analysis exists only in conversation memory:
- **Step 4**: Approved phase structure (names, goals, acceptance criteria, ordering rationale)
- **Step 5**: Approved task overviews per phase (names, summaries, edge cases)
- **Step 6**: Tasks authored one-at-a-time, transferred to output format individually

If session corrupts or context exhausts, everything not yet written to the output format is lost.

**To ensure analysis isn't lost during context refresh, create progress files that capture approved decisions.** These files persist your work so planning can continue across sessions.

## Directory Structure

```
docs/workflow/planning/.progress/{topic}/
  progress.md    # Session state — which step, which phase, which task
  phases.md      # Approved phase structure (Step 4 output)
  tasks.md       # Task overviews + transfer tracking (Steps 5-6 output)
```

Three files, not one monolith (hard to parse on resume), not one-per-task (too granular). Each file owns one concern.

---

## File: `progress.md`

The "where am I?" file. Read first on resume.

```markdown
---
topic: {topic-name}
format: local-markdown
specification: docs/workflow/specification/{topic}.md
step: 5
status: in-progress
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Planning Progress: {topic}

## Current Position

Phase: 2
Task: ~
Note: "Defining tasks for Phase 2. Phase 1 tasks approved."

## Steps

- [x] Step 1: Output format chosen (local-markdown)
- [x] Step 2: Planning principles loaded
- [x] Step 3: Specification read
- [x] Step 4: Phases defined and approved
- [ ] Step 5: Tasks defined (Phase 1: approved, Phase 2: in-progress)
- [ ] Step 6: Tasks authored
- [ ] Step 7: External dependencies resolved
```

---

## File: `phases.md`

Captures the approved output of Step 4 — exactly as presented to and approved by the user.

```markdown
---
status: draft | approved
approved_at: YYYY-MM-DD
---

# Phases

## Phase 1: {Phase Name}

Goal: {What this phase accomplishes}
Why this order: {Why this comes at this position}

Acceptance criteria:
- [ ] {First verifiable criterion}
- [ ] {Second verifiable criterion}

## Phase 2: {Phase Name}
...
```

During Step 4 discussion (before approval), `status: draft`. Updated to `status: approved` when user approves. If user requests restructuring during Step 5, updated and `approved_at` refreshed.

---

## File: `tasks.md`

Tracks task overviews (Step 5) and transfer status (Step 6).

```markdown
---
status: in-progress
---

# Tasks

## Phase 1: {Phase Name}

overview_status: approved

1. {Task Name} — {One-line summary}
   Edge cases: {list}
   transfer: transferred

2. {Task Name} — {One-line summary}
   Edge cases: {list}
   transfer: transferred

3. {Task Name} — {One-line summary}
   Edge cases: {list}
   transfer: pending

## Phase 2: {Phase Name}

overview_status: pending
```

- `overview_status`: `pending` → `approved` (set when Step 5 gate passes for this phase)
- `transfer`: `pending` → `transferred` (set when Step 6 writes the task to the output format)

Full task detail (Problem, Solution, Outcome, Do, Acceptance Criteria, Tests, Context) is NOT stored here — that's the output format's job. These files capture what was agreed (structure, scope, ordering) not the authored content.

Each step file (define-phases.md, define-tasks.md, author-tasks.md) contains the specific progress tracking actions for that step.

---

## Resume Flow

Check: does `docs/workflow/planning/.progress/{topic}/` exist?

**No** → Fresh session. Proceed to Step 1.

**Yes** → Read `progress.md` to determine current position. Ask the user:

> "Found existing progress for **{topic}** — currently at {description of position}.
>
> - **`resume`** — Continue from where you left off
> - **`restart`** — Delete progress and start fresh from Step 1"

**If `restart`** → Delete `.progress/{topic}/` directory, commit: `planning({topic}): restart planning`, then proceed to Step 1.

**If `resume`** → Resume based on current step:

### Step 4 (draft)
Read `phases.md`, present draft, continue phase discussion.

### Step 4 (approved) / Step 5
Read `phases.md` + `tasks.md`. Skip phases with approved overviews. Continue task breakdown for next pending phase.

### Step 5 (all approved) / Step 6
Read `tasks.md` transfer statuses. Read already-transferred tasks from output format for context. Continue authoring from next pending task.

### Step 7+
All content is in the output format. Continue normally (progress files are reference material now).

---

## Orientation Message on Resume

When resuming, orient the user:

> "Resuming planning for **{topic}**. {Description of current position — e.g., 'Phase structure approved. Task overview for Phase 1 approved. Continuing with Phase 2 task breakdown.'}"

---

## Commit Convention

**Commit message format**: `planning({topic}): {description}`

