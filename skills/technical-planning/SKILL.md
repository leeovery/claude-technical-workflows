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

This process constructs a plan from a specification. A plan consists of:

- **Plan Index File** — `docs/workflow/planning/{topic}.md`. Contains frontmatter (topic, format, status, progress), phases with acceptance criteria, and task tables tracking status. This is the single source of truth for planning progress.
- **Authored Tasks** — Detailed task files written to the chosen **Output Format** (selected during planning). The output format determines where and how task detail is stored.

Follow every step in sequence. No steps are optional.

---

## Step 0: Resume Detection

Check if a Plan Index File already exists at `docs/workflow/planning/{topic}.md`.

#### If no Plan Index File exists

→ Proceed to **Step 1**.

#### If Plan Index File exists

If `status: concluded`, update it to `status: planning`.

Note the current phase and task position from the `planning:` block.

Load **[spec-change-detection.md](references/spec-change-detection.md)** to check whether the specification has changed since planning started. Then present the user with an informed choice:

> "Found existing plan for **{topic}** (previously reached phase {N}, task {M}).
>
> {spec change summary from spec-change-detection.md}
>
> - **`continue`** — Walk through the plan from the start. You can review, amend, or skip to any point — including straight to the leading edge.
> - **`restart`** — Erase all planning work for this topic and start fresh. This deletes the Plan Index File and any Authored Tasks. Other topics are unaffected."

**STOP.** Wait for user response.

#### If `continue`

If the specification changed, update `spec_commit` in the Plan Index File frontmatter to the current commit hash.

→ Proceed to **Step 1**.

#### If `restart`

1. Read **[output-formats.md](references/output-formats.md)**, find the entry matching the `format:` field in the Plan Index File, and load the linked adapter
2. Follow the adapter's cleanup instructions to remove Authored Tasks for this topic
3. Delete the Plan Index File
4. Commit: `planning({topic}): restart planning`

→ Proceed to **Step 1**.

---

## Step 1: Initialize Plan

#### If Plan Index File already exists

Read **[output-formats.md](references/output-formats.md)**, find the entry matching the `format:` field, and load the linked adapter.

→ Proceed to **Step 2**.

#### If no Plan Index File exists

First, choose the Output Format. Present the formats from **[output-formats.md](references/output-formats.md)** to the user — including description, pros, cons, and "best for". Number each format and ask the user to pick.

**STOP.** Wait for the user to choose.

Once selected:

1. Read **[output-formats.md](references/output-formats.md)**, find the chosen format entry, and load the linked adapter
2. Capture the current git commit hash: `git rev-parse HEAD`
3. Create the Plan Index File at `docs/workflow/planning/{topic}.md` with the following frontmatter and title:

```yaml
---
topic: {topic-name}
status: planning
format: {chosen-format}
specification: ../specification/{topic}.md
cross_cutting_specs:              # Omit if none
  - ../specification/{spec}.md
spec_commit: {output of git rev-parse HEAD}
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

Load **[planning-principles.md](references/planning-principles.md)** and follow its instructions as written.

→ Proceed to **Step 3**.

---

## Step 3: Verify Source Material

Verify that the source material exists and is accessible before entering agent-driven work.

1. Verify the specification file exists at the path in the Plan Index File's `specification:` field
2. If `cross_cutting_specs:` are listed in frontmatter, verify each file exists
3. If any file is missing, **STOP** — inform the user and do not proceed

You do **not** read these files. The planning agents read the specification directly, guided by **[steps/read-specification.md](references/steps/read-specification.md)**. This keeps your context clean — you hold only the planning artifacts (phases, task tables), not the specification content.

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

1. **Update plan status** — Set `status: concluded` in the Plan Index File frontmatter
3. **Final commit** — Commit the concluded plan
4. **Present completion summary**:

> "Planning is complete for **{topic}**.
>
> The plan contains **{N} phases** with **{M} tasks** total, reviewed for traceability against the specification and structural integrity.
>
> Status has been marked as `concluded`. The plan is ready for implementation."

> **CHECKPOINT**: Do not conclude if any tasks in the Plan Index File show `status: pending`. All tasks must be `authored` before concluding.
