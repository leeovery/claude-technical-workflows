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

## Step 1: Choose Output Format

Present the formats from **[output-formats.md](references/output-formats.md)** to the user as written — including description, pros, cons, and "best for" — so they can make an informed choice. Number each format and ask the user to pick a number.

**STOP.** Wait for the user to choose. After they pick, confirm the choice and load the corresponding `output-{format}.md` adapter from **[output-formats/](references/output-formats/)**.

→ Proceed to **Step 2**.

---

## Step 2: Load Planning Principles

Load **[planning-principles.md](references/planning-principles.md)** — this contains the planning principles, rules, and quality standards that apply throughout the process.

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

1. **Update plan status** — Update the plan frontmatter to `status: concluded`
2. **Final commit** — Commit the concluded plan

**Output**: A complete implementation plan in the chosen format — phases, tasks, acceptance criteria, and dependencies — built collaboratively and reviewed for traceability and integrity.
