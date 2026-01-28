---
name: technical-planning
description: "Transform specifications into actionable implementation plans with phases, tasks, and acceptance criteria. Use when: (1) User asks to create/write an implementation plan, (2) User asks to plan implementation from a specification, (3) Converting specifications from docs/workflow/specification/{topic}.md into implementation plans, (4) User says 'plan this' or 'create a plan', (5) Need to structure how to build something with phases and concrete steps. Creates plans in docs/workflow/planning/{topic}.md that can be executed via strict TDD."
---

# Technical Planning

Act as **expert technical architect**, **product owner**, and **plan documenter**. Collaborate with the user to translate specifications into actionable implementation plans.

Your role spans product (WHAT we're building and WHY) and technical (HOW to structure the work).

## Purpose in the Workflow

This skill can be used:
- **Sequentially**: From a validated specification
- **Standalone** (Contract entry): From any specification meeting format requirements

Either way: Transform specifications into actionable phases, tasks, and acceptance criteria.

### What This Skill Needs

- **Specification content** (required) - The validated decisions and requirements to plan from
- **Topic name** (optional) - Will derive from specification if not provided
- **Output format preference** (optional) - Will ask if not specified
- **Cross-cutting references** (optional) - Cross-cutting specifications that inform technical decisions in this plan

**Before proceeding**, verify the required input is available and unambiguous. If anything is missing or unclear, **STOP** — do not proceed until resolved.

- **No specification content provided?**
  > "I need the specification content to plan from. Could you point me to the specification file (e.g., `docs/workflow/specification/{topic}.md`), or provide the content directly?"

- **Specification seems incomplete or not concluded?**
  > "The specification at {path} appears to be {concern — e.g., 'still in-progress' or 'missing sections that are referenced elsewhere'}. Should I proceed with this, or is there a more complete version?"

---

## The Process

Follow every step in sequence. No steps are optional.

---

## Step 0: Resume Detection

Check if a plan already exists at `docs/workflow/planning/{topic}.md`.

#### If plan exists with `planning:` block in frontmatter

The `planning:` block indicates work in progress. Read the plan to determine current position.

> "Found existing plan for **{topic}** at phase {N}, task {M}.
>
> - **`continue`** — Resume where you left off
> - **`restart`** — Delete plan and start fresh"

**STOP.** Wait for user response.

#### If `restart`

1. Delete the plan file
2. Commit: `planning({topic}): restart planning`

→ Proceed to **Step 1** (fresh start).

#### If `continue`

Load **[spec-change-detection.md](references/spec-change-detection.md)** to validate the specification hasn't changed, then proceed to the appropriate step based on `planning:` position.

#### If no plan exists

→ Proceed to **Step 1** (fresh planning session).

---

## Step 1: Initialize Plan

#### If resuming

The plan already exists. Load the output format adapter from **[output-formats/](references/output-formats/)** based on the `format:` field.

→ Proceed to **Step 3**.

#### If fresh

Create the plan index file.

First, choose the output format. Present the formats from **[output-formats.md](references/output-formats.md)** to the user — including description, pros, cons, and "best for". Number each format and ask the user to pick.

**STOP.** Wait for the user to choose. After they pick:

1. Load the corresponding `output-{format}.md` adapter from **[output-formats/](references/output-formats/)**
2. Create the plan index file at `docs/workflow/planning/{topic}.md`:

```yaml
---
topic: {topic-name}
status: planning
format: {chosen-format}
specification: ../specification/{topic}.md
spec_hash: {sha256-first-8-chars}
created: YYYY-MM-DD  # Use today's actual date
updated: YYYY-MM-DD  # Use today's actual date
planning:
  phase: 1
  task: ~
---

# Plan: {Topic Name}
```

3. Commit: `planning({topic}): initialize plan`

→ Proceed to **Step 2**.

---

## Step 2: Load Planning Principles

Load **[planning-principles.md](references/planning-principles.md)** — the planning principles, rules, and quality standards that apply throughout the process.

→ Proceed to **Step 3**.

---

## Step 3: Read Specification Content

Now read the specification content **in full**. Not a scan, not a summary — read every section, every decision, every edge case. The specification must be fully digested before any structural decisions are made. If a document is too large for a single read, read it in sequential chunks until you have consumed the entire file. Never summarise or skip sections to fit within tool limits.

The specification contains validated decisions. Your job is to translate it into an actionable plan, not to review or reinterpret it.

**The specification is your sole input.** Everything you need is in the specification — do not reference other documents or prior source materials. If cross-cutting specifications are provided, read them alongside the specification so their patterns are available during planning.

From the specification, absorb:
- Key decisions and rationale
- Architectural choices
- Edge cases identified
- Constraints and requirements
- Whether a Dependencies section exists (you will handle these in Step 7)

Do not present or summarize the specification back to the user — it has already been signed off.

→ Proceed to **Step 4**.

---

## Step 4: Define Phases

Load **[steps/define-phases.md](references/steps/define-phases.md)** and follow its instructions as written.

---

## Step 5: Define Tasks

Load **[steps/define-tasks.md](references/steps/define-tasks.md)** and follow its instructions as written.

---

## Step 6: Author Tasks

Load **[steps/author-tasks.md](references/steps/author-tasks.md)** and follow its instructions as written.

---

## Step 7: Resolve External Dependencies

Load **[steps/resolve-dependencies.md](references/steps/resolve-dependencies.md)** and follow its instructions as written.

---

## Step 8: Plan Review

Load **[steps/plan-review.md](references/steps/plan-review.md)** and follow its instructions as written.

---

## Step 9: Conclude the Plan

After the review is complete:

1. **Remove the `planning:` block** — Edit the plan frontmatter to remove the entire `planning:` block
2. **Update plan status** — Set `status: concluded` in frontmatter
3. **Final commit** — Commit the concluded plan
4. **Present completion summary**:

> "Planning is complete for **{topic}**.
>
> The plan contains **{N} phases** with **{M} tasks** total, reviewed for traceability against the specification and structural integrity.
>
> Status has been marked as `concluded`. The plan is ready for implementation."

> **CHECKPOINT**: Do not conclude if any tasks in the plan index show `status: pending`. All tasks must be `authored` before concluding.
