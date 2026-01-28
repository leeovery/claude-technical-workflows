# Progress Tracking

*Reference for **[technical-planning](../SKILL.md)***

---

During planning, approved decisions exist only in conversation memory until transferred to the output format. If session corrupts or context exhausts, this work is lost.

**Progress files capture approved decisions so planning can continue across sessions.**

## Directory Structure

```
docs/workflow/planning/.progress/{topic}/
  progress.md    # Current position — which step, which phase, which task
  phases.md      # Approved phase structure
  tasks.md       # Task overviews and transfer status
```

Three files, each owning one concern.

---

## File: `progress.md`

The "where am I?" file. Read first on resume. The `step` field indicates which step to resume at.

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
```

---

## File: `phases.md`

Captures approved phase structure — exactly as presented to and approved by the user.

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

---

## File: `tasks.md`

Tracks task overviews and transfer status.

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
   transfer: pending

## Phase 2: {Phase Name}

overview_status: pending
```

- `overview_status`: `pending` → `approved`
- `transfer`: `pending` → `transferred`

Full task detail is NOT stored here — that's the output format's job. These files capture what was agreed (structure, scope, ordering).

---

## Resume Flow

Check: does `docs/workflow/planning/.progress/{topic}/` exist?

**No** → Fresh session. Proceed to Step 1.

**Yes** → Read `progress.md`. Ask the user:

> "Found existing progress for **{topic}** — {Note from progress.md}.
>
> - **`resume`** — Continue where you left off
> - **`restart`** — Delete progress and start fresh"

**If `restart`** → Delete `.progress/{topic}/` directory, commit: `planning({topic}): restart planning`, proceed to Step 1.

**If `resume`** → Read the other progress files for context, then jump to the step indicated in `progress.md` and continue.

---

## Commit Convention

**Commit message format**: `planning({topic}): {description}`
