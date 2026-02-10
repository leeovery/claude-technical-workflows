# Traceability Review

*Reference for **[plan-review](plan-review.md)***

---

Compare the plan against the specification **in both directions** to ensure complete, faithful translation.

**Purpose**: Verify that the plan is a faithful, complete translation of the specification. Everything in the spec must be in the plan, and everything in the plan must trace back to the spec. This is the anti-hallucination gate — it catches both missing content and invented content before implementation begins.

Re-read the specification in full before starting. Don't rely on memory — read it as if seeing it for the first time. Then check both directions:

## What You're NOT Doing

- **Not adding new requirements** — If something isn't in the spec, the fix is to remove it from the plan or flag it with `[needs-info]`, not to justify its inclusion
- **Not expanding scope** — Missing spec content should be added as tasks; it shouldn't trigger re-architecture of the plan
- **Not being lenient with hallucinated content** — If it can't be traced to the specification, it must be removed or the user must explicitly approve it as an intentional addition
- **Not re-litigating spec decisions** — The specification reflects validated decisions; you're checking the plan's fidelity to them

---

## Direction 1: Specification → Plan (completeness)

Is everything from the specification represented in the plan?

1. **For each specification element, verify plan coverage**:
   - Every decision → has a task that implements it
   - Every requirement → has a task with matching acceptance criteria
   - Every edge case → has a task or is explicitly handled within a task
   - Every constraint → is reflected in the relevant tasks
   - Every data model or schema → appears in the relevant tasks
   - Every integration point → has a task that addresses it
   - Every validation rule → has a task with test coverage

2. **Check depth of coverage** — It's not enough that a spec topic is *mentioned* in a task. The task must contain enough detail that an implementer wouldn't need to go back to the specification. Summarizing and rewording is fine, but the essence and instruction must be preserved.

## Direction 2: Plan → Specification (fidelity)

Is everything in the plan actually from the specification? This is the anti-hallucination check.

1. **For each task, trace its content back to the specification**:
   - The Problem statement → ties to a spec requirement or decision
   - The Solution approach → matches the spec's architectural choices
   - The implementation details → come from the spec, not invention
   - The acceptance criteria → verify spec requirements, not made-up ones
   - The tests → cover spec behaviors, not imagined scenarios
   - The edge cases → are from the spec, not invented

2. **Flag anything that cannot be traced**:
   - Content that has no corresponding specification section
   - Technical approaches not discussed in the specification
   - Requirements or behaviors not mentioned anywhere in the spec
   - Edge cases the specification never identified
   - Acceptance criteria testing things the specification doesn't require

3. **The standard for hallucination**: If you cannot point to a specific part of the specification that justifies a piece of plan content, it is hallucinated. It doesn't matter how reasonable it seems — if it wasn't discussed and validated, it doesn't belong in the plan.

## Presenting Traceability Findings

After completing your review:

1. **Create the tracking file** — Write all findings to `{topic}-review-traceability-tracking.md`
2. **Commit the tracking file** — Ensures it survives context refresh
3. **Present findings** in two stages:

**Stage 1: Summary**

> "I've completed the traceability review comparing the plan against the specification. I found [N] items:
>
> 1. **[Brief title]** (Missing from plan | Hallucinated | Incomplete)
>    [2-4 line explanation: what's wrong, where in the spec/plan, why it matters]
>
> 2. **[Brief title]** (Missing from plan | Hallucinated | Incomplete)
>    [2-4 line explanation]
>
> Let's work through these one at a time, starting with #1."

**Stage 2: Process One Item at a Time**

Work through each finding **one at a time**. For each finding: present it, propose the fix, wait for approval, then apply it verbatim.

### Present the Finding

Show the finding with full detail:

> **Finding {N} of {total}: {Brief Title}**
>
> **Type**: Missing from plan | Hallucinated content | Incomplete coverage
>
> **Spec Reference**: [Section/decision in the specification]
>
> **Plan Reference**: [Phase/task in the plan, or "N/A" for missing content]
>
> **Details**: [What's wrong and why it matters]

### Propose the Fix

Present the proposed fix **in the format it will be written to the plan**. What the user sees is what gets applied — no changes between approval and writing.

State the action type explicitly so the user knows what's changing structurally:

**Update a task** — change content within an existing task:

> **Proposed fix — update Phase {N}, Task {M}:**
>
> **Current:**
> [The existing content as it appears in the plan]
>
> **Proposed:**
> [The replacement content]

**Add content to a task** — insert into an existing task (e.g., missing acceptance criteria, edge case):

> **Proposed fix — add to Phase {N}, Task {M}, {section}:**
>
> [The exact content to be added, in plan format]

**Remove content from a task** — strip content that shouldn't be there:

> **Proposed fix — remove from Phase {N}, Task {M}, {section}:**
>
> [The exact content to be removed]

**Add a new task** — a spec section has no plan coverage and needs its own task:

> **Proposed fix — add new task to Phase {N}:**
>
> [The complete task in plan format, using the task template]

**Remove a task** — an entire task is hallucinated with no spec backing:

> **Proposed fix — remove Phase {N}, Task {M}: {Task Name}**
>
> **Reason**: [Why this task has no specification basis]

**Add a new phase** — a significant area of the specification has no plan coverage:

> **Proposed fix — add new Phase {N}: {Phase Name}**
>
> [Phase goal, acceptance criteria, and task overview]

**Remove a phase** — an entire phase is not backed by the specification:

> **Proposed fix — remove Phase {N}: {Phase Name}**
>
> **Reason**: [Why this phase has no specification basis]

After presenting the finding and proposed fix, ask:

> **Finding {N} of {total}: {Brief Title}**
>
> · · · · · · · · · · · ·
> **To proceed:**
> - **`y`/`yes`** — Approved. I'll apply it to the plan verbatim.
> - **`s`/`skip`** — Leave this as-is and move to the next finding.
> - **Or tell me what to change.**
> · · · · · · · · · · · ·

**STOP.** Wait for the user's response.

### If the user provides feedback

The user may:
- Request changes to the proposed fix
- Ask questions about why this was flagged
- Suggest a different approach to resolving the finding

Incorporate feedback and re-present the proposed fix **in full** using the same format above. Then ask the same choice again. Repeat until approved or skipped.

### If Approved

Apply the fix to the plan — as presented, using the output format adapter to determine how it's written. Do not modify content between approval and writing. Then update the tracking file: mark resolution as "Fixed", add any discussion notes.

Confirm:

> "Finding {N} of {total}: {Brief Title} — fixed."

### If Skipped

Update the tracking file: mark resolution as "Skipped", note the reason.

> "Finding {N} of {total}: {Brief Title} — skipped."

### Next Finding

Commit the tracking file (and any plan changes) before moving on. This ensures progress survives context refresh or session interruption.

**If findings remain:** → Present the next finding. Follow the same present → propose → ask → apply sequence.

**If all findings are processed:**

**Delete the traceability tracking file** (`{topic}-review-traceability-tracking.md`) — it has served its purpose.

Inform the user the traceability review is complete.

→ Return to **[plan-review.md](plan-review.md)** for the integrity review.
