# Phase Task Overview

*Reference for **[technical-planning](../../SKILL.md)***

---

Load **[task-design.md](../task-design.md)** — the principles for breaking phases into well-scoped tasks.

---

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

#### If Approved

→ Proceed to **Step 6**.

#### If Adjust

Incorporate feedback, re-present the updated task overview, and ask again. Repeat until approved.
